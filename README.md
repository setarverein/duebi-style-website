# Dübi Style Outlet – Website

Diese Website zeigt die aktuellen Angebote des Dübi Style Outlets. Sie basiert auf [Jekyll](https://jekyllrb.com), einem Generator für statische Webseiten.

Alle Produkte sind als einfache Textdateien im Ordner `_products/` hinterlegt. Produktfotos kommen in den Ordner `assets/img/products/`. Du brauchst keine Programmierkenntnisse, um Produkte zu verwalten.

---

## Produkte verwalten

### Neues Produkt hinzufügen

1. Erstelle eine neue Datei im Ordner `_products/`. Der Dateiname wird automatisch ein Teil der Web-Adresse – verwende **nur Kleinbuchstaben, Bindestriche und keine Sonderzeichen**.

   **Beispiel:** `nike-dunk-low.md` → erzeugt die Seite `https://duebi-style.ch/products/nike-dunk-low/`

2. Kopiere die folgende Vorlage in die neue Datei:

   ```yaml
   ---
   layout: product
   title: "Nike Dunk Low"
   price: 79.90
   discount_percent: 30
   category: "Footwear"
   featured: true
   image: /assets/img/products/nike-dunk-low.jpg
   ---

   Produktbeschreibung hier. Ein kurzer Text, der auf der Produktseite erscheint.
   ```

3. Fülle die Felder aus:

   | Feld | Bedeutung | Beispiel |
   |------|-----------|----------|
   | `title` | Produktname | `"Nike Dunk Low"` |
   | `price` | Reduzierter Preis in CHF (Punkt als Komma) | `79.90` |
   | `discount_percent` | Rabatt in Prozent (nur Zahl) | `30` |
   | `category` | Kategorie | `Footwear`, `Denim`, `Apparel`, `Accessories` |
   | `featured` | Für spätere Nutzung, immer `true` | `true` |
   | `image` | Pfad zum Produktfoto (siehe unten) | `/assets/img/products/nike-dunk-low.jpg` |
   | Text unter `---` | Produktbeschreibung (Deutsch) | Beliebig langer Text |

   > **Wichtig:** Der Originalpreis wird automatisch aus `price` und `discount_percent` berechnet. Du musst ihn nicht selbst eintragen.

4. Speichere die Datei. Das Produkt erscheint automatisch auf der Startseite und erhält eine eigene Detailseite.

### Produkt bearbeiten

1. Öffne die entsprechende Datei im Ordner `_products/`.
2. Ändere die gewünschten Werte (Preis, Rabatt, Beschreibung, usw.).
3. Speichere die Datei. Die Änderungen sind nach dem nächsten Build der Website sichtbar.

### Produkt löschen

Lösche einfach die `.md`-Datei im Ordner `_products/`. Das Produkt verschwindet von der Website.

### Produktfotos hinzufügen

1. Lege das Foto im Ordner `assets/img/products/` ab.
2. Benenne das Foto **genau gleich wie die Produktdatei** (mit `.jpg`-Endung):

   | Produktdatei | Foto |
   |--------------|------|
   | `_products/nike-dunk-low.md` | `assets/img/products/nike-dunk-low.jpg` |
   | `_products/levis-501-jeans.md` | `assets/img/products/levis-501-jeans.jpg` |

3. Trage im Produkt das Feld `image` ein (siehe Vorlage oben):

   ```yaml
   image: /assets/img/products/nike-dunk-low.jpg
   ```

   > **Tipp:** Verwende Fotos im Quer- oder Hochformat mit einer Auflösung von ca. 800×1000 Pixeln. Die Website schneidet sie automatisch auf das richtige Format zu.

---

## Website lokal anzeigen (Vorschau)

Bevor Änderungen live gehen, kannst du die Website bei dir auf dem Computer anschauen:

1. **Ruby installieren** (nur beim ersten Mal nötig):
   - Windows: [RubyInstaller](https://rubyinstaller.org/) herunterladen und installieren
   - macOS: Terminal öffnen und `brew install ruby` eingeben

2. **Jekyll installieren** (nur beim ersten Mal nötig):
   ```
   gem install bundler jekyll
   ```

3. **Abhängigkeiten installieren** (einmalig pro Projekt):
   ```
   bundle install
   ```

4. **Lokalen Server starten**:
   ```
   bundle exec jekyll serve
   ```

5. Browser öffnen und **http://localhost:4000** aufrufen.

Während der Server läuft, werden Änderungen an Dateien automatisch erkannt – die Seite lädt sich von selbst neu.

---

## Änderungen veröffentlichen

Die Website wird auf **https://duebi-style.ch** gehostet. Neue Produkte und Änderungen werden durch einen Build-Prozess veröffentlicht.

Sprich mit deinem Entwickler oder Administrator, um zu erfahren, wie der Build genau gestartet wird (z. B. über Git Push, Netlify, GitHub Pages oder einen manuellen Befehl).

---

## Ordner-Übersicht

| Ordner / Datei | Inhalt |
|----------------|--------|
| `_products/` | Alle Produkte (eine `.md`-Datei pro Produkt) |
| `assets/img/products/` | Alle Produktfotos |
| `_data/store.yml` | Laden-Informationen (Adresse, Öffnungszeiten, Telefon, Social Media) |
| `assets/css/main.scss` | Design und Farben der Website |
| `index.html` | Startseite |
