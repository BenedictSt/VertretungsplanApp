//
//  FolgendeStundeSmall.swift
//  VertretungsApp3WidgetExtension
//
//  Created by Benedict on 04.07.22.
//

import Foundation
import SwiftUI

struct FolgendeStundeWidgetSmall: View {
	@Environment(\.colorScheme) var appearance
	let entry: FolgendeStunde
	let showImage: Bool

	init(entry: FolgendeStunde, showImage: Bool = true) {
		self.entry = entry
		self.showImage = showImage
	}

	var body: some View {
		ZStack {
			if showImage {
				VStack {
					Spacer()
					Image("Schullogo")
						.resizable()
						.scaledToFit()
						.foregroundColor(.white)
						.opacity(0.1)
						.clipped()
				}
			}
			VStack(alignment: .leading) {
				HStack {
					if entry.hatHinweis {
						Image(systemName: getAktualisierungsstatus(date: entry.stand!).systemName)
							.resizable()
							.scaledToFit()
							.frame(width: 15)
							.foregroundColor(getAktualisierungsstatus(date: entry.stand!).color)
					}
					Text("Nächste Stunde")
						.font(.caption2.weight(.light))
					Spacer()
				}

				if entry.hatHinweis {
					Text(entry.vFach == "" ? entry.data.kurs.kursKategorie : entry.vFach)
						.font(.body.weight(.bold))
						.foregroundColor(entry.vFach == "" ? .white : .yellow)
					HStack(spacing: 0) {
						Text((entry.vRaum == "" ? entry.data.raum : entry.vRaum) + " ")
							.font(.body.weight(.light))
							.foregroundColor(entry.vRaum == "" ? .white : .yellow)

						Text(entry.vLehrer == "" ? entry.data.kurs.lehrer : entry.vLehrer)
							.font(.body.weight(.light))
							.foregroundColor(entry.vLehrer == "" ? .white : .yellow)
						Spacer()
					}
					Spacer()
					Text(entry.bemerkung)
						.font(.caption)
						.foregroundColor(.yellow)
				} else {
					Text(entry.data.kurs.kursKategorie == Kurs.andereFachName ? entry.data.kurs.fach : entry.data.kurs.kursKategorie)
						.font(.body.weight(.bold))
					HStack {
						Text(entry.data.raum + " " + entry.data.kurs.lehrer)
							.font(.body.weight(.light))
						Spacer()
					}
					Spacer()
				}
				Text(entry.wochentag + ", " + DateF.timeFromMinute(time: entry.startZeit))
					.font(.caption.weight(.semibold))
			}
			.padding()
			.padding(.leading, -1)
			.padding(.trailing, -1)
			.foregroundColor(Color.white)
		}.background(appearance == .dark ? Color.themeColor : Color.themeColor) // TODO: dark variant
	}

	private func getAktualisierungsstatus(date: Date) -> (systemName: String, color: Color) {
		let timeInterval = (date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate)

		if timeInterval > TimeInterval(-1800) {
			return ("exclamationmark.triangle", .white)
		} else if timeInterval < TimeInterval(-1800) && timeInterval > TimeInterval(-7200) {
			return ("exclamationmark.triangle.fill", .yellow)
		} else {
			return ("exclamationmark.arrow.triangle.2.circlepath", .yellow)
		}
	}
}
