import Foundation
import SwiftUI

// MARK: - Active Tween State

struct ActiveTween: Identifiable {
    let id = UUID()
    let targetName: String
    let property: TweenProperty
    let startValue: Double
    let endValue: Double
    let duration: Double
    let startTime: TimeInterval
    let easing: EasingType
    let yoyo: Bool
    let repeatCount: Int
    var isFinished: Bool = false
    var onComplete: (() -> Void)? = nil

    func currentValue(at time: TimeInterval) -> (value: Double, finished: Bool) {
        let elapsed = time - startTime
        guard duration > 0 else { return (endValue, true) }

        let cycleDuration = yoyo ? (duration * 2.0) : duration
        let totalLoops = elapsed / cycleDuration
        let currentLoop = Int(floor(totalLoops))

        if repeatCount > 0 && currentLoop >= repeatCount {
            return (yoyo ? startValue : endValue, true)
        }

        let loopProgress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / duration
        let (rawT, reversed) = loopProgress > 1.0 ? (2.0 - loopProgress, true) : (loopProgress, false)
        let t = max(0.0, min(1.0, rawT))
        let easedT = applyEasing(t, easing: easing)

        let val = startValue + (endValue - startValue) * easedT
        return (val, false)
    }

    private func applyEasing(_ t: Double, easing: EasingType) -> Double {
        switch easing {
        case .linear:
            return t
        case .easeIn:
            return t * t
        case .easeOut:
            return t * (2.0 - t)
        case .easeInOut:
            return t < 0.5 ? 2.0 * t * t : -1.0 + (4.0 - 2.0 * t) * t
        case .spring:
            // Damped harmonic oscillator approximation
            let freq = 12.0
            let decay = 6.0
            return 1.0 - exp(-decay * t) * cos(freq * t)
        case .bounce:
            var progress = t
            if progress < 1 / 2.75 {
                return 7.5625 * progress * progress
            } else if progress < 2 / 2.75 {
                progress -= 1.5 / 2.75
                return 7.5625 * progress * progress + 0.75
            } else if progress < 2.5 / 2.75 {
                progress -= 2.25 / 2.75
                return 7.5625 * progress * progress + 0.9375
            } else {
                progress -= 2.625 / 2.75
                return 7.5625 * progress * progress + 0.984375
            }
        }
    }
}

// MARK: - Script & Action Execution Engine

@MainActor
final class ScriptEngine: ObservableObject {
    @Published var variables: [String: StateVariable] = [:]
    @Published var activeTweens: [ActiveTween] = []
    @Published var activeTransforms: [String: [TweenProperty: Double]] = [:]
    @Published var activeNotification: (title: String, message: String)? = nil
    @Published var triggerConfetti: Int = 0
    @Published var requestedScreenNavigation: (screenName: String, style: NavigationTransitionStyle)? = nil
    @Published var executionLog: [String] = []

    private var initialVariables: [StateVariable] = []

    init() {}

    func initialize(variables: [StateVariable]) {
        self.initialVariables = variables
        self.variables.removeAll()
        for v in variables {
            self.variables[v.name] = v
        }
        self.activeTweens.removeAll()
        self.activeTransforms.removeAll()
        self.activeNotification = nil
    }

