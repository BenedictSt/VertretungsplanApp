//
//  VertretungsAPI.swift
//  
//
//  Created by Benedict on 13.05.22.
//

import Foundation
import SWXMLHash
import OSLog

// swiftlint:disable private_over_fileprivate
fileprivate let apiLogger = Logger(subsystem: "de.bene.VertretungsApp3.api", category: "parser")
// swiftlint:enable private_over_fileprivate

class VertretungsApi: Codable {

	public enum ParseErrors: Error {
		case emptyResponse, parserError
	}

	var credentials: ApiCredentials

	init(credentials: ApiCredentials) {
		self.credentials = credentials
	}

	// MARK: - get Stufen
	public func getStufen() throws -> [String] {
		let tmp = try ApiCall(URL.vertretungsAppApiStufe(credentials: credentials))
		guard let xmlString = tmp.respone else {
			apiLogger.error("lade Stufen: empty response")
			throw ParseErrors.emptyResponse
		}

		let xml = XMLHash.config {_ in
			// config
		}.parse(xmlString)

		let alleStufen: [String] = xml["skList"]["Data"]["Item"].all.map({$0.element?.text}).compactMap({$0})
		apiLogger.log("\(alleStufen.count) Stufen geladen")
		return alleStufen
	}

	public func getStundenPlan(stufe: String) throws -> (kurse: [Kurs],
														 stundenplan: [Wochentag: [Stunde: [StundenPlanItem]]]) {
		// MARK: call API
		let apiCall = try ApiCall(URL.vertretungsAppApiStundenplan(credentials: credentials, stufe: stufe))
		guard let xmlString = apiCall.respone else {
			apiLogger.error("lade Stundenplan: empty response")
			throw ParseErrors.emptyResponse
		}

		let xml = XMLHash.parse(xmlString)

		// MARK: Process
		var kurseTmp: [Kurs] = []
		var planTmp: [Wochentag: [Stunde: [StundenPlanItem]]] = [:]

		for tag in Wochentag.alle {
			for stunde in (1...12) {
				do {
					let alleStundenImBlock = try xml["VertretungsAppBoard"]["Stundenplan"]["Wochentag"]
						.withAttribute("tagId", tag.string)["Stunde"].withAttribute("stundenId", "\(stunde)")["Teilgruppe"].all

					for einzelneStunde in alleStundenImBlock {
						let lehrer = einzelneStunde["Lehrer"].element?.text ?? "Lehrer"
						let fach = einzelneStunde["Fach"].element?.text ?? "Fach"
						let raum = einzelneStunde["Raum"].element?.text ?? "Raum"

						var kurs = kurseTmp.first(where: {$0.name == Kurs.generateName(lehrer: lehrer, fach: fach)})

						if kurs == nil {
							kurs = Kurs(lehrer: lehrer, fach: fach)
							kurseTmp.append(kurs!)
						}

						let stundenPlanItem = StundenPlanItem(raum: raum, kurs: kurs!)
						planTmp[tag, default: [:]][.init(stunde), default: []].append(stundenPlanItem)
					}

				} catch {
					apiLogger.error("lade Stundenplan: keine Stunde gefunden: \(error.localizedDescription, privacy: .public) \n, tag: \(tag.stringShort, privacy: .public); stunde: \(stunde, privacy: .public)") // swiftlint:disable:this line_length
					// throw ParseErrors.parserError
				}
			}
		}
		apiLogger.log("Stundenplan geladen: \(kurseTmp.count) Kurse")
		return (kurseTmp, planTmp)
	}

	public struct ComboResult {
		let nachrichten: [Nachricht]
		let klausuren: [Date: [Klausur]]
		let vertretungen: [Date: [VertretungsItem]]
		let headlines: [Date: String]
		let toDos: [MoodleToDo]
	}

