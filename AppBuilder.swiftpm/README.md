# App Builder Studio für iPad & Swift Playgrounds 🚀

Eine vollwertige, moderne App-Entwicklungs-App für Swift Playgrounds auf iPadOS und macOS. Erstelle **echte, komplett fertige Apps** mit freier Gestaltungsfläche (Scratch-/Figma-Style), 60-FPS-Tweening-Animationen, Sound-Synthesizer, reaktiven Variablen, Multi-Screen-Navigation und Lua-/Swift-Scripting.

---

## 🌟 Neu & Highlights

1. **Freie Canvas-Fläche (Scratch / Figma Drag & Drop)**:
   - Große, unendliche Gestaltungsfläche mit Pan & Zoom (40% - 200%).
   - Elemente komplett **frei verschieben** (X / Y Koordinaten), nicht nur statische Stacks!
   - Live-Resize-Handles (Breite & Höhe direkt auf dem Canvas skalieren) und Rotationsgriffe.
   - Intelligentes 10px Raster-Snapping & Ausrichtungs-Werkzeuge (Links, Zentriert, Rechts, Oben, Unten).
   - Ausrichtung nach Device-Frames (z. B. iPhone 15 Pro Display-Rahmen).

2. **Objekt-Namen & Identifikatoren**:
   - Jedes Objekt (Button, Icon, Card, Label, Slider) erhält einen **eindeutigen Namen** (z. B. `scoreLabel`, `coinIcon`, `playerShip`, `upgradeBtn`).
   - Objekte können direkt in Skripten, Tweens und Bedingungen über ihren Namen referenziert werden.

3. **Echtes Tweening & Animation Engine (60 FPS)**:
   - Flüssige Tweens für Position (X/Y), Skalierung, Rotation, Deckkraft (Opacity), Breite, Höhe und Eckenradius.
   - Konfigurierbare Easing-Kurven: `Spring (Bouncy)`, `Ease In-Out`, `Bounce`, `Linear`, `Ease Out`.
   - Yoyo-Effekt (automatisches Zurückspringen) und Wiederholungen.

4. **Integrierter Audio-Synthesizer & Haptik (Zero-Dependency)**:
   - Echtzeit-Klangsynthese ohne externe Audiodateien: `Coin / Ding`, `Laser Zap`, `Jump Whoosh`, `Pop`, `Power Up`, `Victory Fanfare`, `Fail / Game Over`, `Button Click`, `Chime`.
   - Echtes iOS Taptic Engine Feedback: `Light`, `Medium`, `Heavy`, `Success`, `Warning`, `Error`, `Selection`.

5. **Multi-Screen Support & Screen Flow Map**:
   - Apps mit beliebig vielen Screens (z. B. *Home*, *Game*, *Shop*, *Settings*, *Victory Screen*).
   - Bird's-Eye **Flow Map** mit interaktiven Verbindungslinien (Navigation Wires).
   - Navigation via Push, Sheet-Modal oder Crossfade.

6. **Lua-like & Swift Scripting Engine**:
   - Echte interaktive Logik:
     ```lua
     score = score + 1
     playSound("coin")
     tween("coinIcon", "scale", 1.4, 0.15)
     if score >= 50 then
         playSound("victory")
         confetti()
         navigate("Victory Screen")
     end
     ```
   - Mathematische Ausdrücke, Zufallsgeneratoren (`random(1, 10)`), String-Konkatenation und Verzweigungen.

7. **Fix für Tastatur / Text-Eingaben**:
   - Eigene `BufferedTextField`-Komponenten mit FocusState und stabiler State-Pufferung.
   - Die Bildschirmtastatur öffnet sich sofort beim Antippen und schließt sich nicht mehr unbeabsichtigt während des Tippens.

8. **5 Fertige App-Templates zum sofortigen Ausprobieren**:
   - 🎮 **Cyber Tap Arcade**: Clicker-Game mit animierter Münze, Soundboard, Shop-Upgrades und Sieges-Konfetti.
   - 🚀 **Neon Space Dodger**: Retro Space Arcade Game mit Laser-Sounds, Touch-Steuerung und Schild-Anzeige.
   - 📸 **Nova Social Profile**: Multi-Screen Social App mit Story-Circles, animiertem Like-Button (Heart-Bounce + Pop Sound) und Profil-Editor.
   - ⏱️ **Focus Flow Pomodoro**: Task-Manager mit animiertem Timer, Sound-Alarmen und Session-Tracker.
   - 🧠 **Trivia Quest Quiz**: Interaktives Wissensquiz mit Sofort-Feedback, Punktezähler und Sound-Effekten.

9. **Produktionsreifer SwiftUI Code Export**:
   - Exportiert reinen, sofort kompilierbaren SwiftUI-Code mit `@State`, `withAnimation`, `.offset()`, `NavigationStack` und eingebautem Sound-Synthesizer.
   - Export als `.swiftpm` App-Paket für Swift Playgrounds oder `.swift` Einzeldatei.

---

## 📱 Direkt auf dem iPad öffnen

1. Lade die Datei **`AppBuilder.swiftpm.zip`** herunter.
2. In der **Dateien-App** auf die ZIP-Datei tippen, um sie zu entpacken.
3. Den Ordner **`AppBuilder.swiftpm`** teilen mit **Swift Playgrounds**.
4. In Swift Playgrounds öffnen und auf **Start (Play)** tippen!

---

## 📂 Projektstruktur

```text
AppBuilder.swiftpm/                 Swift-Playgrounds-App-Paket
├── Package.swift                    Manifest für Swift Playgrounds 4 / iOS 16+
├── AppBuilderApp.swift              App Entry, Sidebar & Template-Galerie
├── Models.swift                     AppElement, AppScreen, AppAction, TweenConfig, StateVariable
├── FreeformCanvasView.swift         Freie Drag-and-Drop Arbeitsfläche mit Handles & Snapping
├── InspectorViews.swift             Property Inspector mit Tastatur-Fix & Tween-Editor
├── ScreenFlowMapView.swift          Multi-Screen Node Map mit visuellen Links
├── LogicEditorView.swift            Reaktiver Variablen-Manager & Script Editor
├── PreviewView.swift                Interaktiver 60-FPS Simulator mit Audio & Konfetti
├── SoundManager.swift               Offline Waveform Synthesizer & Taptic Engine
├── ScriptEngine.swift               Aktions-Pipeline, Lua-Parser & Tween-Controller
├── Templates.swift                  5 fertige Starter-Apps (Game, Social, Timer, Quiz)
├── CodeGenerator.swift              Exportiert sauberes, produktionsreifes SwiftUI
├── ProjectStore.swift               Lokale Speicherung & Undo/Redo State Store
├── FileDocuments.swift              Import/Export von .swiftpm, .swift und .json
└── README.md
```
