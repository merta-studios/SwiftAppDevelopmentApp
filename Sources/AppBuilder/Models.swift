import Foundation
import SwiftUI

// MARK: - App Theme & Styles

enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case modernPurple = "Modern Purple"
    case neonCyber = "Neon Cyberpunk"
    case sunsetOrange = "Sunset Glow"
    case oceanicBlue = "Oceanic Blue"
    case emeraldMint = "Emerald Mint"
    case monochromeDark = "Midnight Dark"

    var id: String { rawValue }

    var primaryHex: String {
        switch self {
        case .modernPurple: return "#6C5CE7"
        case .neonCyber: return "#00F5D4"
        case .sunsetOrange: return "#FF6B6B"
        case .oceanicBlue: return "#0984E3"
        case .emeraldMint: return "#00B894"
        case .monochromeDark: return "#2D3436"
        }
    }

    var secondaryHex: String {
        switch self {
        case .modernPurple: return "#A29BFE"
        case .neonCyber: return "#7B2CBF"
        case .sunsetOrange: return "#FFA502"
        case .oceanicBlue: return "#74B9FF"
        case .emeraldMint: return "#55EFC4"
        case .monochromeDark: return "#636E72"
        }
    }
}

// MARK: - Variables & State Management

enum VariableType: String, Codable, CaseIterable, Identifiable {
    case number = "Number"
    case text = "Text"
    case boolean = "Boolean"
    case list = "List"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .number: return "number"
        case .text: return "textformat"
        case .boolean: return "switch.2"
        case .list: return "list.bullet"
        }
    }
}

struct StateVariable: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String // e.g. "score", "playerName", "isSoundOn", "level"
    var type: VariableType = .number
    var numberValue: Double = 0
    var textValue: String = ""
    var boolValue: Bool = false
    var listValue: [String] = []

    init(
        id: UUID = UUID(),
        name: String,
        type: VariableType = .number,
        numberValue: Double = 0,
        textValue: String = "",
        boolValue: Bool = false,
        listValue: [String] = []
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.type = type
        self.numberValue = numberValue
        self.textValue = textValue
        self.boolValue = boolValue
        self.listValue = listValue
    }

    var displayValue: String {
        switch type {
        case .number:
            if numberValue.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(numberValue))"
            } else {
                return String(format: "%.2f", numberValue)
            }
        case .text:
            return textValue
        case .boolean:
            return boolValue ? "true" : "false"
        case .list:
            return "[\(listValue.joined(separator: ", "))]"
        }
    }
}

// MARK: - Tweening & Animations

enum EasingType: String, Codable, CaseIterable, Identifiable {
    case linear = "Linear"
    case easeIn = "Ease In"
    case easeOut = "Ease Out"
    case easeInOut = "Ease In-Out"
    case spring = "Spring (Bouncy)"
    case bounce = "Bounce"

    var id: String { rawValue }
}

enum TweenProperty: String, Codable, CaseIterable, Identifiable {
    case positionX = "X Position"
    case positionY = "Y Position"
    case scale = "Scale (Size)"
    case rotation = "Rotation (Angle)"
    case opacity = "Opacity (Fade)"
    case width = "Width"
    case height = "Height"
    case cornerRadius = "Corner Radius"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .positionX: return "arrow.left.and.right"
        case .positionY: return "arrow.up.and.down"
        case .scale: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .rotation: return "rotate.right"
        case .opacity: return "circle.lefthalf.filled"
        case .width: return "arrow.left.and.right.square"
        case .height: return "arrow.up.and.down.square"
        case .cornerRadius: return "square.inset.filled"
        }
    }
}

struct TweenConfig: Codable, Equatable {
    var targetName: String = "" // Target element name e.g. "playerIcon", "scoreLabel"
    var property: TweenProperty = .scale
    var targetValue: Double = 1.3
    var duration: Double = 0.3 // seconds
    var easing: EasingType = .spring
    var isRelative: Bool = false
    var yoyo: Bool = true
    var repeatCount: Int = 1

    init(
        targetName: String = "",
        property: TweenProperty = .scale,
        targetValue: Double = 1.3,
        duration: Double = 0.3,
        easing: EasingType = .spring,
        isRelative: Bool = false,
        yoyo: Bool = true,
        repeatCount: Int = 1
    ) {
        self.targetName = targetName
        self.property = property
        self.targetValue = targetValue
        self.duration = duration
        self.easing = easing
        self.isRelative = isRelative
        self.yoyo = yoyo
        self.repeatCount = repeatCount
    }
}

