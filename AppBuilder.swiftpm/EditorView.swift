import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var mode: WorkspaceMode = .design
    @State private var selectedBlockID: UUID?
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
                HStack(spacing: 14) {
                    Image(systemName: project.icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(appBuilderAccent)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(project.name)
                            .font(.headline)
                        Text("Everything saves automatically")
                            .font(.caption)
                            .foregroundStyle(appBuilderSecondary)
                    }
                    Spacer()
                    Picker("Workspace", selection: $mode) {
                        ForEach(WorkspaceMode.allCases) { item in
                            Label(item.rawValue, systemImage: item.symbol).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 360)
                    Button {
                        showingPreview = true
                    } label: {
                        Label("Test", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    Menu {
                        Button {
                            showingPackageExporter = true
                        } label: {
                            Label("Swift Playgrounds package", systemImage: "shippingbox")
                        }
                        Button {
                            showingSourceExporter = true
                        } label: {
                            Label("Generated Swift file", systemImage: "swift")
                        }
                        Button {
                            showingProjectExporter = true
                        } label: {
                            Label("App Builder project backup", systemImage: "externaldrive")
                        }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.regularMaterial)

                Divider()

                switch mode {
                case .design:
                    DesignWorkspace(selectedBlockID: $selectedBlockID)
                case .logic:
                    LogicWorkspace(selectedBlockID: $selectedBlockID)
                case .swift:
                    CodeWorkspace()
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
            document: ProjectDocument(project: activeProject ?? BuilderProject(name: "App", document: AppDocument(appName: "App", root: BuilderBlock.starterRoot()))),
            contentType: .json,
            defaultFilename: "\(activeProject?.name ?? "App").appbuilder.json"
        ) { _ in }
        .fileExporter(
            isPresented: $showingPackageExporter,
            document: PlaygroundPackageDocument(project: activeProject ?? BuilderProject(name: "App", document: AppDocument(appName: "App", root: BuilderBlock.starterRoot()))),
            contentType: .data,
            defaultFilename: "\(activeProject?.name ?? "App").swiftpm"
        ) { _ in }
    }
}

struct DesignWorkspace: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedBlockID: UUID?

    var body: some View {
        HStack(spacing: 0) {
            BlockPaletteView(selectedBlockID: $selectedBlockID)
                .frame(minWidth: 220, idealWidth: 250, maxWidth: 290)
            Divider()
            BlockCanvasView(selectedBlockID: $selectedBlockID)
            Divider()
            BlockInspectorView(selectedBlockID: $selectedBlockID)
                .frame(minWidth: 245, idealWidth: 285, maxWidth: 340)
        }
    }
}

struct LogicWorkspace: View {
    @Binding var selectedBlockID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.title2)
                    .foregroundStyle(appBuilderAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Logic, without the scary syntax")
                        .font(.headline)
                    Text("Add events, states, conditions, and repeats. For anything unusual, use a Swift power block.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
            }
            .padding(18)
            Divider()
            HStack(spacing: 0) {
                BlockPaletteView(selectedBlockID: $selectedBlockID, categoryFilter: .logic)
                    .frame(minWidth: 220, idealWidth: 260, maxWidth: 300)
                Divider()
                BlockCanvasView(selectedBlockID: $selectedBlockID)
                Divider()
                BlockInspectorView(selectedBlockID: $selectedBlockID)
                    .frame(minWidth: 245, idealWidth: 285, maxWidth: 340)
            }
        }
    }
}

