//
//  Enums.swift
//  
//
//  Created by Benedict on 24.05.22.
//

import Foundation

// MARK: - Werktage für den Stundenplan
enum Wochentag: Codable {
	case montag, dienstag, mittwoch, donnerstag, freitag

	/// - Parameter day: Tag in gregorian Woche
	public init(day: Int) {
		switch day {
		case 3: self = .dienstag
		case 4: self = .mittwoch
		case 5: self = .donnerstag
		case 6: self = .freitag
		default: self = .montag
		}
	}

	var next: Wochentag {
		switch self {
		case .montag:
			return .dienstag
		case .dienstag:
			return .mittwoch
		case .mittwoch:
			return .donnerstag
		case .donnerstag:
			return .freitag
		case .freitag:
			return .montag
		}
	}

	/// Alle Werktage
	static var alle: [Wochentag] {
		return [.montag, .dienstag, .mittwoch, .donnerstag, .freitag]
	}

	/// ganzer Name vom Wochentag
	///
	/// Bsp: "Montag"
	var string: String {
		return stringMap[self]!
	}

	/// kurzer Name vom Wochentag
	///
	/// Bsp: "Mo"
	var stringShort: String {
		return stringMap[self]!.substring(to: 2)
	}

	/// Tag in Woche im gregorianischen Kalender
	///
	/// Montag: 2
	/// Dienstag: 3, ...
	public var gregorianWeekday: Int {
		return [
			.montag: 2,
			.dienstag: 3,
			.mittwoch: 4,
			.donnerstag: 5,
			.freitag: 6
		][self] ?? 2
	}

	private var stringMap: [Wochentag: String] {[
		.montag: "Montag",
		.dienstag: "Dienstag",
		.mittwoch: "Mittwoch",
		.donnerstag: "Donnerstag",
		.freitag: "Freitag"
	]}
}

// MARK: - Stunden im Stundenplan
enum Stunde: Codable, Comparable {
	case s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, andere // swiftlint:disable:this identifier_name

	init(_ value: Int) {
		self = Stunde.intMap[value, default: .andere]
	}

	/// Alle verfügbaren Stundne
	static var alle: [Stunde] {
		return [.s1, .s2, .s3, .s4, .s5, .s6, .s7, .s8, .s9, .s10, .s11, .s12]
	}

	/// Int zu Stunde
	///
	/// Bsp: 1 : .s1
	static var intMap: [Int: Stunde] {[
		1: .s1,
		2: .s2,
		3: .s3,
		4: .s4,
		5: .s5,
		6: .s6,
		7: .s7,
		8: .s8,
		9: .s9,
		10: .s10,
		11: .s11,
		12: .s12
	]}

	/// Label für Start und Endzeit
	///
	/// Bsp: (08:00 - 08:45)
	///  - Warning: Unterscheidet nicht zwischen Modellen der Stunde: z.B. (12:30 - 13:15 / 12:50 - 13:35)
	var label: String {
		switch self {
		case .s1:
			return "(08:00 - 08:45)"
		case .s2:
			return "(08:45 - 09:30)"
		case .s3:
			return "(09:50 - 10:35)"
		case .s4:
			return "(10:35 - 11:20)"
		case .s5:
			return "(11:40 - 12:25)"
		case .s6:
			return "(12:30 - 13:15 / 12:50 - 13:35)"
		case .s7:
			return "(13:40 - 14:25)"
		case .s8:
			return "(14:30 - 15:15)"
		case .s9:
			return "(15:20 - 16:05)"
		case .s10:
			return "(16:05 - 16:50)"
		case .s11:
			return "(16:50 - 17:35)"
		case .s12:
			return "(17:35 - 18:20)"
		case .andere:
			return "Andere"
		}
	}

	/// Start Uhrzeit für Stunde als String
	///
	/// Bsp: 08:00
	/// - Warning: Nur Oberstufe
	var sek2StartTimeLabel: String {
		switch self {
		case .s1:
			return "08:00"
		case .s2:
			return "08:45"
		case .s3:
			return "09:50"
		case .s4:
			return "10:35"
		case .s5:
			return "11:40"
		case .s6:
			return "12:50"
		case .s7:
			return "13:40"
		case .s8:
			return "14:30"
		case .s9:
			return "15:20"
		case .s10:
			return "16:05"
		case .s11:
			return "16:50"
		case .s12:
			return "17:35"
		case .andere:
			return "Andere"
		}
	}

	/// End Uhrzeit für Stunde als String
	///
	/// Bsp: 08:45
	/// - Warning: Nur Oberstufe
	var sek2EndTimeLabel: String {
		switch self {
		case .s1:
			return "08:45"
		case .s2:
			return "09:30"
		case .s3:
			return "10:35"
		case .s4:
			return "11:20"
		case .s5:
			return "12:25"
		case .s6:
			return "13:35"
		case .s7:
			return "14:25"
		case .s8:
			return "15:15"
		case .s9:
			return "16:05"
		case .s10:
			return "16:50"
		case .s11:
			return "17:35"
		case .s12:
			return "18:20"
		case .andere:
			return "Andere"
		}
	}

	/// Stunde als Zahl von Int
	///
	/// Bsp: "1"
	/// Bei einem Fehler: "?"
	var numberStr: String {
		if let intValue = Stunde.intMap.first(where: {$0.value == self})?.key {
			return String(intValue)
		}
		return "?"
	}

	/// Stunde als Int
	///
	/// Bsp: 1
	/// Bei einem Fehler: 0
	var number: Int {
		if let intValue = Stunde.intMap.first(where: {$0.value == self})?.key {
			return intValue
		}
		return 0
	}

	/// Startzeit von Kurs
	///
	/// - Returns: Uhrzeit in Minuten seit Tagesbeginn (00:00)
	var start: Int {
		return [
			.s1: 480,
			.s2: 525,
			.s3: 590,
			.s4: 635,
			.s5: 700,
			.s6: 770,
			.s7: 820,
			.s8: 870,
			.s9: 920,
			.s10: 965,
			.s11: 1010,
			.s12: 1055,
			.andere: 1200
		][self]!
	}

	/// Endzeit von Kurs
	///
	/// - Returns: Uhrzeit in Minuten seit Tagesbeginn (00:00)
	var end: Int { start + 45}
}
