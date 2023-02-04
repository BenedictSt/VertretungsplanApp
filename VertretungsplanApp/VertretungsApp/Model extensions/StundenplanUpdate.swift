//
//  StundenplanUpdate.swift
//  
//
//  Created by Benedict on 12.06.22.
//

import Foundation
import OSLog

/// Verwaltet Updates von dem StundenplanUpdate
class StundenplanUpdateResult: Codable, ObservableObject {
	/// Ob das Update fehlgeschlagen ist
	var failed = true

	// Kurse, die neu im Stundenplan sind
	var neueKurse: [Kurs] = []

	// Kurse, die im neuen Stundenplan fehlen
	var gelöschteKurse: [Kurs] = []

	// Raumverlegungen
	var raumVerlegungen: [RaumUpdate] = []

	// Kurs-Stunden, die im neuen Stundenplan fehlen
	var fehlendeStunden: [StundeMitDatum] = []

	// Kurs-Stunden, die im neu dazu gekommen sind
	var neueStunden: [StundeMitDatum] = []

	/// Ob sich auch nur ein einziger Wert verändert hat
	var hatAenderungen: Bool {
		return !(neueStunden.isEmpty &&
		neueKurse.isEmpty &&
		gelöschteKurse.isEmpty &&
		raumVerlegungen.isEmpty &&
		fehlendeStunden.isEmpty &&
		neueStunden.isEmpty)
	}

	/// Ob es Änderungen bei Kursen gibt, die in meinen Kursen sind
	func hatMeineAenderungen(data: DataModel) -> Bool {
		let alleMeineKurse = data.alleKurse.davonMeine(data.meineKurse)

		var betroffeneKurse: Set<Kurs> = []
		betroffeneKurse.formUnion(neueStunden.map({$0.stunde.kurs}))
		betroffeneKurse.formUnion(gelöschteKurse)
		betroffeneKurse.formUnion(raumVerlegungen.map({$0.stunde.kurs}))
		betroffeneKurse.formUnion(fehlendeStunden.map({$0.stunde.kurs}))
		betroffeneKurse.formUnion(neueStunden.map({$0.stunde.kurs}))

		return !betroffeneKurse.isDisjoint(with: alleMeineKurse)
	}

	/// Besonderes Update bei Raumverlegung
	struct RaumUpdate: Hashable, Codable, KursComparable {
		let stunde: StundenPlanItem
		let stundeStr: String
		let alterRaum: String
		var kurs: Kurs {stunde.kurs}
	}

	/// StundenPlanItem mit StundenZeit als String
	struct StundeMitDatum: Hashable, Codable, KursComparable {
		let stunde: StundenPlanItem

		/// Stunde z.B. "Mo, 1"
		let zeit: String
		var kurs: Kurs {stunde.kurs}
	}
}

/// Vergleicht alten Stundenplan aus dem DataModel mit einem neuen Stundenplan
///
/// Gibt Ergebnisse asyncron via callback zurück
private class StundenplanUpdate {
	typealias RaumUpdate = StundenplanUpdateResult.RaumUpdate
	typealias StundeMitDatum = StundenplanUpdateResult.StundeMitDatum
	let data: DataModel
	let finished: (_ r: StundenplanUpdateResult) -> Void

	// VERGLEICH:
	let updateResult = StundenplanUpdateResult()

	public func ladeNeuenStundenplan() -> (kurse: [Kurs], stundenplan: [Wochentag: [Stunde: [StundenPlanItem]]])? {
		do {
			if let meineStufe = data.meineStufe {
				if let response = try data.api?.getStundenPlan(stufe: meineStufe) {
					return response
				} else {

				}
			}
		} catch {
			print("konnte neuen Stundenplan nicht herunterladen")
		}
		return nil
	}

