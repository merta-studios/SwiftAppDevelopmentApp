import SwiftUI

/// Full Interactive Runtime Simulator for App Builder.
/// Executes state variables, 60fps tweens, sound synthesis, haptics, particle effects, and screen navigation.
struct PreviewRuntimeView: View {
    let project: BuilderProject
    @Binding var isPresented: Bool

    @StateObject private var engine = ScriptEngine()
    @State private var currentScreenName: String = ""
    @State private var activeSheetScreenName: String? = nil
    @State private var showingDebugBar = true

    private var currentScreen: AppScreen? {
        if let match = project.document.screens.first(where: { $0.name == currentScreenName }) {
            return match
        }
        return project.document.screens.first
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack(alignment: .topTrailing) {
                // Background & Current Screen Content
                ZStack {
                    if let screen = currentScreen {
                        ScreenRuntimeCanvas(screen: screen, engine: engine)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: currentScreen?.backgroundColorHex ?? "#0F172A"))
                .ignoresSafeArea()

                // Confetti Explosion Overlay
                if engine.triggerConfetti > 0 {
                    ConfettiParticleOverlay(burstID: engine.triggerConfetti)
                        .allowsHitTesting(false)
                }

                // Top Floating Close & Debug Bar
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        // Debug state pill
                        Button {
                            withAnimation { showingDebugBar.toggle() }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "ladybug.fill")
                                    .font(.caption2)
                                Text("Variables (\(engine.variables.count))")
                                    .font(.caption.weight(.bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .foregroundStyle(.white)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        // Stop Preview Button
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(.black.opacity(0.75), in: Circle())
                                .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Floating Variable Watcher HUD
                    if showingDebugBar && !engine.variables.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(engine.variables.values)) { v in
                                    HStack(spacing: 4) {
                                        Text(v.name + ":")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(.white.opacity(0.7))
                                        Text(v.displayValue)
                                            .font(.caption2.monospacedDigit().weight(.heavy))
                                            .foregroundStyle(Color(hex: project.document.accentHex))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                                }

                                Button {
                                    engine.resetToDefaults()
                                } label: {
                                    Label("Reset", systemImage: "arrow.counterclockwise")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.red.opacity(0.7), in: RoundedRectangle(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()
                }

                // Alert notification
                if let notif = engine.activeNotification {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(notif.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(notif.message)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Spacer()
                            Button("Dismiss") {
                                engine.activeNotification = nil
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.2), in: Capsule())
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 1))
                        .padding(20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onChange(of: timeline.date) { _ in
                engine.updateTweens()
            }
            .onChange(of: engine.requestedScreenNavigation?.screenName) { newScreen in
                if let target = newScreen {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentScreenName = target
                    }
                    engine.requestedScreenNavigation = nil
                }
            }
        }
        .onAppear {
            engine.initialize(variables: project.document.globalVariables)
            currentScreenName = project.document.screens.first?.name ?? "Home"
        }
    }
}

// MARK: - Screen Runtime Canvas

struct ScreenRuntimeCanvas: View {
    let screen: AppScreen
    @ObservedObject var engine: ScriptEngine

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(screen.elements) { el in
                    RuntimeElementView(element: el, engine: engine)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
    }
}

// MARK: - Runtime Element View (Interactive)

struct RuntimeElementView: View {
    let element: AppElement
    @ObservedObject var engine: ScriptEngine

    @State private var inputText: String = ""

    var body: some View {
        let transforms = engine.activeTransforms[element.name] ?? [:]
        let dynScale = transforms[.scale] ?? element.scale
        let dynRot = transforms[.rotation] ?? element.rotation
        let dynOpacity = transforms[.opacity] ?? element.opacity
        let dynX = transforms[.positionX] ?? 0
        let dynY = transforms[.positionY] ?? 0
        let dynW = transforms[.width] ?? element.width
        let dynH = transforms[.height] ?? element.height

        Group {
            switch element.kind {
            case .button:
                Button {
                    engine.executeAll(element.onTapActions)
                } label: {
                    HStack(spacing: 8) {
                        if !element.iconName.isEmpty {
                            Image(systemName: element.iconName)
                        }
                        Text(displayText(for: element))
                            .font(.system(size: element.fontSize, weight: element.fontWeight.swiftWeight, design: element.fontDesign.swiftDesign))
                    }
                    .foregroundStyle(Color(hex: element.textColorHex))
                    .frame(width: CGFloat(dynW), height: CGFloat(dynH))
                    .background(Color(hex: element.colorHex), in: RoundedRectangle(cornerRadius: element.cornerRadius))
                    .shadow(color: Color(hex: element.shadowColorHex), radius: element.shadowRadius, x: 0, y: element.shadowY)
                }
                .buttonStyle(ScaleButtonStyle())

            case .icon:
                Image(systemName: element.iconName.isEmpty ? "sparkles" : element.iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color(hex: element.colorHex))
                    .frame(width: CGFloat(dynW), height: CGFloat(dynH))
                    .onTapGesture {
                        engine.executeAll(element.onTapActions)
                    }

            case .text:
                Text(displayText(for: element))
                    .font(.system(size: element.fontSize, weight: element.fontWeight.swiftWeight, design: element.fontDesign.swiftDesign))
                    .foregroundStyle(Color(hex: element.textColorHex))
                    .multilineTextAlignment(element.textAlignment.swiftAlignment)
                    .frame(width: CGFloat(dynW), height: CGFloat(dynH), alignment: .leading)
                    .onTapGesture {
                        engine.executeAll(element.onTapActions)
                    }

            case .shape:
                RoundedRectangle(cornerRadius: element.cornerRadius)
                    .fill(Color(hex: element.colorHex))
                    .frame(width: CGFloat(dynW), height: CGFloat(dynH))
                    .overlay(
                        Text(displayText(for: element))
                            .font(.system(size: element.fontSize, weight: element.fontWeight.swiftWeight))
                            .foregroundStyle(Color(hex: element.textColorHex))
                    )
                    .onTapGesture {
                        engine.executeAll(element.onTapActions)
                    }

            case .textField:
                TextField(element.placeholder, text: Binding(
                    get: {
                        if !element.boundVariable.isEmpty {
                            return engine.getText(element.boundVariable)
                        }
                        return inputText
                    },
                    set: { val in
                        inputText = val
                        if !element.boundVariable.isEmpty {
                            engine.setText(element.boundVariable, val)
                        }
                    }
                ))
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .frame(width: CGFloat(dynW), height: CGFloat(dynH))
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: element.cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: element.cornerRadius).stroke(Color(hex: element.colorHex), lineWidth: 1))

            case .toggle:
                Toggle(element.text, isOn: Binding(
                    get: {
                        if !element.boundVariable.isEmpty {
                            return engine.getBool(element.boundVariable)
                        }
                        return false
                    },
                    set: { val in
                        if !element.boundVariable.isEmpty {
                            engine.setBool(element.boundVariable, val)
                        }
                        engine.executeAll(element.onTapActions)
                    }
                ))
                .tint(Color(hex: element.colorHex))
                .frame(width: CGFloat(dynW), height: CGFloat(dynH))

            case .slider:
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(element.text).font(.caption.weight(.bold))
                        Spacer()
                        if !element.boundVariable.isEmpty {
                            Text(String(format: "%.1f", engine.getNumber(element.boundVariable)))
                                .font(.caption.monospacedDigit())
                        }
                    }
                    Slider(
                        value: Binding(
                            get: {
                                if !element.boundVariable.isEmpty {
                                    return engine.getNumber(element.boundVariable)
                                }
                                return 50
                            },
                            set: { val in
                                if !element.boundVariable.isEmpty {
                                    engine.setNumber(element.boundVariable, val)
                                }
                            }
                        ),
                        in: element.minValue...element.maxValue
                    )
                    .tint(Color(hex: element.colorHex))
                }
                .frame(width: CGFloat(dynW), height: CGFloat(dynH))

            case .progressBar:
                let currentVal = !element.boundVariable.isEmpty ? engine.getNumber(element.boundVariable) : 50
                let progress = max(0.0, min(1.0, (currentVal - element.minValue) / max(1.0, (element.maxValue - element.minValue))))

                GeometryReader { barGeo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                        Capsule()
                            .fill(Color(hex: element.colorHex))
                            .frame(width: barGeo.size.width * CGFloat(progress))
                    }
                }
                .frame(width: CGFloat(dynW), height: CGFloat(dynH))