// MARK: - Sound & Haptic FX

enum SoundEffectType: String, Codable, CaseIterable, Identifiable {
    case coin = "Coin / Ding"
    case jump = "Jump / Whoosh"
    case laser = "Laser / Zap"
    case pop = "Pop / Bubble"
    case powerup = "Power Up"
    case victory = "Victory Fanfare"
    case failure = "Game Over / Fail"
    case click = "Button Click"
    case tap = "Light Tap"
    case chime = "Chime"
    case synth = "Synth Tone"
    case none = "None"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coin: return "dollarsign.circle.fill"
        case .jump: return "arrow.up.circle.fill"
        case .laser: return "bolt.fill"
        case .pop: return "circle.dotted"
        case .powerup: return "star.fill"
        case .victory: return "trophy.fill"
        case .failure: return "xmark.octagon.fill"
        case .click: return "hand.tap.fill"
        case .tap: return "circle.fill"
        case .chime: return "sparkles"
        case .synth: return "waveform"
        case .none: return "speaker.slash"
        }
    }
}

enum HapticType: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case light = "Light"
    case medium = "Medium"
    case heavy = "Heavy"
    case success = "Success"
    case warning = "Warning"
    case error = "Error"
    case selection = "Selection"

    var id: String { rawValue }
}

// MARK: - Actions & Logic

enum ActionKind: String, Codable, CaseIterable, Identifiable {
    case setVariable = "Change Variable"
    case tween = "Animate / Tween Object"
    case playSound = "Play Sound & Haptics"
    case navigate = "Go to Screen"
    case conditional = "If Condition (Branch)"
    case toggleBool = "Toggle Switch / Bool"
    case showNotification = "Show Alert Message"
    case confetti = "Burst Confetti FX"
    case waitDelay = "Wait / Delay"
    case runScript = "Run Lua Script"
    case resetState = "Reset State / Variables"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .setVariable: return "equal.circle.fill"
        case .tween: return "wand.and.stars"
        case .playSound: return "speaker.wave.3.fill"
        case .navigate: return "arrow.right.circle.fill"
        case .conditional: return "arrow.triangle.branch"
        case .toggleBool: return "switch.2"
        case .showNotification: return "bell.fill"
        case .confetti: return "party.popper.fill"
        case .waitDelay: return "timer"
        case .runScript: return "chevron.left.forwardslash.chevron.right"
        case .resetState: return "arrow.counterclockwise.circle.fill"
        }
    }
}

enum VariableOperation: String, Codable, CaseIterable, Identifiable {
    case assign = "Set to (=)"
    case add = "Add (+)"
    case subtract = "Subtract (-)"
    case multiply = "Multiply (*)"
    case divide = "Divide (/)"
    case append = "Append to List"

    var id: String { rawValue }
}

enum NavigationTransitionStyle: String, Codable, CaseIterable, Identifiable {
    case push = "Push Navigation"
    case sheet = "Modal Sheet"
    case fullscreen = "Full Screen"
    case crossfade = "Crossfade"

    var id: String { rawValue }
}

