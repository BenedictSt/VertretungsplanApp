//
//  URLGenerator.swift
//  
//
//  Created by Benedict on 23.08.22.
//

import Foundation

// swiftlint:disable line_length

extension URL {
	/// URL auf Moodle, um die Anmeldedaten zurückzusetzen
	static func resetMoodlePassword() -> URL? {
		return URL(string: "https://moodle..org/login/forgot_password.php")
	}

	/// URL zu einen Moodle Kurs
	/// - Parameter kursId: Moodle Id von dem Kurs
	static func moodleWebsiteKurs(kursId: Int) -> URL? {
		return URL(string: "")
	}

	/// VertretungsApiUrl um die Stufen abzurufen
	///  - Parameter credentials: Api Credentials von dem Benutzer
	static func vertretungsAppApiStufe(credentials: ApiCredentials) -> URL? {
		return URL(string: "https://api..org/.php?\(credentials.urlCredentials)")
	}

	/// VertretungsApiUrl um den Stundenplan für eine Stufe herunter zu laden
	///  - Parameter credentials: Api Credentials von dem Benutzer
	///  - Parameter stufe: StufenId für die der Stundenplan herunter geladen werden soll
	static func vertretungsAppApiStundenplan(credentials: ApiCredentials, stufe: String) -> URL? {
		return URL(string: "https://api..org/.php?\(credentials.urlCredentials)&stufe=\(stufe)")
	}

	/// VertretungsApiUrl um den ComboDaten für eine Stufe herunter zu laden
	///  - Parameter credentials: Api Credentials von dem Benutzer
	///  - Parameter stufe: StufenId für die der Stundenplan herunter geladen werden soll
	static func vertretungsAppApiCombo(credentials: ApiCredentials, stufe: String) -> URL? {
		let day = DateF.VertretungsAppApi.string(from: Date())
		return URL(string: "https://api..org/.php?day=\(day)&stufe=\(stufe)&\(credentials.urlCredentials)")
	}
}
