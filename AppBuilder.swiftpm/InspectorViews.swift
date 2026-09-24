import SwiftUI

// MARK: - Rock-Solid Buffered Text Field (Fixes Keyboard Issues on iPadOS / iOS)

struct BufferedTextField: View {
    let title: String
    let prompt: String?
    @Binding var text: String
    var isMonospaced: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var disableAutocorrection: Bool = true
    var onCommit: ((String) -> Void)? = nil

    @State private var localText: String = ""
    @FocusState private var isFocused: Bool

    init(
        _ title: String,
        text: Binding<String>,
        prompt: String? = nil,
        isMonospaced: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .never,
        disableAutocorrection: Bool = true,
        onCommit: ((String) -> Void)? = nil
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.isMonospaced = isMonospaced
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.disableAutocorrection = disableAutocorrection
        self.onCommit = onCommit
        self._localText = State(initialValue: text.wrappedValue)
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField(prompt ?? title, text: $localText)
                .focused($isFocused)
                .font(isMonospaced ? .system(.body, design: .monospaced) : .body)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disableAutocorrection)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? appBuilderAccent : Color.secondary.opacity(0.2), lineWidth: isFocused ? 1.5 : 1)
                )
                .onChange(of: text) { newValue in
                    if newValue != localText {
                        localText = newValue
                    }
                }
                .onChange(of: localText) { newValue in
                    if newValue != text {
                        text = newValue
                        onCommit?(newValue)
                    }
                }
                .onSubmit {
                    text = localText
                    onCommit?(localText)
                }

            if isFocused && !localText.isEmpty {
                Button {
                    localText = ""
                    text = ""
                    onCommit?("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Inspector Number Stepper

struct InspectorNumberField: View {
    let title: String
    @Binding var value: Double
    var step: Double = 1.0
    var min: Double = -10000
    var max: Double = 10000
    var unit: String = ""

    @State private var textBuffer: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Button {
                    let next = Swift.max(min, value - step)
                    value = next
                    textBuffer = format(next)
                } label: {
                    Image(systemName: "minus")
                        .font(.caption.weight(.bold))
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)

                TextField(title, text: $textBuffer)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .font(.system(.body, design: .monospaced))
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 6))
                    .onChange(of: value) { newVal in
                        textBuffer = format(newVal)
                    }
                    .onChange(of: textBuffer) { newStr in
                        if let parsed = Double(newStr.trimmingCharacters(in: .whitespaces)) {
                            value = Swift.min(max, Swift.max(min, parsed))
                        }
                    }
                    .onAppear {
                        textBuffer = format(value)
                    }

                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    let next = Swift.min(max, value + step)
                    value = next
                    textBuffer = format(next)
                } label: {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func format(_ num: Double) -> String {
        if num.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(num))"
        } else {
            return String(format: "%.1f", num)
        }
    }
}

// MARK: - Inspector Color Picker

struct InspectorColorPicker: View {
    let title: String
    @Binding var hexColor: String

    private let presetColors = [
        "#6C5CE7", "#00F5D4", "#FF6B6B", "#FFA502", "#0984E3", "#00B894",
        "#FD79A8", "#E84393", "#6C5CE7", "#2D3436", "#FFFFFF", "#111827"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: hexColor))
                    .frame(width: 24, height: 24)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3), lineWidth: 1))
            }

            // Presets grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presetColors, id: \.self) { hex in
                        Button {
                            hexColor = hex
                        } label: {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(hexColor.uppercased() == hex.uppercased() ? appBuilderAccent : Color.secondary.opacity(0.2), lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            BufferedTextField("Hex Color (e.g. #6C5CE7)", text: $hexColor, isMonospaced: true)
        }
    }
}

// MARK: - Main Element Inspector View

