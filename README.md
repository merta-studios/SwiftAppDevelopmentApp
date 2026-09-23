# App Builder für Swift Playgrounds

Eine iPad-App, mit der man SwiftUI-Apps visuell wie in Scratch oder Roblox Studio zusammenbauen kann. Das Projekt ist absichtlich dependency-frei und liegt als Swift-Package-App vor, damit es direkt in **Swift Playgrounds auf dem iPad** geöffnet werden kann.

## Auf dem iPad öffnen

1. In der GitHub-App oder in Swift Playgrounds dieses Repository laden.
2. Den Ordner mit `Package.swift` öffnen. Falls Swift Playgrounds nach dem Öffnen fragt, **App** bzw. **Swift Package** auswählen.
3. Ein paar Sekunden kompilieren lassen und die App starten.

Das Projekt verwendet Swift 5.9 und iOS 16 als Mindestversion. Es braucht keine Internetverbindung und keine externen Pakete. Ein Team Identifier ist absichtlich leer: Swift Playgrounds übernimmt das Signieren für das eigene iPad.

## Was schon enthalten ist

- **Projektzentrale:** mehrere Projekte, Duplizieren, Löschen, Suchen und automatisches lokales Speichern in `Application Support`.
- **Block-Bibliothek:** Layout-, Anzeige-, Eingabe-, Logik- und Power-Blöcke. Blöcke werden verschachtelt und können nach oben oder unten bewegt, dupliziert und gelöscht werden.
- **Inspector:** Texte, SF-Symbol-Namen, Farben als Hex-Wert, Bedingungen, Wiederholungen, Button-Aktionen und Zustände ohne Swift-Syntax bearbeiten.
- **Logic-Modus:** Events, Zustände, `If`/`else` und Wiederholungen wie Scratch-Bausteine.
- **Power code:** ein bewusst eingebauter Fluchtweg. Beliebiger Swift-/SwiftUI-Code bleibt erhalten und wird bei visuellen Änderungen nicht überschrieben. Dadurch wird die visuelle Oberfläche nicht zu einer künstlichen Grenze: APIs, Frameworks und Funktionen, die Swift kann, können weiterhin benutzt werden.
- **Live-Test:** Die visuelle App läuft in einer Fullscreen-Preview. Der Stop-Knopf ist absichtlich klein, halbtransparent und oben rechts, damit er beim Testen nicht stört.
- **Import:** `.swift`-Dateien sowie Ordner mit Swift-Quellen, `.playground`-Ordner und Swift-Package-Projekte können importiert werden. Der Quelltext wird verlustfrei in **Power code** abgelegt; die automatische Vorschau ist bei importiertem, beliebigem Swift naturgemäß nur ein Startbildschirm.
- **Export:**
  - eine echte `.swift`-Datei mit gewöhnlichem SwiftUI-Code,
  - ein `.swiftpm`-Package, das wieder in Swift Playgrounds geöffnet werden kann,
  - eine `.appbuilder.json`-Sicherung für das visuelle Projekt.

## Die wichtigen Dateien

```text
Package.swift                         Swift-Playgrounds-App-Paket
Sources/AppBuilder/AppBuilderApp.swift App-Einstieg und Projekt-Sidebar
Sources/AppBuilder/Models.swift        Projekte, Blöcke, Farben und UI-Konstanten
Sources/AppBuilder/ProjectStore.swift  lokale Speicherung, Import und Baum-Operationen
Sources/AppBuilder/EditorView.swift    Design-, Logic- und Block-Canvas-Oberfläche
Sources/AppBuilder/InspectorAndCodeView.swift Inspector und Power-code-Editor
Sources/AppBuilder/PreviewView.swift   fullscreen Runtime-Vorschau
Sources/AppBuilder/CodeGenerator.swift SwiftUI-Codegenerator und Package-Export
Sources/AppBuilder/FileDocuments.swift File-Import/-Export für iPadOS
```

## Bedienung in einer Minute

1. Mit **New** ein Projekt erstellen.
2. Im **Design**-Tab links einen Block antippen. Er wird in den ausgewählten Block gelegt; ohne Auswahl landet er auf der Home-Screen.
3. Im Canvas einen Block auswählen und rechts im Inspector bearbeiten. Über `…` lassen sich Blöcke verschieben oder duplizieren.
4. Im **Logic**-Tab Logik-Blöcke einfügen. Komplexe Spezialfälle kommen in **Power code**.
5. **Test** öffnet die App fullscreen. Mit dem kleinen Kreis oben rechts zurückkehren.
6. Über **Export → Swift Playgrounds package** ein eigenständiges, normales SwiftUI-Projekt erzeugen.

## Design-Entscheidung: visuell einfach, technisch ohne harte Decke

Eine Blocksprache kann nicht jede einzelne zukünftige Apple-API sinnvoll als Block vorwegnehmen. Deshalb ist App Builder hybrid: Die häufigen Dinge sind extrem einfach und visuell, während **Power code** jederzeit echten Swift-Code erlaubt. Der Export erzeugt keinen proprietären Interpreter, sondern lesbaren SwiftUI-Code. So kann ein Projekt in Swift Playgrounds weiterentwickelt werden, ohne in App Builder eingeschlossen zu sein.

Die Preview ist ein sicherer, sofortiger visueller Runtime-Renderer für die unterstützten Bausteine. Der exportierte Swift-Code ist dagegen der echte Code für Swift Playgrounds. Das trennt schnelles Ausprobieren von der späteren, vollständig erweiterbaren App.
