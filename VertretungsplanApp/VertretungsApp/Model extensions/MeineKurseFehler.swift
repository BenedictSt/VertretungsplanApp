//
//  MeineKurseFehler.swift
//  
//
//  Created by Benedict on 26.05.22.
//

import Foundation

var fehlerKurseCache: (kurse: [String], beschreibungen: [String])?
var fehlerKurseCacheHash: Int = 0

extension DataModel {
	/// alle Kurse, die in meineKurse enthalten sind und bei denen es einen Konflikt gibt
	var meineFehlerKurse: [String] { meineFehlerKurseBeschreibung.kurse}

	/// Alle meine Kurse, die einen Fehler haben mit genauer Fehlermeldunge
	// TODO: besser dokumentieren
	var meineFehlerKurseBeschreibung: (kurse: [String], beschreibungen: [String]) {
		var hasher = Hasher.init()
		hasher.combine(meineKurse)
		hasher.combine(alleKurse.count)

		if fehlerKurseCacheHash != hasher.finalize() {
			fehlerKurseCache = nil // invalidate cache wenn sich betreffender Parameter verändert haben
		}
		if fehlerKurseCache == nil {
			fehlerKurseCache = getMeineFehlerKurseBeschreibung()
			fehlerKurseCacheHash = hasher.finalize()
		}

		return fehlerKurseCache!
	}

	/// Meine Kurse, aber als Array mit Kursen
	var meineKurseAK: [Kurs] {
		alleKurse.davonMeine(meineKurse)
	}

	/// berechnet meineFehlerKurseBeschreibung neu- das Ergebnis wird dann gecached
	fileprivate func getMeineFehlerKurseBeschreibung() -> (kurse: [String], beschreibungen: [String]) {
		var fehler: [String] = []
		var beschreibungen: [String] = []

		let meineAKCache = meineKurseAK
		// Prüfe zwei im gleichen Fach
		let kurseInKategorien = getFaecher(filter: "")
		for faecher in kurseInKategorien.filter({$0.key != Kurs.andereFachName}).values {
			let davonMeine = faecher.filter({ kurs in meineAKCache.contains(where: {$0 == kurs})})
			if davonMeine.count > 1 {
				fehler.append(contentsOf: davonMeine.map({$0.name}))
				beschreibungen.append("Mehrere Kurse im gleichen Fach:\n\(davonMeine.map({$0.name}).joined(separator: ", "))")
			}
		}

		// Prüfe zur gleichen Zeit
		for stundenplanTag in stundenplan {
			for kurseInBlock in stundenplanTag.value {
				var kursnamenInBlock: [String] = []
				for item in kurseInBlock.value where meineAKCache.contains(item.kurs) {
					kursnamenInBlock.append(item.kurs.name)
				}
				if kursnamenInBlock.count > 1 {
					fehler.append(contentsOf: kursnamenInBlock)
					beschreibungen.append("Die Kurse: \(kursnamenInBlock.joined(separator: ", ")) finden zur gleichen Zeit statt.")
				}
			}
		}

		return (fehler, Array(Set(beschreibungen)))
	}

}
