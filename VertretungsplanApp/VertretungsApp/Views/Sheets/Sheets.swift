//
//  Sheets.swift
//  
//
//  Created by Benedict on 27.05.22.
//

import SwiftUI

enum SheetTyp {
	case anmelden, stufen, stunden, info, einstellungen
}

struct Sheets: View {
	@ObservedObject var data: DataModel
	@Binding var sheet: SheetTyp?
	@State var showMessage = false
	@Binding var onboarding: Bool
	@Binding var stundenplanEditMode: Bool
	@Binding var update: UUID
	@Binding var zeigeSPU: Bool

	var body: some View {
		ZStack {
			ZStack {
				switch sheet {
				case .anmelden:
					AnmeldedatenView(data: data)
				case .stufen:
					StufenAuswahl(data: data, onboarding: onboarding)
				case .stunden:
					StundenAuswahlView(data: data, finish: {sheet = nil; stundenplanEditMode = false; onboarding = false})
				case .info:
					InfoView(hide: {sheet = nil})
				case .einstellungen:
					EinstellungenView(data: data, shownSheet: $sheet, update: $update)
				default:
					Text("Fehler")
				}
			}
			.disabled(showMessage)
			.blur(radius: showMessage ? 2 : 0)

			if showMessage {
				FehlerView(data: data, shownSheet: $sheet, zeigeSPU: $zeigeSPU)
			}
		}
		.interactiveDismissDisabled(onboarding || showMessage)
		.onChange(of: data.busy, perform: { busy in
			if busy {
				showMessage = false
				return
			}
			if let new = data.serverStatus {
				if new == .success {
					data.serverStatus = nil
					if onboarding {
					switch sheet {
					case .anmelden:
						sheet = .stufen
					case .stufen:
						sheet = .stunden
					default:
						sheet = nil
						onboarding = false
					}
					} else {
						if sheet == .stufen {
							// aktualisiere Combo, wenn Stufe geändert wird
							data.aktualisiere()
						}
						sheet = nil
					}
				} else {
					showMessage = true
				}
			} else {
				showMessage = false
			}
		})
		.onChange(of: data.serverStatus, perform: { new in
			if new == nil || new == .success {
				showMessage = false
			} else {
					showMessage = true
			}
		})
		.onDisappear {
			data.serverStatus = nil
		}
		.id(sheet.debugDescription)
	}
}
