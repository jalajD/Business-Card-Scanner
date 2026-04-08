# Business Card Scanner

An iOS app that digitizes physical business cards using OCR. Snap a photo of any business card and the app automatically extracts contact details — name, company, job title, email, phone, website, and address — and saves them locally on your device.

---

## Demo


---

## Features

- **Scan business cards** using the device camera or select from the photo library
- **OCR text extraction** powered by Google ML Kit
- **Smart parsing** — automatically identifies email, phone, website, job title, company, and address from raw text
- **Manual editing** — review and correct any extracted field before saving
- **Local storage** — all data stored on-device with Core Data, no cloud required
- **Search** — filter saved cards by name, company, email, or phone in real time
- **Delete** — swipe to delete or use edit mode for batch deletion

---

## Screenshots

| Card List | Scan Options | Edit Card | Card Detail |
|-----------|-------------|-----------|-------------|
| _(add screenshot)_ | _(add screenshot)_ | _(add screenshot)_ | _(add screenshot)_ |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| OCR | Google ML Kit — TextRecognition v4.0.0 |
| Persistence | Core Data (SQLite + external binary storage) |
| Camera / Photo Library | UIKit — UIImagePickerController |
| Dependency Manager | CocoaPods |
| Minimum iOS | 15.0 |

---

## Project Structure

```
Business-Card-Scanner/
├── Business_Card_ScannerApp.swift   # App entry point, Core Data setup
├── ContentView.swift                # Main list view with search
├── ScanBusinessCardView.swift       # Scan entry point (camera or gallery)
├── CameraView.swift                 # UIImagePickerController wrappers
├── TextRecognitionService.swift     # ML Kit OCR service
├── BusinessCardParser.swift         # Regex-based text parser
├── BusinessCardDetailView.swift     # Read-only detail view
├── BusinessCardEditView.swift       # Form for creating / editing cards
├── Persistence.swift                # Core Data stack
└── Business_Card_Scanner.xcdatamodeld/
    └── BusinessCard entity          # name, company, jobTitle, email,
                                     # phone, website, address, notes,
                                     # rawText, imageData, createdAt
```

---

## Requirements

- Xcode 14+
- iOS 15.0+
- CocoaPods

---

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Business-Card-Scanner.git
   cd Business-Card-Scanner
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Open the workspace** (not the `.xcodeproj`)
   ```bash
   open Business-Card-Scanner.xcworkspace
   ```

4. **Build and run** on a physical device or simulator (iOS 15+)

> Camera functionality requires a physical device. The photo library picker works on the simulator.

---

## How It Works

1. Tap **+** to start scanning
2. Choose **Take Photo** or **Choose from Library**
3. The app runs **ML Kit OCR** on the image to extract all visible text
4. **BusinessCardParser** applies regex patterns to identify:
   - Email addresses
   - Phone numbers (international, US, and various formats)
   - URLs and websites
   - Job titles (matched against a keyword list)
   - Name (first non-empty line)
   - Company (second line or fallback logic)
   - Address (remaining unclassified lines)
5. Results appear in an **editable form** — review and correct anything
6. Tap **Save** to store the card with its photo in Core Data

---

## Dependencies

Managed via CocoaPods:

```ruby
pod 'GoogleMLKit/TextRecognition', '~> 4.0.0'
```

---

## License

MIT
