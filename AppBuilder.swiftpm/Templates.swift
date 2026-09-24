import Foundation
import SwiftUI

/// Ready-to-use rich app templates showcasing complete apps with state, logic, tweens, and multi-screens.
struct AppTemplates {
    static let all: [BuilderProject] = [
        clickerGame(),
        spaceArcade(),
        socialProfile(),
        focusTimer(),
        triviaQuiz()
    ]

    // MARK: - 1. Cyber Tap: Clicker Game
    static func clickerGame() -> BuilderProject {
        let homeElements: [AppElement] = [
            // Background glow shape
            AppElement(
                name: "glowBg",
                kind: .shape,
                x: 20, y: 40, width: 353, height: 750,
                colorHex: "#111827",
                backgroundColorHex: "#1E293B"
            ),
            // Title
            {
                var el = AppElement(name: "titleText", kind: .text, x: 40, y: 70, width: 313, height: 40, text: "CYBER TAP ⚡️")
                el.fontSize = 28
                el.fontWeight = .heavy
                el.textColorHex = "#00F5D4"
                return el
            }(),
            // Subtitle / Level
            {
                var el = AppElement(name: "levelBadge", kind: .badge, x: 130, y: 120, width: 133, height: 32, text: "LEVEL 1 • ROOKIE")
                el.colorHex = "#7B2CBF"
                el.textColorHex = "#FFFFFF"
                return el
            }(),
            // Animated Coin / Tap Target
            {
                var el = AppElement(name: "coinIcon", kind: .icon, x: 120, y: 180, width: 153, height: 153, text: "dollarsign.circle.fill")
                el.colorHex = "#FFD166"
                el.fontSize = 90
                el.onTapActions = [
                    AppAction(kind: .setVariable, targetVariable: "score", operation: .add, expression: "multiplier"),
                    AppAction(
                        kind: .tween,
                        tweenConfig: TweenConfig(targetName: "coinIcon", property: .scale, targetValue: 1.35, duration: 0.15, easing: .spring, isRelative: false, yoyo: true)
                    ),
                    AppAction(
                        kind: .tween,
                        tweenConfig: TweenConfig(targetName: "scoreLabel", property: .scale, targetValue: 1.25, duration: 0.12, easing: .spring, isRelative: false, yoyo: true)
                    ),
                    AppAction(kind: .playSound, sound: .coin, haptic: .medium),
                    AppAction(
                        kind: .conditional,
                        conditionExpression: "score >= 50",
                        thenActions: [
                            AppAction(kind: .confetti),
                            AppAction(kind: .navigate, targetScreenName: "Victory Screen", navigationStyle: .sheet)
                        ]
                    )
                ]
                return el
            }(),
            // Score Display
            {
                var el = AppElement(name: "scoreLabel", kind: .text, x: 40, y: 350, width: 313, height: 50, text: "Score: 0")
                el.fontSize = 32
                el.fontWeight = .bold
                el.textColorHex = "#00F5D4"
                el.boundVariable = "score"
                return el
            }(),
            // Progress Bar towards next level
            {
                var el = AppElement(name: "progressBar", kind: .progressBar, x: 50, y: 410, width: 293, height: 18, text: "Goal")
                el.colorHex = "#00F5D4"
                el.boundVariable = "score"
                el.minValue = 0
                el.maxValue = 50
                return el
            }(),
            // Upgrade Multiplier Button
            {
                var el = AppElement(name: "upgradeBtn", kind: .button, x: 60, y: 450, width: 273, height: 54, text: "⚡️ Upgrade Tap (+2 Power)")
                el.colorHex = "#7B2CBF"
                el.textColorHex = "#FFFFFF"
                el.onTapActions = [
                    AppAction(kind: .setVariable, targetVariable: "multiplier", operation: .add, expression: "2"),
                    AppAction(kind: .playSound, sound: .powerup, haptic: .heavy),
                    AppAction(
                        kind: .tween,
                        tweenConfig: TweenConfig(targetName: "upgradeBtn", property: .scale, targetValue: 1.1, duration: 0.15, easing: .spring, yoyo: true)
                    ),
                    AppAction(kind: .showNotification, notificationTitle: "Upgrade!", notificationMessage: "Your taps now give +2 more points!")
                ]
                return el
            }(),
            // Laser Zap Soundboard Button
            {
                var el = AppElement(name: "laserBtn", kind: .button, x: 60, y: 520, width: 130, height: 48, text: "💥 Zap Sound")
                el.colorHex = "#EF476F"
                el.textColorHex = "#FFFFFF"
                el.onTapActions = [
                    AppAction(kind: .playSound, sound: .laser, haptic: .heavy),
                    AppAction(kind: .tween, tweenConfig: TweenConfig(targetName: "laserBtn", property: .rotation, targetValue: 15, duration: 0.15, yoyo: true))
                ]
                return el
            }(),
            // Jump FX Button
            {
                var el = AppElement(name: "jumpBtn", kind: .button, x: 200, y: 520, width: 133, height: 48, text: "🦘 Whoosh")
                el.colorHex = "#118AB2"
                el.textColorHex = "#FFFFFF"
                el.onTapActions = [
                    AppAction(kind: .playSound, sound: .jump, haptic: .medium)
                ]
                return el
            }(),
            // Go to Shop Screen Button
            {
                var el = AppElement(name: "shopNavBtn", kind: .button, x: 60, y: 590, width: 273, height: 50, text: "🛍️ Open Cyber Shop →")
                el.colorHex = "#06D6A0"
                el.textColorHex = "#111827"
                el.onTapActions = [
                    AppAction(kind: .navigate, targetScreenName: "Shop Screen", navigationStyle: .push)
                ]
                return el
            }(),
            // Reset state
            {
                var el = AppElement(name: "resetBtn", kind: .button, x: 120, y: 660, width: 153, height: 40, text: "🔄 Reset Game")
                el.colorHex = "#4B5563"
                el.fontSize = 14
                el.onTapActions = [
                    AppAction(kind: .resetState),
                    AppAction(kind: .playSound, sound: .pop, haptic: .light)
                ]
                return el
            }()
        ]

        let victoryElements: [AppElement] = [
            AppElement(name: "vicTitle", kind: .text, x: 40, y: 120, width: 313, height: 60, text: "🏆 VICTORY! 🏆"),
            AppElement(name: "vicMsg", kind: .text, x: 40, y: 190, width: 313, height: 80, text: "You reached 50 points and conquered Cyber Tap!"),
            {
                var el = AppElement(name: "trophyIcon", kind: .icon, x: 130, y: 280, width: 133, height: 133, text: "trophy.fill")
                el.colorHex = "#FFD166"
                el.fontSize = 80
                return el
            }(),
            {
                var el = AppElement(name: "playAgainBtn", kind: .button, x: 60, y: 440, width: 273, height: 54, text: "🎮 Play Again")
                el.colorHex = "#00F5D4"
                el.textColorHex = "#111827"
                el.onTapActions = [
                    AppAction(kind: .resetState),
                    AppAction(kind: .navigate, targetScreenName: "Cyber Game", navigationStyle: .push)
                ]
                return el
            }()
        ]

        let shopElements: [AppElement] = [
            AppElement(name: "shopTitle", kind: .text, x: 40, y: 80, width: 313, height: 40, text: "🛍️ Cyber Power Shop"),
            {
                var el = AppElement(name: "item1", kind: .button, x: 40, y: 150, width: 313, height: 64, text: "💎 Diamond Auto-Clicker (+5)")
                el.colorHex = "#3B82F6"
                el.onTapActions = [
                    AppAction(kind: .setVariable, targetVariable: "multiplier", operation: .add, expression: "5"),
                    AppAction(kind: .playSound, sound: .powerup, haptic: .heavy),
                    AppAction(kind: .showNotification, notificationTitle: "Purchased!", notificationMessage: "Multiplier boosted by +5!")
                ]
                return el
            }(),
            {
                var el = AppElement(name: "item2", kind: .button, x: 40, y: 230, width: 313, height: 64, text: "🚀 Warp Speed Booster (+10)")
                el.colorHex = "#EC4899"
                el.onTapActions = [
                    AppAction(kind: .setVariable, targetVariable: "multiplier", operation: .add, expression: "10"),
                    AppAction(kind: .playSound, sound: .victory, haptic: .heavy),
                    AppAction(kind: .showNotification, notificationTitle: "Mega Boost!", notificationMessage: "Taps boosted by +10!")
                ]
                return el
            }(),
            {
                var el = AppElement(name: "backHomeBtn", kind: .button, x: 60, y: 340, width: 273, height: 50, text: "← Return to Game")
                el.colorHex = "#6B7280"
                el.onTapActions = [
                    AppAction(kind: .navigate, targetScreenName: "Cyber Game", navigationStyle: .push)
                ]
                return el
            }()
        ]

        let screens: [AppScreen] = [
            AppScreen(
                name: "Cyber Game",
                icon: "gamecontroller.fill",
                backgroundColorHex: "#0B0F19",
                elements: homeElements,
                variables: [
                    StateVariable(name: "score", type: .number, numberValue: 0),
                    StateVariable(name: "multiplier", type: .number, numberValue: 1),
                    StateVariable(name: "highScore", type: .number, numberValue: 0)
                ],
                flowX: 80, flowY: 100
            ),
            AppScreen(
                name: "Shop Screen",
                icon: "cart.fill",
                backgroundColorHex: "#111827",
                elements: shopElements,
                flowX: 380, flowY: 100
            ),
            AppScreen(
                name: "Victory Screen",
                icon: "trophy.fill",
                backgroundColorHex: "#1E1B4B",
                elements: victoryElements,
                flowX: 380, flowY: 340
            )
        ]

        return BuilderProject(
            name: "Cyber Tap Arcade",
            icon: "gamecontroller.fill",
            document: AppDocument(
                appName: "Cyber Tap Arcade",
                accentHex: "#00F5D4",
                theme: .neonCyber,
                screens: screens,
                globalVariables: [
                    StateVariable(name: "score", type: .number, numberValue: 0),
                    StateVariable(name: "multiplier", type: .number, numberValue: 1)
                ],
                notes: "An interactive clicker game with animated tweens, upgrades shop, audio synthesizer, and victory celebration."
            )
        )
    }