struct ElementInspectorView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedElementID: UUID?

    @State private var showingActionSheet = false
    @State private var activeTab: InspectorTab = .design

    enum InspectorTab: String, CaseIterable, Identifiable {
        case design = "Design"
        case actions = "Actions & Tweens"
        case logic = "Bindings"

        var id: String { rawValue }
    }

    private var selectedElement: AppElement? {
        guard let selectedElementID else { return nil }
        return store.element(id: selectedElementID)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                if let el = selectedElement {
                    Image(systemName: el.kind.symbol)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(appBuilderAccent)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(el.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(el.kind.rawValue)
                            .font(.caption2)
                            .foregroundStyle(appBuilderSecondary)
                    }
                } else {
                    Text("Inspector")
                        .font(.headline)
                }
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(appBuilderAccent)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            if selectedElement != nil {
                Picker("Tab", selection: $activeTab) {
                    ForEach(InspectorTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let el = selectedElement, let elID = selectedElementID {
                            switch activeTab {
                            case .design:
                                DesignTabInspector(element: el, elementID: elID)
                            case .actions:
                                ActionsTabInspector(element: el, elementID: elID)
                            case .logic:
                                BindingsTabInspector(element: el, elementID: elID)
                            }
                        }
                    }
                    .padding(16)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "cursorarrow.click.2")
                        .font(.system(size: 40))
                        .foregroundStyle(appBuilderAccent.opacity(0.6))
                    Text("Select an Object")
                        .font(.headline)
                    Text("Tap any element on the canvas to edit its name, position, colors, actions, and tweens.")
                        .font(.caption)
                        .foregroundStyle(appBuilderSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(uiColor: .tertiarySystemBackground))
    }
}

// MARK: - Inspector Sub-Tabs

struct DesignTabInspector: View {
    @EnvironmentObject private var store: ProjectStore
    let element: AppElement
    let elementID: UUID

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Identity
            VStack(alignment: .leading, spacing: 6) {
                Text("OBJECT IDENTIFIER (NAME)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                BufferedTextField(
                    "Element Name (e.g. scoreLabel, coinIcon)",
                    text: Binding(
                        get: { store.element(id: elementID)?.name ?? "" },
                        set: { val in store.updateElement(id: elementID) { $0.name = val } }
                    ),
                    isMonospaced: true
                )
                Text("Reference this name in Lua scripts and tween animations.")
                    .font(.caption2)
                    .foregroundStyle(appBuilderSecondary)
            }

            Divider()