	typealias NeueDaten = (kurse: [Kurs], stundenplan: [Wochentag: [Stunde: [StundenPlanItem]]])
	func vergleiche() {
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			guard let neueDaten = ladeNeuenStundenplan() else {
				self.finished(self.updateResult)
				return
			}

			// MARK: gelöschte Kurse
			for alterKurs in data.alleKurse where !neueDaten.kurse.contains(alterKurs) {
				updateResult.gelöschteKurse.append(alterKurs)
			}

			// MARK: neue Kurse
			for neuerKurs in neueDaten.kurse where !data.alleKurse.contains(where: {$0 == neuerKurs}) {
				updateResult.neueKurse.append(neuerKurs)
			}

			// MARK: fehlendeStunden & Raumverlegung
			fehlendeStundenUndRaumverlegungen(neueDaten: neueDaten)

			// MARK: neueStunden
			for tag in neueDaten.stundenplan {
				for stunden in tag.value {
					let stundeStr = "\(tag.key.stringShort), \(stunden.key.numberStr)"
					for stunde in stunden.value where !(data.stundenplan[tag.key]![stunden.key]?.contains(where: {
						$0.kurs == stunde.kurs
					}) ?? false) {
						updateResult.neueStunden.append(StundeMitDatum(stunde: stunde, zeit: stundeStr))
					}
				}
			}
			DispatchQueue.main.async {
				self.updateResult.failed = false
				self.finished(self.updateResult)
			}
		}
	}

	private func fehlendeStundenUndRaumverlegungen(neueDaten: NeueDaten) {
		for tag in data.stundenplan {
			for stunden in tag.value {
				let stundeStr = "\(tag.key.stringShort), \(stunden.key.numberStr)"
				for stunde in stunden.value {
					if !(neueDaten.stundenplan[tag.key]![stunden.key]?.contains(where: {$0.kurs == stunde.kurs}) ?? false) {
						updateResult.fehlendeStunden.append(StundeMitDatum(stunde: stunde, zeit: stundeStr))
					} else {
						// Prüfe Raum:
						if let neueStunde = neueDaten.stundenplan[tag.key]![stunden.key]?.first(where: {$0.kurs == stunde.kurs})! {
							if stunde.raum != neueStunde.raum {
								let raumUpdate = RaumUpdate(stunde: neueStunde,
															stundeStr: stundeStr,
															alterRaum: stunde.raum)
								updateResult.raumVerlegungen.append(raumUpdate)
							}
						}
					}
				}
			}
		}
	}

	init(data: DataModel, callback: @escaping (_ r: StundenplanUpdateResult) -> Void) {
		self.data = data
		finished = callback
	}
}

// swiftlint:disable private_over_fileprivate
fileprivate let updateLogger = Logger(subsystem: "deb.bene.VertretungsApp3.stundenplanUpdate", category: "")
// swiftlint:enable private_over_fileprivate

extension DataModel {
	/// Lädt Stundenplan herunter und vergleicht, ob es Änderungen gibt
	///
	/// - Parameter inBackground: Wenn true: gibt nur Meldungen aus, wenn ein neuer Stundenplan verfügbar ist
	func versucheStundenplanUpdate(inBackground: Bool = true) {
		if (abs(letzterUpdateFetch.timeIntervalSinceNow) < 12*60*60 && inBackground) || self.api == nil {
			return
		}
		updateLogger.log("Fetch neuen Stundenplan")
		let updater = StundenplanUpdate(data: self, callback: { result in
			if result.failed {
				updateLogger.error("Fehler beim aktualisieren des Stundenplans")
				if !inBackground {
					self.serverStatus = .stundenplanUpdateFehlgeschlagen
				}
				return
			}
			self.letzterUpdateFetch = Date()

			if result.hatAenderungen {
				updateLogger.log("Stundenplan Update verfügbar")
				DispatchQueue.main.async {
					self.stundenPlanUpdateResult = result
					// TODO: if result hat eigene
					if result.hatMeineAenderungen(data: self) {
						self.serverStatus = .spuMit
					} else {
						self.serverStatus = .spuOhne
					}
				}
			} else {
				if !inBackground {
					self.serverStatus = .keinStundenplanUpdate
				}
			}
		})

		updater.vergleiche()
	}
}