    // MARK: - 2. Neon Space Dodger
    static func spaceArcade() -> BuilderProject {
        let screens: [AppScreen] = [
            AppScreen(
                name: "Space Mission",
                icon: "airplane",
                backgroundColorHex: "#050814",
                elements: [
                    AppElement(name: "starsBg", kind: .shape, x: 20, y: 40, width: 353, height: 750, colorHex: "#0D1322"),
                    {
                        var el = AppElement(name: "gameTitle", kind: .text, x: 40, y: 70, width: 313, height: 36, text: "SPACE DEFENDER 🚀")
                        el.fontSize = 24
                        el.fontWeight = .heavy
                        el.textColorHex = "#38BDF8"
                        return el
                    }(),
                    // Player Ship
                    {
                        var el = AppElement(name: "playerShip", kind: .icon, x: 160, y: 380, width: 73, height: 73, text: "airplane")
                        el.colorHex = "#38BDF8"
                        el.fontSize = 50
                        return el
                    }(),
                    // Controls: Move Left, Fire Laser, Move Right
                    {
                        var el = AppElement(name: "btnLeft", kind: .button, x: 40, y: 520, width: 90, height: 50, text: "◀️ Left")
                        el.colorHex = "#1E293B"
                        el.onTapActions = [
                            AppAction(kind: .tween, tweenConfig: TweenConfig(targetName: "playerShip", property: .positionX, targetValue: -50, duration: 0.2, easing: .spring, isRelative: true, yoyo: false)),
                            AppAction(kind: .playSound, sound: .tap, haptic: .light)
                        ]
                        return el
                    }(),
                    {
                        var el = AppElement(name: "btnFire", kind: .button, x: 140, y: 520, width: 113, height: 50, text: "🔥 FIRE")
                        el.colorHex = "#EF4444"
                        el.onTapActions = [
                            AppAction(kind: .setVariable, targetVariable: "score", operation: .add, expression: "10"),
                            AppAction(kind: .playSound, sound: .laser, haptic: .heavy),
                            AppAction(kind: .tween, tweenConfig: TweenConfig(targetName: "playerShip", property: .positionY, targetValue: -20, duration: 0.1, yoyo: true))
                        ]
                        return el
                    }(),
                    {
                        var el = AppElement(name: "btnRight", kind: .button, x: 263, y: 520, width: 90, height: 50, text: "Right ▶️")
                        el.colorHex = "#1E293B"
                        el.onTapActions = [
                            AppAction(kind: .tween, tweenConfig: TweenConfig(targetName: "playerShip", property: .positionX, targetValue: 50, duration: 0.2, easing: .spring, isRelative: true, yoyo: false)),
                            AppAction(kind: .playSound, sound: .tap, haptic: .light)
                        ]
                        return el
                    }(),
                    // Health bar
                    {
                        var el = AppElement(name: "healthBar", kind: .progressBar, x: 40, y: 130, width: 313, height: 18, text: "Shields")
                        el.colorHex = "#22C55E"
                        el.boundVariable = "health"
                        el.minValue = 0
                        el.maxValue = 100
                        return el
                    }(),
                    // Score text
                    {
                        var el = AppElement(name: "scoreTxt", kind: .text, x: 40, y: 160, width: 313, height: 32, text: "Enemies Destroyed: 0")
                        el.textColorHex = "#FBBF24"
                        el.boundVariable = "score"
                        return el
                    }()
                ],
                variables: [
                    StateVariable(name: "score", type: .number, numberValue: 0),
                    StateVariable(name: "health", type: .number, numberValue: 100)
                ]
            )
        ]

        return BuilderProject(
            name: "Neon Space Dodger",
            icon: "airplane",
            document: AppDocument(
                appName: "Neon Space Dodger",
                accentHex: "#38BDF8",
                screens: screens,
                globalVariables: [StateVariable(name: "score", type: .number, numberValue: 0)]
            )
        )
    }

