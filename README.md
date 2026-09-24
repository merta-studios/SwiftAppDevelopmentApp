# App Builder für Swift Playgrounds

Dieses Repository enthält eine **echte Swift-Playgrounds-App**. Sie ist dependency-frei und kann direkt auf dem iPad geöffnet und gestartet werden.

## Direkt auf dem iPad öffnen

### Empfohlen: nur die fertige App herunterladen

1. Öffne auf GitHub die Datei **`AppBuilder.swiftpm.zip`** und lade sie herunter. Nicht den grünen **Code → Download ZIP**-Button verwenden.
2. Öffne die Downloads in der **Dateien-App** und tippe auf die ZIP-Datei, um sie zu entpacken.
3. Tippe auf den entstandenen Ordner **`AppBuilder.swiftpm`** beziehungsweise halte ihn gedrückt und wähle **Teilen → Swift Playgrounds**.
4. Swift Playgrounds öffnet die App. Danach einfach oben auf **Start** tippen.

### Wenn du das gesamte Repository herunterlädst

Nach dem Entpacken des Repository-ZIPs liegt im Ordner `SwiftAppDevelopmentApp-main` die Datei bzw. der Ordner **`AppBuilder.swiftpm`**. Öffne genau diesen Ordner in Swift Playgrounds – nicht den äußeren Repository-Ordner. Die Endung `.swiftpm` ist wichtig: Sie kennzeichnet das App-Paket, das Swift Playgrounds erwartet.

Es ist kein manuelles Kopieren der Swift-Dateien in ein neues Projekt nötig.

## Projektstruktur

```text
AppBuilder.swiftpm/                 direkt öffnbares Swift-Playgrounds-App-Paket
├── Package.swift                    App-Manifest mit iOSApplication-Produkt
├── AppBuilderApp.swift              App-Einstieg und Projekt-Sidebar
├── Models.swift                     Projekte, Blöcke, Farben und UI-Konstanten
├── ProjectStore.swift               lokale Speicherung, Import und Baum-Operationen
├── EditorView.swift                 Design-, Logic- und Block-Canvas
├── InspectorAndCodeView.swift       Inspector und Power-Code-Editor
├── PreviewView.swift                Fullscreen-Testvorschau
├── CodeGenerator.swift              SwiftUI-Codegenerator und Package-Export
└── FileDocuments.swift              Dateiimport und -export auf iPadOS

Package.swift / Sources/AppBuilder/  Entwicklungs-Kopie im Repository-Root
```

Der Root enthält die Dateien weiterhin für GitHub, Xcode und normale Swift-Package-Werkzeuge. Für Swift Playgrounds auf dem iPad ist **`AppBuilder.swiftpm`** die relevante Datei. Die ZIP-Datei enthält genau dieses Paket bereits mit der richtigen `.swiftpm`-Endung.

## Was enthalten ist

- Design-, Logic- und Swift-Modus
- verschachtelbare Layout-, Anzeige-, Eingabe- und Logic-Blöcke
- Inspector für Texte, SF Symbols, Farben und Verhalten
- lokale Speicherung auf dem iPad
- Import von Swift-Dateien und Swift-Projekten
- Fullscreen-Testvorschau
- Export einer echten Swift-Datei, eines `.swiftpm`-Packages und einer Projektsicherung
- keine externen Packages und keine Internetverbindung nötig

Die App verwendet Swift 5.9 und iOS 16. Swift Playgrounds übernimmt das Signieren für das eigene iPad.