struct AppAction: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var kind: ActionKind = .setVariable
    var isEnabled: Bool = true

    // Change variable
    var targetVariable: String = "score"
    var operation: VariableOperation = .add
    var expression: String = "1"

    // Tween
    var tweenConfig: TweenConfig = TweenConfig()

    // Sound & Haptic
    var sound: SoundEffectType = .coin
    var haptic: HapticType = .light

    // Navigation
    var targetScreenName: String = "Game"
    var navigationStyle: NavigationTransitionStyle = .push

    // Conditional
    var conditionExpression: String = "score >= 10"
    var thenActions: [AppAction] = []
    var elseActions: [AppAction] = []

    // Notification
    var notificationTitle: String = "Awesome!"
    var notificationMessage: String = "You unlocked the next level!"

    // Delay
    var delaySeconds: Double = 0.5

    // Script
    var scriptCode: String = "score = score + 1\ntween(\"scoreLabel\", \"scale\", 1.3, 0.15)\nplaySound(\"coin\")"

    init(
        id: UUID = UUID(),
        kind: ActionKind = .setVariable,
        isEnabled: Bool = true,
        targetVariable: String = "score",
        operation: VariableOperation = .add,
        expression: String = "1",
        tweenConfig: TweenConfig = TweenConfig(),
        sound: SoundEffectType = .coin,
        haptic: HapticType = .light,
        targetScreenName: String = "Game",
        navigationStyle: NavigationTransitionStyle = .push,
        conditionExpression: String = "score >= 10",
        thenActions: [AppAction] = [],
        elseActions: [AppAction] = [],
        notificationTitle: String = "Awesome!",
        notificationMessage: String = "You unlocked the next level!",
        delaySeconds: Double = 0.5,
        scriptCode: String = "score = score + 1\ntween(\"scoreLabel\", \"scale\", 1.3, 0.15)\nplaySound(\"coin\")"
    ) {
        self.id = id
        self.kind = kind
        self.isEnabled = isEnabled
        self.targetVariable = targetVariable
        self.operation = operation
        self.expression = expression
        self.tweenConfig = tweenConfig
        self.sound = sound
        self.haptic = haptic
        self.targetScreenName = targetScreenName
        self.navigationStyle = navigationStyle
        self.conditionExpression = conditionExpression
        self.thenActions = thenActions
        self.elseActions = elseActions
        self.notificationTitle = notificationTitle
        self.notificationMessage = notificationMessage
        self.delaySeconds = delaySeconds
        self.scriptCode = scriptCode
    }
}

// MARK: - Shapes & Elements

enum ShapeType: String, Codable, CaseIterable, Identifiable {
    case rectangle = "Rectangle"
    case roundedRectangle = "Rounded Rectangle"
    case circle = "Circle"
    case capsule = "Capsule"
    case heart = "Heart"
    case star = "Star"
    case cloud = "Cloud"
    case shield = "Shield"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rectangle: return "square.fill"
        case .roundedRectangle: return "app.fill"
        case .circle: return "circle.fill"
        case .capsule: return "capsule.fill"
        case .heart: return "heart.fill"
        case .star: return "star.fill"
        case .cloud: return "cloud.fill"
        case .shield: return "shield.fill"
        }
    }
}

enum GradientType: String, Codable, CaseIterable, Identifiable {
    case none = "Solid Color"
    case linear = "Linear Gradient"
    case radial = "Radial Gradient"

    var id: String { rawValue }
}

enum FontWeightOption: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case semibold = "Semibold"
    case bold = "Bold"
    case heavy = "Heavy"

    var id: String { rawValue }

    var swiftWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        }
    }
}

enum FontDesignOption: String, Codable, CaseIterable, Identifiable {
    case `default` = "Default"
    case rounded = "Rounded"
    case monospaced = "Monospaced"
    case serif = "Serif"

    var id: String { rawValue }

    var swiftDesign: Font.Design {
        switch self {
        case .default: return .default
        case .rounded: return .rounded
        case .monospaced: return .monospaced
        case .serif: return .serif
        }
    }
}

enum TextAlignmentOption: String, Codable, CaseIterable, Identifiable {
    case leading = "Left"
    case center = "Center"
    case trailing = "Right"

    var id: String { rawValue }

    var swiftAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

enum ElementCategory: String, Codable, CaseIterable, Identifiable {
    case shapes = "Shapes & Visuals"
    case controls = "Controls & Buttons"
    case textAndIcons = "Text & Media"
    case containers = "Stacks & Layout"
    case gameAndFX = "Game & Logic"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .shapes: return "square.on.circle"
        case .controls: return "hand.tap.fill"
        case .textAndIcons: return "textformat"
        case .containers: return "rectangle.3.group"
        case .gameAndFX: return "gamecontroller.fill"
        }
    }
}

enum ElementKind: String, Codable, CaseIterable, Identifiable {
    // Shapes & Cards
    case shape = "Card / Shape"
    case icon = "SF Icon"
    case text = "Text / Label"
    case image = "Image"
    case badge = "Badge / Pill"
    case divider = "Divider"

    // Controls & Inputs
    case button = "Interactive Button"
    case textField = "Text Input"
    case toggle = "Switch Toggle"
    case slider = "Slider"
    case stepper = "Stepper (+/-)"
    case progressBar = "Progress Bar / Gauge"
    case soundPad = "Sound Pad"