    // MARK: - 3. Nova Social: Profile & Feed
    static func socialProfile() -> BuilderProject {
        let screens: [AppScreen] = [
            AppScreen(
                name: "Feed",
                icon: "person.crop.circle.fill",
                backgroundColorHex: "#F8FAFC",
                elements: [
                    // Avatar & Header
                    {
                        var el = AppElement(name: "avatarIcon", kind: .icon, x: 155, y: 60, width: 83, height: 83, text: "person.crop.circle.fill")
                        el.colorHex = "#6366F1"
                        el.fontSize = 72
                        return el
                    }(),
                    {
                        var el = AppElement(name: "userName", kind: .text, x: 40, y: 150, width: 313, height: 30, text: "Alex Rivera ✦")
                        el.fontSize = 22
                        el.fontWeight = .bold
                        el.textColorHex = "#0F172A"
                        return el
                    }(),
                    {
                        var el = AppElement(name: "userBio", kind: .text, x: 40, y: 185, width: 313, height: 24, text: "Creative Coder & App Designer")
                        el.fontSize = 14
                        el.textColorHex = "#64748B"
                        return el
                    }(),
                    // Followers Badge
                    {
                        var el = AppElement(name: "followersPill", kind: .badge, x: 120, y: 220, width: 153, height: 36, text: "1.2K Followers")
                        el.colorHex = "#6366F1"
                        el.textColorHex = "#FFFFFF"
                        return el
                    }(),
                    // Feed Card
                    AppElement(name: "feedCard", kind: .shape, x: 30, y: 270, width: 333, height: 300, colorHex: "#FFFFFF", backgroundColorHex: "#FFFFFF"),
                    {
                        var el = AppElement(name: "cardTitle", kind: .text, x: 50, y: 290, width: 293, height: 28, text: "Building my first Swift App! 🚀")
                        el.fontSize = 17
                        el.fontWeight = .bold
                        el.textColorHex = "#0F172A"
                        return el
                    }(),
                    {
                        var el = AppElement(name: "cardBody", kind: .text, x: 50, y: 325, width: 293, height: 60, text: "Created entirely inside App Builder with freeform canvas drag-and-drop & Lua scripting.")
                        el.fontSize = 14
                        el.textColorHex = "#475569"
                        return el
                    }(),
                    // Heart Like Button with Spring Tween & Audio
                    {
                        var el = AppElement(name: "heartBtn", kind: .button, x: 50, y: 490, width: 130, height: 46, text: "❤️ Like (0)")
                        el.colorHex = "#EF4444"
                        el.textColorHex = "#FFFFFF"
                        el.boundVariable = "likes"
                        el.onTapActions = [
                            AppAction(kind: .setVariable, targetVariable: "likes", operation: .add, expression: "1"),
                            AppAction(kind: .playSound, sound: .pop, haptic: .medium),
                            AppAction(
                                kind: .tween,
                                tweenConfig: TweenConfig(targetName: "heartBtn", property: .scale, targetValue: 1.3, duration: 0.18, easing: .spring, yoyo: true)
                            )
                        ]
                        return el
                    }(),
                    // Edit Profile Nav
                    {
                        var el = AppElement(name: "editNavBtn", kind: .button, x: 195, y: 490, width: 150, height: 46, text: "⚙️ Edit Profile")
                        el.colorHex = "#475569"
                        el.textColorHex = "#FFFFFF"
                        el.onTapActions = [
                            AppAction(kind: .navigate, targetScreenName: "Edit Profile", navigationStyle: .sheet)
                        ]
                        return el
                    }()
                ],
                variables: [StateVariable(name: "likes", type: .number, numberValue: 0)]
            ),
            AppScreen(
                name: "Edit Profile",
                icon: "slider.horizontal.3",
                backgroundColorHex: "#FFFFFF",
                elements: [
                    AppElement(name: "sheetTitle", kind: .text, x: 40, y: 60, width: 313, height: 36, text: "Edit Profile"),
                    {
                        var el = AppElement(name: "nameInput", kind: .textField, x: 40, y: 120, width: 313, height: 44, text: "Alex Rivera")
                        el.boundVariable = "userName"
                        return el
                    }(),
                    {
                        var el = AppElement(name: "bioInput", kind: .textField, x: 40, y: 180, width: 313, height: 44, text: "Developer")
                        el.boundVariable = "userBio"
                        return el
                    }(),
                    {
                        var el = AppElement(name: "saveBtn", kind: .button, x: 40, y: 260, width: 313, height: 50, text: "Save Changes")
                        el.colorHex = "#6366F1"
                        el.onTapActions = [
                            AppAction(kind: .playSound, sound: .chime, haptic: .success),
                            AppAction(kind: .navigate, targetScreenName: "Feed", navigationStyle: .push)
                        ]
                        return el
                    }()
                ]
            )
        ]

        return BuilderProject(
            name: "Nova Social Profile",
            icon: "person.crop.circle.fill",
            document: AppDocument(
                appName: "Nova Social",
                accentHex: "#6366F1",
                screens: screens,
                globalVariables: [
                    StateVariable(name: "likes", type: .number, numberValue: 0),
                    StateVariable(name: "userName", type: .text, textValue: "Alex Rivera"),
                    StateVariable(name: "userBio", type: .text, textValue: "App Creator")
                ]
            )
        )
    }

