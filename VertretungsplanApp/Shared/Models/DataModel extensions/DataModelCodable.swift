//
//  DataModelCodable.swift
//  
//
//  Created by Benedict on 07.08.22.
//

import Foundation
import SwiftUI

struct DataModelCodable: Codable {
		var alleStufenNamen: [String] = []
		var alleKurse: [Kurs] = []
		var stundenplan: [Wochentag: [Stunde: [StundenPlanItem]]] = [:]
		var meineKurse: [String] = []
		var meineStufe: String?
		var nachrichten: [Nachricht] = []
		var klausuren: [Date: [Klausur]] = [:]
		var vertretung: [Date: [VertretungsItem]] = [:]
		var vertretungKopfzeilen: [Date: String] = [:]
		var toDos: [MoodleToDo] = []
		var lastFetch: Date?
		var busy = false
		var serverStatus: ServerStatus?
		var hatUngeleseneNachrichten = false

		#if !WIDGET
		var stundenPlanUpdateResult: StundenplanUpdateResult?
		var api: VertretungsApi?
		var stundenplanConvenience = StundenplanConvenience()
		var letzterUpdateFetch = Date()
		#endif
}

extension DataModel: Codable {
	enum CodingKeys: CodingKey {
		// swiftlint:disable duplicate_enum_cases
		// Swiftlint erkennt die Compiler config nicht
#if !Widget
		case alleStufenNamen,
		alleKurse,
		stundenplan,
		meineKurse,
		meineStufe,
		nachrichten,
		klausuren,
		vertretung,
		vertretungKopfzeilen,
		toDos,
		lastFetch,
		busy,
		serverStatus,
		hatUngeleseneNachrichten,
		// kein Widget
		apiCredentials,
		stundenPlanUpdateResult,
		api,
		stundenplanConvenience,
		letzterUpdateFetch
#else
		case alleStufenNamen,
		alleKurse,
		stundenplan,
		meineKurse,
		meineStufe,
		nachrichten,
		klausuren,
		vertretung,
		vertretungKopfzeilen,
		toDos,
		lastFetch,
		busy,
		serverStatus,
		hatUngeleseneNachrichten
#endif
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(alleStufenNamen, forKey: .alleStufenNamen)
		try container.encode(alleKurse, forKey: .alleKurse)
		try container.encode(stundenplan, forKey: .stundenplan)
		try container.encode(meineKurse, forKey: .meineKurse)
		try container.encode(meineStufe, forKey: .meineStufe)
		try container.encode(nachrichten, forKey: .nachrichten)
		try container.encode(klausuren, forKey: .klausuren)
		try container.encode(vertretung, forKey: .vertretung)
		try container.encode(vertretungKopfzeilen, forKey: .vertretungKopfzeilen)
		try container.encode(toDos, forKey: .toDos)
		try container.encode(lastFetch, forKey: .lastFetch)
		try container.encode(busy, forKey: .busy)
		try container.encode(serverStatus, forKey: .serverStatus)
		try container.encode(hatUngeleseneNachrichten, forKey: .hatUngeleseneNachrichten)
		#if !WIDGET
		try container.encode(apiCredentials, forKey: .apiCredentials)
		try container.encode(stundenPlanUpdateResult, forKey: .stundenPlanUpdateResult)
		try container.encode(api, forKey: .api)
		try container.encode(stundenplanConvenience, forKey: .stundenplanConvenience)
		try container.encode(letzterUpdateFetch, forKey: .letzterUpdateFetch)
		#endif
	}
}
