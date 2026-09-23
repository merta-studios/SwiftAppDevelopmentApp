import Foundation
import SwiftUI

// MARK: - Project model

struct BuilderProject: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var document: AppDocument
    /// The escape hatch: anything SwiftUI or Swift can do can live here.
    /// It is deliberately kept separate from generated code so visual edits never erase it.
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

struct AppDocument: Codable, Equatable {
    var appName: String
    var accentHex: String
    var root: BuilderBlock
    var notes: String

    init(
        appName: String,
        accentHex: String = "#6C5CE7",
        root: BuilderBlock,
        notes: String = ""
    ) {
        self.appName = appName
        self.accentHex = accentHex
        self.root = root
        self.notes = notes
    }
}

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
    // Layout
    case verticalStack
    case horizontalStack
    case zStack
    case spacer
    case padding
    // Display
    case text
    case image
    case colorBox
    case divider
    case badge
    // Input and navigation
    case button
    case navigationLink
    case toggle
    case slider
    case textField
    case list
    // Logic
    case state
    case conditional
    case repeatBlock
    case event
    // Escape hatch
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
        case .button: return "Runs an action when tapped."
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

    var defaultTitle: String {
        switch self {
        case .text: return "Hello, App Builder!"
        case .image: return "star.fill"
        case .colorBox: return ""
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
        case .rawSwift: return "Text(\"My custom SwiftUI view\")"
        default: return title
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
                BuilderBlock(kind: .text, title: "Drag ideas together like Scratch blocks, then export a real Swift app.", colorHex: "#5B6475"),
                BuilderBlock(kind: .button, title: "Try it", secondaryValue: "Shows a friendly message", colorHex: "#6C5CE7")
            ]
        )
    }
}

extension BuilderBlock {
    var isContainer: Bool {
        switch kind {
        case .verticalStack, .horizontalStack, .zStack, .padding, .conditional, .repeatBlock, .event:
            return true
        default:
            return !children.isEmpty
        }
    }
}

// MARK: - Small shared values

enum WorkspaceMode: String, CaseIterable, Identifiable {
    case design = "Design"
    case logic = "Logic"
    case swift = "Swift"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .design: return "square.on.square"
        case .logic: return "point.3.connected.trianglepath.dotted"
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
}

let appBuilderAccent = Color(hex: "#6C5CE7")
let appBuilderInk = Color(hex: "#172033")
let appBuilderSecondary = Color(hex: "#5B6475")
