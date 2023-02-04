//
//  Speichern.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import Foundation
import OSLog

// swiftlint:disable private_over_fileprivate
fileprivate let speicherLogger = Logger(subsystem: "de.bene.VertretungsApp3.load", category: "disk")
// swiftlint:enable private_over_fileprivate

extension DataModel {

	/// URL zum Container der App-Gruppe
	fileprivate static var groupURL: URL {
		FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.VertretungsApp")!
	}

	/// Lädt DataModel
	static func loadFromDisk() -> DataModel {
		speicherLogger.log("Lade vom Speicher")
		do {
			let data = try Data(contentsOf: groupURL.appendingPathComponent("saveData.txt"))
			let model = try JSONDecoder().decode(DataModel.self, from: data)
			return model
		} catch {
			speicherLogger.error("Fehler beim laden: \(error.localizedDescription)")
		}
		let modelTmp = DataModel()
		return modelTmp
	}

	#if !WIDGET
	/// Speichert DataModel
	func saveToDisk() {
		speicherLogger.log("speichern")
		do {
			let data = try JSONEncoder().encode(self)
			try data.write(to: DataModel.groupURL.appendingPathComponent("saveData.txt"))
		} catch {
			speicherLogger.error("Fehler beim speichern: \(error.localizedDescription)")
		}
	}
	#endif
}
