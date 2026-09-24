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
    @State private var newProjectName = "My new app"
    @State private var showingImporter = false

    var body: some View {
        NavigationSplitView {
            SidebarView(
                showingNewProject: $showingNewProject,
                showingImporter: $showingImporter
            )
        } detail: {
            if store.activeProject != nil {
                EditorView()
            } else {
                EmptyWorkspaceView(showingNewProject: $showingNewProject)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .alert("New project", isPresented: $showingNewProject) {
            TextField("Project name", text: $newProjectName)
            Button("Create") {
                store.createProject(name: newProjectName)
                newProjectName = "My new app"
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Start with a friendly visual canvas. You can rename it later.")
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
            allowedContentTypes: [.data, .plainText, .folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                store.importURL(url)
            }
        }
    }
}

struct EmptyWorkspaceView: View {
    @Binding var showingNewProject: Bool

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(appBuilderAccent)
            Text("Your creative workspace")
                .font(.largeTitle.weight(.bold))
            Text("Create an app, snap together blocks, test it full screen, and export real Swift.")
                .font(.body)
                .foregroundStyle(appBuilderSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 440)
            Button("Create your first app") {
                showingNewProject = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

struct SidebarView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var showingNewProject: Bool
    @Binding var showingImporter: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                    Text("Make it. See it. Ship it.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 14)

            HStack(spacing: 8) {
                Button {
                    showingNewProject = true
                } label: {
                    Label("New", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Menu {
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Swift project", systemImage: "arrow.down.doc")
                    }
                    Button {
                        store.duplicateActiveProject()
                    } label: {
                        Label("Duplicate selected", systemImage: "plus.square.on.square")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 34, height: 32)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Find projects", text: $store.searchText)
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

            Text("PROJECTS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 18)
                .padding(.bottom, 5)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(store.filteredProjects) { project in
                        ProjectRow(project: project, isSelected: store.activeProject?.id == project.id)
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
                Image(systemName: "externaldrive.fill.badge.checkmark")
                    .foregroundStyle(.green)
                Text("Saved locally on this iPad")
                    .font(.caption)
                    .foregroundStyle(appBuilderSecondary)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

struct ProjectRow: View {
    let project: BuilderProject
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: project.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(isSelected ? .white : appBuilderAccent)
                .frame(width: 30, height: 30)
                .background(isSelected ? .white.opacity(0.18) : appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(project.updatedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : appBuilderSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .foregroundStyle(isSelected ? .white : appBuilderInk)
        .background(isSelected ? appBuilderAccent : .clear, in: RoundedRectangle(cornerRadius: 11))
    }
}
