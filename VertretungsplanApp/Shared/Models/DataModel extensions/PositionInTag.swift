//
//  PositionInTag.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import Foundation

extension DataModel {
	#if !WIDGET
	/// Aktualisiert die letze Minute im Tag im stundenplanConvenience-Model
	func updateLetzteMinuteInTag() {
		stundenplanConvenience.letzteMinuteInTag = getLetzteMinuteInTag(meine: true)
	}
	#endif

	/// Gibt die Minute, der letzten Stunde im Tag
	///
	/// - Parameter meine: Ob nur Kurse berücksichtigt werden sollen, die in meineKurse enthalten sind
	func getLetzteMinuteInTag(meine: Bool) -> [Wochentag: Int] {
		var tmp: [Wochentag: Int] = [:]

		for tag in Wochentag.alle {
			var letzteStunde: Stunde?
			for stunde in Stunde.alle where !getSlot(tag, stunde, meine: meine).isEmpty {
					letzteStunde = stunde
			}
			if let letzteStunde = letzteStunde {
				tmp[tag] = letzteStunde.end
			}
		}
		return tmp
	}

	/// Gibt zurück, ob die Stunde die aktuellste Stunde jetzt gerade ist
	///
	/// - Parameter tag, stunde: Stunde um die es get
	/// - Parameter meine: Ob nur Kurse berücksichtigt werden sollen, die in meineKurse enthalten sind
	func getIstAktuelleStundeInStundenplan(tag: Wochentag, stunde stundeTest: Int, meine: Bool) -> Bool {
		if
			getLetzteMinuteInTag(meine: meine)[tag] ?? 9999 < Date().minutesInDay
			|| tag.gregorianWeekday != Date().gregorianWeekday {
			return false
		}

		var letzteStundeBefore: Stunde?
		var canDoNext = false
		for stunde in Stunde.alle {
			let items = getSlot(tag, stunde, meine: meine)
			if !items.isEmpty && stunde.start < Date().minutesInDay {
				letzteStundeBefore = stunde
				if stunde.end < Date().minutesInDay {
					canDoNext = true
				} else {
					canDoNext = false
				}
			} else if !items.isEmpty && canDoNext {
				letzteStundeBefore = stunde
				canDoNext = false
			}
		}
		if let letzteStundeBefore = letzteStundeBefore {
			return letzteStundeBefore.numberStr == String(stundeTest)
		}
		return false
	}
}