    // Containers & Layout
    case container = "Container Frame"
    case vstack = "Vertical Stack"
    case hstack = "Horizontal Stack"
    case zstack = "Layer Stack"
    case scrollBox = "Scroll Area"
    case list = "Dynamic List"

    // Game & Special
    case timerLoop = "Game Loop / Timer"
    case confettiFX = "Confetti Burst"
    case rawSwift = "Swift Power Code"

    var id: String { rawValue }

    var category: ElementCategory {
        switch self {
        case .shape, .icon, .badge, .divider: return .shapes
        case .text, .image: return .textAndIcons
        case .button, .textField, .toggle, .slider, .stepper, .progressBar, .soundPad: return .controls
        case .container, .vstack, .hstack, .zstack, .scrollBox, .list: return .containers
        case .timerLoop, .confettiFX, .rawSwift: return .gameAndFX
        }
    }

    var symbol: String {
        switch self {
        case .shape: return "app.fill"
        case .icon: return "star.fill"
        case .text: return "textformat"
        case .image: return "photo.fill"
        case .badge: return "seal.fill"
        case .divider: return "minus"
        case .button: return "hand.tap.fill"
        case .textField: return "character.cursor.ibeam"
        case .toggle: return "switch.2"
        case .slider: return "slider.horizontal.3"
        case .stepper: return "plusminus.circle.fill"
        case .progressBar: return "gauge.medium"
        case .soundPad: return "waveform.circle.fill"
        case .container: return "square.dashed"
        case .vstack: return "rectangle.split.3x1"
        case .hstack: return "rectangle.split.1x2"
        case .zstack: return "square.3.layers.3d"
        case .scrollBox: return "scroll.fill"
        case .list: return "list.bullet.rectangle"
        case .timerLoop: return "timer"
        case .confettiFX: return "party.popper.fill"
        case .rawSwift: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var defaultTitle: String {
        switch self {
        case .shape: return "Card"
        case .icon: return "sparkles"
        case .text: return "Hello App Builder"
        case .image: return "photo"
        case .badge: return "NEW"
        case .divider: return ""
        case .button: return "Tap Me!"
        case .textField: return "Type your name..."
        case .toggle: return "Enabled"
        case .slider: return "Volume"
        case .stepper: return "Count"
        case .progressBar: return "Progress"
        case .soundPad: return "Coin Sound"
        case .container: return "Box"
        case .vstack: return "VStack"
        case .hstack: return "HStack"
        case .zstack: return "ZStack"
        case .scrollBox: return "Scroll Area"
        case .list: return "Item"
        case .timerLoop: return "Game Tick"
        case .confettiFX: return "Confetti"
        case .rawSwift: return "Text(\"Custom Swift\")"
        }
    }

    var defaultSize: (width: Double, height: Double) {
        switch self {
        case .shape: return (160, 100)
        case .icon: return (56, 56)
        case .text: return (220, 36)
        case .image: return (140, 140)
        case .badge: return (90, 32)
        case .divider: return (280, 2)
        case .button: return (180, 52)
        case .textField: return (260, 44)
        case .toggle: return (200, 36)
        case .slider: return (240, 44)
        case .stepper: return (180, 44)
        case .progressBar: return (240, 24)
        case .soundPad: return (120, 100)
        case .container: return (280, 180)
        case .vstack, .hstack, .zstack: return (300, 200)
        case .scrollBox: return (300, 260)
        case .list: return (280, 180)
        case .timerLoop: return (140, 40)
        case .confettiFX: return (60, 60)
        case .rawSwift: return (220, 50)
        }
    }
}

// MARK: - App Element (The Building Block of everything)

struct AppElement: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String = "element1" // Identifier referenced in Lua / tweens / logic!
    var kind: ElementKind = .text

    // Geometry on Freeform Canvas
    var x: Double = 60
    var y: Double = 100
    var width: Double = 180
    var height: Double = 44
    var rotation: Double = 0 // degrees
    var scale: Double = 1.0
    var opacity: Double = 1.0
    var zIndex: Double = 0

    // Appearance
    var text: String = "Hello World"
    var placeholder: String = "Type something..."
    var iconName: String = "sparkles"
    var shapeType: ShapeType = .roundedRectangle
    var colorHex: String = "#6C5CE7"
    var secondaryColorHex: String = "#A29BFE"
    var backgroundColorHex: String = "#FFFFFF"
    var borderColorHex: String = "#6C5CE7"
    var borderWidth: Double = 0
    var cornerRadius: Double = 14
    var shadowRadius: Double = 4
    var shadowColorHex: String = "#00000022"
    var shadowY: Double = 2
    var blurRadius: Double = 0
    var isGlassmorphism: Bool = false
    var gradientType: GradientType = .none

    // Typography
    var fontSize: Double = 17
    var fontWeight: FontWeightOption = .semibold
    var fontDesign: FontDesignOption = .default
    var textColorHex: String = "#172033"
    var textAlignment: TextAlignmentOption = .center
    var lineLimit: Int = 2

    // Variables & Binding
    var boundVariable: String = "" // e.g. "score", "userName", "health"
    var minValue: Double = 0
    var maxValue: Double = 100
    var stepValue: Double = 1

    // Actions & Triggers
    var onTapActions: [AppAction] = []
    var onAppearActions: [AppAction] = []
    var onChangeActions: [AppAction] = []

    // Children & Hierarchy
    var children: [AppElement] = []
    var isExpanded: Bool = true
    var isLocked: Bool = false
    var isHidden: Bool = false

    init(
        id: UUID = UUID(),
        name: String? = nil,
        kind: ElementKind,
        x: Double = 60,
        y: Double = 100,
        width: Double? = nil,
        height: Double? = nil,
        text: String? = nil,
        colorHex: String = "#6C5CE7",
        backgroundColorHex: String = "#FFFFFF",
        children: [AppElement] = []
    ) {
        self.id = id
        self.kind = kind
        let defaultDim = kind.defaultSize
        self.width = width ?? defaultDim.width
        self.height = height ?? defaultDim.height
        self.x = x
        self.y = y
        self.text = text ?? kind.defaultTitle
        self.name = name ?? "\(kind.rawValue.lowercased().prefix(4))_\(abs(id.hashValue % 1000))"
        self.colorHex = colorHex
        self.backgroundColorHex = backgroundColorHex
        self.children = children
    }
}

// MARK: - App Screen

enum ScreenLayoutMode: String, Codable, CaseIterable, Identifiable {
    case freeform = "Freeform (Drag Anywhere)"
    case stack = "Responsive Stacks"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .freeform: return "square.on.square"
        case .stack: return "rectangle.split.3x1"
        }
    }
}

