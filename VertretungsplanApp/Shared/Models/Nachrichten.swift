//
//  Nachrichten.swift
//  
//
//  Created by Benedict on 19.05.22.
//

import Foundation

/// Struct um allgemeine Nachrichten zu verwalten
struct Nachricht: Codable, Hashable {
	let title: String
	let text: String
}

/// Struct um Moodle Aufgaben zu verwalten
struct MoodleToDo: Codable, Hashable {
	/// Moodle interne KursId
	let kursId: Int

	/// Kursname von Moodle
	let kursName: String

	/// Überschrifz der Abgabe
	let title: String

	/// Beschreibung von der Abgabe
	let beschreibung: String

	/// Abgabedatum
	let datum: Date

	init(kursId: Int, kursName: String, title: String, beschreibung: String, time: Int) {
		self.kursId = kursId
		self.kursName = kursName
		self.title = title
		self.beschreibung = beschreibung
		self.datum = Date(timeIntervalSince1970: Double(time))
	}
}
