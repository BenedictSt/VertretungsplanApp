//
//  generateCredentials.swift
//  
//
//  Created by Benedict on 12.05.22.
//

import Foundation
import OSLog

class ApiCredentials: Codable, Equatable {

	private static let credLogger = Logger(subsystem: "de.bene.VertretungsApp3.load", category: "cred") // TODO: bundleId

	static func == (lhs: ApiCredentials, rhs: ApiCredentials) -> Bool {
		return lhs.username == rhs.username && lhs.password == rhs.password
	}

	/// moodle user name
	var username: String
	private var password: String

	/// password formatted for the api
	var apiPassword: String {
		return password.asciiValues.map({3*($0 - 1)}).map({String(format: "%04d", $0)}).joined(separator: "-")
	}

	var urlCredentials: String {
		return "pwd=\(apiPassword)&uname=\(username)"
	}

	init(username: String, password: String) {
		self.username = username
		self.password = password
		ApiCredentials.savePassword(new: password)
	}

	// MARK: - save password in iOS keychain
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.username = try container.decode(String.self, forKey: .username)
		self.password = ApiCredentials.loadPassword()
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.username, forKey: .username)
	}

	static func loadPassword() -> String {
		do {
			credLogger.log("Lade Passwort aus der Keychain")
			let keyData = try KeychainInterface.readPassword(service: "VertretungsApp_Moodle", account: "password")
			guard let password = String(data: keyData, encoding: .utf8) else {
				credLogger.error("Konnte Passwort nicht decodieren: \(keyData)")
				return ""
			}
			return password
		} catch {
			credLogger.error("Fehler beim laden des Passworts aus der Keychain: \(error.localizedDescription)")
			return ""
		}
	}

	static func savePassword(new: String) {
		do {
			credLogger.log("Speicher Passwort in der Keychain: \(new, privacy: .private(mask: .hash))")
			guard let password = new.data(using: .utf8) else {
				credLogger.error("Konnte Passwort nicht zu utf8 codieren")
				return
			}
			try KeychainInterface.save(password: password, service: "VertretungsApp_Moodle", account: "password")
		} catch {
			credLogger.error("Konnte Passwort nicht speichern: \(error.localizedDescription)")
		}
	}

	static func deleteFromKeychain() {
		do {
			credLogger.log("Lösche Nutzerpasswort aus der Keychain")
			try KeychainInterface.deletePassword(service: "VertretungsApp_Moodle", account: "password")
		} catch {
			credLogger.error("Passwort konnte nicht aus der Keychain gelöscht werden: \(error.localizedDescription)")
		}
	}

	enum CodingKeys: CodingKey {
		case username
	}
}
