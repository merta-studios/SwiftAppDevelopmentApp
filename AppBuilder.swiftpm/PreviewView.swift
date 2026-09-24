import SwiftUI

struct PreviewRuntimeView: View {
    let project: BuilderProject
    @Binding var isPresented: Bool
    @State private var notice: String?
    @State private var inputText = ""
    @State private var toggleValue = false
    @State private var sliderValue = 0.5

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationStack {
                ScrollView {
                    runtimeView(project.document.root)
                        .frame(maxWidth: 760, alignment: .topLeading)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 28)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .background(Color(hex: project.document.accentHex).opacity(0.055))
                .navigationTitle(project.document.appName)
                .navigationBarTitleDisplayMode(.inline)
            }

            // Deliberately tiny: testing should feel like using the app, not debugging it.
            Button {
                isPresented = false
            } label: {
                Image(systemName: "stop.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(.black.opacity(0.68), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.32), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .padding(.trailing, 10)
            .accessibilityLabel("Stop preview")
        }
        .statusBarHidden(true)
        .alert("App message", isPresented: Binding(
            get: { notice != nil },
            set: { if !$0 { notice = nil } }
        )) {
            Button("OK") { notice = nil }
        } message: {
            Text(notice ?? "")
        }
    }

    private func runtimeView(_ block: BuilderBlock) -> AnyView {
        switch block.kind {
        case .verticalStack:
            return AnyView(VStack(alignment: .leading, spacing: 16) {
                ForEach(block.children) { child in runtimeView(child) }
            })
        case .horizontalStack:
            return AnyView(HStack(spacing: 12) {
                ForEach(block.children) { child in runtimeView(child) }
            })
        case .zStack:
            return AnyView(ZStack {
                ForEach(block.children) { child in runtimeView(child) }
            })
        case .spacer:
            return AnyView(Spacer(minLength: 18))
        case .padding:
            return AnyView(VStack(alignment: .leading, spacing: 12) {
                ForEach(block.children) { child in runtimeView(child) }
            }.padding(18))
        case .text:
            return AnyView(Text(block.title)
                .font(.title3)
                .foregroundStyle(Color(hex: block.colorHex)))
        case .image:
            return AnyView(Image(systemName: block.title.isEmpty ? "star.fill" : block.title)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(Color(hex: block.colorHex)))
        case .colorBox:
            return AnyView(RoundedRectangle(cornerRadius: 22)
                .fill(Color(hex: block.colorHex))
                .frame(height: 86)
                .overlay(Text(block.title).foregroundStyle(.white).font(.headline)))
        case .divider:
            return AnyView(Divider())
        case .badge:
            return AnyView(Text(block.title)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(Color(hex: block.colorHex).opacity(0.18), in: Capsule())
                .foregroundStyle(Color(hex: block.colorHex)))
        case .button:
            return AnyView(Button {
                notice = block.secondaryValue.isEmpty ? "You tapped \(block.title)." : block.secondaryValue
            } label: {
                Text(block.title)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: block.colorHex)))
        case .navigationLink:
            return AnyView(NavigationLink {
                VStack(spacing: 14) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color(hex: block.colorHex))
                    Text("Next screen")
                        .font(.title2.weight(.bold))
                    Text("This destination was made from one visual block.")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .navigationTitle(block.title)
            } label: {
                Label(block.title, systemImage: "arrow.right.circle")
            })
        case .toggle:
            return AnyView(Toggle(block.title, isOn: $toggleValue)
                .tint(Color(hex: block.colorHex)))
        case .slider:
            return AnyView(VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(block.title)
                    Spacer()
                    Text(sliderValue, format: .number.precision(.fractionLength(2)))
                        .foregroundStyle(.secondary)
                }
                Slider(value: $sliderValue, in: 0...1)
                    .tint(Color(hex: block.colorHex))
            })
        case .textField:
            return AnyView(TextField(block.title, text: $inputText)
                .textFieldStyle(.roundedBorder))
        case .list:
            return AnyView(VStack(alignment: .leading, spacing: 0) {
                ForEach(1...3, id: \.self) { number in
                    Label("\(block.title) \(number)", systemImage: "circle.fill")
                        .font(.body)
                        .foregroundStyle(Color(hex: block.colorHex))
                        .padding(.vertical, 10)
                    if number < 3 { Divider() }
                }
            })
        case .state:
            return AnyView(Label("\(block.title): \(block.value.isEmpty ? "0" : block.value)", systemImage: "number.circle"))
        case .conditional:
            let shouldShow = block.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "false"
            return AnyView(Group {
                if shouldShow {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(block.children) { child in runtimeView(child) }
                    }
                }
            })
        case .repeatBlock:
            let count = max(0, Int(block.title) ?? 3)
            return AnyView(VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<count, id: \.self) { _ in
                    ForEach(block.children) { child in runtimeView(child) }
                }
            })
        case .event:
            return AnyView(VStack(alignment: .leading, spacing: 9) {
                Text(block.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                ForEach(block.children) { child in runtimeView(child) }
            })
        case .rawSwift:
            return AnyView(HStack(spacing: 9) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                Text("Power code preview")
                    .font(.subheadline.monospaced())
                Spacer()
            }
            .padding(12)
            .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12)))
        }
    }
}
