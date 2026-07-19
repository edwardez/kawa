import Carbon
import Cocoa

class InputSource {
  let tisInputSource: TISInputSource
  let icon: NSImage?

  var id: String {
    return tisInputSource.id
  }

  var name: String {
    return tisInputSource.name
  }

  init(tisInputSource: TISInputSource) {
    self.tisInputSource = tisInputSource

    var iconImage: NSImage? = nil

    if let imageURL = tisInputSource.iconImageURL {
      for url in [imageURL.retinaImageURL, imageURL.tiffImageURL, imageURL] {
        if let image = NSImage(contentsOf: url) {
          iconImage = image
          break
        }
      }
    }

    if iconImage == nil, let iconRef = tisInputSource.iconRef {
      iconImage = NSImage(iconRef: iconRef)
    }

    self.icon = iconImage
  }

  var isCJKV: Bool {
    if let lang = tisInputSource.sourceLanguages.first {
      return lang == "ko" || lang == "ja" || lang == "vi" || lang.hasPrefix("zh")
    }
    return false
  }

  func select() {
    if InputSource.current()?.id == id {
      return
    }

    TISSelectInputSource(tisInputSource)

    // TISSelectInputSource updates the menu bar immediately, but CJKV input
    // methods don't take over the focused app's input context until a focus
    // change occurs, so keystrokes keep going to the previous input source.
    // Briefly stealing key-window focus forces the context to re-sync.
    // Adapted from macism, MIT License, (c) laishulu:
    // https://github.com/laishulu/macism
    if isCJKV {
      InputSource.forceInputContextRefresh()
    }
  }
}

extension InputSource: Equatable {
  static func == (lhs: InputSource, rhs: InputSource) -> Bool {
    return lhs.id == rhs.id
  }
}

extension InputSource {
  // Empirically the smallest fully-stable wait for the CJK race on recent
  // macOS (matches macism's default).
  private static let refreshWaitMs = 150

  static func current() -> InputSource? {
    let tis = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    return InputSource(tisInputSource: tis)
  }

  static func forceInputContextRefresh() {
    guard let screen = NSScreen.main else { return }

    let previousApp = NSWorkspace.shared.frontmostApplication
    AppDelegate.suppressActivationBehavior = true

    let frame = screen.visibleFrame
    let window = NSWindow(
      contentRect: NSRect(x: frame.maxX - 11, y: frame.minY + 8, width: 3, height: 3),
      styleMask: [.titled], // a borderless window can never become key
      backing: .buffered,
      defer: false
    )
    window.titlebarAppearsTransparent = true
    window.level = .screenSaver
    window.collectionBehavior = [.canJoinAllSpaces, .stationary]
    window.isReleasedWhenClosed = false
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(refreshWaitMs)) {
      window.close()
      let target = previousApp ?? NSWorkspace.shared.menuBarOwningApplication
      _ = target?.activate(options: [])
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
        AppDelegate.suppressActivationBehavior = false
      }
    }
  }

  static var sources: [InputSource] {
    let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
    let inputSourceList = inputSourceNSArray as! [TISInputSource]

    return inputSourceList
      .filter {
        $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable
    }.map {
      InputSource(tisInputSource: $0)
    }
  }
}

private extension URL {
  var retinaImageURL: URL {
    var components = pathComponents
    let filename: String = components.removeLast()
    let ext: String = pathExtension
    let retinaFilename = filename.replacingOccurrences(of: "." + ext, with: "@2x." + ext)
    return NSURL.fileURL(withPathComponents: components + [retinaFilename])!
  }

  var tiffImageURL: URL {
    return deletingPathExtension().appendingPathExtension("tiff")
  }
}
