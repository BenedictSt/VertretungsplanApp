//
//  exportCalendar.swift
//  
//
//  Created by Benedict on 13.08.22.
//

import Foundation
import EventKit

import SwiftUI

class UpdateCalender {

	let eventStore = EKEventStore()
	var calendar: EKCalendar?
	let data: DataModel

	var eventsToAdd: [EKEvent] = []

	var calendarIdentifier: String? {
		get {
			let defaults = UserDefaults()
			return defaults.string(forKey: "VertretungsApp3CalendarURL")
		}

		set {
			let defaults = UserDefaults()
			defaults.set(newValue, forKey: "VertretungsApp3CalendarURL")
		}
	}

	static var exportEnabled: Bool {
		get {
			let defaults = UserDefaults()
			return defaults.bool(forKey: "VertretungsApp3CalendarExport")
		}

		set {
			let defaults = UserDefaults()
			defaults.set(newValue, forKey: "VertretungsApp3CalendarExport")
		}
	}


	func resetCalendar() {
		if let calendarIdentifier = calendarIdentifier {
			if let calendarTmp = eventStore.calendar(withIdentifier: calendarIdentifier) {
				do {
					try eventStore.removeCalendar(calendarTmp, commit: true)
				} catch {
					print("konnte alten Kalender nicht entfernen")
					print(error)
				}
			} else {
				print("konnte alten Kalender nicht entfernen")
			}
		}

		print("create new Calendar")
		calendar = EKCalendar(for: EKEntityType.event, eventStore: eventStore)
		calendar!.source = eventStore.defaultCalendarForNewEvents!.source
		calendar!.title = "Stundenplan"

		do {
			try eventStore.saveCalendar(calendar!, commit: true)
			calendarIdentifier = calendar!.calendarIdentifier
		} catch {
			print(error)
			return
		}

	}

	init(data: DataModel) {
		self.data = data
		if !UpdateCalender.exportEnabled {
			return
		}

		eventStore.requestAccess(to: .event) { [self] (granted, error) in
			if !granted || error != nil {
				DispatchQueue.main.sync {
					data.kalenderFehler = true
				}
				print("kein Access: \(error.debugDescription)")
				return
			}

			resetCalendar()

			guard let calendar = calendar else {
				print("Kein Kalender vorhanden")
				return
			}

			calendar.cgColor = Color.themeColor.cgColor

			saveStundenplan()

			do {
				for event in eventsToAdd {
					try eventStore.save(event, span: .thisEvent, commit: false)
				}
				try eventStore.commit()
			} catch {
				print("fehler beim Speichern der Änderungen")
				print(error)
			}
		}
	}

	func saveStundenplan() {
		for tag in Wochentag.alle {
			for stunde in Stunde.alle {
				let meineStundenInBlock = data.stundenplan[tag]?[stunde]?.davonMeine(data.meineKurse) ?? []
				for stundenplanItem in meineStundenInBlock {
					saveStundenplanItem(kurs: stundenplanItem.kurs,
										raum: stundenplanItem.raum,
										tag: tag,
										stunde: stunde)
				}
			}
		}
	}

	func saveStundenplanItem(kurs: Kurs, raum: String, tag: Wochentag, stunde: Stunde) {
		let recurrenceRule = EKRecurrenceRule(
			recurrenceWith: .weekly,
			interval: 1,
			end: EKRecurrenceEnd(end: Date().addingTimeInterval(60*60*24*100))
		)

		let event: EKEvent = EKEvent(eventStore: eventStore)
		event.availability = .unavailable
		event.addRecurrenceRule(recurrenceRule)
		event.calendar = calendar

		event.title = kurs.kursKategorie != Kurs.andereFachName ? kurs.kursKategorie : kurs.fach
		event.location = raum
		event.notes = "\(kurs.lehrer)\n[automatisch von der VertretungsApp generiert]"

		let startDate = Date()
			.next(tag, direction: .backward)
			.addingTimeInterval(Double(stunde.start) * 60)
		event.startDate = startDate
		event.endDate = startDate.addingTimeInterval(45*60)

		if let lastEvent = eventsToAdd.last {
			if lastEvent.endDate == event.startDate &&
				lastEvent.title == event.title &&
				lastEvent.location == event.location {
				// combine
				lastEvent.endDate = event.endDate
				return
			}
		}
		eventsToAdd.append(event)
	}
}
