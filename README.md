````markdown
# Flutter Playground ⚡️

> **Stop rebuilding. Start tweaking.**

A real-time component playground for Flutter. Tweak properties on a web dashboard and see changes instantly on your device—without recompiling or hot reloading.

---

## 🚀 Why?
Flutter's hot reload is fast, but tweaking UI values (padding, colors, alignment) still requires:
1. Changing code
2. Saving
3. Waiting for frame update
4. Repeating x100

**Flutter Playground** solves this by creating a live link between your app and a web dashboard.

## ✨ Features
* **📱 Live Property Editing:** Tweak padding, colors, and text in real-time.
* **🖥️ Responsive Grid View:** See Mobile, Tablet, and Desktop layouts side-by-side.
* **⚡️ Zero-Setup:** Auto-detects your device IP (or works via localhost).
* **📋 Code Export:** Copy the generated Dart code directly from the dashboard.

## 📦 Installation

**Step 1:** Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_playground:
    git:
      url: [https://github.com/rajparihar281/flutter_playground.git](https://github.com/rajparihar281/flutter_playground.git)
````

**Step 2:** Android Permission (Required for local web server)

Add this to your `android/app/src/main/AndroidManifest.xml` (above the `<application>` tag):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## ⚡️ Quick Start

Wrap any widget you want to inspect with Playground:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_playground/flutter_playground.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Playground(
      builder: (context, values) {
        // 1. Get values from the dashboard (with defaults)
        final double padding = (values['padding'] as num?)?.toDouble() ?? 10.0;
        
        return Container(
          padding: EdgeInsets.all(padding),
          child: Text("Edit me live!"),
        );
      },
    );
  }
}
```

**Run your app:** Check the console logs for the dashboard link:

```plaintext
⚡️ Playground Server running on [http://0.0.0.0:8080](http://0.0.0.0:8080)
👉 [http://192.168.1.5:8080](http://192.168.1.5:8080)
```

## 🛠 Tech Stack

  * **Shelf:** Lightweight web server running inside the Flutter app.
  * **WebSockets:** Real-time bi-directional communication.
  * **HTML/JS:** Zero-dependency dashboard (served directly from Dart).

## 📄 License

MIT

```
```