struct AppScreen: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String = "Home" // e.g. "Home", "Game", "Shop", "Settings", "Results"
    var icon: String = "house.fill"
    var backgroundColorHex: String = "#F8F9FD"
    var gradientHex: [String] = []
    var layoutMode: ScreenLayoutMode = .freeform
    var elements: [AppElement] = []
    var variables: [StateVariable] = []
    var onAppearActions: [AppAction] = []
    var isTimerActive: Bool = false
    var timerInterval: Double = 0.1 // 10 ticks/sec for game loop
    var onTimerActions: [AppAction] = []

    // Coordinates in the Screen Flow Map
    var flowX: Double = 100
    var flowY: Double = 100

    init(
        id: UUID = UUID(),
        name: String = "Home",
        icon: String = "house.fill",
        backgroundColorHex: String = "#F8F9FD",
        gradientHex: [String] = [],
        layoutMode: ScreenLayoutMode = .freeform,
        elements: [AppElement] = [],
        variables: [StateVariable] = [],
        onAppearActions: [AppAction] = [],
        isTimerActive: Bool = false,
        timerInterval: Double = 0.1,
        onTimerActions: [AppAction] = [],
        flowX: Double = 100,
        flowY: Double = 100
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.backgroundColorHex = backgroundColorHex
        self.gradientHex = gradientHex
        self.layoutMode = layoutMode
        self.elements = elements
        self.variables = variables
        self.onAppearActions = onAppearActions
        self.isTimerActive = isTimerActive
        self.timerInterval = timerInterval
        self.onTimerActions = onTimerActions
        self.flowX = flowX
        self.flowY = flowY
    }
}

// MARK: - Legacy Compatibility: BuilderBlock

enum BlockCategory: String, CaseIterable, Codable {
    case layout = "Layout"
    case display = "Display"
    case input = "Input"
    case logic = "Logic"
    case advanced = "Advanced"