    func resetToDefaults() {
        initialize(variables: initialVariables)
        log("🔄 State reset to initial values")
    }

    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        executionLog.insert("[\(timestamp)] \(message)", at: 0)
        if executionLog.count > 50 {
            executionLog.removeLast()
        }
    }

    // MARK: - Variable Access

    func getNumber(_ name: String) -> Double {
        return variables[name]?.numberValue ?? 0
    }

    func getText(_ name: String) -> String {
        return variables[name]?.textValue ?? ""
    }

    func getBool(_ name: String) -> Bool {
        return variables[name]?.boolValue ?? false
    }

    func setNumber(_ name: String, _ val: Double) {
        if var v = variables[name] {
            v.numberValue = val
            v.type = .number
            variables[name] = v
        } else {
            variables[name] = StateVariable(name: name, type: .number, numberValue: val)
        }
    }

    func setText(_ name: String, _ val: String) {
        if var v = variables[name] {
            v.textValue = val
            v.type = .text
            variables[name] = v
        } else {
            variables[name] = StateVariable(name: name, type: .text, textValue: val)
        }
    }

    func setBool(_ name: String, _ val: Bool) {
        if var v = variables[name] {
            v.boolValue = val
            v.type = .boolean
            variables[name] = v
        } else {
            variables[name] = StateVariable(name: name, type: .boolean, boolValue: val)
        }
    }

    // MARK: - Action Execution

    func execute(_ action: AppAction) {
        guard action.isEnabled else { return }

        switch action.kind {
        case .setVariable:
            executeSetVariable(action)

        case .tween:
            executeTween(action.tweenConfig)

        case .playSound:
            SoundManager.shared.play(action.sound)
            SoundManager.shared.playHaptic(action.haptic)
            log("🔊 Sound '\(action.sound.rawValue)' played")

        case .navigate:
            requestedScreenNavigation = (action.targetScreenName, action.navigationStyle)
            log("🚀 Navigate to screen '\(action.targetScreenName)'")

        case .conditional:
            let isConditionMet = evaluateCondition(action.conditionExpression)
            log("🔍 Condition '\(action.conditionExpression)' -> \(isConditionMet ? "TRUE" : "FALSE")")
            if isConditionMet {
                for act in action.thenActions { execute(act) }
            } else {
                for act in action.elseActions { execute(act) }
            }

        case .toggleBool:
            let current = getBool(action.targetVariable)
            setBool(action.targetVariable, !current)
            log("🔄 Toggled '\(action.targetVariable)' to \(!current)")

        case .showNotification:
            activeNotification = (action.notificationTitle, action.notificationMessage)
            log("🔔 Alert: \(action.notificationTitle) - \(action.notificationMessage)")

        case .confetti:
            triggerConfetti += 1
            SoundManager.shared.play(.victory)
            SoundManager.shared.playHaptic(.success)
            log("🎉 Confetti burst!")

        case .waitDelay:
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(max(0.01, action.delaySeconds) * 1_000_000_000))
                for act in action.thenActions {
                    self.execute(act)
                }
            }

        case .runScript:
            executeScript(action.scriptCode)

        case .resetState:
            resetToDefaults()
        }
    }

    func executeAll(_ actions: [AppAction]) {
        for action in actions {
            execute(action)
        }
    }

    // MARK: - Set Variable Logic

    private func executeSetVariable(_ action: AppAction) {
        let varName = action.targetVariable.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !varName.isEmpty else { return }

        let expr = action.expression.trimmingCharacters(in: .whitespacesAndNewlines)
        let existing = variables[varName]

        switch action.operation {
        case .assign:
            if let num = evaluateMathExpression(expr) {
                setNumber(varName, num)
                log("✏️ \(varName) = \(num)")
            } else if expr.lowercased() == "true" {
                setBool(varName, true)
                log("✏️ \(varName) = true")
            } else if expr.lowercased() == "false" {
                setBool(varName, false)
                log("✏️ \(varName) = false")
            } else {
                let text = evaluateStringExpression(expr)
                setText(varName, text)
                log("✏️ \(varName) = \"\(text)\"")
            }

        case .add:
            let delta = evaluateMathExpression(expr) ?? 1
            let current = existing?.numberValue ?? 0
            setNumber(varName, current + delta)
            log("➕ \(varName) = \(current + delta) (+ \(delta))")

        case .subtract:
            let delta = evaluateMathExpression(expr) ?? 1
            let current = existing?.numberValue ?? 0
            setNumber(varName, current - delta)
            log("➖ \(varName) = \(current - delta) (- \(delta))")

        case .multiply:
            let factor = evaluateMathExpression(expr) ?? 2
            let current = existing?.numberValue ?? 1
            setNumber(varName, current * factor)
            log("✖️ \(varName) = \(current * factor) (* \(factor))")

        case .divide:
            let divisor = evaluateMathExpression(expr) ?? 1
            let current = existing?.numberValue ?? 1
            if divisor != 0 {
                setNumber(varName, current / divisor)
                log("➗ \(varName) = \(current / divisor)")
            }

        case .append:
            let text = evaluateStringExpression(expr)
            if var v = existing {
                v.listValue.append(text)
                variables[varName] = v
            } else {
                variables[varName] = StateVariable(name: varName, type: .list, listValue: [text])
            }
            log("📋 Appended \"\(text)\" to \(varName)")
        }
    }

    // MARK: - Tween Execution

    func executeTween(_ config: TweenConfig) {
        let target = config.targetName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !target.isEmpty else { return }

        let currentVal = activeTransforms[target]?[config.property] ?? defaultPropertyValue(config.property)
        let finalVal = config.isRelative ? (currentVal + config.targetValue) : config.targetValue

        let tween = ActiveTween(
            targetName: target,
            property: config.property,
            startValue: currentVal,
            endValue: finalVal,
            duration: config.duration,
            startTime: CACurrentMediaTime(),
            easing: config.easing,
            yoyo: config.yoyo,
            repeatCount: config.repeatCount
        )

        activeTweens.removeAll { $0.targetName == target && $0.property == config.property }
        activeTweens.append(tween)
        log("✨ Tween '\(target)' .\(config.property.rawValue) to \(finalVal) in \(config.duration)s")
    }

    private func defaultPropertyValue(_ prop: TweenProperty) -> Double {
        switch prop {
        case .positionX, .positionY, .rotation: return 0
        case .scale, .opacity: return 1.0
        case .width: return 100
        case .height: return 100
        case .cornerRadius: return 12
        }
    }

    // MARK: - Animation Frame Update (60 FPS)

    func updateTweens(at time: TimeInterval = CACurrentMediaTime()) {
        guard !activeTweens.isEmpty else { return }

        var remaining: [ActiveTween] = []
        for tween in activeTweens {
            let (val, finished) = tween.currentValue(at: time)
            if activeTransforms[tween.targetName] == nil {
                activeTransforms[tween.targetName] = [:]
            }
            activeTransforms[tween.targetName]?[tween.property] = val

            if !finished {
                remaining.append(tween)
            } else {
                tween.onComplete?()
            }
        }
        activeTweens = remaining
    }

    // MARK: - Mini Scripting Interpreter (Lua / Swift Syntax)

    func executeScript(_ script: String) {
        let lines = script.components(separatedBy: .newlines)
        log("⚡ Running script (\(lines.count) lines)")

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty || line.hasPrefix("--") || line.hasPrefix("//") {
                continue
            }
            executeScriptLine(line)
        }
    }

    private func executeScriptLine(_ line: String) {
        // playSound("coin")
        if line.starts(with: "playSound(") && line.hasSuffix(")") {
            let param = extractStringArgument(line, prefix: "playSound(")
            if let sound = SoundEffectType.allCases.first(where: { $0.rawValue.localizedCaseInsensitiveContains(param) || $0.id.localizedCaseInsensitiveContains(param) }) {
                SoundManager.shared.play(sound)
                log("🔊 Script: playSound(\(sound.rawValue))")
            }
            return
        }

        // haptic("heavy")
        if line.starts(with: "haptic(") && line.hasSuffix(")") {
            let param = extractStringArgument(line, prefix: "haptic(")
            if let haptic = HapticType.allCases.first(where: { $0.rawValue.localizedCaseInsensitiveContains(param) }) {
                SoundManager.shared.playHaptic(haptic)
            }
            return
        }

        // navigate("ScreenName")
        if line.starts(with: "navigate(") && line.hasSuffix(")") {
            let screen = extractStringArgument(line, prefix: "navigate(")
            requestedScreenNavigation = (screen, .push)
            log("🚀 Script: navigate(\(screen))")
            return
        }

        // confetti()
        if line.contains("confetti()") {
            triggerConfetti += 1
            SoundManager.shared.play(.victory)
            return
        }

        // alert("Title", "Message")
        if line.starts(with: "alert(") && line.hasSuffix(")") {
            let inner = line.dropFirst(6).dropLast(1)
            let parts = inner.components(separatedBy: ",")
            let title = parts.first?.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces) ?? "Alert"
            let msg = parts.count > 1 ? parts[1].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces) : ""
            activeNotification = (title, msg)
            return
        }

        // tween("targetName", "property", value, duration)
        // e.g. tween("scoreLabel", "scale", 1.4, 0.2)
        if line.starts(with: "tween(") && line.hasSuffix(")") {
            parseTweenCall(line)
            return
        }

        // Variable assignment: variable = expression
        if let eqIndex = line.firstIndex(of: "=") {
            let varName = String(line[..<eqIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            let rightSide = String(line[line.index(after: eqIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)

            if let num = evaluateMathExpression(rightSide) {
                setNumber(varName, num)
                log("✏️ \(varName) = \(num)")
            } else if rightSide == "true" || rightSide == "false" {
                setBool(varName, rightSide == "true")
            } else {
                let text = evaluateStringExpression(rightSide)
                setText(varName, text)
            }
        }
    }

    private func extractStringArgument(_ line: String, prefix: String) -> String {
        let inside = line.dropFirst(prefix.count).dropLast(1)
        return inside.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "").trimmingCharacters(in: .whitespaces)
    }

    private func parseTweenCall(_ line: String) {
        // format: tween("target", "scale", 1.5, 0.3)
        let inside = line.dropFirst(6).dropLast(1)
        let parts = inside.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 3 else { return }

        let target = parts[0].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
        let propStr = parts[1].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "").lowercased()
        let val = evaluateMathExpression(parts[2]) ?? 1.0
        let dur = parts.count > 3 ? (evaluateMathExpression(parts[3]) ?? 0.3) : 0.3

        var prop: TweenProperty = .scale
        if propStr.contains("x") { prop = .positionX }
        else if propStr.contains("y") { prop = .positionY }
        else if propStr.contains("rot") { prop = .rotation }
        else if propStr.contains("opac") || propStr.contains("alpha") { prop = .opacity }
        else if propStr.contains("width") { prop = .width }
        else if propStr.contains("height") { prop = .height }

        let cfg = TweenConfig(targetName: target, property: prop, targetValue: val, duration: dur, easing: .spring, isRelative: false, yoyo: true)
        executeTween(cfg)
    }

    // MARK: - Expressions & Math

    func evaluateMathExpression(_ raw: String) -> Double? {
        var str = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Replace random(min, max)
        if let range = str.range(of: "random\\((\\d+)\\s*,\\s*(\\d+)\\)", options: .regularExpression) {
            let match = String(str[range])
            let nums = match.replacingOccurrences(of: "random(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ",")
            if nums.count == 2, let min = Double(nums[0].trimmingCharacters(in: .whitespaces)), let max = Double(nums[1].trimmingCharacters(in: .whitespaces)) {
                let rnd = Double.random(in: min...max)
                str = str.replacingCharacters(in: range, with: "\(rnd)")
            }
        }

        // Substitute known variable values
        for (name, variable) in variables {
            if variable.type == .number {
                str = str.replacingOccurrences(of: name, with: "\(variable.numberValue)")
            }
        }

        let expr = NSExpression(format: str)
        if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
            return result.doubleValue
        }
        return Double(str)
    }

    func evaluateStringExpression(_ raw: String) -> String {
        var str = raw
        // Lua string concatenation .. or +
        let parts = str.components(separatedBy: "..")
        if parts.count > 1 {
            return parts.map { evaluateStringPart($0) }.joined()
        }
        return evaluateStringPart(str)
    }

    private func evaluateStringPart(_ part: String) -> String {
        let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"")) || (trimmed.hasPrefix("'") && trimmed.hasSuffix("'")) {
            return String(trimmed.dropFirst().dropLast())
        }
        if let v = variables[trimmed] {
            return v.displayValue
        }
        return trimmed
    }

    func evaluateCondition(_ condition: String) -> Bool {
        var cond = condition.trimmingCharacters(in: .whitespacesAndNewlines)
        if cond.isEmpty || cond.lowercased() == "true" { return true }
        if cond.lowercased() == "false" { return false }

        // Substitute variable values
        for (name, variable) in variables {
            if variable.type == .number {
                cond = cond.replacingOccurrences(of: name, with: "\(variable.numberValue)")
            } else if variable.type == .boolean {
                cond = cond.replacingOccurrences(of: name, with: variable.boolValue ? "1 == 1" : "1 == 0")
            } else if variable.type == .text {
                cond = cond.replacingOccurrences(of: name, with: "\"\(variable.textValue)\"")
            }
        }

        // Lua syntax adjustments
        cond = cond.replacingOccurrences(of: "==", with: "==")
        cond = cond.replacingOccurrences(of: "and", with: "AND")
        cond = cond.replacingOccurrences(of: "or", with: "OR")
        cond = cond.replacingOccurrences(of: "not", with: "NOT")

        if let predicate = try? NSPredicate(format: cond) {
            return predicate.evaluate(with: nil)
        }
        return false
    }
}