struct BlockPaletteView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedBlockID: UUID?
    var categoryFilter: BlockCategory? = nil
    @State private var search = ""

    private var kinds: [BlockKind] {
        BlockKind.allCases.filter { kind in
            (categoryFilter == nil || kind.category == categoryFilter) &&
            (search.isEmpty || kind.title.localizedCaseInsensitiveContains(search) || kind.help.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(categoryFilter == .logic ? "Logic blocks" : "Block library")
                        .font(.headline)
                    Text("Tap to add • nest ideas together")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
                Image(systemName: "hand.tap")
                    .foregroundStyle(appBuilderAccent)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search blocks", text: $search)
                    .textFieldStyle(.plain)
            }
            .padding(9)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(kinds) { kind in
                        Button {
                            let block = store.makeNewBlock(kind)
                            store.append(block, inside: selectedBlockID)
                            selectedBlockID = block.id
                        } label: {
                            HStack(spacing: 11) {
                                Image(systemName: kind.symbol)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(color(for: kind.category))
                                    .frame(width: 32, height: 32)
                                    .background(color(for: kind.category).opacity(0.13), in: RoundedRectangle(cornerRadius: 9))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(kind.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(appBuilderInk)
                                    Text(kind.help)
                                        .font(.caption2)
                                        .foregroundStyle(appBuilderSecondary)
                                        .lineLimit(2)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(appBuilderAccent.opacity(0.7))
                            }
                            .padding(9)
                            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 13)
                .padding(.bottom, 16)
            }
        }
        .background(Color(uiColor: .tertiarySystemBackground))
    }

    private func color(for category: BlockCategory) -> Color {
        switch category {
        case .layout: return .blue
        case .display: return .orange
        case .input: return .green
        case .logic: return .purple
        case .advanced: return appBuilderAccent
        }
    }
}

struct BlockCanvasView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedBlockID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Canvas")
                        .font(.headline)
                    Text("Select a block to edit it on the right")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
                Button {
                    let block = BuilderBlock(kind: .text, title: "New text")
                    store.append(block)
                    selectedBlockID = block.id
                } label: {
                    Label("Quick text", systemImage: "text.badge.plus")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 12)

            Divider()

            if let root = store.activeProject?.document.root {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text("Your app screen is a tree. Put blocks inside stacks to build a layout.")
                                .font(.caption)
                                .foregroundStyle(appBuilderSecondary)
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                        BlockTreeNode(block: root, depth: 0, selectedBlockID: $selectedBlockID)
                    }
                    .padding(18)
                    .frame(maxWidth: 760, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct BlockTreeNode: View {
    @EnvironmentObject private var store: ProjectStore
    let block: BuilderBlock
    let depth: Int
    @Binding var selectedBlockID: UUID?

    private var isSelected: Bool { selectedBlockID == block.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                if !block.children.isEmpty {
                    Button {
                        store.updateBlock(id: block.id) { $0.isExpanded.toggle() }
                    } label: {
                        Image(systemName: block.isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption.weight(.bold))
                            .frame(width: 20, height: 28)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 20, height: 28)
                }

                Image(systemName: block.kind.symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(block.kind.category == .logic ? .purple : appBuilderAccent)
                    .frame(width: 30, height: 30)
                    .background((block.kind.category == .logic ? Color.purple : appBuilderAccent).opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(block.kind.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(block.title.isEmpty ? block.kind.defaultTitle : block.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(appBuilderInk)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                if !block.children.isEmpty {
                    Text("\(block.children.count) \(block.children.count == 1 ? "child" : "children")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Menu {
                    Button {
                        selectedBlockID = block.id
                        let child = BuilderBlock(kind: .text, title: "New text")
                        store.append(child, inside: block.id)
                        selectedBlockID = child.id
                    } label: {
                        Label("Add text inside", systemImage: "text.badge.plus")
                    }
                    Button {
                        store.duplicateBlock(id: block.id)
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    Divider()
                    Button {
                        store.moveBlock(id: block.id, direction: -1)
                    } label: {
                        Label("Move up", systemImage: "arrow.up")
                    }
                    Button {
                        store.moveBlock(id: block.id, direction: 1)
                    } label: {
                        Label("Move down", systemImage: "arrow.down")
                    }
                    if depth > 0 {
                        Divider()
                        Button(role: .destructive) {
                            store.deleteBlock(id: block.id)
                            if selectedBlockID == block.id { selectedBlockID = nil }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.leading, CGFloat(depth) * 24)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(isSelected ? appBuilderAccent.opacity(0.12) : Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? appBuilderAccent.opacity(0.7) : .clear, lineWidth: 1.5)
            }
            .contentShape(Rectangle())
            .onTapGesture { selectedBlockID = block.id }

            if block.isExpanded {
                ForEach(block.children) { child in
                    BlockTreeNode(block: child, depth: depth + 1, selectedBlockID: $selectedBlockID)
                }
            }
        }
    }
}
