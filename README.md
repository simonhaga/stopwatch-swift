## stopwatch-swift

Menu bar stopwatch for macOS, implemented as a Swift Package using Cocoa.

### Requirements

- **macOS**: 13.0 or later
- **Tools**: Xcode (with its bundled command line tools) or a Swift 6.2+ toolchain

### Clone

```bash
git clone https://github.com/your-username/stopwatch-swift.git
cd stopwatch-swift
```

### Run from the command line

From the project root:

```bash
swift run
```

This will build the executable target `stopwatch-swift` and launch it. The app runs as a **menu bar app**:

- You will not see a Dock icon or window.
- A new stopwatch item appears in the macOS menu bar showing `HH:MM:SS`.

### Using the app

From the menu bar icon:

- **Start / Stop**: Toggle the stopwatch.
- **Reset**: Reset to 00:00:00 (or the configured start time).
- **Set Start Time…**: Enter a custom starting value in `HH:MM:SS`.
- **Quit**: Exit the app.

### Open in Xcode

You can also open the package directly in Xcode:

1. Open Xcode.
2. Choose **File → Open…**.
3. Select the `Package.swift` file in this directory.
4. Build and run the `stopwatch-swift` scheme.

### Should the `Sources` folder be ignored?

No. **Do not ignore the `Sources` directory.**

In a Swift Package Manager project, `Sources/` contains all of your executable and library source code. It should be tracked in git and is required for the package to build. Your existing `.gitignore` is fine as-is and already ignores only build artifacts (`.build`, `DerivedData`, etc.), not the `Sources` folder.