    // MARK: - 4. Focus Flow: Pomodoro Timer
    static func focusTimer() -> BuilderProject {
        let screens: [AppScreen] = [
            AppScreen(
                name: "Timer",
                icon: "timer",
                backgroundColorHex: "#0F172A",
                elements: [
                    AppElement(name: "clockBg", kind: .shape, x: 30, y: 40, width: 333, height: 750, colorHex: "#1E293B"),
                    {
                        var el = AppElement(name: "appHeading", kind: .text, x: 40, y: 80, width: 313, height: 40, text: "FOCUS FLOW ⏳")
                        el.fontSize = 26
                        el.fontWeight = .heavy
                        el.textColorHex = "#F43F5E"
                        return el
                    }(),
                    {
                        var el = AppElement(name: "timerIcon", kind: .icon, x: 140, y: 160, width: 113, height: 113, text: "timer")
                        el.colorHex = "#F43F5E"
                        el.fontSize = 72
                        return el
                    }(),
                    {
                        var el = AppElement(name: "timerNumber", kind: .text, x: 40, y: 300, width: 313, height: 64, text: "25:00")
                        el.fontSize = 48
                        el.fontWeight = .bold
                        el.textColorHex = "#FFFFFF"
                        return el
                    }(),
                    // Start Button
                    {
                        var el = AppElement(name: "startBtn", kind: .button, x: 60, y: 400, width: 273, height: 56, text: "▶️ START FOCUS SESSION")
                        el.colorHex = "#F43F5E"
                        el.textColorHex = "#FFFFFF"
                        el.onTapActions = [
                            AppAction(kind: .playSound, sound: .chime, haptic: .heavy),
                            AppAction(kind: .setVariable, targetVariable: "completedSessions", operation: .add, expression: "1"),
                            AppAction(
                                kind: .tween,
                                tweenConfig: TweenConfig(targetName: "timerIcon", property: .rotation, targetValue: 360, duration: 1.0, easing: .easeInOut, yoyo: false)
                            ),
                            AppAction(kind: .showNotification, notificationTitle: "Session Started", notificationMessage: "Stay focused for the next 25 minutes!")
                        ]
                        return el
                    }(),
                    // Completed Count
                    {
                        var el = AppElement(name: "sessionsBadge", kind: .badge, x: 100, y: 480, width: 193, height: 36, text: "Sessions Done: 0")
                        el.colorHex = "#334155"
                        el.textColorHex = "#38BDF8"
                        el.boundVariable = "completedSessions"
                        return el
                    }()
                ],
                variables: [StateVariable(name: "completedSessions", type: .number, numberValue: 0)]
            )
        ]

        return BuilderProject(
            name: "Focus Flow Pomodoro",
            icon: "timer",
            document: AppDocument(
                appName: "Focus Flow",
                accentHex: "#F43F5E",
                screens: screens,
                globalVariables: [StateVariable(name: "completedSessions", type: .number, numberValue: 0)]
            )
        )
    }

