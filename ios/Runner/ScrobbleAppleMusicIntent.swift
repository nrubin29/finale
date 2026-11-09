import AppIntents
import Flutter

/// Scrobbles recent Apple Music plays without opening the app, so it can be run
/// from Shortcuts automations (e.g. when CarPlay disconnects).
///
/// The scrobbling itself is done in Dart: this starts a headless engine at
/// `appleMusicSyncMain` (lib/main.dart) and waits for it to report back.
@available(iOS 16.0, *)
struct ScrobbleAppleMusicIntent: AppIntent {
    static let title: LocalizedStringResource = "Scrobble Apple Music"
    static let description = IntentDescription(
        "Scrobbles the songs you've played in Apple Music since Finale last scrobbled them."
    )
    static let openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let count = try await AppleMusicSyncRunner.run()

        if count == 0 {
            return .result(value: count, dialog: "No new songs to scrobble.")
        } else if count == 1 {
            return .result(value: count, dialog: "Scrobbled 1 song.")
        } else {
            return .result(value: count, dialog: "Scrobbled \(count) songs.")
        }
    }
}

@available(iOS 16.0, *)
struct FinaleShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ScrobbleAppleMusicIntent(),
            phrases: [
                "Scrobble Apple Music with \(.applicationName)",
                "Sync Apple Music with \(.applicationName)",
            ]
        )
    }
}

@available(iOS 16.0, *)
struct AppleMusicSyncError: Error, CustomLocalizedStringResourceConvertible {
    let message: String

    var localizedStringResource: LocalizedStringResource { "\(message)" }
}

@available(iOS 16.0, *)
private enum AppleMusicSyncRunner {
    private static let channelName = "com.nrubintech.finale/apple_music_sync"

    /// Background intents are killed after roughly 30 seconds.
    private static let timeout: TimeInterval = 25

    @MainActor private static var isRunning = false

    @MainActor
    static func run() async throws -> Int {
        guard !isRunning else {
            throw AppleMusicSyncError(message: "Finale is already scrobbling.")
        }
        isRunning = true
        defer { isRunning = false }

        let engine = FlutterEngine(name: "AppleMusicSync", project: nil, allowHeadlessExecution: true)
        defer { engine.destroyContext() }

        guard engine.run(withEntrypoint: "appleMusicSyncMain") else {
            throw AppleMusicSyncError(message: "Couldn't start Finale.")
        }
        GeneratedPluginRegistrant.register(with: engine)

        // Handlers can only be set once the engine is running. Dart can't send
        // the result before this, since its messages are handled on this thread.
        let completion = SyncCompletion()
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: engine.binaryMessenger)
        channel.setMethodCallHandler { call, reply in
            reply(nil)
            guard call.method == "result", let args = call.arguments as? [String: Any] else { return }

            if let error = args["error"] as? String {
                completion.finish(.failure(AppleMusicSyncError(message: error)))
            } else {
                completion.finish(.success(args["count"] as? Int ?? 0))
            }
        }

        return try await completion.wait(timeout: timeout)
    }
}

/// Bridges the method channel callback to async/await. The result may arrive
/// before or after [wait] is called, and only the first result is used.
@available(iOS 16.0, *)
private final class SyncCompletion: @unchecked Sendable {
    private let lock = NSLock()
    private var result: Result<Int, Error>?
    private var continuation: CheckedContinuation<Int, Error>?

    func finish(_ result: Result<Int, Error>) {
        lock.lock()
        guard self.result == nil else {
            lock.unlock()
            return
        }
        self.result = result
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()

        continuation?.resume(with: result)
    }

    func wait(timeout: TimeInterval) async throws -> Int {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [self] in
            finish(.failure(AppleMusicSyncError(message: "Scrobbling timed out.")))
        }

        return try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            if let result {
                lock.unlock()
                continuation.resume(with: result)
            } else {
                self.continuation = continuation
                lock.unlock()
            }
        }
    }
}
