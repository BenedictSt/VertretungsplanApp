//
//  DateFormatter.swift
//  
//
//  Created by Benedict on 23.08.22.
//

import Foundation

typealias DateF = DateFormatter

extension DateF {

	/// initialisiert einen Dateformatter mit einem DateFormat
	/// - Parameter format: normaler DateFormatter Syntax, um das dateFormat zu definieren
	convenience init (format: String) {
		self.init()
		self.dateFormat = format
		self.locale = Locale(identifier: "de_DE")
	}


	/// DateFormatter für ein normales Deutsches Datum
	///
	/// dd.MM.YYYY -
	/// 12.01.2005
	static var deutschesDatum: DateFormatter {
		DateFormatter(format: "dd.MM.YY")
	}

	/// DateFormatter für die VertretungsApi
	///
	/// YYYYMMdd -
	/// 20051205
	/// - Warning: Breaking
	static var VertretungsAppApi: DateFormatter {
		DateFormatter(format: "YYYYMMdd")
	}

	/// DateFormatter für ein ein ausführliches Datum mit Uhrzeit
	///
	/// EE dd.MM | HH:mm -
	/// Mi. 24.08 | 14:45
	static var ausfuerlichDatumUhr: DateFormatter {
		DateFormatter(format: "EE dd.MM | HH:mm")
	}

	/// DateFormatter für ein ein ausführliches Datum ohne Uhrzeit
	///
	/// EEEE, dd.MM.YY -
	/// Freitag, 26.08.22
	static var ausfuerlichDatum: DateFormatter {
		DateFormatter(format: "EEEE, dd.MM.YY")
	}

	/// DateFormatter für nur Wochentag
	///
	/// EEEE |
	/// Freitag
	static var wochentag: DateFormatter {
		DateFormatter(format: "EEEE")
	}

	/// Ersetze Wochentag durch Heute / Morgen entsprechend
	///
	/// Freitag, 26.08.22 -> Heute, 26.08.22
	static func ersetzeHeuteMorgen(date: Date, formatter: DateFormatter) -> String {
		let dateString: String
		let asGermanyDate = deutschesDatum.string(from: date)

		if asGermanyDate == deutschesDatum.string(from: Date()) {
			dateString = formatter.string(from: date).replacingOccurrences(of: wochentag.string(from: date), with: "Heute")
		} else if asGermanyDate == deutschesDatum.string(from: Date().addingTimeInterval(20*60*60)) {
			dateString = formatter.string(from: date).replacingOccurrences(of: wochentag.string(from: date), with: "Morgen")
		} else {
			dateString = formatter.string(from: date)
		}

		return dateString
	}

	/// gibt die Uhrzeit von Minuten in tag zurueck
	/// - Parameter time: minuten in Tag z.B. 485
	/// HH:mm | 08:05
	static func timeFromMinute(time: Int) -> String {
		let minutes = time % 60
		let hours = (time - minutes) / 60
		return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
	}
}
