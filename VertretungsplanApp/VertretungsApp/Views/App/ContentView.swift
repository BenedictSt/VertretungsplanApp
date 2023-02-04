//
//  ContentView.swift
//  
//
//  Created by Benedict on 12.05.22.
//

import SwiftUI

enum AppState {
	case vertretung, stundenplan, klausuren, nachrichten
}

struct ContentView: View {
	@ObservedObject var data: DataModel
	@State var appState: AppState = .stundenplan
	@State var onboarding = false
	@State var shownSheet: SheetTyp?
	@State var stundenplanEditMode = false
	@State var update = UUID()
	@State var zeigeSPU = false

	@State var scroll: CGFloat = 0
	var body: some View {
		GeometryReader { reader in
			ZStack {
				let zeigeFehler = data.serverStatus != .success &&
									data.serverStatus != nil &&
									shownSheet == nil ||
									data.kalenderFehler

				VStack(spacing: 0) {
					TopBar(data: data, shownSheet: $shownSheet)

					MainScreen(data: data,
							   appState: $appState,
							   shownSheet: $shownSheet,
							   stundenplanEditMode: $stundenplanEditMode)

					Navbar(data: data, appState: $appState, width: reader.size.width)
				}
				.disabled(zeigeFehler)
				.blur(radius: zeigeFehler ? 2 : 0)

				// MARK: - Fehlermeldungen
				if zeigeFehler {
					FehlerView(data: data, shownSheet: $shownSheet, zeigeSPU: $zeigeSPU)
						.onAppear {
							hapticFeedback(style: .heavy)
						}
				}
			}
		}
		.id(update)
		.sheet(isPresented: showSheets, content: {
			Sheets(data: data,
				   sheet: $shownSheet,
				   onboarding: $onboarding,
				   stundenplanEditMode: $stundenplanEditMode,
				   update: $update,
				   zeigeSPU: $zeigeSPU)
		})
		.sheet(isPresented: $zeigeSPU, content: {
			StundenplanUpdateView(updateResult: data.stundenPlanUpdateResult!, data: data, zeigeSPU: $zeigeSPU)
		})

		// MARK: PrüfeOnboarding
		.onChange(of: data.apiCredentials, perform: { _ in
			pruefeOnboarding()
		})
		.onChange(of: data.meineStufe, perform: { _ in
			if !onboarding {
				pruefeOnboarding()
			}
		})
		.onAppear {
			data.busy = false
			data.stundenPlanUpdateResult = nil
			data.serverStatus = nil
			data.versucheStundenplanUpdate()
			pruefeOnboarding()
		}
		// MARK: speichere bevor die App geschlossen wird

		.onChange(of: appState, perform: { _ in
			hapticFeedback(style: .soft)
		})
		.onChange(of: shownSheet, perform: {
			if $0 != nil {
				hapticFeedback(style: .soft)
			}
		})
	}

	public var showSheets: Binding<Bool> { Binding(
		get: { shownSheet != nil && !zeigeSPU},
		set: { _ in shownSheet = nil }
	)
	}

	private func pruefeOnboarding() {
		if data.apiCredentials?.apiPassword ?? "" == "" {
			data.apiCredentials = nil
		}
		if data.apiCredentials == nil || data.meineStufe == nil {
			onboarding = true
			shownSheet = .anmelden
		} else {
			onboarding = false
		}
	}
}
