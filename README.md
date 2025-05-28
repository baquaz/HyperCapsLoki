<img src=".github/screen.png"/>

# HyperCapsLoki – A Native macOS Hyper Key Remapper

**Swift**: built with the latest Swift 6  
**Strict Concurrency Checking**: complete  
**License**: MIT  
**Integrity**: ✅ Verified with MD5A checksum  
**Build**: 100% Xcode compatible – no external tools  
**Tested on**: `MacbookPro (with Touch Bar)` keyboard, `Logitec MX Keys Mini` keyboard

---


## What is HyperCapsLoki?

HyperCapsLoki remaps your **Caps Lock** key into a powerful **Hyper Key** – a combination of:

- ⌘ **Command** (META)  
- ⌥ **Option**  (SUPER)  
- ⌃ **Control** (HYPER)  
- ⇧ **Shift**   (SHIFT)

This combo is triggered **only when Caps Lock is held down together with another key** 

- for example: `Caps Lock + h` or `Caps Lock + Space`.

If you just tap and release Caps Lock like usual, it behaves as the standard Caps Lock key — nothing changes.  


### Features

- 🧑‍💻 **Open Source** – no secrets here.
- 🖥️ **Fully Native** – written entirely in Swift with SwiftUI.
- 🧼 **No Third-Party Libraries** – zero dependencies.
- 🛠️ **Customizable** – configure which modifier keys are active.
- 🏃 **Auto-Launch** – start at login, silently.
- 📋 **Anonymous Diagnostic Logs** – logging for debugging with option to save logs in a file.

---

## Installation

You can get started in two ways:

- ✅ **Download the [release version]()** and run it like any other macOS app.
(You can verify the app with MD5A checksum for integrity)
- 🛠️ **Build it yourself** using Xcode – just clone this repo and hit Run.

No extra tools. No setup headaches.

## 🔐 Permissions & Accessibility

To capture key events, the app uses **macOS Accessibility APIs**. When launched, it:

- Checks whether it has permission.
- Prompts you to allow access if not granted - just plain macOS requirements.

**Monitoring service** tracks the permission state and updates the UI reactively.

> _Why?_ macOS restricts apps from monitoring keyboard input unless explicitly allowed, to protect user privacy.

---

## 🏗️ App Architecture

HyperCapsLoki is designed with maintainability and clarity in mind.

<details>
    <summary><b>Project Structure</b></summary>

<img src=".github/project-structure.png" width="800"/>

  - Clean separation between app, UI, logic, and logs.
  - Modular components with clear naming.
</details>

---

## ⌨️ Key Events and Mappings

HyperCapsLoki uses `CGEventTap` to intercept key events system-wide:

- Maps **Caps Lock** via its **HIDUsageCode** (e.g., `0x39`)
- Emits simulated modifier keys using **CarbonKeyCode** values.
- Clean abstraction layers match key events to app-defined key models.

```swift
// Example: Intercepting Caps Lock
```

> You’ll find a clean separation of domain logic from macOS internals.

---

## Diagnostic Logging

The app logs diagnostic events **anonymously** to help troubleshoot issues:

- Logs only capture behavior related to the app (e.g., remapping failures, event dispatch status).
- No personally identifiable data is ever stored or transmitted.

```swift
// Example: Logging system setup
```

You can easily inspect, filter, or save logs.

---

## Motivation

HyperCapsLoki started as a playground for:

- 🍏 Building my first real-world **macOS utility** app from scratch
- 🧱 Implementing a full **Clean SwiftUI** architecture
- 🧪 Exploring the new **Swift Testing Framework**
- 💬  Giving back to the macOS dev community with a tool that prioritizes transparency, and usefulness.

When building something that intercepts keyboard events, there's no room for ambiguity — the only way to earn full trust is to make the code open and inspectable.

That principle was the foundation of HyperCapsLoki: no hidden behavior, no third-party code — just a clean, native solution you can verify yourself.

---

## 🤝 Contribute

Ideas, issues, or improvements? PRs welcome.  
Open discussions if you have questions or suggestions!

---

## 📄 License

MIT – free to use, fork, and improve.
