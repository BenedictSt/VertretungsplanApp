//
//  StundenplanConvenience.swift
//  
//
//  Created by Benedict on 18.08.22.
//

import Foundation
import SwiftUI

class StundenplanConvenience: ObservableObject, Codable {
	@Published var selectedDay: Wochentag = .montag {
		didSet {
			letzerManualSet = Date()
		}
	}
	@Published var zeigeAlle = false
	var letzteMinuteInTag: [Wochentag: Int] = [:]
	private var letzerManualSet: Date?

	enum CodingKeys: CodingKey {
		case selectedDay, zeigeAlle, letzteMinuteInTag, letzerManualSet
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(selectedDay, forKey: .selectedDay)
		try container.encode(zeigeAlle, forKey: .zeigeAlle)
		try container.encode(letzteMinuteInTag, forKey: .letzteMinuteInTag)
		try container.encode(letzerManualSet, forKey: .letzerManualSet)
	}

	init() {}
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		selectedDay = try container.decode(Wochentag.self, forKey: .selectedDay)
		zeigeAlle = try container.decode(Bool.self, forKey: .zeigeAlle)
		letzteMinuteInTag = try container.decode([Wochentag: Int].self, forKey: .letzteMinuteInTag)
		letzerManualSet = try container.decode(Date?.self, forKey: .letzerManualSet)
	}

	public func stundenplanAppear() {
		if let letzerManualSet = letzerManualSet {
			if letzerManualSet.timeIntervalSinceNow < -10 * 60 {
				setzteZuTag()
			}
		} else {
			setzteZuTag()
		}
	}

	public func setzteZuTag() {
		var wochentag: Wochentag = Wochentag(day: Date().gregorianWeekday)
		let isWeekend = Date().gregorianWeekday == 7 || Date().gregorianWeekday == 1

		if let letzteMinute = letzteMinuteInTag[wochentag] {
			if Date().minutesInDay > letzteMinute + 30 && !isWeekend {
				wochentag = wochentag.next
			}
		}
		selectedDay = wochentag
	}

	// TODO: implement
	/// gibt id von scroll-Id zurück, damit automatisch zur richtigen Stunde gescrolled werden kann
	public func getScrollPosition(stunden: [Stunde]) -> String? {
		//		if let letzerManualSet = letzerManualSet {
		//			if (letzerManualSet.timeIntervalSinceNow > -10 * 60) {
		//				return nil
		//			}
		//		}
		for stunde in stunden.sorted(by: {$0.start < $1.start}) {
			if stunde.end < Date().minutesInDay {
				continue
			} else {
				return stunde.numberStr
			}
		}
		return nil
	}
}
