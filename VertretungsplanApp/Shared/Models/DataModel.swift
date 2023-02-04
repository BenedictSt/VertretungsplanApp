//
//  DataModel.swift
//  
//
//  Created by Benedict on 12.05.22.
//

import Foundation
import OSLog

enum ServerStatus: Codable {
	case success,
		 noConnection,
		 authFail,
		 other,
		 timeout,
		 stundenplanExistiertNicht,
		 keinStundenplanUpdate,
		 stundenplanUpdateFehlgeschlagen,
		 spuOhne,
		 spuMit
}

// TODO: bei betreffenden Änderungen WidgetCenter.shared.reloadAllTimelines() aufrufen
class DataModel: ObservableObject {
	// MARK: - Stufen
	@Published var alleStufenNamen: [String] = []
	var finishedInit = false

	// MARK: - Stundenplan
	@Published var alleKurse: [Kurs] = []
	@Published public	 var stundenplan: [Wochentag: [Stunde: [StundenPlanItem]]] = [:] {
		didSet {
			#if !WIDGET
			if finishedInit {
				_ = UpdateCalender(data: self)
			}
			#endif
		}
	}
	public func getSlot(_ tag: Wochentag, _ stunde: Stunde, meine: Bool = true) -> [StundenPlanItem] {
		return stundenplan[tag, default: [:]][stunde, default: []].davonMeine(meineKurse, active: meine)
	}
	public func getKursByName(_ name: String) -> Kurs? {
		return alleKurse.first(where: {$0.name == name})
	}

	// MARK: - meine Sachen
	@Published var meineKurse: [String] = [] {
		didSet {
			#if !WIDGET
			if finishedInit {
				_ = UpdateCalender(data: self)
			}
			#endif
		}
	}
	var meineStufe: String?

	// MARK: - Aktuelles
	var nachrichten: [Nachricht] = []
	var klausuren: [Date: [Klausur]] = [:]
	var vertretung: [Date: [VertretungsItem]] = [:]
	var vertretungKopfzeilen: [Date: String] = [:]
	var toDos: [MoodleToDo] = []

	// MARK: - Status
	var lastFetch: Date?
	@Published var busy = false
	@Published var serverStatus: ServerStatus?
	@Published var hatUngeleseneNachrichten = false
	#if !WIDGET
	@Published var stundenPlanUpdateResult: StundenplanUpdateResult?
	#endif

	#if !WIDGET
	// MARK: - Zugangsdaten
	var apiCredentials: ApiCredentials? {
		didSet {
			// TODO: prüfen ob das hier immer richtig aufgerufen wird
			if let apiCredentials = apiCredentials {
				self.api = VertretungsApi(credentials: apiCredentials)
			} else {
				api = nil
				// ApiCredentials.deleteFromKeychain()
				Logger().fault("hätte keychain gelöscht")
			}
			saveToDisk()
		}
	}
	var api: VertretungsApi?

	// MARK: Zustand
	var stundenplanConvenience = StundenplanConvenience()
	var letzterUpdateFetch = Date()

	/// ob alle Daten (name, pwd, stufe) eingetragen sind
	var configAbgeschlossen: Bool { apiCredentials != nil && meineStufe != nil}
	@Published var kalenderFehler = false
	#endif

	init() {}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		alleStufenNamen = try container.decode([String].self, forKey: .alleStufenNamen)
		alleKurse = try container.decode([Kurs].self, forKey: .alleKurse)
		stundenplan = try container.decode([Wochentag: [Stunde: [StundenPlanItem]]].self, forKey: .stundenplan)
		meineKurse = try container.decode([String].self, forKey: .meineKurse)
		meineStufe = try container.decode(String?.self, forKey: .meineStufe)
		nachrichten = try container.decode([Nachricht].self, forKey: .nachrichten)
		klausuren = try container.decode([Date: [Klausur]].self, forKey: .klausuren)
		vertretung = try container.decode([Date: [VertretungsItem]].self, forKey: .vertretung)
		vertretungKopfzeilen = try container.decode([Date: String].self, forKey: .vertretungKopfzeilen)
		toDos = try container.decode([MoodleToDo].self, forKey: .toDos)
		lastFetch = try container.decode(Date?.self, forKey: .lastFetch)
		busy = try container.decode(Bool.self, forKey: .busy)
		serverStatus = try container.decode(ServerStatus?.self, forKey: .serverStatus)
		hatUngeleseneNachrichten = try container.decode(Bool.self, forKey: .hatUngeleseneNachrichten)

		#if !WIDGET
		apiCredentials = try container.decode(ApiCredentials?.self, forKey: .apiCredentials)
		stundenPlanUpdateResult = try container.decode(StundenplanUpdateResult?.self, forKey: .stundenPlanUpdateResult)
		api = try container.decode(VertretungsApi?.self, forKey: .api)
		stundenplanConvenience = try container.decode(StundenplanConvenience.self, forKey: .stundenplanConvenience)
		letzterUpdateFetch = try container.decode(Date.self, forKey: .letzterUpdateFetch)
		#endif
		finishedInit = true
	}
}

extension DataModel {
	// Ob der Tag Kurse hat, die in meineKurse sind
	public func hatEigeneKurseAnTag(_ tag: Wochentag) -> Bool {
		for stunde in Stunde.alle where !getSlot(tag, stunde, meine: true).isEmpty {
			return true
		}
		return false
	}
}
