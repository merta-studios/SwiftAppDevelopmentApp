import SwiftUI

@main
struct AppBuilderApp: App {
    @StateObject private var store = ProjectStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(appBuilderAccent)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var showingNewProject = false
    @State private var showingTemplateGallery = false
    @State private var newProjectName = "My New App"
    @State private var showingImporter = false

    var body: some View {
        NavigationSplitView {
            SidebarView(
                showingNewProject: $showingNewProject,
                showingTemplateGallery: $showingTemplateGallery,
                showingImporter: $showingImporter
            )
        } detail: {
            if store.activeProject != nil {
                EditorView()
            } else {
                EmptyWorkspaceView(
                    showingNewProject: $showingNewProject,
                    showingTemplateGallery: $showingTemplateGallery
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .alert("New App Project", isPresented: $showingNewProject) {
            TextField("App name", text: $newProjectName)
            Button("Create Blank App") {
                store.createProject(name: newProjectName)
                newProjectName = "My New App"
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Start with an empty freeform canvas or explore pre-made templates.")
        }
        .sheet(isPresented: $showingTemplateGallery) {
            TemplateGalleryView { template in
                store.addTemplateProject(template)
                showingTemplateGallery = false
            }
        }
        .alert("App Builder", isPresented: Binding(
            get: { store.lastMessage != nil },
            set: { isPresented in if !isPresented { store.clearMessage() } }
        )) {
            Button("OK") { store.clearMessage() }
        } message: {
            Text(store.lastMessage ?? "")
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.data, .plainText, .folder, .json],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                store.importURL(url)
            }
        }
    }
}

// MARK: - Template Gallery View

struct TemplateGalleryView: View {
    let onSelect: (BuilderProject) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                    ForEach(AppTemplates.all) { template in
                        Button {
                            onSelect(template)
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: template.icon)
                                        .font(.title2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color(hex: template.document.accentHex), in: RoundedRectangle(cornerRadius: 12))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(template.name)
                                            .font(.headline)
                                            .foregroundStyle(appBuilderInk)
                                        Text("\(template.document.screens.count) Screens • Ready to Play")
                                            .font(.caption2)
                                            .foregroundStyle(appBuilderSecondary)
                                    }
                                    Spacer()
                                }

                                Text(template.document.notes.isEmpty ? "Full interactive app template with custom tweens, reactive state, and audio synthesis." : template.document.notes)
                                    .font(.caption)
                                    .foregroundStyle(appBuilderSecondary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)

                                HStack {
                                    Label("Use Template", systemImage: "sparkles")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color(hex: template.document.accentHex))
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundStyle(Color(hex: template.document.accentHex))
                                }
                            }
                            .padding(16)
                            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationTitle("App Templates Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Empty Workspace

struct EmptyWorkspaceView: View {
    @Binding var showingNewProject: Bool
    @Binding var showingTemplateGallery: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(appBuilderAccent)

            Text("Full App Development Studio")
                .font(.largeTitle.weight(.bold))

            Text("Design screens on a huge freeform canvas, animate with 60fps tweens, write Lua scripts, synthesize arcade audio, and export real SwiftUI apps.")
                .font(.body)
                .foregroundStyle(appBuilderSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)

            HStack(spacing: 12) {
                Button {
                    showingTemplateGallery = true
                } label: {
                    Label("Explore Templates", systemImage: "sparkles")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showingNewProject = true
                } label: {
                    Label("Create Blank App", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(32)
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var showingNewProject: Bool
    @Binding var showingTemplateGallery: Bool
    @Binding var showingImporter: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Banner Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(appBuilderAccent.gradient)
                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(.white)
                        .font(.title3.weight(.bold))
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text("App Builder")
                        .font(.headline)
                    Text("Complete App Studio")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 14)

            // Quick Actions Bar
            HStack(spacing: 8) {
                Button {
                    showingTemplateGallery = true
                } label: {
                    Label("Templates", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showingNewProject = true
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 34, height: 32)
                }
                .buttonStyle(.bordered)

                Menu {
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Project / Swift", systemImage: "arrow.down.doc")
                    }
                    Button {
                        store.duplicateActiveProject()
                    } label: {
                        Label("Duplicate Selected", systemImage: "plus.square.on.square")
                    }
                    Button {
                        store.loadTemplates()
                    } label: {
                        Label("Reload Sample Apps", systemImage: "arrow.clockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 34, height: 32)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // Search Filter
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search projects", text: $store.searchText)
                    .textFieldStyle(.plain)
                if !store.searchText.isEmpty {
                    Button {
                        store.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(9)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Text("YOUR APPS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 18)
                .padding(.bottom, 6)

            // Project List
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(store.filteredProjects) { project in
                        ProjectRowItem(project: project, isSelected: store.activeProject?.id == project.id)
                            .contentShape(Rectangle())
                            .onTapGesture { store.select(project.id) }
                            .contextMenu {
                                Button {
                                    store.select(project.id)
                                    store.duplicateActiveProject()
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                Button(role: .destructive) {
                                    store.delete(project.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 10)
            }

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("Ready for Swift Playgrounds & iOS")
                    .font(.caption2)
                    .foregroundStyle(appBuilderSecondary)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

struct ProjectRowItem: View {
    let project: BuilderProject
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: project.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Color(hex: project.document.accentHex))
                .frame(width: 32, height: 32)
                .background(isSelected ? .white.opacity(0.2) : Color(hex: project.document.accentHex).opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(project.document.screens.count) Screens • \(project.document.globalVariables.count) Variables")
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.75) : appBuilderSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .foregroundStyle(isSelected ? .white : appBuilderInk)
        .background(isSelected ? appBuilderAccent : .clear, in: RoundedRectangle(cornerRadius: 11))
    }
}
