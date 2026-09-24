import SwiftUI

struct FreeformCanvasView: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var selectedElementID: UUID?

    @State private var zoomScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var isSnappingEnabled: Bool = true
    @State private var showingAddScreenAlert = false
    @State private var newScreenName = "New Screen"
    @State private var selectedCategory: ElementCategory = .controls
    @State private var searchBlock = ""

    private var activeScreen: AppScreen? { store.activeScreen }

    var body: some View {
        HStack(spacing: 0) {
            // Left Palette
            ElementPaletteSidebar(
                selectedCategory: $selectedCategory,
                search: $searchBlock,
                onAddElement: { element in
                    var el = element
                    // Place in center of view
                    el.x = 100
                    el.y = 200
                    store.addElement(el)
                    selectedElementID = el.id
                }
            )
            .frame(minWidth: 230, idealWidth: 260, maxWidth: 290)

            Divider()

            // Main Canvas Area
            VStack(spacing: 0) {
                // Top Screen & Canvas Controls Toolbar
                CanvasTopToolbar(
                    zoomScale: $zoomScale,
                    panOffset: $panOffset,
                    isSnappingEnabled: $isSnappingEnabled,
                    showingAddScreenAlert: $showingAddScreenAlert,
                    selectedElementID: $selectedElementID
                )

                Divider()

                // Interactive Infinite Artboard
                ZStack {
                    // Dot Grid Background
                    CanvasGridBackground()
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    panOffset = CGSize(
                                        width: panOffset.width + val.translation.width * 0.1,
                                        height: panOffset.height + val.translation.height * 0.1
                                    )
                                }
                        )
                        .onTapGesture {
                            selectedElementID = nil
                        }

                    // Artboard Device Frame
                    if let screen = activeScreen {
                        DeviceArtboard(
                            screen: screen,
                            selectedElementID: $selectedElementID,
                            isSnappingEnabled: isSnappingEnabled,
                            zoomScale: zoomScale
                        )
                        .scaleEffect(zoomScale)
                        .offset(panOffset)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: zoomScale)
                    }
                }
                .clipped()
            }
        }
        .alert("Create New Screen", isPresented: $showingAddScreenAlert) {
            TextField("Screen Name (e.g. Shop, Settings)", text: $newScreenName)
            Button("Create") {
                store.addScreen(name: newScreenName)
                newScreenName = "New Screen"
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Canvas Top Toolbar

struct CanvasTopToolbar: View {
    @EnvironmentObject private var store: ProjectStore
    @Binding var zoomScale: CGFloat
    @Binding var panOffset: CGSize
    @Binding var isSnappingEnabled: Bool
    @Binding var showingAddScreenAlert: Bool
    @Binding var selectedElementID: UUID?

    var body: some View {
        HStack(spacing: 12) {
            // Screen Switcher
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    if let project = store.activeProject {
                        ForEach(project.document.screens) { screen in
                            let isSelected = store.activeScreen?.id == screen.id
                            Button {
                                store.selectScreen(screen.id)
                                selectedElementID = nil
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: screen.icon)
                                        .font(.caption2)
                                    Text(screen.name)
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .foregroundStyle(isSelected ? .white : appBuilderInk)
                                .background(isSelected ? appBuilderAccent : Color(uiColor: .secondarySystemBackground), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    store.duplicateScreen(id: screen.id)
                                } label: {
                                    Label("Duplicate Screen", systemImage: "plus.square.on.square")
                                }
                                if project.document.screens.count > 1 {
                                    Button(role: .destructive) {
                                        store.deleteScreen(id: screen.id)
                                    } label: {
                                        Label("Delete Screen", systemImage: "trash")
                                    }
                                }
                            }
                        }

                        Button {
                            showingAddScreenAlert = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.caption.weight(.bold))
                                .padding(8)
                                .background(Color(uiColor: .secondarySystemBackground), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }

            Spacer()

            // Align Tools (if element selected)
            if let selectedID = selectedElementID {
                HStack(spacing: 4) {
                    Button {
                        store.updateElement(id: selectedID) { $0.x = 40 }
                    } label: {
                        Image(systemName: "align.horizontal.left.fill")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        store.updateElement(id: selectedID) { $0.x = (393 - $0.width) / 2 }
                    } label: {
                        Image(systemName: "align.horizontal.center.fill")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        store.updateElement(id: selectedID) { $0.x = 393 - 40 - $0.width }
                    } label: {
                        Image(systemName: "align.horizontal.right.fill")
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider().frame(height: 20)

            // Snapping Toggle
            Button {
                isSnappingEnabled.toggle()
            } label: {
                Image(systemName: isSnappingEnabled ? "grid.circle.fill" : "grid.circle")
                    .foregroundStyle(isSnappingEnabled ? appBuilderAccent : .secondary)
            }
            .buttonStyle(.plain)
            .help("Snap to 10px Grid")

            // Zoom Controls
            HStack(spacing: 4) {
                Button {
                    zoomScale = max(0.4, zoomScale - 0.15)
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Button {
                    zoomScale = 1.0
                    panOffset = .zero
                } label: {
                    Text("\(Int(zoomScale * 100))%")
                        .font(.caption.monospacedDigit())
                        .frame(width: 44)
                }
                .buttonStyle(.plain)

                Button {
                    zoomScale = min(2.0, zoomScale + 0.15)
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
            .padding(.trailing, 12)
        }
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }
}

// MARK: - Device Artboard

struct DeviceArtboard: View {
    @EnvironmentObject private var store: ProjectStore
    let screen: AppScreen
    @Binding var selectedElementID: UUID?
    let isSnappingEnabled: Bool
    let zoomScale: CGFloat

    private let artboardWidth: CGFloat = 393
    private let artboardHeight: CGFloat = 852

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Screen Background
            RoundedRectangle(cornerRadius: 44)
                .fill(Color(hex: screen.backgroundColorHex))
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.black.opacity(0.15), lineWidth: 8)
                )
                .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)

            // Dynamic Island / Notch
            Capsule()
                .fill(Color.black)
                .frame(width: 120, height: 32)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 12)

            // Render Elements
            ForEach(screen.elements) { el in
                DraggableCanvasElement(
                    element: el,
                    isSelected: selectedElementID == el.id,
                    isSnappingEnabled: isSnappingEnabled,
                    onSelect: {
                        selectedElementID = el.id
                    },
                    onMove: { newX, newY in
                        store.updateElement(id: el.id) { element in
                            element.x = newX
                            element.y = newY
                        }
                    },
                    onResize: { newW, newH in
                        store.updateElement(id: el.id) { element in
                            element.width = newW
                            element.height = newH
                        }
                    }
                )
            }
        }
        .frame(width: artboardWidth, height: artboardHeight)
    }
}

// MARK: - Draggable Canvas Element with Handles

struct DraggableCanvasElement: View {
    let element: AppElement
    let isSelected: Bool
    let isSnappingEnabled: Bool
    let onSelect: () -> Void
    let onMove: (Double, Double) -> Void
    let onResize: (Double, Double) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var resizeOffset: CGSize = .zero

    var body: some View {
        let currentX = element.x + Double(dragOffset.width)
        let currentY = element.y + Double(dragOffset.height)
        let currentW = max(20, element.width + Double(resizeOffset.width))
        let currentH = max(10, element.height + Double(resizeOffset.height))

        ZStack(alignment: .topLeading) {
            // Visual element representation
            CanvasElementRenderView(element: element, width: currentW, height: currentH)
                .frame(width: CGFloat(currentW), height: CGFloat(currentH))
                .scaleEffect(element.scale)
                .rotationEffect(.degrees(element.rotation))
                .opacity(element.opacity)

            // Selection Outline & Handles
            if isSelected {
                ZStack {
                    RoundedRectangle(cornerRadius: element.cornerRadius)
                        .stroke(appBuilderAccent, lineWidth: 2)
                        .padding(-4)

                    // Coordinate Tooltip badge
                    VStack {
                        Text("\(element.name) • X: \(Int(currentX)) Y: \(Int(currentY))")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(appBuilderAccent, in: Capsule())
                            .offset(y: -24)
                        Spacer()
                    }

                    // Bottom-Right Resize Handle
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(appBuilderAccent)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .offset(x: 6, y: 6)
                                .gesture(
                                    DragGesture()
                                        .onChanged { val in
                                            resizeOffset = val.translation
                                        }
                                        .onEnded { val in
                                            var finalW = element.width + Double(val.translation.width)
                                            var finalH = element.height + Double(val.translation.height)
                                            if isSnappingEnabled {
                                                finalW = round(finalW / 10.0) * 10.0
                                                finalH = round(finalH / 10.0) * 10.0
                                            }
                                            onResize(max(20, finalW), max(10, finalH))
                                            resizeOffset = .zero
                                        }
                                    )
                        }
                    }
                }
                .frame(width: CGFloat(currentW), height: CGFloat(currentH))
            }
        }
        .offset(x: CGFloat(currentX), y: CGFloat(currentY))
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { val in
                    dragOffset = val.translation
                    if !isSelected { onSelect() }
                }
                .onEnded { val in
                    var finalX = element.x + Double(val.translation.width)
                    var finalY = element.y + Double(val.translation.height)
                    if isSnappingEnabled {
                        finalX = round(finalX / 10.0) * 10.0
                        finalY = round(finalY / 10.0) * 10.0
                    }
                    onMove(finalX, finalY)
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Canvas Element Render View

struct CanvasElementRenderView: View {
    let element: AppElement
    let width: Double
    let height: Double

    var body: some View {
        switch element.kind {
        case .shape:
            RoundedRectangle(cornerRadius: element.cornerRadius)
                .fill(Color(hex: element.colorHex))
                .overlay(
                    Text(element.text)
                        .font(.system(size: element.fontSize, weight: element.fontWeight.swiftWeight, design: element.fontDesign.swiftDesign))
                        .foregroundStyle(Color(hex: element.textColorHex))
                )

        case .icon:
            Image(systemName: element.iconName.isEmpty ? "sparkles" : element.iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(hex: element.colorHex))

        case .text:
            Text(element.text)
                .font(.system(size: element.fontSize, weight: element.fontWeight.swiftWeight, design: element.fontDesign.swiftDesign))
                .foregroundStyle(Color(hex: element.textColorHex))
                .multilineTextAlignment(element.textAlignment.swiftAlignment)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .button:
            HStack(spacing: 6) {
                if !element.iconName.isEmpty {
                    Image(systemName: element.iconName)
                }
                Text(element.text)
                    .font(.system(size: element.fontSize, weight: element.fontWeight.swiftWeight))
            }
            .foregroundStyle(Color(hex: element.textColorHex))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: element.colorHex), in: RoundedRectangle(cornerRadius: element.cornerRadius))

        case .textField:
            HStack {
                Text(element.text.isEmpty ? element.placeholder : element.text)
                    .font(.system(size: element.fontSize))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(maxHeight: .infinity)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: element.cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: element.cornerRadius).stroke(Color.secondary.opacity(0.3), lineWidth: 1))

        case .toggle:
            HStack {
                Text(element.text)
                    .font(.system(size: element.fontSize))
                Spacer()
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: element.colorHex))
                    .frame(width: 44, height: 26)
                    .overlay(
                        Circle().fill(Color.white).frame(width: 22, height: 22).offset(x: 8)
                    )
            }

        case .slider:
            VStack(alignment: .leading, spacing: 4) {
                Text(element.text).font(.caption2)
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 8)
                    .overlay(
                        HStack {
                            Capsule().fill(Color(hex: element.colorHex)).frame(width: CGFloat(width * 0.5))
                            Circle().fill(Color.white).frame(width: 16, height: 16).shadow(radius: 2)
                            Spacer()
                        }
                    )
            }

        case .badge:
            Text(element.text)
                .font(.system(size: element.fontSize, weight: .bold))
                .foregroundStyle(Color(hex: element.textColorHex))
                .padding(.horizontal, 10)
                .frame(maxHeight: .infinity)
                .background(Color(hex: element.colorHex), in: Capsule())

        case .progressBar:
            VStack(alignment: .leading, spacing: 2) {
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: CGFloat(height))
                    .overlay(
                        HStack {
                            Capsule().fill(Color(hex: element.colorHex)).frame(width: CGFloat(width * 0.6))
                            Spacer()
                        }
                    )
            }

        case .soundPad:
            VStack(spacing: 4) {
                Image(systemName: "waveform")
                    .font(.title3)
                Text(element.text)
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: element.colorHex), in: RoundedRectangle(cornerRadius: element.cornerRadius))

        case .stepper:
            HStack {
                Text(element.text)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "minus").frame(width: 24, height: 24).background(.quaternary, in: Circle())
                    Text("0").font(.monospacedDigit())
                    Image(systemName: "plus").frame(width: 24, height: 24).background(.quaternary, in: Circle())
                }
            }

        default:
            RoundedRectangle(cornerRadius: element.cornerRadius)
                .strokeBorder(Color(hex: element.colorHex), style: StrokeStyle(lineWidth: 2, dash: [4]))
                .overlay(Text(element.text).font(.caption))
        }
    }
}