	public func getCombo(stufe: String) throws -> ComboResult {
		let apiCall = try ApiCall(URL.vertretungsAppApiCombo(credentials: credentials, stufe: stufe))
		guard let xmlString = apiCall.respone else {
			apiLogger.error("lade Combo: empty response")
			throw ParseErrors.emptyResponse
		}

		let xml = XMLHash.parse(xmlString)

		let alleMitteilungen = nachrichten(xml)
		let alleToDos = todos(xml)
		let alleKlausuren: [Date: [Klausur]] = klausuren(xml)

		// MARK: Vertretung & Headlines
		var alleVertretungen: [Date: [VertretungsItem]] = [:]
		var alleHeadlines: [Date: String] = [:]
		do {
			try xml["roundUp"]["vPlan"]["Data"]["Day"].all.forEach({ tag in
				let tagStr: String = try tag.value(ofAttribute: "date")
				let tagDate = DateF.VertretungsAppApi.date(from: tagStr) ?? .init(timeIntervalSince1970: 0)

				let headlineStr: String = try tag.value(ofAttribute: "headline")

				if headlineStr != "" {
					alleHeadlines[tagDate] = headlineStr
				}

				tag["Item"].all.forEach({ vertretung in
					let stundeInt = Int(vertretung["Stunde"].element?.text.filter { "0"..."9" ~= $0 } ?? "-1") ?? -1
					let stunde = Stunde.init(stundeInt)
					alleVertretungen[tagDate, default: []].append(
						VertretungsItem(
							stunde: stunde,
							kurs: vertretung["Kurs"].element?.text ?? "",
							vFach: vertretung["Vertretung-Fach"].element?.text ?? "",
							vLehrer: vertretung["Vertretung-Lehrer"].element?.text ?? "",
							vRaum: vertretung["Vertretung-Raum"].element?.text ?? "",
							bemerkung: vertretung["Bemerkung"].element?.text ?? "")
					)

				})
			})
		} catch {
			apiLogger.error("Fehler beim laden der Headlines \(error.localizedDescription) \n \(xmlString)")
		}

		return ComboResult(nachrichten: alleMitteilungen,
						   klausuren: alleKlausuren,
						   vertretungen: alleVertretungen,
						   headlines: alleHeadlines,
						   toDos: alleToDos)
	}

	/// ließt die Mitteillungen aus der XML-Response aus
	private func nachrichten(_ rawData: XMLIndexer) -> [Nachricht] {
		return rawData["roundUp"]["Mitteilungen"]["Data"]["Item"].all.map({
			Nachricht(title: $0["Ueberschrift"].element?.text ?? "", text: $0["Text"].element?.text ?? "")
		})
	}

	/// ließt die Aufgaben aus der XML-Response aus
	private func todos(_ rawData: XMLIndexer) -> [MoodleToDo] {
		do {
			return try rawData["roundUp"]["mdlAssign"]["Data"]["Item"].all.map({
				MoodleToDo(kursId: try $0["FullCourseName"].value(ofAttribute: "course_id") as Int,
						   kursName: $0["FullCourseName"].element?.text ?? "",
						   title: $0["Task"].element?.text ?? "",
						   beschreibung: $0["Description"].element?.text ?? "",
						   time: Int($0["TimeToDo"].element?.text ?? "0") ?? 0)
			})
		} catch {
			apiLogger.error("Fehler beim laden der Aufgaben \(error.localizedDescription) \(rawData)")
			return []
		}
	}

	/// ließt die Klausuren aus der XML-Response aus
	private func klausuren(_ rawData: XMLIndexer) -> [Date: [Klausur]] {
		var alleKlausurenRaw: [Date: [Klausur]] = [:]
		do {
			try rawData["roundUp"]["kPlan"]["Data"]["Day"].all.forEach({ tag in
				let tagStr: String = try tag.value(ofAttribute: "date")
				let tagDate = DateF.VertretungsAppApi.date(from: tagStr) ?? .init(timeIntervalSince1970: 0)

				tag["Item"].all.forEach({ klausur in
					let stundeInt = Int(klausur["Stunde"].element?.text.filter { "0"..."9" ~= $0 } ?? "-1") ?? -1
					let stunde = Stunde.init(stundeInt)
					alleKlausurenRaw[tagDate, default: []].append(
						Klausur(
							stunde: stunde,
							raum: klausur["Raum"].element?.text ?? "-",
							bemerkung: klausur["Bemerkung"].element?.text ?? "-")
					)
				})
			})
		} catch {
			apiLogger.error("Fehler beim laden der Klausuren \(error.localizedDescription) \(rawData)")
		}

		// Kombinieren
		var alleKlausuren: [Date: [Klausur]] = [:]
		for tag in alleKlausurenRaw {
			alleKlausurenRaw[tag.key] = tag.value.sorted(by: {$0.von < $1.von})
			for klausur in tag.value {
				if alleKlausuren[tag.key, default: []].contains(where: {
					$0.bemerkung + $0.raum == klausur.bemerkung + klausur.raum
				}) {
					alleKlausuren[tag.key]!.first(where: {
						$0.bemerkung + $0.raum == klausur.bemerkung + klausur.raum
					})!.bis = klausur.bis
				} else {
					alleKlausuren[tag.key, default: []].append(klausur)
				}
			}
		}

		return alleKlausuren
	}

}