    // MARK: - 5. Trivia Quiz App
    static func triviaQuiz() -> BuilderProject {
        let screens: [AppScreen] = [
            AppScreen(
                name: "Quiz Question",
                icon: "questionmark.circle.fill",
                backgroundColorHex: "#312E81",
                elements: [
                    AppElement(name: "quizTitle", kind: .text, x: 40, y: 70, width: 313, height: 36, text: "🧠 SWIFT TRIVIA"),
                    AppElement(name: "questionCard", kind: .shape, x: 30, y: 130, width: 333, height: 160, colorHex: "#4338CA"),
                    {
                        var el = AppElement(name: "questionText", kind: .text, x: 45, y: 160, width: 303, height: 90, text: "What keyword defines an immutable constant in Swift?")
                        el.fontSize = 20
                        el.fontWeight = .bold
                        el.textColorHex = "#FFFFFF"
                        return el
                    }(),
                    // Option A (Correct)
                    {
                        var el = AppElement(name: "optA", kind: .button, x: 40, y: 320, width: 313, height: 54, text: "A) let")
                        el.colorHex = "#4F46E5"
                        el.textColorHex = "#FFFFFF"
                        el.onTapActions = [
                            AppAction(kind: .setVariable, targetVariable: "quizScore", operation: .add, expression: "10"),
                            AppAction(kind: .playSound, sound: .victory, haptic: .success),
                            AppAction(kind: .confetti),
                            AppAction(
                                kind: .tween,
                                tweenConfig: TweenConfig(targetName: "optA", property: .scale, targetValue: 1.15, duration: 0.2, easing: .spring, yoyo: true)
                            ),
                            AppAction(kind: .showNotification, notificationTitle: "Correct! 🎉", notificationMessage: "+10 points awarded! 'let' creates immutable constants.")
                        ]
                        return el
                    }(),
                    // Option B (Incorrect)
                    {
                        var el = AppElement(name: "optB", kind: .button, x: 40, y: 390, width: 313, height: 54, text: "B) var")
                        el.colorHex = "#3730A3"
                        el.textColorHex = "#E0E7FF"
                        el.onTapActions = [
                            AppAction(kind: .playSound, sound: .failure, haptic: .error),
                            AppAction(
                                kind: .tween,
                                tweenConfig: TweenConfig(targetName: "optB", property: .positionX, targetValue: 15, duration: 0.1, yoyo: true, repeatCount: 3)
                            ),
                            AppAction(kind: .showNotification, notificationTitle: "Oops!", notificationMessage: "'var' is used for mutable variables, not constants.")
                        ]
                        return el
                    }(),
                    // Option C (Incorrect)
                    {
                        var el = AppElement(name: "optC", kind: .button, x: 40, y: 460, width: 313, height: 54, text: "C) const")
                        el.colorHex = "#3730A3"
                        el.textColorHex = "#E0E7FF"
                        el.onTapActions = [
                            AppAction(kind: .playSound, sound: .failure, haptic: .error),
                            AppAction(kind: .showNotification, notificationTitle: "Oops!", notificationMessage: "'const' is from JavaScript/C++, Swift uses 'let'!")
                        ]
                        return el
                    }(),
                    // Score Tracker
                    {
                        var el = AppElement(name: "scoreTxt", kind: .text, x: 40, y: 550, width: 313, height: 40, text: "Score: 0 Points")
                        el.textColorHex = "#A5B4FC"
                        el.boundVariable = "quizScore"
                        return el
                    }()
                ],
                variables: [StateVariable(name: "quizScore", type: .number, numberValue: 0)]
            )
        ]

        return BuilderProject(
            name: "Trivia Quest Quiz",
            icon: "questionmark.circle.fill",
            document: AppDocument(
                appName: "Trivia Quest",
                accentHex: "#6366F1",
                screens: screens,
                globalVariables: [StateVariable(name: "quizScore", type: .number, numberValue: 0)]
            )
        )
    }
}
