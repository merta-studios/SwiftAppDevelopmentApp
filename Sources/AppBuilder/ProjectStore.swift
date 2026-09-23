import Foundation
import SwiftUI

@MainActor
final class ProjectStore: ObservableObject {
    @Published private(set) var projects: [BuilderProject] = []
    @Published var selectedProjectID: UUID?
    @Published var searchText = ""
    @Published var lastMessage: String?

    private let fileManager = FileManager.default
    private let storageURL: URL

    init() {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        storageURL = base.appendingPathComponent("AppBuilder", isDirectory: true)
        load()
    }

    var activeProject: BuilderProject? {
        guard let selectedProjectID else { return projects.first }
        return projects.first(where: { $0.id == selectedProjectID }) ?? projects.first
    }

    var filteredProjects: [BuilderProject] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return projects }
        return projects.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func select(_ id: UUID) {
        selectedProjectID = id
    }

    @discardableResult
    func createProject(name: String = "My new app") -> UUID {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectName = trimmed.isEmpty ? "My new app" : trimmed
        let project = BuilderProject(
            name: projectName,
            icon: "app.badge",
            document: AppDocument(appName: projectName, root: BuilderBlock(
                kind: .verticalStack,
                title: "Home screen",
                children: [BuilderBlock(kind: .text, title: "Welcome to \(projectName)", colorHex: "#172033")]
            ))
        )
        projects.insert(project, at: 0)
        selectedProjectID = project.id
        save()
        return project.id
    }

    func duplicateActiveProject() {
        guard var source = activeProject else { return }
        source.id = UUID()
        source.name += " copy"
        source.document.appName = source.name
        source.createdAt = Date()
        source.updatedAt = Date()
        projects.insert(source, at: 0)
        selectedProjectID = source.id
        save()
    }

    func delete(_ id: UUID) {
        guard projects.count > 1 else {
            lastMessage = "Keep at least one project in your workspace."
            return
        }
        projects.removeAll { $0.id == id }
        if selectedProjectID == id {
            selectedProjectID = projects.first?.id
        }
        save()
    }

    func renameActive(to name: String) {
        mutateActive { project in
            let newName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !newName.isEmpty else { return }
            project.name = newName
            project.document.appName = newName
        }
    }

    func updateActiveDocument(_ update: (inout AppDocument) -> Void) {
        mutateActive { project in update(&project.document) }
    }

    func updateActiveProject(_ update: (inout BuilderProject) -> Void) {
        mutateActive(update)
    }

    func updateBlock(id: UUID, _ update: (inout BuilderBlock) -> Void) {
        mutateActive { project in
            _ = Self.modify(block: &project.document.root, id: id, update: update)
        }
    }

    func append(_ block: BuilderBlock, inside parentID: UUID? = nil) {
        mutateActive { project in
            if let parentID {
                if !Self.modify(block: &project.document.root, id: parentID, update: { $0.children.append(block); $0.isExpanded = true }) {
                    project.document.root.children.append(block)
                }
            } else {
                project.document.root.children.append(block)
            }
        }
    }

    func duplicateBlock(id: UUID) {
        guard let original = block(id: id) else { return }
        var copy = original
        copy.id = UUID()
        mutateActive { project in
            if !Self.insertAfter(block: &project.document.root, id: id, newBlock: copy) {
                project.document.root.children.append(copy)
            }
        }
    }

    func deleteBlock(id: UUID) {
        mutateActive { project in
            _ = Self.removeChild(block: &project.document.root, id: id)
        }
    }

    func moveBlock(id: UUID, direction: Int) {
        mutateActive { project in
            _ = Self.moveChild(block: &project.document.root, id: id, direction: direction)
        }
    }

    func block(id: UUID) -> BuilderBlock? {
        guard let root = activeProject?.document.root else { return nil }
        return Self.find(block: root, id: id)
    }

    func makeNewBlock(_ kind: BlockKind) -> BuilderBlock {
        BuilderBlock(kind: kind, colorHex: activeProject?.document.accentHex ?? "#6C5CE7")
    }

    func importURL(_ url: URL) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }

        do {
            if fileManager.fileExists(atPath: url.path), isDirectory(url) {
                let swiftFiles = swiftFiles(in: url)
                let source = swiftFiles.compactMap { try? String(contentsOf: $0, encoding: .utf8) }
                    .joined(separator: "\n\n// ─────────────────────────────────────\n\n")
                guard !source.isEmpty else {
                    throw ImportError.noSwiftFiles
                }
                let folderName = url.deletingPathExtension().lastPathComponent
                importSource(source, name: folderName.isEmpty ? "Imported playground" : folderName)
            } else {
                let data = try Data(contentsOf: url)
                if let project = try? JSONDecoder.appBuilder.decode(BuilderProject.self, from: data) {
                    projects.insert(project, at: 0)
                    selectedProjectID = project.id
                    save()
                    lastMessage = "Project imported."
                } else if let text = String(data: data, encoding: .utf8) {
                    importSource(text, name: url.deletingPathExtension().lastPathComponent)
                } else {
                    throw ImportError.notReadable
                }
            }
        } catch {
            lastMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    func importSource(_ source: String, name: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Imported app" : name
        let project = BuilderProject(
            name: cleanName,
            icon: "arrow.down.doc",
            document: AppDocument(
                appName: cleanName,
                root: BuilderBlock(
                    kind: .verticalStack,
                    title: "Imported preview",
                    children: [BuilderBlock(kind: .text, title: "Imported Swift project", colorHex: "#172033"),
                               BuilderBlock(kind: .rawSwift, title: "Text(\"Preview this in Power code\")")]
                )
            ),
            customSwift: source
        )
        projects.insert(project, at: 0)
        selectedProjectID = project.id
        save()
        lastMessage = "Swift source imported into Power code."
    }

    func clearMessage() {
        lastMessage = nil
    }

    // MARK: Persistence

    private func load() {
        do {
            try fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
            let url = storageURL.appendingPathComponent("projects.json")
            if fileManager.fileExists(atPath: url.path) {
                let data = try Data(contentsOf: url)
                projects = try JSONDecoder.appBuilder.decode([BuilderProject].self, from: data)
            }
        } catch {
            projects = []
        }

        if projects.isEmpty {
            let starter = BuilderProject(
                name: "Welcome app",
                icon: "wand.and.stars",
                document: AppDocument(appName: "Welcome app", root: BuilderBlock.starterRoot()),
                customSwift: "// This is your power lane.\n// Add any Swift or SwiftUI code here; visual blocks stay safe above.\n"
            )
            projects = [starter]
        }
        selectedProjectID = projects.first?.id
    }

    private func save() {
        do {
            try fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
            let data = try JSONEncoder.appBuilder.encode(projects)
            try data.write(to: storageURL.appendingPathComponent("projects.json"), options: .atomic)
        } catch {
            lastMessage = "Could not save locally: \(error.localizedDescription)"
        }
    }

    private func mutateActive(_ update: (inout BuilderProject) -> Void) {
        guard let id = activeProject?.id, let index = projects.firstIndex(where: { $0.id == id }) else { return }
        update(&projects[index])
        projects[index].updatedAt = Date()
        save()
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func swiftFiles(in folder: URL) -> [URL] {
        guard let enumerator = fileManager.enumerator(at: folder, includingPropertiesForKeys: [.isDirectoryKey]) else { return [] }
        return enumerator.compactMap { item -> URL? in
            guard let url = item as? URL,
                  url.pathExtension.lowercased() == "swift",
                  !url.lastPathComponent.hasPrefix(".") else { return nil }
            return url
        }.sorted { $0.path < $1.path }
    }

    // MARK: Recursive block helpers

    private static func find(block: BuilderBlock, id: UUID) -> BuilderBlock? {
        if block.id == id { return block }
        for child in block.children {
            if let found = find(block: child, id: id) { return found }
        }
        return nil
    }

    @discardableResult
    private static func modify(block: inout BuilderBlock, id: UUID, update: (inout BuilderBlock) -> Void) -> Bool {
        if block.id == id {
            update(&block)
            return true
        }
        for index in block.children.indices {
            if modify(block: &block.children[index], id: id, update: update) { return true }
        }
        return false
    }

    @discardableResult
    private static func removeChild(block: inout BuilderBlock, id: UUID) -> Bool {
        if let index = block.children.firstIndex(where: { $0.id == id }) {
            block.children.remove(at: index)
            return true
        }
        for index in block.children.indices {
            if removeChild(block: &block.children[index], id: id) { return true }
        }
        return false
    }

    @discardableResult
    private static func insertAfter(block: inout BuilderBlock, id: UUID, newBlock: BuilderBlock) -> Bool {
        if let index = block.children.firstIndex(where: { $0.id == id }) {
            block.children.insert(newBlock, at: index + 1)
            return true
        }
        for index in block.children.indices {
            if insertAfter(block: &block.children[index], id: id, newBlock: newBlock) { return true }
        }
        return false
    }

    @discardableResult
    private static func moveChild(block: inout BuilderBlock, id: UUID, direction: Int) -> Bool {
        if let index = block.children.firstIndex(where: { $0.id == id }) {
            let target = index + direction
            guard block.children.indices.contains(target) else { return false }
            block.children.swapAt(index, target)
            return true
        }
        for index in block.children.indices {
            if moveChild(block: &block.children[index], id: id, direction: direction) { return true }
        }
        return false
    }
}

enum ImportError: LocalizedError {
    case noSwiftFiles
    case notReadable

    var errorDescription: String? {
        switch self {
        case .noSwiftFiles: return "This folder does not contain a Swift source file."
        case .notReadable: return "The selected file is not text or an App Builder project."
        }
    }
}

extension JSONEncoder {
    static var appBuilder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var appBuilder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
