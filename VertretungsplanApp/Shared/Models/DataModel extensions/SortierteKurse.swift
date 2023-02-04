//
//  SortierteKurse.swift
//  
//
//  Created by Benedict on 26.05.22.
//

import Foundation

// MARK: - Extensions, die für die Kursauswahl benötigt werden
extension DataModel {

	/// Gibt alle Kurse nach Fachnamen sortiert zurück
	///
	/// - Returns: [Fachname(String) : Kurse(Kurs)]
	func getFaecher(filter: String) -> [String: [Kurs]] {
		var dict: [String: [Kurs]] = [:]

		for kurs in alleKurse where kurs.filter(filterString: filter) {
			dict[kurs.kursKategorie, default: []].append(kurs)
		}

		for key in dict.keys {
			dict[key] = dict[key]!.sorted(by: {$0.fach.numberPartAsInt < $1.fach.numberPartAsInt})
			dict[key] = dict[key]!.sorted(by: {$0.fach.textPart.count < $1.fach.textPart.count})
		}

		return dict
	}

	/// Gibt alle Kurse nach Lehrer sortiert zurück
	///
	/// - Returns: [LehrerName(String) : Kurse(Kurs)]
	func getSortiertNachLehrer(filter: String) -> [String: [Kurs]] {
		let alleNamen = Array(Set(alleKurse.map({$0.lehrer})))
		var dict: [String: [Kurs]] = [:]

		for name in alleNamen {
			dict[name] = alleKurse.filter({$0.lehrer == name && $0.filter(filterString: filter)})
		}
		dict = dict.filter({$0.value.count > 0})
		return dict
	}
}

// MARK: - Filter Kurse und Fachkategorien
extension Kurs {

	/// Wenn kein Fachstring für einen Kurs gefunden werden kann, wird andereFachName verwendet
	static let andereFachName = "Andere"

	/// Gibt Fachname von Kurs zurück
	///
	/// Wenn kein Name erkannt wird: "Andere"
	/// - Returns: Kategorie als String
	var kursKategorie: String {
		var fachId = self.fach
			.replacingOccurrences(of: " NAT", with: "").uppercased().textPart
		if fachId != "L" && fachId != "PL" && fachId.last == "L" {
			fachId = String(fachId.dropLast())
		}
		let fachKategorie = Kurs.fachMap.keys.first(where: {fachId.uppercased() == $0})
		if let fachKategorieTmp = fachKategorie {
			return Kurs.fachMap[fachKategorieTmp] ?? Kurs.andereFachName
		} else {
			return Kurs.andereFachName
		}
	}

	/// Prüft, ob ein Kurs eine Bedingung erfüllt
	///
	/// wenn filterString == "" ist, return true
	/// matcht: Fach, lehrer, KursId
	/// nicht case sensitiv
	/// - Parameter filterString: Bedingung
	/// - Returns: true wenn Kurs Bedingung erfüllt
	func filter(filterString: String) -> Bool {
		if filterString == "" {return true}

		let searchTerms = filterString.uppercased().split(separator: " ")
		let kursDescription = (fach + "|||" + lehrer + "|||" + kursKategorie).uppercased()

		var included = true

		for searchTerm in searchTerms where !kursDescription.contains(searchTerm) {
				included = false
		}

		return included
	}
}
