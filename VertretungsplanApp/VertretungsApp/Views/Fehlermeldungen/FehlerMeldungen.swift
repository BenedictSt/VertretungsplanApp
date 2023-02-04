//
//  FehlerMeldungen.swift
//  
//
//  Created by Benedict on 25.05.22.
//

import SwiftUI

class Fehlermeldungen {
	// MARK: - kein Internet
	struct KeinInternet: View {
		var action: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "wifi.slash",
				title: "Fehlgeschlagen",
				message: "Prüfe deine Internet Verbindung",
				buttons: [
					FehlerButton(title: "OK", action: {action()})
				])
		}
	}

	// MARK: - allgemeiner Fehler
	struct AllgemeinerFehler: View {
		var action: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "exclamationmark.triangle",
				title: "Es ist ein Fehler aufgetreten",
				message: "Versuche es später erneut.",
				buttons: [
					FehlerButton(title: "OK", action: {action()})
				])
		}
	}

	// MARK: - Timeout
	struct Timeout: View {
		var action: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "hourglass.tophalf.filled",
				title: "Server nicht erreichbar",
				message: "Versuche es später erneut.",
				buttons: [
					FehlerButton(title: "OK", action: {action()})
				])
		}
	}

	// MARK: - Auth
	struct Auth: View {
		var action: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "key",
				title: "Anmeldedaten falsch",
				message: "Anmeldename und Passwort stimmen nicht überrein.",
				buttons: [
					FehlerButton(title: "OK", action: {action()})
				])
		}
	}

	// MARK: - AuthGoToSettings
	struct AuthGoToSettings: View {
		var okAction: () -> Void
		var settings: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "key",
				title: "Anmeldedaten falsch",
				message: "Anmeldename und Passwort stimmen nicht überrein.",
				buttons: [
					FehlerButton(title: "Prüfen", action: {settings()}),
					FehlerButton(title: "OK", action: {okAction()})
				])
		}
	}

	// MARK: - AuthGoToSettings
	struct StundenplanExistiertNicht: View {
		var okAction: () -> Void
		var neuLaden: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "calendar.badge.exclamationmark",
				title: "Stundenplan existiert nicht!",
				message: "Der angeforderte Stundenplan existiert nicht.",
				buttons: [
					FehlerButton(title: "OK", action: {okAction()}),
					FehlerButton(title: "Aktualisieren", action: {neuLaden()})
				])
		}
	}

	// MARK: - keinStundenplanUpdate
	struct StundenplanAktuell: View {
		var action: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "checkmark",
				title: "Kein Update verfügbar.",
				message: "Dein Stundenplan befindet sich auf dem aktuellsten Stand.",
				buttons: [
					FehlerButton(title: "OK", action: {action()})
				])
		}
	}

	// MARK: - stundenplanUpdateFehlgeschlagen
	struct StundenplanUpdateFehlgeschlagen: View {
		var action: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "exclamationmark.arrow.triangle.2.circlepath",
				title: "Fehler beim Prüfen eines Updates",
				message: "Versuche es später erneut.",
				buttons: [
					FehlerButton(title: "OK", action: {action()})
				])
		}
	}

	// MARK: - neuer Stundenplan Verfügbar
	struct NeuerStundenplanDa: View {
		var laden: () -> Void
		var ansehen: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "calendar.badge.exclamationmark",
				title: "Neuer Stundenplan",
				message: "Es ist ein neuer Stundenplan vorhanden.",
				buttons: [
					FehlerButton(title: "Laden", action: {laden()}),
					FehlerButton(title: "Ansehen", action: {ansehen()})
				])
		}
	}

	// MARK: - neuer Stundenplan Verfügbar mit eigenen Änderungen
	struct NeuerStundenplanDaMitEigen: View {
		var laden: () -> Void
		var ansehen: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "calendar.badge.exclamationmark",
				title: "Neuer Stundenplan",
				message: "Es ist ein neuer Stundenplan vorhanden. Auch an deinen Kursen hat sich etwas verändert.",
				buttons: [
					FehlerButton(title: "Laden", action: {laden()}),
					FehlerButton(title: "Ansehen", action: {ansehen()})
				])
		}
	}

	// MARK: - keinen Zugriff auf iOS Kalender
	struct KeinenKalenderZugriff: View {
		var deaktivieren: () -> Void
		var ausblenden: () -> Void
		var body: some View {
			AllgemeineFehlermeldung(
				symbol: "calendar.badge.exclamationmark",
				title: "Kein Zugriff",
				message: "Um deinen Stundenplan zum iOS-Kalender hinzufügen zu können, " +
				"braucht die VertretungsApp Zugriff auf den Kalender.",
				buttons: [
					FehlerButton(title: "Deaktivieren", action: { deaktivieren() }),
					FehlerButton(title: "Erlauben", action: {
						UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
						ausblenden()
					})
				])
		}
	}

	// MARK: - private helper
	private struct AllgemeineFehlermeldung: View {
		let symbol: String
		let title: String
		let message: String
		let buttons: [FehlerButton]

		var body: some View {
			VStack {
				Image(systemName: symbol)
					.resizable()
					.aspectRatio(contentMode: ContentMode.fit)
					.frame(width: 30, height: 30)
				Text(title)
					.font(.title2)
				Text(message)
					.multilineTextAlignment(.center)
					.padding(.top, 5)

				HStack {
					ForEach(buttons, id: \.self) { button in
						button
					}
				}
			}
			.padding(20)
			.background(Color(UIColor.tertiarySystemBackground))
			.cornerRadius(20)
			.shadow(radius: 10)
		}

	}

	private struct FehlerButton: View, Hashable {
		let title: String
		let action: () -> Void

		var body: some View {
			Button(action: {
				action()}
			) {
				Text(title)
					.foregroundColor(.white)
					.padding(5)
					.font(.headline)
					.frame(width: 100, height: 30, alignment: .center)
					.background(Color.themeColor)
					.cornerRadius(8)
					.padding(.top, 20)
			}
		}

		// MARK: Hashable
		static func == (lhs: Fehlermeldungen.FehlerButton, rhs: Fehlermeldungen.FehlerButton) -> Bool {
			lhs.title == rhs.title
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(title)
		}
	}
}
