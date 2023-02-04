//
//  Loads.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import Foundation
import WidgetKit
import OSLog

// swiftlint:disable private_over_fileprivate
fileprivate let loadLogger = Logger(subsystem: "de.bene.VertretungsApp3.api", category: "loads")
// swiftlint:enable private_over_fileprivate

extension DataModel {
	/// Ob die Daten aktuell sind
	///
	/// Gilt als aktuell, wenn nicht älter als 15 Minuten
	var datenAktuell: Bool {
		return abs(self.lastFetch?.timeIntervalSinceNow ?? 100) < 15*60
	}

	/// Lädt Stufennamen herunter
	public func ladeStufen() {
		loadLogger.log("Lade Stufen")
		serverStatus = nil
		if !Reachability.checkIsConnectedToNetwork() {
			serverStatus = .noConnection
			return
		}
		busy = true
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			do {
				if let neueStufen = try self.api?.getStufen() {
					DispatchQueue.main.async { [self] in
						self.alleStufenNamen = neueStufen
						serverStatus = .success
					}
				} else {
					loadLogger.log("Fehler beim laden der Stufen")
					DispatchQueue.main.async { [self] in
						serverStatus = .other
					}
				}
			} catch {
				loadLogger.log("Fehler beim laden der Stufen: \(error.localizedDescription)")
				DispatchQueue.main.async { [self] in
					switch error {
					case ApiCall.ApiError.auth:
						serverStatus = .authFail
					case ApiCall.ApiError.timeout:
						serverStatus = .timeout
					default:
						serverStatus = .other
					}
				}
			}
			DispatchQueue.main.async {
				self.busy = false
			}
			saveToDisk()
		}
	}

	/// Lädt neuen Stundenplan herunter
	public func ladeStundenplan() {
		loadLogger.log("Lade Stundenplan: \(self.meineStufe ?? "nil", privacy: .public)")
		serverStatus = nil
		if !Reachability.checkIsConnectedToNetwork() {
			serverStatus = .noConnection
			return
		}
		busy = true
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			do {
				if let meineStufe = meineStufe {
					if let response = try api?.getStundenPlan(stufe: meineStufe) {
						DispatchQueue.main.async { [self] in
							alleKurse = response.kurse
							stundenplan = response.stundenplan
							serverStatus = .success
							WidgetCenter.shared.reloadAllTimelines()
						}
					} else {
						loadLogger.log("Fehler beim laden des Stundenplans")
						DispatchQueue.main.async { [self] in
							serverStatus = .other
						}
					}

				} else {
					// TODO: fehlermeldung
				}
			} catch {
				loadLogger.log("Fehler beim laden des Stundenplans: \(error.localizedDescription)")
				DispatchQueue.main.async { [self] in
					switch error {
					case ApiCall.ApiError.auth:
						serverStatus = .authFail
					case ApiCall.ApiError.timeout:
						serverStatus = .timeout
					case ApiCall.ApiError.stundenplanExistiertNicht:
						serverStatus = .stundenplanExistiertNicht
					default:
						serverStatus = .other
					}
				}
			}
			DispatchQueue.main.async {
				self.busy = false
			}
			self.saveToDisk()
		}
	}

	/// Aktualisiert Vertretungsplan, Klausuren, Nachrichten, Moodle Abgaben
	public func aktualisiere() {
		loadLogger.log("Lade Combo: \(self.meineStufe ?? "nil", privacy: .public)")
		serverStatus = nil
		if !Reachability.checkIsConnectedToNetwork() {
			serverStatus = .noConnection
			return
		}
		busy = true
		DispatchQueue.global(qos: .userInitiated).async { [self] in
			do {
				if let meineStufe = meineStufe {
					if let comboResult = try api?.getCombo(stufe: meineStufe) {
						DispatchQueue.main.async { [self] in
							if(comboResult.nachrichten.contains(where: {neueNachricht in
								!self.nachrichten.contains(where: {$0 == neueNachricht})}) ||
								comboResult.toDos.contains(where: {neuesToDo in !self.toDos.contains(where: {$0 == neuesToDo})
								})) {
								hatUngeleseneNachrichten = true
							}
							nachrichten = comboResult.nachrichten
							toDos = comboResult.toDos
							klausuren = comboResult.klausuren
							vertretung = comboResult.vertretungen
							vertretungKopfzeilen = comboResult.headlines
						}
						self.lastFetch = Date()
						WidgetCenter.shared.reloadAllTimelines()
					}
				} else {
					loadLogger.log("Fehler beim Laden der Combo")
					// TODO: fehlermeldung
				}
			} catch {
				loadLogger.log("Fehler beim Laden der Combo: \(error.localizedDescription)")
				DispatchQueue.main.async { [self] in
					switch error {
					case ApiCall.ApiError.auth:
						serverStatus = .authFail
					case ApiCall.ApiError.timeout:
						serverStatus = .timeout
					case ApiCall.ApiError.stundenplanExistiertNicht:
						serverStatus = .stundenplanExistiertNicht
					default:
						serverStatus = .other
					}
				}
			}

			DispatchQueue.main.sync {
				self.busy = false
			}
			self.saveToDisk()
		}
	}
}
