//
//  VertretungsItem.swift
//  
//
//  Created by Benedict on 31.05.22.
//

import Foundation

/// Vertretungseinträge im Vertretungsplan
struct VertretungsItem: Codable, Hashable {
	let stunde: Stunde
	let kurs: String
	let vFach: String
	let vLehrer: String
	let vRaum: String
	let bemerkung: String

	/// VertretungsText
	///
	/// Für Unterestufe of benutzt
	/// Wenn in einer Stunde ein anderes Fach bei einem anderen Lehrer Unterrichtet wird
	///
	/// Bsp: "Deutsch bei Thün"
	///
	/// Wenn nicht beides Verändert wird, wird nur das veränderte zurückgegeben
	///
	var vText: String {
		if vFach != "" && vLehrer != "" {
			return "\(vFach) bei \(vLehrer)"
		}
		return vFach+vLehrer
	}
}
