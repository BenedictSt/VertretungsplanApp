//
//  StundenplanView.swift
//  
//
//  Created by Benedict on 16.06.22.
//

import WidgetKit
import SwiftUI
import Intents

struct FolgendeStunde: TimelineEntry, Hashable {
	// WidgetCenter.shared.reloadAllTimelines() //TODO: Benedict nach Hintergrundaktualisierung
	public let date: Date
	public let data: StundenPlanItem
	public let wochentag: String
	public let startZeit: Int
	public let configuration: ConfigurationIntent

	// MARK: Vertretung
	public let vFach: String
	public let vLehrer: String
	public let vRaum: String
	public let bemerkung: String
	public let stand: Date?
	public var hatHinweis: Bool {
		return vFach != "" ||
		vLehrer != "" ||
		vFach != "" ||
		bemerkung != ""
	}

	/// Welche Stunden für den nächsten Tag folgen
	public var restTag: [FolgendeStunde]

	public init(date: Date,
				data: StundenPlanItem,
				wochentag: String,
				startZeit: Int,
				configuration: ConfigurationIntent,
				vFach: String = "",
				vLehrer: String = "",
				vRaum: String = "",
				bemerkung: String = "",
				stand: Date? = nil
	) {
		self.date = date
		self.data = data
		self.wochentag = wochentag
		self.startZeit = startZeit
		self.configuration = configuration
		self.vFach = vFach
		self.vLehrer = vLehrer
		self.vRaum = vRaum
		self.bemerkung = bemerkung
		self.stand = stand
		self.restTag = []
	}
}

// swiftlint:disable line_length
struct FolgendeStundeWidgetProvider: IntentTimelineProvider {
	func placeholder(in context: Context) -> FolgendeStunde {
		FolgendeStunde(date: Date(),
					   data: StundenPlanItem(raum: "6.43", kurs: Kurs(lehrer: "VertretungsApp", fach: "KR2")),
					   wochentag: "Montag",
					   startZeit: 8*60,
					   configuration: ConfigurationIntent())
	}

	func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (FolgendeStunde) -> Void) {
		let entry = FolgendeStunde(date: Date(),
								   data: StundenPlanItem(raum: "6.43", kurs: Kurs(lehrer: "VertretungsApp", fach: "KR2")),
								   wochentag: "Montag",
								   startZeit: 8*60,
								   configuration: configuration)
		completion(entry)
	}

	func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<FolgendeStunde>) -> Void) {
		let data: DataModel = DataModel.loadFromDisk()

		print(data.alleKurse.map({$0.name}))

		let timeline = Timeline(entries: data.generateFolgendeStundenFuerTag(configuration: configuration), policy: .atEnd)
		completion(timeline)
	}
}
// swiftlint:enable line_length

extension DataModel {
	// TODO: sek 1 muss andere Stunden haben
	public func generateFolgendeStundenFuerTag(configuration: ConfigurationIntent) -> [FolgendeStunde] {
		let letzteMinute: Int
		if Wochentag(day: Date().gregorianWeekday).gregorianWeekday == Date().gregorianWeekday {
			letzteMinute = getLetzteMinuteInTag(meine: true)[Wochentag(day: Date().gregorianWeekday)] ?? 0
		} else {
			letzteMinute = 0
		}

		var anzeigeTag = DateF.VertretungsAppApi.date(from: DateF.VertretungsAppApi.string(from: Date()))! // Neutrales Datum vom heutigen Tag

		var amGleichenTag = true // Ob die folgenden Stunden für heute oder den nächsten Tag generiert werden
		// MARK: Lade Stunden für den nächsten Tag, wenn der aktuelle Tag keine Stunden mehr hat
		if Date().minutesInDay > letzteMinute || Date().gregorianWeekday == 0 || Date().gregorianWeekday == 7 {
			let neuerWochentag = Wochentag(day: Date().gregorianWeekday + (Date().gregorianWeekday == 7 ? 2 : 1))
			anzeigeTag = Date().next(neuerWochentag, direction: .forward)
			amGleichenTag = false
		}

		let wochentag = Wochentag(day: anzeigeTag.gregorianWeekday)

		var items: [FolgendeStunde] = []

		var letzteAngezeigteStunde: Stunde?
		for stunde in Stunde.alle {
			if stunde.start + 10 < Date().minutesInDay && amGleichenTag {
				continue
			}
			if let anzeigeStunde = getSlot(wochentag, stunde).first {
				var anzeigeDatum = Date()
				if letzteAngezeigteStunde != nil {
					anzeigeDatum = anzeigeTag.addingTimeInterval(Double(letzteAngezeigteStunde!.start)*60 + 10*60)
				}

				if Date() < anzeigeDatum.addingTimeInterval(10) {
					var folgendeStunde: FolgendeStunde?
					let vertretungsItem = self.vertretung[anzeigeTag]?.first(where: {
						$0.kurs == anzeigeStunde.kurs.name && stunde == $0.stunde
					})
					folgendeStunde = FolgendeStunde(
						date: anzeigeDatum,
						data: anzeigeStunde,
						// TODO: logik für heute morgen, ... im Widgets und nicht hier
						wochentag: "\(amGleichenTag ? "Heute" :  Date().gregorianWeekday != 6 && Date().gregorianWeekday != 7 ? "Morgen" :  Wochentag.init(day: wochentag.gregorianWeekday).string)", // swiftlint:disable:this all
						startZeit: stunde.start,
						configuration: configuration,
						vFach: vertretungsItem?.vFach ?? "",
						vLehrer: vertretungsItem?.vLehrer ?? "",
						vRaum: vertretungsItem?.vRaum ?? "",
						bemerkung: vertretungsItem?.bemerkung ?? "",
						stand: Date().addingTimeInterval(-60*60)
						// stand: self.lastFetch //TODO: <- Ändern bei Eingliederung in die VertretungsApp 3
					)
					// zu den restlichen Stunden im Tag hinzufügen
					items.indices.forEach({items[$0].restTag.append(folgendeStunde!)})
					items.append(folgendeStunde!)
				}

				letzteAngezeigteStunde = stunde
			}
		}

#if DEBUG
		itemsPrint(items: items)
#endif

		return items
	}
}

#if DEBUG
/// Zum Debuggen: gibt alle generierten Items in die Konsole aus
func itemsPrint(items: [FolgendeStunde]) {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "E, HH:mm"

	print("AnzeigeZeit | Kurs | Kurs Startzeit | Vertretung | folgend : \(items.count)")
	for item in items {
		print("\(dateFormatter.string(from: item.date)) -> Kurs: \(item.data.kurs.name);" +
			  " \(DateF.timeFromMinute(time: item.startZeit)) - \(item.hatHinweis ? "V" : "k") | F\(item.restTag.count)")
	}
}
#endif
