//
//  Klausur.swift
//  
//
//  Created by Benedict on 27.05.22.
//

import Foundation

/// Klasse um Klausuren zu verwalten
class Klausur: Codable, Identifiable, Equatable {
	static func == (lhs: Klausur, rhs: Klausur) -> Bool {
		return lhs.von == rhs.von && lhs.bis == rhs.bis && lhs.bemerkung == rhs.bemerkung && lhs.raum == rhs.raum
	}

	/// Stunde bei der die Klausur beginnt
	let von: Stunde

	/// Stunde bei der die Klausur endet
	var bis: Stunde

	/// Raum der Klausur
	let raum: String

	/// Bemerkung zur klausur
	let bemerkung: String

	let id: UUID

	init(von: Stunde, bis: Stunde, raum: String, bemerkung: String) {
		self.von = von
		self.bis = bis
		self.bemerkung = bemerkung
		self.raum = raum
		self.id = UUID()
	}

	init(stunde: Stunde, raum: String, bemerkung: String) {
		self.von = stunde
		self.bis = stunde
		self.bemerkung = bemerkung
		self.raum = raum
		self.id = UUID()
	}
}