// MARK: - Grid Background

struct CanvasGridBackground: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 20
            var path = Path()

            for x in stride(from: 0, to: size.width, by: step) {
                for y in stride(from: 0, to: size.height, by: step) {
                    path.addEllipse(in: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                }
            }
            context.fill(path, with: .color(Color.secondary.opacity(0.18)))
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Element Palette Sidebar

struct ElementPaletteSidebar: View {
    @Binding var selectedCategory: ElementCategory
    @Binding var search: String
    let onAddElement: (AppElement) -> Void

    private var filteredKinds: [ElementKind] {
        ElementKind.allCases.filter { kind in
            kind.category == selectedCategory &&
            (search.isEmpty || kind.rawValue.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Components")
                        .font(.headline)
                    Text("Drag or tap to place on canvas")
                        .font(.caption2)
                        .foregroundStyle(appBuilderSecondary)
                }
                Spacer()
            }
            .padding(14)

            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Find blocks", text: $search)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(ElementCategory.allCases) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: cat.icon)
                                    .font(.caption2)
                                Text(cat.rawValue)
                                    .font(.caption.weight(.semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .foregroundStyle(selectedCategory == cat ? .white : appBuilderInk)
                            .background(selectedCategory == cat ? appBuilderAccent : Color.clear, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            Divider()

            // Block list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredKinds) { kind in
                        Button {
                            let el = AppElement(kind: kind)
                            onAddElement(el)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: kind.symbol)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(appBuilderAccent)
                                    .frame(width: 32, height: 32)
                                    .background(appBuilderAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(kind.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(appBuilderInk)
                                    Text(kind.defaultTitle)
                                        .font(.caption2)
                                        .foregroundStyle(appBuilderSecondary)
                                        .lineLimit(1)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(appBuilderAccent.opacity(0.7))
                            }
                            .padding(8)
                            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }
        }
        .background(Color(uiColor: .tertiarySystemBackground))
    }
}
