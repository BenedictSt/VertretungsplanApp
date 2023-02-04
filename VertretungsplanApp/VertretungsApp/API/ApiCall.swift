//
//  GetDataFromApi.swift
//  
//
//  Created by Benedict on 12.05.22.
//

import Foundation
import OSLog

class ApiCall {
	private final let callLogger = Logger(subsystem: "de.bene.VertretungsApp3.api", category: "apiCall")

	enum ApiError: Error {
		case timeout, forbidden, auth, invalidURL, other, stundenplanExistiertNicht
	}

	var query: URL?
	var respone: String?

	init(_ query: URL?, timeout: Double = 12) throws {
		self.query = query
		try call(timeout: timeout)
	}

	public func call(timeout: Double = 12) throws {
		let wait = DispatchSemaphore(value: 0)

		guard let url = query else {
			throw ApiError.invalidURL
		}

		var fetchResponse: (Data, URLResponse?, Error?)?

		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else { return }
			fetchResponse = (data, response, error)
			wait.signal()
		}

		task.resume()
		let timeoutResult = wait.wait(timeout: .now() + timeout)
		if timeoutResult == .timedOut {
			callLogger.log("timeout \(timeout)")
			throw ApiError.timeout
		}

		guard let fetchResponse = fetchResponse else {
			callLogger.error("Fehler beim laden der Antwort")
			throw ApiError.other
		}

		// callLogger.log("ApiCallResponseCode: \(fetchResponse.1!)") TODO: an StatusCode kommen

		guard let fetchedString = String(data: fetchResponse.0, encoding: .utf8) else {
			callLogger.error("Fehler beim decodieren der Antwort: \(fetchResponse.0)")
			throw ApiError.other
		}

		// specific
		if fetchedString.contains("Dein Passwort oder der Username ist falsch!") {
			callLogger.log("Name oder Passwort falsch")
			throw ApiError.auth
		}
		if fetchedString.contains("Der angeforderte Stundenplan existiert nicht!") {
			callLogger.log("angeforderte Stundenplan existiert nicht")
			throw ApiError.stundenplanExistiertNicht
		}

		self.respone = fetchedString.replacingOccurrences(of: "&nbsp;", with: " ")
	}
}