    var symbol: String {
        switch self {
        case .layout: return "rectangle.3.group"
        case .display: return "textformat"
        case .input: return "hand.tap"
        case .logic: return "point.3.connected.trianglepath.dotted"
        case .advanced: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

enum BlockKind: String, CaseIterable, Codable, Identifiable {
    case verticalStack
    case horizontalStack
    case zStack
    case spacer
    case padding
    case text
    case image
    case colorBox
    case divider
    case badge
    case button
    case navigationLink
    case toggle
    case slider
    case textField
    case list
    case state
    case conditional
    case repeatBlock
    case event
    case rawSwift

    var id: String { rawValue }

    var category: BlockCategory {
        switch self {
        case .verticalStack, .horizontalStack, .zStack, .spacer, .padding: return .layout
        case .text, .image, .colorBox, .divider, .badge: return .display
        case .button, .navigationLink, .toggle, .slider, .textField, .list: return .input
        case .state, .conditional, .repeatBlock, .event: return .logic
        case .rawSwift: return .advanced
        }
    }

    var title: String {
        switch self {
        case .verticalStack: return "Vertical stack"
        case .horizontalStack: return "Horizontal stack"
        case .zStack: return "Layer stack"
        case .spacer: return "Spacer"
        case .padding: return "Padding"
        case .text: return "Text"
        case .image: return "Icon"
        case .colorBox: return "Color card"
        case .divider: return "Divider"
        case .badge: return "Badge"
        case .button: return "Button"
        case .navigationLink: return "Go to screen"
        case .toggle: return "Switch"
        case .slider: return "Slider"
        case .textField: return "Text input"
        case .list: return "List"
        case .state: return "State variable"
        case .conditional: return "If / else"
        case .repeatBlock: return "Repeat"
        case .event: return "When event happens"
        case .rawSwift: return "Swift power block"
        }
    }

    var symbol: String {
        switch self {
        case .verticalStack: return "rectangle.split.3x1"
        case .horizontalStack: return "rectangle.split.1x2"
        case .zStack: return "square.3.layers.3d"
        case .spacer: return "arrow.up.and.down"
        case .padding: return "arrow.up.left.and.arrow.down.right"
        case .text: return "textformat"
        case .image: return "photo"
        case .colorBox: return "square.fill"
        case .divider: return "minus"
        case .badge: return "seal"
        case .button: return "rectangle.and.hand.point.up.left"
        case .navigationLink: return "arrow.right.circle"
        case .toggle: return "switch.2"
        case .slider: return "slider.horizontal.3"
        case .textField: return "character.cursor.ibeam"
        case .list: return "list.bullet"
        case .state: return "function"
        case .conditional: return "questionmark.diamond"
        case .repeatBlock: return "repeat"
        case .event: return "bolt"
        case .rawSwift: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var defaultTitle: String {
        switch self {
        case .text: return "Hello, App Builder!"
        case .image: return "star.fill"
        case .colorBox: return "Card"
        case .button: return "Tap me"
        case .navigationLink: return "Next screen"
        case .toggle: return "Enabled"
        case .slider: return "Amount"
        case .textField: return "Type something"
        case .list: return "List item"
        case .state: return "score"
        case .conditional: return "true"
        case .repeatBlock: return "3"
        case .event: return "When the app starts"
        case .rawSwift: return "Text(\"Custom View\")"
        default: return title
        }
    }

    var help: String {
        switch self {
        case .verticalStack: return "Puts items below each other."
        case .horizontalStack: return "Puts items next to each other."
        case .zStack: return "Layers items on top of each other."
        case .spacer: return "Adds flexible empty space."
        case .padding: return "Adds breathing room around its children."
        case .text: return "Shows a title, label, or paragraph."
        case .image: return "Shows any SF Symbol by name."
        case .colorBox: return "A rounded colored rectangle."
        case .divider: return "A thin separating line."
        case .badge: return "A compact label with a colored background."
        case .button: return "Runs actions, tweens, and sounds when tapped."
        case .navigationLink: return "Opens another screen in the preview."
        case .toggle: return "A true / false switch."
        case .slider: return "Lets a person choose a number."
        case .textField: return "Lets a person type text."
        case .list: return "Repeats a row for a quick list."
        case .state: return "Stores a value that can change."
        case .conditional: return "Shows children only when a condition is true."
        case .repeatBlock: return "Repeats children a chosen number of times."
        case .event: return "Names an interaction, such as on start or on tap."
        case .rawSwift: return "Paste any SwiftUI view or Swift code here."
        }
    }
}

struct BuilderBlock: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: BlockKind
    var title: String
    var value: String
    var secondaryValue: String
    var colorHex: String
    var children: [BuilderBlock]
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        kind: BlockKind,
        title: String? = nil,
        value: String = "",
        secondaryValue: String = "",
        colorHex: String = "#6C5CE7",
        children: [BuilderBlock] = [],
        isExpanded: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.title = title ?? kind.defaultTitle
        self.value = value
        self.secondaryValue = secondaryValue
        self.colorHex = colorHex
        self.children = children
        self.isExpanded = isExpanded
    }

    static func starterRoot() -> BuilderBlock {
        BuilderBlock(
            kind: .verticalStack,
            title: "Home screen",
            children: [
                BuilderBlock(kind: .image, title: "sparkles", colorHex: "#6C5CE7"),
                BuilderBlock(kind: .text, title: "Build without the scary code.", colorHex: "#172033"),
                BuilderBlock(kind: .text, title: "Drag ideas together freely on a huge canvas, script animations, and export real Swift apps.", colorHex: "#5B6475"),
                BuilderBlock(kind: .button, title: "Try it", secondaryValue: "Shows a friendly message", colorHex: "#6C5CE7")
            ]
        )
    }
}

// MARK: - Document & Project

struct AppDocument: Codable, Equatable {
    var appName: String
    var accentHex: String
    var theme: AppTheme
    var screens: [AppScreen]
    var activeScreenID: UUID?
    var globalVariables: [StateVariable]
    var notes: String

    // Legacy fallback
    var root: BuilderBlock

    init(
        appName: String,
        accentHex: String = "#6C5CE7",
        theme: AppTheme = .modernPurple,
        screens: [AppScreen] = [],
        activeScreenID: UUID? = nil,
        globalVariables: [StateVariable] = [],
        notes: String = "",
        root: BuilderBlock = BuilderBlock.starterRoot()
    ) {
        self.appName = appName
        self.accentHex = accentHex
        self.theme = theme
        self.screens = screens
        self.activeScreenID = activeScreenID ?? screens.first?.id
        self.globalVariables = globalVariables
        self.notes = notes
        self.root = root
    }
}

struct BuilderProject: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var document: AppDocument
    var customSwift: String

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "wand.and.stars",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        document: AppDocument,
        customSwift: String = ""
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.document = document
        self.customSwift = customSwift
    }
}

// MARK: - Workspace Modes

enum WorkspaceMode: String, CaseIterable, Identifiable {
    case freeform = "Freeform Canvas"
    case tree = "Stacks & Tree"
    case screenFlow = "Screen Flow Map"
    case logic = "Logic & Scripts"
    case swift = "Swift Code"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .freeform: return "square.and.arrow.up.on.square"
        case .tree: return "rectangle.3.group"
        case .screenFlow: return "point.3.connected.trianglepath.dotted"
        case .logic: return "bolt.horizontal.fill"
        case .swift: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

enum CodePanel: String, CaseIterable, Identifiable {
    case power = "Power code"
    case generated = "Generated Swift"
    case notes = "Notes"

    var id: String { rawValue }
}

// MARK: - Color Extension & Palette Helpers

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red, green, blue, alpha: UInt64
        switch cleaned.count {
        case 3:
            red = ((value >> 8) & 0xF) * 17
            green = ((value >> 4) & 0xF) * 17
            blue = (value & 0xF) * 17
            alpha = 255
        case 6:
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 255
        case 8:
            red = (value >> 24) & 0xFF
            green = (value >> 16) & 0xFF
            blue = (value >> 8) & 0xFF
            alpha = value & 0xFF
        default:
            red = 108
            green = 92
            blue = 231
            alpha = 255
        }
        self.init(
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    func toHex() -> String {
        let uic = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uic.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

let appBuilderAccent = Color(hex: "#6C5CE7")
let appBuilderInk = Color(hex: "#172033")
let appBuilderSecondary = Color(hex: "#5B6475")
