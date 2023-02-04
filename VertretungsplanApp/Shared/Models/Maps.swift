//
//  Maps.swift
//  
//
//  Created by Benedict on 26.05.22.
//

import Foundation

extension Kurs {
	/// Fach Identifier von der KursId zu Fachname
	///
	/// Bsp: "Ma" : "Mathe"
	static let fachMap: [String: String] = [
		"BI": "Bio",
		"KR": "kath. Religion",
		"KRE": "kath. Religion",
		"F": "Französisch",
		"FR": "Französisch",
		"L": "Latein",
		"LAT": "Latein",
		"PH": "Physik",
		"CH": "Chemie",
		"GE": "Geschichte",
		"SW": "Sowi",
		"D": "Deutsch",
		"EK": "Erdkunde",
		"PA": "Pädagogik",
		"S": "Spanisch",
		"SP": "Sport",
		"PL": "Philosophie",
		"ER": "evgl. Relgion",
		"ERE": "evgl. Relgion",
		"MU": "Musik",
		"KU": "Kunst",
		"M": "Mathe",
		"MA": "Mathe",
		"E": "Englisch",
		"EN": "Englisch",
		"IF": "Informatik",
		"SCHGO": "Gottesdienst",
		"MAFÖ": "Ma. Förder",
		"DEFÖ": "De. Förder",
		"LATFÖ": "Lat. Förder",
		"ENFÖ": "En. Förder",
		"FRFÖ": "Fr. Förder",
		"SFÖ": "S. Förder"
	]
}
