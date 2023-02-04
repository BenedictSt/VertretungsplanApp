//
//  Kurs.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import Foundation

class Kurs: Hashable, Codable, Identifiable, KursComparable {
	let lehrer: String
	let fach: String

	/// Name von Kurs
	///
	/// Wird zur Identifikation eines Kurses genutzt
	/// Bsp: "ML2 FEIC"
	var name: String {
		return Kurs.generateName(lehrer: lehrer, fach: fach)
	}

	/// Gibt Kursname zurück
	///
	/// Wird zur Identifikation eines Kurses genutzt
	/// Bsp: "ML2 FEIC"
	static func generateName(lehrer: String, fach: String) -> String {
		return lehrer + " " + fach
	}

	init(lehrer: String, fach: String) {
		self.lehrer = lehrer
		self.fach = fach
	}

	// MARK: Protocol Confomance

	static func == (lhs: Kurs, rhs: Kurs) -> Bool {
		lhs.name == rhs.name
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}

	var kurs: Kurs { self }
}

/// Enthält Raum und Kurs. Wird in einem StundenplanDictionary gespeichert
class StundenPlanItem: Hashable, Codable, Identifiable, Equatable, KursComparable {
	let raum: String
	var kurs: Kurs
	let id: UUID

	static func == (lhs: StundenPlanItem, rhs: StundenPlanItem) -> Bool {
		return lhs.id == rhs.id
	}

	init(raum: String, kurs: Kurs) {
		self.raum = raum
		self.kurs = kurs
		self.id = UUID()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(kurs)
		hasher.combine(raum)
	}
}

/// Alle konformen Klassen enthalten einen Kurs
protocol KursComparable {
	var kurs: Kurs { get }
}

extension Array where Element: KursComparable {

	/// Gibt alle Elemente aus dem Array zurück, deren Kurs in meinenKursen ist
	func davonMeine(_ meine: [String]) -> [Element] {
		return self.filter({element in meine.contains(where: {element.kurs.name == $0})})
	}

	/// Gibt alle Elemente aus dem Array zurück, deren Kurs in meinenKursen ist
	/// - Parameter active: ob der Filter angewendet werden soll
	func davonMeine(_ meine: [String], active: Bool) -> [Element] {
		if active {
			return self.davonMeine(meine)
		}
		return self
	}
}
