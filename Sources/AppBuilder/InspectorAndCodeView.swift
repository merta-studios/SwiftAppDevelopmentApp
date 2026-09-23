import SwiftUI

struct BlockInspectorView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedBlockID: UUID?

    private var selectedBlock: BuilderBlock? {
        guard let selectedBlockID else { return nil }
        return store.block(id: selectedBlockID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Inspector")
                    .font(.headline)
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(appBuilderAccent)
            }
            .padding(.horizontal, 17)
            .padding(.top, 18)
            .padding(.bottom, 14)
            Divider()

            if let block = selectedBlock, let selectedBlockID {
                ScrollView {
                    VStack(alignment: .leading, spacing: 17) {
                        HStack(spacing: 10) {
                            Image(systemName: block.kind.symbol)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(appBuilderAccent)
                                .frame(width: 38, height: 38)
                                .background(appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(block.kind.title)
                                    .font(.subheadline.weight(.bold))
                                Text(block.kind.help)
                                    .font(.caption)
                                    .foregroundStyle(appBuilderSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        InspectorTextField(
                            title: titleLabel(for: block.kind),
                            text: Binding(
                                get: { store.block(id: selectedBlockID)?.title ?? "" },
                                set: { value in store.updateBlock(id: selectedBlockID) { $0.title = value } }
                            )
                        )

                        if showsValueField(for: block.kind) {
                            InspectorTextField(
                                title: valueLabel(for: block.kind),
                                text: Binding(
                                    get: { store.block(id: selectedBlockID)?.value ?? "" },
                                    set: { value in store.updateBlock(id: selectedBlockID) { $0.value = value } }
                                )
                            )
                        }

                        if block.kind == .button || block.kind == .event {
                            InspectorTextField(
                                title: "What happens?",
                                text: Binding(
                                    get: { store.block(id: selectedBlockID)?.secondaryValue ?? "" },
                                    set: { value in store.updateBlock(id: selectedBlockID) { $0.secondaryValue = value } }
                                )
                            )
                        }

                        if block.kind == .conditional {
                            Text("Condition")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text("Use true, false, or a Swift expression. Advanced expressions belong in Power code.")
                                .font(.caption2)
                                .foregroundStyle(appBuilderSecondary)
                        }

                        if block.kind != .spacer && block.kind != .divider && block.kind != .state {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Color")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color(hex: block.colorHex))
                                        .frame(width: 28, height: 28)
                                    TextField("#6C5CE7", text: Binding(
                                        get: { store.block(id: selectedBlockID)?.colorHex ?? "#6C5CE7" },
                                        set: { value in store.updateBlock(id: selectedBlockID) { $0.colorHex = value } }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.body, design: .monospaced))
                                }
                            }
                        }

                        if !block.children.isEmpty {
                            Label("Contains \(block.children.count) blocks", systemImage: "square.stack.3d.up")
                                .font(.caption)
                                .foregroundStyle(appBuilderSecondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick actions")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Button {
                                let child = BuilderBlock(kind: .text, title: "New text")
                                store.append(child, inside: selectedBlockID)
                            } label: {
                                Label("Add text inside", systemImage: "text.badge.plus")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            Button {
                                store.duplicateBlock(id: selectedBlockID)
                            } label: {
                                Label("Duplicate block", systemImage: "plus.square.on.square")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            if block.kind != .verticalStack || block.children.count > 0 {
                                Button(role: .destructive) {
                                    store.deleteBlock(id: selectedBlockID)
                                    self.selectedBlockID = nil
                                } label: {
                                    Label("Delete block", systemImage: "trash")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(17)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "cursorarrow.click.2")
                        .font(.title)
                        .foregroundStyle(appBuilderAccent)
                    Text("Pick a block")
                        .font(.headline)
                    Text("Tap anything in the canvas to change its words, color, and behavior.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(uiColor: .tertiarySystemBackground))
    }

    private func titleLabel(for kind: BlockKind) -> String {
        switch kind {
        case .image: return "SF Symbol name"
        case .state: return "State name"
        case .conditional: return "Condition"
        case .repeatBlock: return "How many times"
        case .event: return "Event"
        case .rawSwift: return "SwiftUI expression"
        default: return "Text / label"
        }
    }

    private func valueLabel(for kind: BlockKind) -> String {
        switch kind {
        case .state: return "Starting value"
        case .textField: return "Placeholder"
        default: return "Value"
        }
    }

    private func showsValueField(for kind: BlockKind) -> Bool {
        switch kind {
        case .text, .image, .colorBox, .divider, .badge, .button, .navigationLink,
             .toggle, .slider, .textField, .list, .state, .conditional, .repeatBlock,
             .event, .rawSwift:
            return kind == .state || kind == .textField
        default:
            return false
        }
    }
}

struct InspectorTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            TextField(title, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
        }
    }
}

struct CodeWorkspace: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var panel: CodePanel = .power

    private var generatedCode: String {
        guard let project = store.activeProject else { return "" }
        return SwiftCodeGenerator.generate(project: project)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Power lane")
                        .font(.headline)
                    Text("Most people never need this. It is here so your imagination has no ceiling.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
                Picker("Code panel", selection: $panel) {
                    ForEach(CodePanel.allCases) { panel in
                        Text(panel.rawValue).tag(panel)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 390)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            Divider()

            switch panel {
            case .power:
                PowerCodeEditor()
            case .generated:
                GeneratedCodeView(code: generatedCode)
            case .notes:
                NotesEditor()
            }
        }
    }
}

struct PowerCodeEditor: View {
    @EnvironmentObject private var store: ProjectStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: "lock.open.fill")
                    .foregroundStyle(.orange)
                Text("Power code is never overwritten when you change blocks.")
                    .font(.caption.weight(.semibold))
                Spacer()
                Text("Swift / SwiftUI")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(.orange.opacity(0.1))

            TextEditor(text: Binding(
                get: { store.activeProject?.customSwift ?? "" },
                set: { value in store.updateActiveProject { $0.customSwift = value } }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(14)
            .background(Color(uiColor: .systemBackground))
        }
    }
}

struct GeneratedCodeView: View {
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("This is the real SwiftUI your blocks become. Export it when you are ready.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(appBuilderSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(.green.opacity(0.1))
            ScrollView([.horizontal, .vertical]) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(appBuilderInk)
                    .textSelection(.enabled)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }
}

struct NotesEditor: View {
    @EnvironmentObject private var store: ProjectStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Project notes")
                .font(.headline)
                .padding(.horizontal, 18)
                .padding(.top, 18)
            Text("Keep ideas, TODOs, and explanations beside the project. Notes are saved locally too.")
                .font(.caption)
                .foregroundStyle(appBuilderSecondary)
                .padding(.horizontal, 18)
            TextEditor(text: Binding(
                get: { store.activeProject?.document.notes ?? "" },
                set: { value in store.updateActiveDocument { $0.notes = value } }
            ))
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(14)
            .background(Color(uiColor: .systemBackground))
        }
    }
}
