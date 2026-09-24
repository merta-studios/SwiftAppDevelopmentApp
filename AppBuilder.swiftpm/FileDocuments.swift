import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SourceDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .data] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        text = String(data: data, encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

struct ProjectDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .data] }

    var project: BuilderProject

    init(project: BuilderProject) {
        self.project = project
    }

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        project = try JSONDecoder.appBuilder.decode(BuilderProject.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder.appBuilder.encode(project)
        return FileWrapper(regularFileWithContents: data)
    }
}

/// A real folder package. Swift Playgrounds can open the resulting `.swiftpm` file directly.
struct PlaygroundPackageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.data] }

    var project: BuilderProject

    init(project: BuilderProject) {
        self.project = project
    }

    init(configuration: ReadConfiguration) throws {
        let root = configuration.file
        if let package = root.fileWrappers?["Package.swift"],
           let data = package.regularFileContents,
           let source = String(data: data, encoding: .utf8) {
            let name = source
                .split(separator: "\n")
                .first(where: { $0.contains("name:") })
                .map(String.init) ?? "Imported package"
            project = BuilderProject(
                name: name.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines),
                document: AppDocument(appName: "Imported package", root: BuilderBlock.starterRoot())
            )
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let files = SwiftCodeGenerator.playgroundPackage(project: project)
        // FileWrapper needs the folder hierarchy explicitly. Keeping this small and explicit
        // also makes the exported package easy to inspect in the Files app.
        let packageSwift = FileWrapper(regularFileWithContents: files["Package.swift"] ?? Data())
        let readme = FileWrapper(regularFileWithContents: files["README.md"] ?? Data())
        let appSource = FileWrapper(regularFileWithContents: files["Sources/App/App.swift"] ?? Data())
        let appFolder = FileWrapper(directoryWithFileWrappers: ["App.swift": appSource])
        let sourcesFolder = FileWrapper(directoryWithFileWrappers: ["App": appFolder])
        return FileWrapper(directoryWithFileWrappers: [
            "Package.swift": packageSwift,
            "README.md": readme,
            "Sources": sourcesFolder
        ])
    }
}
