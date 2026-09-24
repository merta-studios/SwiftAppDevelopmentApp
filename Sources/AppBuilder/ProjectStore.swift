import Foundation
import SwiftUI

@MainActor
final class ProjectStore: ObservableObject {
    @Published private(set) var projects: [BuilderProject] = []
    @Published var selectedProjectID: UUID?
    @Published var activeScreenID: UUID?
    @Published var searchText = ""
    @Published var lastMessage: String?

    private let fileManager = FileManager.default
    private let storageURL: URL

    init() {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        storageURL = base.appendingPathComponent("AppBuilder", isDirectory: true)
        load()

        if projects.isEmpty {
            loadTemplates()
        }
    }

    var activeProject: BuilderProject? {
        guard let selectedProjectID else { return projects.first }
        return projects.first(where: { $0.id == selectedProjectID }) ?? projects.first
    }

    var activeScreen: AppScreen? {
        guard let project = activeProject else { return nil }
        if let activeScreenID, let screen = project.document.screens.first(where: { $0.id == activeScreenID }) {
            return screen
        }
        return project.document.screens.first
    }

    var filteredProjects: [BuilderProject] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return projects }
        return projects.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func select(_ id: UUID) {
        selectedProjectID = id
        if let project = projects.first(where: { $0.id == id }) {
            activeScreenID = project.document.screens.first?.id
        }
    }

    func selectScreen(_ id: UUID) {
        activeScreenID = id
    }

    func loadTemplates() {
        projects = AppTemplates.all
        selectedProjectID = projects.first?.id
        activeScreenID = projects.first?.document.screens.first?.id
        save()
    }

    @discardableResult
    func createProject(name: String = "My App", theme: AppTheme = .modernPurple) -> UUID {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectName = trimmed.isEmpty ? "My App" : trimmed

        let initialElements: [AppElement] = [
            AppElement(name: "welcomeTitle", kind: .text, x: 40, y: 100, width: 313, height: 44, text: "Welcome to \(projectName)!"),
            AppElement(name: "heroIcon", kind: .icon, x: 140, y: 170, width: 113, height: 113, text: "sparkles"),
            {
                var el = AppElement(name: "mainButton", kind: .button, x: 60, y: 320, width: 273, height: 54, text: "Tap to Start")
                el.onTapActions = [
                    AppAction(kind: .setVariable, targetVariable: "counter", operation: .add, expression: "1"),
                    AppAction(kind: .playSound, sound: .coin, haptic: .medium),
                    AppAction(kind: .tween, tweenConfig: TweenConfig(targetName: "heroIcon", property: .scale, targetValue: 1.4, duration: 0.2, easing: .spring, yoyo: true))
                ]
                return el
            }(),
            {
                var el = AppElement(name: "counterLabel", kind: .text, x: 40, y: 400, width: 313, height: 36, text: "Taps: 0")
                el.boundVariable = "counter"
                return el
            }()
        ]

        let initialScreen = AppScreen(
            name: "Home",
            icon: "house.fill",
            elements: initialElements,
            variables: [StateVariable(name: "counter", type: .number, numberValue: 0)]
        )

        let project = BuilderProject(
            name: projectName,
            icon: "wand.and.stars",
            document: AppDocument(
                appName: projectName,
                accentHex: theme.primaryHex,
                theme: theme,
                screens: [initialScreen],
                globalVariables: [StateVariable(name: "counter", type: .number, numberValue: 0)]
            )
        )

        projects.insert(project, at: 0)
        selectedProjectID = project.id
        activeScreenID = initialScreen.id
        save()
        return project.id
    }

    func addTemplateProject(_ template: BuilderProject) {
        var copy = template
        copy.id = UUID()
        copy.name = "\(template.name) (New)"
        copy.createdAt = Date()
        copy.updatedAt = Date()
        projects.insert(copy, at: 0)
        selectedProjectID = copy.id
        activeScreenID = copy.document.screens.first?.id
        save()
    }

    func duplicateActiveProject() {
        guard var source = activeProject else { return }
        source.id = UUID()
        source.name += " Copy"
        source.document.appName = source.name
        source.createdAt = Date()
        source.updatedAt = Date()
        projects.insert(source, at: 0)
        selectedProjectID = source.id
        activeScreenID = source.document.screens.first?.id
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
            activeScreenID = projects.first?.document.screens.first?.id
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

    // MARK: - Screen Operations

    func addScreen(name: String = "New Screen") {
        mutateActive { project in
            let newScreen = AppScreen(
                name: name,
                icon: "rectangle.stack.fill",
                elements: [
                    AppElement(name: "screenTitle", kind: .text, x: 40, y: 80, width: 313, height: 40, text: name)
                ],
                flowX: Double((project.document.screens.count % 3) * 260 + 80),
                flowY: Double((project.document.screens.count / 3) * 240 + 100)
            )
            project.document.screens.append(newScreen)
            self.activeScreenID = newScreen.id
        }
    }

    func deleteScreen(id: UUID) {
        mutateActive { project in
            guard project.document.screens.count > 1 else {
                self.lastMessage = "Your app needs at least one screen."
                return
            }
            project.document.screens.removeAll { $0.id == id }
            if self.activeScreenID == id {
                self.activeScreenID = project.document.screens.first?.id
            }
        }
    }

    func duplicateScreen(id: UUID) {
        mutateActive { project in
            guard let screen = project.document.screens.first(where: { $0.id == id }) else { return }
            var copy = screen
            copy.id = UUID()
            copy.name += " Copy"
            copy.flowX += 40
            copy.flowY += 40
            project.document.screens.append(copy)
            self.activeScreenID = copy.id
        }
    }

    func updateScreen(id: UUID, _ update: (inout AppScreen) -> Void) {
        mutateActive { project in
            if let idx = project.document.screens.firstIndex(where: { $0.id == id }) {
                update(&project.document.screens[idx])
            }
        }
    }

    // MARK: - Element Operations

    func element(id: UUID) -> AppElement? {
        guard let screen = activeScreen else { return nil }
        return findElement(in: screen.elements, id: id)
    }

    private func findElement(in elements: [AppElement], id: UUID) -> AppElement? {
        for el in elements {
            if el.id == id { return el }
            if let child = findElement(in: el.children, id: id) { return child }
        }
        return nil
    }

    func addElement(_ element: AppElement, toScreen screenID: UUID? = nil) {
        mutateActive { project in
            let targetScreenID = screenID ?? self.activeScreenID ?? project.document.screens.first?.id
            if let idx = project.document.screens.firstIndex(where: { $0.id == targetScreenID }) {
                project.document.screens[idx].elements.append(element)
            }
        }
    }

    func updateElement(id: UUID, _ update: (inout AppElement) -> Void) {
        mutateActive { project in
            guard let screenID = self.activeScreenID ?? project.document.screens.first?.id,
                  let sIdx = project.document.screens.firstIndex(where: { $0.id == screenID }) else { return }

            func modify(elements: inout [AppElement]) -> Bool {
                for i in 0..<elements.count {
                    if elements[i].id == id {
                        update(&elements[i])
                        return true
                    }
                    if modify(elements: &elements[i].children) {
                        return true
                    }
                }
                return false
            }

            _ = modify(elements: &project.document.screens[sIdx].elements)
        }
    }

    func deleteElement(id: UUID) {
        mutateActive { project in
            guard let screenID = self.activeScreenID ?? project.document.screens.first?.id,
                  let sIdx = project.document.screens.firstIndex(where: { $0.id == screenID }) else { return }

            func remove(elements: inout [AppElement]) {
                elements.removeAll { $0.id == id }
                for i in 0..<elements.count {
                    remove(elements: &elements[i].children)
                }
            }

            remove(elements: &project.document.screens[sIdx].elements)
        }
    }

    func duplicateElement(id: UUID) {
        guard let original = element(id: id) else { return }
        var copy = original
        copy.id = UUID()
        copy.name = "\(original.name)_copy"
        copy.x += 20
        copy.y += 20
        addElement(copy)
    }

    func bringElementToFront(id: UUID) {
        mutateActive { project in
            guard let screenID = self.activeScreenID ?? project.document.screens.first?.id,
                  let sIdx = project.document.screens.firstIndex(where: { $0.id == screenID }) else { return }
            if let elIdx = project.document.screens[sIdx].elements.firstIndex(where: { $0.id == id }) {
                let item = project.document.screens[sIdx].elements.remove(at: elIdx)
                project.document.screens[sIdx].elements.append(item)
            }
        }
    }

    func sendElementToBack(id: UUID) {
        mutateActive { project in
            guard let screenID = self.activeScreenID ?? project.document.screens.first?.id,
                  let sIdx = project.document.screens.firstIndex(where: { $0.id == screenID }) else { return }
            if let elIdx = project.document.screens[sIdx].elements.firstIndex(where: { $0.id == id }) {
                let item = project.document.screens[sIdx].elements.remove(at: elIdx)
                project.document.screens[sIdx].elements.insert(item, at: 0)
            }
        }
    }

    // MARK: - Variables Management

    func addVariable(_ variable: StateVariable) {
        mutateActive { project in
            project.document.globalVariables.append(variable)
        }
    }

    func deleteVariable(id: UUID) {
        mutateActive { project in
            project.document.globalVariables.removeAll { $0.id == id }
        }
    }

    func updateVariable(id: UUID, _ update: (inout StateVariable) -> Void) {
        mutateActive { project in
            if let idx = project.document.globalVariables.firstIndex(where: { $0.id == id }) {
                update(&project.document.globalVariables[idx])
            }
        }
    }

    // MARK: - Legacy BuilderBlock Support

    func block(id: UUID) -> BuilderBlock? {
        guard let project = activeProject else { return nil }
        return findBlock(in: project.document.root, id: id)
    }

    private func findBlock(in block: BuilderBlock, id: UUID) -> BuilderBlock? {
        if block.id == id { return block }
        for child in block.children {
            if let match = findBlock(in: child, id: id) { return match }
        }
        return nil
    }

    func updateBlock(id: UUID, _ update: (inout BuilderBlock) -> Void) {
        mutateActive { project in
            _ = Self.modifyBlock(&project.document.root, id: id, update: update)
        }
    }

    func append(_ block: BuilderBlock, inside parentID: UUID? = nil) {
        mutateActive { project in
            if let parentID {
                _ = Self.modifyBlock(&project.document.root, id: parentID) { parent in
                    parent.children.append(block)
                    parent.isExpanded = true
                }
            } else {
                project.document.root.children.append(block)
            }
        }
    }

    func deleteBlock(id: UUID) {
        mutateActive { project in
            _ = Self.removeBlock(&project.document.root, id: id)
        }
    }

    func duplicateBlock(id: UUID) {
        guard let original = block(id: id) else { return }
        var copy = original
        copy.id = UUID()
        append(copy)
    }

    func moveBlock(id: UUID, direction: Int) {
        mutateActive { project in
            _ = Self.reorderBlock(&project.document.root, id: id, direction: direction)
        }
    }

    private static func modifyBlock(_ block: inout BuilderBlock, id: UUID, update: (inout BuilderBlock) -> Void) -> Bool {
        if block.id == id {
            update(&block)
            return true
        }
        for i in 0..<block.children.count {
            if modifyBlock(&block.children[i], id: id, update: update) {
                return true
            }
        }
        return false
    }

    private static func removeBlock(_ block: inout BuilderBlock, id: UUID) -> Bool {
        if let idx = block.children.firstIndex(where: { $0.id == id }) {
            block.children.remove(at: idx)
            return true
        }
        for i in 0..<block.children.count {
            if removeBlock(&block.children[i], id: id) {
                return true
            }
        }
        return false
    }

    private static func reorderBlock(_ block: inout BuilderBlock, id: UUID, direction: Int) -> Bool {
        if let idx = block.children.firstIndex(where: { $0.id == id }) {
            let target = idx + direction
            if target >= 0 && target < block.children.count {
                block.children.swapAt(idx, target)
                return true
            }
        }
        for i in 0..<block.children.count {
            if reorderBlock(&block.children[i], id: id, direction: direction) {
                return true
            }
        }
        return false
    }

    func makeNewBlock(_ kind: BlockKind) -> BuilderBlock {
        BuilderBlock(kind: kind)
    }

    func clearMessage() {
        lastMessage = nil
    }

    // MARK: - Mutate & Persistence

    func mutateActive(_ block: (inout BuilderProject) -> Void) {
        guard let project = activeProject, let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        var modified = projects[index]
        block(&modified)
        modified.updatedAt = Date()
        projects[index] = modified
        save()
    }

    func importURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if let decoded = try? JSONDecoder.appBuilder.decode(BuilderProject.self, from: data) {
                projects.insert(decoded, at: 0)
                selectedProjectID = decoded.id
                activeScreenID = decoded.document.screens.first?.id
                save()
                lastMessage = "Project imported successfully!"
            }
        } catch {
            lastMessage = "Could not import: \(error.localizedDescription)"
        }
    }

    private func save() {
        do {
            try fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
            let fileURL = storageURL.appendingPathComponent("projects.json")
            let data = try JSONEncoder.appBuilder.encode(projects)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Memory storage fallback
        }
    }

    private func load() {
        let fileURL = storageURL.appendingPathComponent("projects.json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let loaded = try JSONDecoder.appBuilder.decode([BuilderProject].self, from: data)
            if !loaded.isEmpty {
                self.projects = loaded
                self.selectedProjectID = loaded.first?.id
                self.activeScreenID = loaded.first?.document.screens.first?.id

                // Ensure screens exist for any older format
                for i in 0..<self.projects.count {
                    if self.projects[i].document.screens.isEmpty {
                        let converted = AppScreen(
                            name: "Home",
                            elements: [AppElement(kind: .text, text: self.projects[i].name)]
                        )
                        self.projects[i].document.screens = [converted]
                    }
                }
            }
        } catch {
            // Load templates fallback
        }
    }
}

extension JSONEncoder {
    static var appBuilder: JSONEncoder {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return enc
    }
}

extension JSONDecoder {
    static var appBuilder: JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }
}