            case .badge:
                Text(displayText(for: element))
                    .font(.system(size: element.fontSize, weight: .bold))
                    .foregroundStyle(Color(hex: element.textColorHex))
                    .padding(.horizontal, 12)
                    .frame(height: CGFloat(dynH))
                    .background(Color(hex: element.colorHex), in: Capsule())

            case .soundPad:
                Button {
                    engine.executeAll(element.onTapActions)
                    SoundManager.shared.play(.coin)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.title2)
                        Text(element.text)
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: CGFloat(dynW), height: CGFloat(dynH))
                    .background(Color(hex: element.colorHex), in: RoundedRectangle(cornerRadius: element.cornerRadius))
                }
                .buttonStyle(ScaleButtonStyle())

            default:
                EmptyView()
            }
        }
        .scaleEffect(dynScale)
        .rotationEffect(.degrees(dynRot))
        .opacity(dynOpacity)
        .offset(x: CGFloat(element.x + dynX), y: CGFloat(element.y + dynY))
    }

    private func displayText(for el: AppElement) -> String {
        if !el.boundVariable.isEmpty {
            if let v = engine.variables[el.boundVariable] {
                return "\(el.text.isEmpty ? "" : el.text + " ")\(v.displayValue)"
            }
        }
        return el.text
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Confetti Particle Overlay

struct ConfettiParticleOverlay: View {
    let burstID: Int
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var color: Color
        var size: CGFloat
        var velocityX: CGFloat
        var velocityY: CGFloat
        var rotation: Double
    }

    private let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange, .pink, .cyan]

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for p in particles {
                    var path = Path()
                    path.addRect(CGRect(x: p.x, y: p.y, width: p.size, height: p.size))
                    context.fill(path, with: .color(p.color))
                }
            }
        }
        .onAppear {
            generateParticles()
        }
        .onChange(of: burstID) { _ in
            generateParticles()
        }
    }

    private func generateParticles() {
        var newP: [Particle] = []
        for _ in 0..<70 {
            newP.append(
                Particle(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...400),
                    color: colors.randomElement() ?? .yellow,
                    size: CGFloat.random(in: 6...12),
                    velocityX: CGFloat.random(in: -100...100),
                    velocityY: CGFloat.random(in: -200...200),
                    rotation: Double.random(in: 0...360)
                )
            )
        }
        particles = newP
    }
}
