import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusBar = StatusBar.shared

  var justLaunched: Bool = true

  // Set while the CJKV switch workaround briefly activates the app to steal
  // focus; without this, every shortcut press would pop the preferences window.
  static var suppressActivationBehavior = false

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if PermanentStorage.launchedForTheFirstTime {
      PermanentStorage.launchedForTheFirstTime = false
    }
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    if AppDelegate.suppressActivationBehavior {
      return
    }

    if !justLaunched || PermanentStorage.launchedForTheFirstTime {
      showPreferences()
    }

    if justLaunched {
      justLaunched = false
    }
  }

  @IBAction func showPreferences(_ sender: AnyObject? = nil) {
    MainWindowController.shared.showAndActivate(self)
  }

  @IBAction func hidePreferences(_ sender: AnyObject?) {
    MainWindowController.shared.close()
  }
}