            // Text / Content
            if element.kind == .text || element.kind == .button || element.kind == .badge || element.kind == .textField {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CONTENT TEXT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    BufferedTextField(
                        "Label Text",
                        text: Binding(
                            get: { store.element(id: elementID)?.text ?? "" },
                            set: { val in store.updateElement(id: elementID) { $0.text = val } }
                        )
                    )
                }
            }

            // SF Symbol Icon Name
            if element.kind == .icon || element.kind == .button {
                VStack(alignment: .leading, spacing: 6) {
                    Text("SF SYMBOL ICON")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    BufferedTextField(
                        "Icon Name (e.g. star.fill, sparkles, play.fill)",
                        text: Binding(
                            get: { store.element(id: elementID)?.iconName ?? "" },
                            set: { val in store.updateElement(id: elementID) { $0.iconName = val } }
                        ),
                        isMonospaced: true
                    )
                }
            }

            Divider()

            // Geometry (X, Y, Width, Height, Rotation, Scale, Opacity)
            VStack(alignment: .leading, spacing: 10) {
                Text("CANVAS GEOMETRY & TRANSFORM")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    InspectorNumberField(
                        title: "X Pos",
                        value: Binding(
                            get: { store.element(id: elementID)?.x ?? 0 },
                            set: { val in store.updateElement(id: elementID) { $0.x = val } }
                        ),
                        step: 10, unit: "px"
                    )
                    InspectorNumberField(
                        title: "Y Pos",
                        value: Binding(
                            get: { store.element(id: elementID)?.y ?? 0 },
                            set: { val in store.updateElement(id: elementID) { $0.y = val } }
                        ),
                        step: 10, unit: "px"
                    )
                }

                HStack(spacing: 12) {
                    InspectorNumberField(
                        title: "Width",
                        value: Binding(
                            get: { store.element(id: elementID)?.width ?? 100 },
                            set: { val in store.updateElement(id: elementID) { $0.width = val } }
                        ),
                        step: 10, min: 20, unit: "px"
                    )
                    InspectorNumberField(
                        title: "Height",
                        value: Binding(
                            get: { store.element(id: elementID)?.height ?? 50 },
                            set: { val in store.updateElement(id: elementID) { $0.height = val } }
                        ),
                        step: 10, min: 10, unit: "px"
                    )
                }

                HStack(spacing: 12) {
                    InspectorNumberField(
                        title: "Rotation",
                        value: Binding(
                            get: { store.element(id: elementID)?.rotation ?? 0 },
                            set: { val in store.updateElement(id: elementID) { $0.rotation = val } }
                        ),
                        step: 15, unit: "°"
                    )
                    InspectorNumberField(
                        title: "Scale",
                        value: Binding(
                            get: { store.element(id: elementID)?.scale ?? 1.0 },
                            set: { val in store.updateElement(id: elementID) { $0.scale = val } }
                        ),
                        step: 0.1, min: 0.1, max: 5.0
                    )
                }

                InspectorNumberField(
                    title: "Opacity (0.0 to 1.0)",
                    value: Binding(
                        get: { store.element(id: elementID)?.opacity ?? 1.0 },
                        set: { val in store.updateElement(id: elementID) { $0.opacity = val } }
                    ),
                    step: 0.1, min: 0.0, max: 1.0
                )
            }

            Divider()

            // Colors & Appearance
            VStack(alignment: .leading, spacing: 12) {
                Text("COLORS & STYLING")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                InspectorColorPicker(
                    title: "Primary Tint / Accent Color",
                    hexColor: Binding(
                        get: { store.element(id: elementID)?.colorHex ?? "#6C5CE7" },
                        set: { val in store.updateElement(id: elementID) { $0.colorHex = val } }
                    )
                )

                InspectorColorPicker(
                    title: "Background Color",
                    hexColor: Binding(
                        get: { store.element(id: elementID)?.backgroundColorHex ?? "#FFFFFF" },
                        set: { val in store.updateElement(id: elementID) { $0.backgroundColorHex = val } }
                    )
                )

                InspectorNumberField(
                    title: "Corner Radius",
                    value: Binding(
                        get: { store.element(id: elementID)?.cornerRadius ?? 12 },
                        set: { val in store.updateElement(id: elementID) { $0.cornerRadius = val } }
                    ),
                    step: 4, min: 0, max: 100, unit: "px"
                )
            }

            Divider()

            // Typography
            if element.kind == .text || element.kind == .button || element.kind == .badge {
                VStack(alignment: .leading, spacing: 10) {
                    Text("TYPOGRAPHY")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    InspectorNumberField(
                        title: "Font Size",
                        value: Binding(
                            get: { store.element(id: elementID)?.fontSize ?? 17 },
                            set: { val in store.updateElement(id: elementID) { $0.fontSize = val } }
                        ),
                        step: 2, min: 8, max: 96, unit: "pt"
                    )

                    InspectorColorPicker(
                        title: "Text Color",
                        hexColor: Binding(
                            get: { store.element(id: elementID)?.textColorHex ?? "#172033" },
                            set: { val in store.updateElement(id: elementID) { $0.textColorHex = val } }
                        )
                    )
                }
            }

            Divider()

            // Quick Layer Actions
            VStack(alignment: .leading, spacing: 8) {
                Text("LAYER ACTIONS")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button {
                        store.bringElementToFront(id: elementID)
                    } label: {
                        Label("Bring Front", systemImage: "square.3.layers.3d.top.filled")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        store.sendElementToBack(id: elementID)
                    } label: {
                        Label("Send Back", systemImage: "square.3.layers.3d.bottom.filled")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                HStack(spacing: 8) {
                    Button {
                        store.duplicateElement(id: elementID)
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        store.deleteElement(id: elementID)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}

// MARK: - Actions Tab Inspector

struct ActionsTabInspector: View {
    @EnvironmentObject private var store: ProjectStore
    let element: AppElement
    let elementID: UUID

    @State private var showingAddActionSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TAP ACTIONS & TWEENS")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text("Trigger real logic, sounds, tweens, and navigation when tapped.")
                        .font(.caption2)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
                Button {
                    showingAddActionSheet = true
                } label: {
                    Label("Add Action", systemImage: "plus.circle.fill")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
            }

            if element.onTapActions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.title2)
                        .foregroundStyle(appBuilderAccent.opacity(0.7))
                    Text("No actions attached")
                        .font(.subheadline.weight(.semibold))
                    Text("Add a Tween animation, sound effect, variable change, or screen navigation.")
                        .font(.caption2)
                        .foregroundStyle(appBuilderSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(Array(element.onTapActions.enumerated()), id: \.element.id) { index, action in
                    ActionRowCard(
                        action: action,
                        elementName: element.name,
                        onUpdate: { updated in
                            store.updateElement(id: elementID) { el in
                                el.onTapActions[index] = updated
                            }
                        },
                        onDelete: {
                            store.updateElement(id: elementID) { el in
                                el.onTapActions.remove(at: index)
                            }
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddActionSheet) {
            AddActionSheet(elementName: element.name) { newAction in
                store.updateElement(id: elementID) { el in
                    el.onTapActions.append(newAction)
                }
                showingAddActionSheet = false
            }
        }
    }
}

// MARK: - Bindings Tab Inspector

struct BindingsTabInspector: View {
    @EnvironmentObject private var store: ProjectStore
    let element: AppElement
    let elementID: UUID

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("BIND TO STATE VARIABLE")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text("This element will display or control the value of a live variable in real time.")
                    .font(.caption2)
                    .foregroundStyle(appBuilderSecondary)

                BufferedTextField(
                    "Variable Name (e.g. score, userName, health)",
                    text: Binding(
                        get: { store.element(id: elementID)?.boundVariable ?? "" },
                        set: { val in store.updateElement(id: elementID) { $0.boundVariable = val } }
                    ),
                    isMonospaced: true
                )
            }

            if element.kind == .slider || element.kind == .progressBar {
                HStack(spacing: 12) {
                    InspectorNumberField(
                        title: "Min Value",
                        value: Binding(
                            get: { store.element(id: elementID)?.minValue ?? 0 },
                            set: { val in store.updateElement(id: elementID) { $0.minValue = val } }
                        )
                    )
                    InspectorNumberField(
                        title: "Max Value",
                        value: Binding(
                            get: { store.element(id: elementID)?.maxValue ?? 100 },
                            set: { val in store.updateElement(id: elementID) { $0.maxValue = val } }
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Action Card Component

struct ActionRowCard: View {
    let action: AppAction
    let elementName: String
    let onUpdate: (AppAction) -> Void
    let onDelete: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: action.kind.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(appBuilderAccent)
                    .frame(width: 28, height: 28)
                    .background(appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 2) {
                    Text(action.kind.rawValue)
                        .font(.subheadline.weight(.semibold))
                    Text(actionSummary(action))
                        .font(.caption2)
                        .foregroundStyle(appBuilderSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                Divider()
                ActionConfigEditor(action: action, elementName: elementName, onUpdate: onUpdate)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    private func actionSummary(_ act: AppAction) -> String {
        switch act.kind {
        case .setVariable:
            return "\(act.targetVariable) \(act.operation.rawValue) \(act.expression)"
        case .tween:
            return "Tween '\(act.tweenConfig.targetName)' .\(act.tweenConfig.property.rawValue) to \(act.tweenConfig.targetValue)"
        case .playSound:
            return "Sound: \(act.sound.rawValue)"
        case .navigate:
            return "Go to screen: '\(act.targetScreenName)'"
        case .conditional:
            return "If \(act.conditionExpression)"
        case .toggleBool:
            return "Toggle \(act.targetVariable)"
        case .showNotification:
            return "\(act.notificationTitle): \(act.notificationMessage)"
        case .confetti:
            return "Burst celebration particles"
        case .waitDelay:
            return "Wait \(act.delaySeconds)s"
        case .runScript:
            return "Run Lua Script"
        case .resetState:
            return "Reset variables"
        }
    }
}

// MARK: - Action Config Editor

struct ActionConfigEditor: View {
    let action: AppAction
    let elementName: String
    let onUpdate: (AppAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch action.kind {
            case .setVariable:
                BufferedTextField(
                    "Target Variable",
                    text: Binding(
                        get: { action.targetVariable },
                        set: { val in var a = action; a.targetVariable = val; onUpdate(a) }
                    ),
                    isMonospaced: true
                )
                Picker("Operation", selection: Binding(
                    get: { action.operation },
                    set: { val in var a = action; a.operation = val; onUpdate(a) }
                )) {
                    ForEach(VariableOperation.allCases) { op in
                        Text(op.rawValue).tag(op)
                    }
                }
                .pickerStyle(.menu)

                BufferedTextField(
                    "Expression / Value (e.g. 1, score + 10, random(1,5))",
                    text: Binding(
                        get: { action.expression },
                        set: { val in var a = action; a.expression = val; onUpdate(a) }
                    ),
                    isMonospaced: true
                )

            case .tween:
                BufferedTextField(
                    "Target Object Name",
                    text: Binding(
                        get: { action.tweenConfig.targetName.isEmpty ? elementName : action.tweenConfig.targetName },
                        set: { val in var a = action; a.tweenConfig.targetName = val; onUpdate(a) }
                    ),
                    isMonospaced: true
                )
                Picker("Property", selection: Binding(
                    get: { action.tweenConfig.property },
                    set: { val in var a = action; a.tweenConfig.property = val; onUpdate(a) }
                )) {
                    ForEach(TweenProperty.allCases) { prop in
                        Text(prop.rawValue).tag(prop)
                    }
                }
                .pickerStyle(.menu)

                HStack(spacing: 8) {
                    InspectorNumberField(
                        title: "To Value",
                        value: Binding(
                            get: { action.tweenConfig.targetValue },
                            set: { val in var a = action; a.tweenConfig.targetValue = val; onUpdate(a) }
                        ),
                        step: 0.1
                    )
                    InspectorNumberField(
                        title: "Duration",
                        value: Binding(
                            get: { action.tweenConfig.duration },
                            set: { val in var a = action; a.tweenConfig.duration = val; onUpdate(a) }
                        ),
                        step: 0.1, min: 0.05, max: 10.0, unit: "s"
                    )
                }

                Picker("Easing Curve", selection: Binding(
                    get: { action.tweenConfig.easing },
                    set: { val in var a = action; a.tweenConfig.easing = val; onUpdate(a) }
                )) {
                    ForEach(EasingType.allCases) { e in
                        Text(e.rawValue).tag(e)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Yoyo (Bounce Back)", isOn: Binding(
                    get: { action.tweenConfig.yoyo },
                    set: { val in var a = action; a.tweenConfig.yoyo = val; onUpdate(a) }
                ))
                .font(.caption)

            case .playSound:
                Picker("Sound Preset", selection: Binding(
                    get: { action.sound },
                    set: { val in var a = action; a.sound = val; onUpdate(a) }
                )) {
                    ForEach(SoundEffectType.allCases) { s in
                        Label(s.rawValue, systemImage: s.icon).tag(s)
                    }
                }
                .pickerStyle(.menu)

                Picker("Haptic Touch", selection: Binding(
                    get: { action.haptic },
                    set: { val in var a = action; a.haptic = val; onUpdate(a) }
                )) {
                    ForEach(HapticType.allCases) { h in
                        Text(h.rawValue).tag(h)
                    }
                }
                .pickerStyle(.menu)

            case .navigate:
                BufferedTextField(
                    "Target Screen Name",
                    text: Binding(
                        get: { action.targetScreenName },
                        set: { val in var a = action; a.targetScreenName = val; onUpdate(a) }
                    )
                )

                Picker("Transition Style", selection: Binding(
                    get: { action.navigationStyle },
                    set: { val in var a = action; a.navigationStyle = val; onUpdate(a) }
                )) {
                    ForEach(NavigationTransitionStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.menu)

            case .showNotification:
                BufferedTextField(
                    "Title",
                    text: Binding(
                        get: { action.notificationTitle },
                        set: { val in var a = action; a.notificationTitle = val; onUpdate(a) }
                    )
                )
                BufferedTextField(
                    "Message",
                    text: Binding(
                        get: { action.notificationMessage },
                        set: { val in var a = action; a.notificationMessage = val; onUpdate(a) }
                    )
                )

            case .runScript:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lua / Swift Script:")
                        .font(.caption.weight(.bold))
                    TextEditor(text: Binding(
                        get: { action.scriptCode },
                        set: { val in var a = action; a.scriptCode = val; onUpdate(a) }
                    ))
                    .font(.system(.caption, design: .monospaced))
                    .frame(height: 100)
                    .padding(4)
                    .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 6))
                }

            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Add Action Sheet

struct AddActionSheet: View {
    let elementName: String
    let onAdd: (AppAction) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Choose Action Type") {
                    ForEach(ActionKind.allCases) { kind in
                        Button {
                            var act = AppAction(kind: kind)
                            if kind == .tween {
                                act.tweenConfig.targetName = elementName
                            }
                            onAdd(act)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: kind.icon)
                                    .font(.title3)
                                    .foregroundStyle(appBuilderAccent)
                                    .frame(width: 34, height: 34)
                                    .background(appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(kind.rawValue)
                                        .font(.headline)
                                        .foregroundStyle(appBuilderInk)
                                    Text(description(for: kind))
                                        .font(.caption)
                                        .foregroundStyle(appBuilderSecondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Add Interaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func description(for kind: ActionKind) -> String {
        switch kind {
        case .setVariable: return "Modify a number, text, or list (e.g. score + 1)"
        case .tween: return "Smoothly animate position, scale, rotation, or opacity"
        case .playSound: return "Play sound FX (coin, laser, jump) and device haptics"
        case .navigate: return "Open another screen in your app"
        case .conditional: return "Check conditions (e.g. if score >= 10)"
        case .toggleBool: return "Flip a true/false switch variable"
        case .showNotification: return "Display a popup message or banner"
        case .confetti: return "Celebrate with celebratory confetti particles"
        case .waitDelay: return "Pause before triggering the next action"
        case .runScript: return "Run powerful custom Lua / Swift scripting"
        case .resetState: return "Restart app variables back to initial values"
        }
    }
}
