import SwiftUI

/// Node-based bird's eye view connecting all app screens with interactive wires.
struct ScreenFlowMapView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedElementID: UUID?

    @State private var showingAddScreen = false
    @State private var newScreenName = "New Screen"

    private var project: BuilderProject? { store.activeProject }

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Multi-Screen Flow Map")
                        .font(.headline)
                    Text("Interactive bird's-eye view of all screens and navigation connections.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
                Button {
                    showingAddScreen = true
                } label: {
                    Label("Add Screen", systemImage: "plus.rectangle.on.rectangle")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)

            Divider()

            // Large Pan & Zoom Flow Board
            ZStack {
                CanvasGridBackground()

                if let project {
                    // Connection Wires between screens
                    Canvas { context, _ in
                        for screen in project.document.screens {
                            for el in screen.elements {
                                for act in el.onTapActions where act.kind == .navigate {
                                    if let target = project.document.screens.first(where: { $0.name.localizedCaseInsensitiveContains(act.targetScreenName) }) {
                                        let start = CGPoint(x: screen.flowX + 220, y: screen.flowY + 120)
                                        let end = CGPoint(x: target.flowX, y: target.flowY + 120)

                                        var path = Path()
                                        path.move(to: start)
                                        let midX = (start.x + end.x) / 2
                                        path.addCurve(to: end, control1: CGPoint(x: midX, y: start.y), control2: CGPoint(x: midX, y: end.y))

                                        context.stroke(path, with: .color(appBuilderAccent), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 4]))
                                    }
                                }
                            }
                        }
                    }

                    // Screen Nodes
                    ForEach(project.document.screens) { screen in
                        ScreenNodeCard(
                            screen: screen,
                            isSelected: store.activeScreen?.id == screen.id,
                            onSelect: {
                                store.selectScreen(screen.id)
                            },
                            onMove: { newX, newY in
                                store.updateScreen(id: screen.id) { s in
                                    s.flowX = newX
                                    s.flowY = newY
                                }
                            }
                        )
                    }
                }
            }
        }
        .alert("New Screen", isPresented: $showingAddScreen) {
            TextField("Screen Name", text: $newScreenName)
            Button("Create") {
                store.addScreen(name: newScreenName)
                newScreenName = "New Screen"
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Screen Node Card

struct ScreenNodeCard: View {
    @EnvironmentObject private var store: ProjectStore
    let screen: AppScreen
    let isSelected: Bool
    let onSelect: () -> Void
    let onMove: (Double, Double) -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        let currentX = screen.flowX + Double(dragOffset.width)
        let currentY = screen.flowY + Double(dragOffset.height)

        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: screen.icon)
                    .foregroundStyle(isSelected ? .white : appBuilderAccent)
                Text(screen.name)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : appBuilderInk)
                    .lineLimit(1)
                Spacer()
                Text("\(screen.elements.count) items")
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? appBuilderAccent : Color(uiColor: .secondarySystemBackground))

            // Mini Screen Preview
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: screen.backgroundColorHex))

                ForEach(screen.elements.prefix(6)) { el in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: el.colorHex).opacity(0.7))
                        .frame(width: CGFloat(el.width * 0.45), height: CGFloat(el.height * 0.45))
                        .offset(x: CGFloat(el.x * 0.45), y: CGFloat(el.y * 0.45))
                }
            }
            .frame(height: 160)
            .padding(10)

            // Footer
            HStack {
                Button {
                    store.selectScreen(screen.id)
                } label: {
                    Label("Edit Canvas", systemImage: "pencil")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(appBuilderAccent)

                Spacer()

                Menu {
                    Button {
                        store.duplicateScreen(id: screen.id)
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    Button(role: .destructive) {
                        store.deleteScreen(id: screen.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .frame(width: 220)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? appBuilderAccent : Color.secondary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .offset(x: CGFloat(currentX), y: CGFloat(currentY))
        .gesture(
            DragGesture()
                .onChanged { val in
                    dragOffset = val.translation
                }
                .onEnded { val in
                    onMove(screen.flowX + Double(val.translation.width), screen.flowY + Double(val.translation.height))
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            onSelect()
        }
    }
}
