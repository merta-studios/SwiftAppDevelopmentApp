import SwiftUI

/// Dedicated Logic, Variables, and Scripting Workspace.
struct LogicEditorView: View {
    @EnvironmentObject private var store: ProjectStore

    @State private var showingAddVar = false
    @State private var newVarName = "score"
    @State private var newVarType: VariableType = .number
    @State private var newVarNum: Double = 0
    @State private var newVarText = ""
    @State private var testScript = "-- Lua-like app script\nscore = score + 1\nplaySound(\"coin\")\ntween(\"coinIcon\", \"scale\", 1.4, 0.15)\nif score >= 10 then\n    playSound(\"victory\")\n    confetti()\nend"
    @StateObject private var testEngine = ScriptEngine()

    private var project: BuilderProject? { store.activeProject }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "bolt.horizontal.fill")
                        .font(.title)
                        .foregroundStyle(appBuilderAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Logic & Scripting Engine")
                            .font(.title2.weight(.bold))
                        Text("Manage reactive state variables, write Lua-like scripts, and animate objects with tweens.")
                            .font(.subheadline)
                            .foregroundStyle(appBuilderSecondary)
                    }
                    Spacer()
                }
                .padding(.bottom, 8)

                // 1. Reactive State Variables Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("APP STATE VARIABLES")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text("Values that change dynamically as users interact with your app.")
                                .font(.caption2)
                                .foregroundStyle(appBuilderSecondary)
                        }
                        Spacer()
                        Button {
                            showingAddVar = true
                        } label: {
                            Label("New Variable", systemImage: "plus")
                                .font(.caption.weight(.bold))
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if let project {
                        if project.document.globalVariables.isEmpty {
                            Text("No state variables defined yet. Tap 'New Variable' to create your first variable (e.g. score, userName, lives).")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        } else {
                            VStack(spacing: 8) {
                                ForEach(project.document.globalVariables) { variable in
                                    VariableRowCard(variable: variable)
                                }
                            }
                        }
                    }
                }
                .padding(18)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))

                // 2. Interactive Lua-like Script Runner & Snippets
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LUA-LIKE SCRIPT RUNNER")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text("Execute powerful interactive scripts and instant tween animations.")
                                .font(.caption2)
                                .foregroundStyle(appBuilderSecondary)
                        }
                        Spacer()
                        Button {
                            if let project {
                                testEngine.initialize(variables: project.document.globalVariables)
                                testEngine.executeScript(testScript)
                            }
                        } label: {
                            Label("Run Test Script", systemImage: "play.fill")
                                .font(.caption.weight(.bold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }

                    // Quick Snippets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SnippetButton(title: "+ Tween Scale", code: "tween(\"coinIcon\", \"scale\", 1.4, 0.15)\n") {
                                testScript += $0
                            }
                            SnippetButton(title: "+ Play Coin", code: "playSound(\"coin\")\n") {
                                testScript += $0
                            }
                            SnippetButton(title: "+ Play Laser", code: "playSound(\"laser\")\n") {
                                testScript += $0
                            }
                            SnippetButton(title: "+ Confetti", code: "confetti()\n") {
                                testScript += $0
                            }
                            SnippetButton(title: "+ Score + 1", code: "score = score + 1\n") {
                                testScript += $0
                            }
                            SnippetButton(title: "+ If Condition", code: "if score >= 10 then\n    navigate(\"WinScreen\")\nend\n") {
                                testScript += $0
                            }
                        }
                    }

                    // Script Editor with Line Numbers Look
                    VStack(alignment: .leading, spacing: 6) {
                        TextEditor(text: $testScript)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 140)
                            .padding(10)
                            .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    }

                    // Live Log output
                    if !testEngine.executionLog.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CONSOLE OUTPUT:")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(testEngine.executionLog.prefix(6), id: \.self) { log in
                                        Text(log)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundStyle(appBuilderInk)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxHeight: 90)
                            .padding(8)
                            .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(18)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemBackground))
        .alert("New State Variable", isPresented: $showingAddVar) {
            TextField("Variable Name (e.g. score, lives, name)", text: $newVarName)
            Button("Create") {
                let v = StateVariable(
                    name: newVarName,
                    type: newVarType,
                    numberValue: newVarNum,
                    textValue: newVarText
                )
                store.addVariable(v)
                newVarName = "score"
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Variable Card

struct VariableRowCard: View {
    @EnvironmentObject private var store: ProjectStore
    let variable: StateVariable

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: variable.type.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(appBuilderAccent)
                .frame(width: 32, height: 32)
                .background(appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(variable.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(appBuilderInk)
                Text("Type: \(variable.type.rawValue) • Default: \(variable.displayValue)")
                    .font(.caption2)
                    .foregroundStyle(appBuilderSecondary)
            }

            Spacer()

            // Quick live initial value editor
            if variable.type == .number {
                HStack(spacing: 4) {
                    Text("Initial:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    TextField("0", value: Binding(
                        get: { variable.numberValue },
                        set: { val in store.updateVariable(id: variable.id) { $0.numberValue = val } }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                    .font(.caption.monospacedDigit())
                }
            } else if variable.type == .text {
                TextField("Initial Text", text: Binding(
                    get: { variable.textValue },
                    set: { val in store.updateVariable(id: variable.id) { $0.textValue = val } }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
                .font(.caption)
            }

            Button(role: .destructive) {
                store.deleteVariable(id: variable.id)
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Snippet Button

struct SnippetButton: View {
    let title: String
    let code: String
    let onInsert: (String) -> Void

    var body: some View {
        Button {
            onInsert(code)
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemBackground), in: Capsule())
                .overlay(Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
