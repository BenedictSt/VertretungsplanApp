//
//  extensions.swift
//  
//
//  Created by Benedict on 19.07.22.
//

import Foundation
import Network

public class Reachability {
	/// Prüft, ob das Gerät eine Internetverbindung hat
	static func checkIsConnectedToNetwork() -> Bool {
		let monitor = NWPathMonitor()
		var hasConnection = false
		let wait = DispatchGroup()
		wait.enter()
		monitor.pathUpdateHandler = { path in
			if path.status == .satisfied {
				hasConnection = true
			}
			wait.leave()
		}
		monitor.start(queue: DispatchQueue(label: "Monitor", qos: .userInitiated))
		if wait.wait(timeout: .now() + 2) == .timedOut {
			hasConnection = false
		}
		monitor.cancel()
		return hasConnection
	}
}


extension String {
	/// Gibt String zurück, der nur aus Großbuchstaben des Alphabets besteht
	var textPart: String {
		self.filter { "A"..."Z" ~= $0 || "Ü" ~= $0 || "Ä" ~= $0 || "Ö" ~= $0}
	}

	/// Gibt eine Zahl zurück, die aus dem String entseht, wenn man alle nicht Digits entfernt
	/// - Returns: default: 0
	var numberPartAsInt: Int {
		Int(self.filter { "0"..."9" ~= $0 }) ?? 0
	}

	func index(from: Int) -> Index {
		return self.index(startIndex, offsetBy: from)
	}

	func substring(from: Int) -> String {
		let fromIndex = index(from: from)
		return String(self[fromIndex...])
	}

	func substring(to: Int) -> String { // swiftlint:disable:this identifier_name
		let toIndex = index(from: to)
		return String(self[..<toIndex])
	}

	func substring(with range: Range<Int>) -> String {
		let startIndex = index(from: range.lowerBound)
		let endIndex = index(from: range.upperBound)
		return String(self[startIndex..<endIndex])
	}
}

extension Date {
	/// Wie viele Minuten der Tag alt ist. Von 00:00 an
	var minutesInDay: Int {
		let calendar = Calendar.current
		let hours = calendar.component(.hour, from: self)
		let minutes = calendar.component(.minute, from: self)
		return hours * 60 + minutes
	}

	/// Welcher Wochentag ist im gregorianischen Kalender
	///
	/// 1: Sonntag |
	/// 2: Montag |
	/// 3: Dienstag |
	/// 4: Mittwoch |
	/// 5: Donnerstag |
	/// 6: Freitag |
	/// 7: Samstag
	var gregorianWeekday: Int {
		let calendar = Calendar.current
		return  calendar.component(.weekday, from: self)
	}

	/// gibt das Datum des Tages von dem nächsten gesuchten Wochentag zurück
	func next(_ weekday: Wochentag,
					 direction: Calendar.SearchDirection = .forward) -> Date {
		let calendar = Calendar(identifier: .gregorian)
		let components = DateComponents(weekday: weekday.gregorianWeekday)

		return calendar.nextDate(after: self,
								 matching: components,
								 matchingPolicy: .nextTime,
								 direction: direction)!
	}
}
