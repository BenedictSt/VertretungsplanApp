//
//  FehlerView.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import SwiftUI

struct FehlerView: View {
	@ObservedObject var data: DataModel
	@Binding var shownSheet: SheetTyp?
	@Binding var zeigeSPU: Bool

	var body: some View {
		switch data.serverStatus {
		case .noConnection:
			Fehlermeldungen.KeinInternet(action: {data.serverStatus = nil})

		case .authFail:
			if shownSheet == .anmelden {
				Fehlermeldungen.Auth(action: {data.serverStatus = nil})
			} else {
				Fehlermeldungen.AuthGoToSettings(okAction: {
					data.serverStatus = nil
				}, settings: {
					data.serverStatus = nil
					shownSheet = .anmelden
				})
			}

		case .timeout:
			Fehlermeldungen.Timeout(action: {data.serverStatus = nil})

		case .stundenplanExistiertNicht:
			Fehlermeldungen.StundenplanExistiertNicht(okAction: {
				data.serverStatus = nil
			}, neuLaden: {
				data.meineStufe = nil
				data.ladeStufen()
				shownSheet = .stufen
			})

		case .keinStundenplanUpdate:
			Fehlermeldungen.StundenplanAktuell(action: {data.serverStatus = nil})

		case .stundenplanUpdateFehlgeschlagen:
			Fehlermeldungen.StundenplanUpdateFehlgeschlagen(action: {data.serverStatus = nil})

		case .spuOhne:
			Fehlermeldungen.NeuerStundenplanDa(laden: {
				ladeSPU()
			}, ansehen: {
				zeigeSPU = true
				data.serverStatus = nil
			})

		case .spuMit:
			Fehlermeldungen.NeuerStundenplanDaMitEigen(laden: {
				ladeSPU()
			}, ansehen: {
				zeigeSPU = true
			})

		default:

			if data.kalenderFehler {
				Fehlermeldungen.KeinenKalenderZugriff(deaktivieren: {
					data.kalenderFehler = false
					UpdateCalender.exportEnabled = false
				}, ausblenden: {
					data.kalenderFehler = false
				})
			.padding()
			} else {
				Fehlermeldungen.AllgemeinerFehler(action: {
					data.serverStatus = nil
				})
			}
		}
	}

	private func ladeSPU() {
		data.stundenPlanUpdateResult = nil
		data.serverStatus = nil
		data.ladeStundenplan()
	}
}
