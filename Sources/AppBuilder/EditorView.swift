import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var mode: WorkspaceMode = .freeform
    @State private var selectedElementID: UUID?
    @State private var showingPreview = false
    @State private var showingSourceExporter = false
    @State private var showingProjectExporter = false
    @State private var showingPackageExporter = false

    private var activeProject: BuilderProject? { store.activeProject }
    private var generatedSource: String {
        guard let activeProject else { return "" }
        return SwiftCodeGenerator.generate(project: activeProject)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let project = activeProject {
                // Top Header Toolbar
                HStack(spacing: 14) {
                    Image(systemName: project.icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(hex: project.document.accentHex))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(project.name)
                            .font(.headline)
                        Text("Auto-saved • \(project.document.screens.count) Screens • \(project.document.globalVariables.count) Variables")
                            .font(.caption2)
                            .foregroundStyle(appBuilderSecondary)
                    }

                    Spacer()

                    // Workspace Mode Segmented Picker
                    Picker("Workspace Mode", selection: $mode) {
                        ForEach(WorkspaceMode.allCases) { item in
                            Label(item.rawValue, systemImage: item.symbol).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 580)

                    Spacer()

                    // Test / Simulator Play Button
                    Button {
                        showingPreview = true
                    } label: {
                        Label("Test App", systemImage: "play.fill")
                            .font(.subheadline.weight(.bold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    // Export Menu
                    Menu {
                        Button {
                            showingPackageExporter = true
                        } label: {
                            Label("Swift Playgrounds package (.swiftpm)", systemImage: "shippingbox")
                        }
                        Button {
                            showingSourceExporter = true
                        } label: {
                            Label("Generated SwiftUI source (.swift)", systemImage: "swift")
                        }
                        Button {
                            showingProjectExporter = true
                        } label: {
                            Label("App Builder project backup (.json)", systemImage: "externaldrive")
                        }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.regularMaterial)

                Divider()

                // Main Workspace Layout
                HStack(spacing: 0) {
                    // Central Workspace Switcher
                    Group {
                        switch mode {
                        case .freeform:
                            FreeformCanvasView(selectedElementID: $selectedElementID)

                        case .tree:
                            StackLayoutWorkspace(selectedElementID: $selectedElementID)

                        case .screenFlow:
                            ScreenFlowMapView(selectedElementID: $selectedElementID)

                        case .logic:
                            LogicEditorView()

                        case .swift:
                            CodeWorkspaceView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right-Hand Property & Tweens Inspector (visible in Canvas and Tree modes)
                    if mode == .freeform || mode == .tree {
                        Divider()
                        ElementInspectorView(selectedElementID: $selectedElementID)
                            .frame(minWidth: 280, idealWidth: 320, maxWidth: 360)
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .fullScreenCover(isPresented: $showingPreview) {
            if let project = activeProject {
                PreviewRuntimeView(project: project, isPresented: $showingPreview)
            }
        }
        .fileExporter(
            isPresented: $showingSourceExporter,
            document: SourceDocument(text: generatedSource),
            contentType: .plainText,
            defaultFilename: "\(activeProject?.name ?? "App").swift"
        ) { _ in }
        .fileExporter(
            isPresented: $showingProjectExporter,
            document: ProjectDocument(project: activeProject ?? BuilderProject(name: "App", document: AppDocument(appName: "App"))),
            contentType: .json,
            defaultFilename: "\(activeProject?.name ?? "App").appbuilder.json"
        ) { _ in }
        .fileExporter(
            isPresented: $showingPackageExporter,
            document: PlaygroundPackageDocument(project: activeProject ?? BuilderProject(name: "App", document: AppDocument(appName: "App"))),
            contentType: .data,
            defaultFilename: "\(activeProject?.name ?? "App").swiftpm"
        ) { _ in }
    }
}

// MARK: - Stack Layout Workspace (Auto-Layout View)

struct StackLayoutWorkspace: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedElementID: UUID?

    private var activeScreen: AppScreen? { store.activeScreen }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tree & Stack Hierarchy")
                        .font(.headline)
                    Text("Hierarchical organization of screen components.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
            }
            .padding(16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let screen = activeScreen {
                        ForEach(screen.elements) { el in
                            StackElementRow(
                                element: el,
                                isSelected: selectedElementID == el.id,
                                onSelect: { selectedElementID = el.id }
                            )
                        }
                    }
                }
                .padding(16)
            }
        }
    }
}

struct StackElementRow: View {
    let element: AppElement
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: element.kind.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(appBuilderAccent)
                .frame(width: 32, height: 32)
                .background(appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(element.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(appBuilderInk)
                Text("\(element.kind.rawValue) • \(element.text)")
                    .font(.caption2)
                    .foregroundStyle(appBuilderSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if !element.onTapActions.isEmpty {
                Label("\(element.onTapActions.count) actions", systemImage: "wand.and.stars")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(appBuilderAccent)
            }
        }
        .padding(10)
        .background(isSelected ? appBuilderAccent.opacity(0.12) : Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? appBuilderAccent : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Code Workspace View

struct CodeWorkspaceView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var panel: CodePanel = .generated

    private var generatedCode: String {
        guard let project = store.activeProject else { return "" }
        return SwiftCodeGenerator.generate(project: project)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Swift Code Export & Custom Powerlane")
                        .font(.headline)
                    Text("Inspect generated SwiftUI code or add custom Swift code.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
                Picker("Panel", selection: $panel) {
                    ForEach(CodePanel.allCases) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 380)
            }
            .padding(14)

            Divider()

            switch panel {
            case .generated:
                ScrollView {
                    Text(generatedCode)
                        .font(.system(.caption, design: .monospaced))
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(uiColor: .systemGroupedBackground))

            case .power:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Swift Extensions & SwiftUI Views")
                        .font(.caption.weight(.bold))
                    TextEditor(text: Binding(
                        get: { store.activeProject?.customSwift ?? "" },
                        set: { val in store.mutateActive { $0.customSwift = val } }
                    ))
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(16)

            case .notes:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Notes & Architecture")
                        .font(.caption.weight(.bold))
                    TextEditor(text: Binding(
                        get: { store.activeProject?.document.notes ?? "" },
                        set: { val in store.mutateActive { $0.document.notes = val } }
                    ))
                    .font(.body)
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(16)
            }
        }
    }
}
