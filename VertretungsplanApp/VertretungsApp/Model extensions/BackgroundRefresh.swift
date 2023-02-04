//
//  BackgroundRefresh.swift
//  VertretungsApp3 (iOS)
//
//  Created by Benedict on 27.06.22.
//

import Foundation

extension DataModel {

	fileprivate static var baseURL: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}

	/// Wird vom System aufgerufen, um eine Hintergrundaktualisierung zu starten
	static func backgroundRefresh() {
		let model = DataModel.loadFromDisk()
		model.backgroundAktualisiere()
		model.saveToDisk()
	}

	/// versucht neue Daten im Hintergrund herunter zu laden
	public func backgroundAktualisiere() {
		if !Reachability.checkIsConnectedToNetwork() {
			return
		}
		do {
			if let meineStufe = meineStufe {
				if let response = try api?.getCombo(stufe: meineStufe) {
					if(response.nachrichten.contains(where: {neueNachricht in
						!self.nachrichten.contains(where: {$0 == neueNachricht})
					}) || response.toDos.contains(where: { neuesToDo in
						!self.toDos.contains(where: {$0 == neuesToDo})
					})) {
						hatUngeleseneNachrichten = true
					}

					nachrichten = response.nachrichten
					toDos = response.toDos
					klausuren = response.klausuren
					vertretung = response.vertretungen
					vertretungKopfzeilen = response.headlines
					self.lastFetch = Date()
					backgroundLogger.log("Hat Daten im Hintergrund geladen")
				} else {
					backgroundLogger.error("Fehler bei der Hintergrundaktualisierung: respone = nil")
				}
			} else {
				backgroundLogger.log("Konnte im Hintergrund nicht aktualisieren, da keine Stufe ausgewählt ist")
			}
		} catch {
			backgroundLogger.error("Fehler bei der Hintergrundaktualisierung: \(error.localizedDescription)")
		}
	}
}
