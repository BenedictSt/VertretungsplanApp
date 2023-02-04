//
//  VertretungsApp3App.swift
//  
//
//  Created by Benedict on 12.05.22.
//

import SwiftUI
import BackgroundTasks
import OSLog

@main
struct VertretungsApp3App: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@State var data: DataModel = DataModel.loadFromDisk()

	var body: some Scene {
		WindowGroup {
			ContentView(data: data)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { (_) in
					appDelegate.scheduleAppRefresh()
					data.saveToDisk()
					print("background")
				}
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification), perform: { (_) in
					print("active")
					// data = DataModel.loadFromDisk()
				})
		}
	}
}


let backgroundLogger = Logger(subsystem: "de.bene.VertretungsApp3.api", category: "background")

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "VertretungsAppBackgroundTask", using: nil) { task in
			backgroundLogger.log("[BGTASK] Perform background fetch VertretungsAppBackgroundTask")
			DataModel.backgroundRefresh()
			task.setTaskCompleted(success: true)
			self.scheduleAppRefresh()
		}
		return true
	}

	func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: "VertretungsAppBackgroundTask")
		request.earliestBeginDate = Date(timeIntervalSinceNow: 0)

		do {
			try BGTaskScheduler.shared.submit(request)
			backgroundLogger.log("schedule Backgrond refresh")
		} catch {
			print("Could not schedule app refresh task \(error.localizedDescription)")
		}
	}
}
