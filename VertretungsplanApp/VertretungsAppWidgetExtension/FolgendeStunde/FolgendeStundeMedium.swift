//
//  MediumWidget.swift
//  VertretungsApp3WidgetExtension
//
//  Created by Benedict on 04.07.22.
//

import Foundation
import SwiftUI

struct FolgendeStundeWidgetMedium: View {
	@Environment(\.colorScheme) var appearance

	var entry: FolgendeStunde

	var body: some View {
		HStack {
			GeometryReader { geo in
				FolgendeStundeWidgetSmall(entry: entry, showImage: false)
					.frame(width: geo.size.height)
			}
			ZStack {
				VStack {
					Spacer()
					Image("Schullogo")
						.resizable()
						.scaledToFit()
						.foregroundColor(Color.white)
						.opacity(0.1)
						.clipped()
				}

				VStack(alignment: .leading) {
					if !entry.restTag.isEmpty {
						Text("Kommende Stunden")
							.font(.caption2.weight(.light))
					} else {
						HStack {
							Spacer()
							Text("Alles geschafft!")
								.font(.caption2.weight(.light))
						}

					}

					// swiftlint:disable line_length
					// TODO: @anh das hast du geschrieben
					ForEach(entry.restTag.indices, id: \.self) { entryIndex in
						if entryIndex < 4 {
							if entry.restTag[entryIndex].hatHinweis {
								HStack(spacing: 3) {
									Text(entry.restTag[entryIndex].vFach != "" ? entry.restTag[entryIndex].vFach : entry.restTag[entryIndex].data.kurs.kursKategorie)
										.lineLimit(1)
										.font(.caption.weight(.semibold))
										.foregroundColor(entry.restTag[entryIndex].vFach != "" ? .yellow : .white)
									if entry.restTag[entryIndex].vLehrer != ""{
										Text(entry.restTag[entryIndex].data.kurs.lehrer != entry.restTag[entryIndex].vLehrer ? "\(entry.restTag[entryIndex].vLehrer)" : "")
											.lineLimit(1)
											.font(.caption.weight(.light))
											.foregroundColor(.yellow)
									}
									if entry.restTag[entryIndex].bemerkung != ""{
										Text(entry.restTag[entryIndex].bemerkung)
											.lineLimit(1)
											.font(.caption.weight(.light))
											.foregroundColor(.yellow)
									}
									Spacer()
									Text(entry.restTag[entryIndex].vRaum != "" ? entry.restTag[entryIndex].vRaum : entry.restTag[entryIndex].data.raum)
										.lineLimit(1)
										.font(.caption.weight(.light))
										.foregroundColor(entry.restTag[entryIndex].vFach != "" ? .yellow : .white)
								}
							} else {
								HStack {
									Text(entry.restTag[entryIndex].data.kurs.kursKategorie == Kurs.andereFachName ? entry.restTag[entryIndex].data.kurs.fach : entry.restTag[entryIndex].data.kurs.kursKategorie)
										.font(.caption.weight(.semibold))
									Spacer()
									Text(entry.restTag[entryIndex].data.raum)
										.font(.caption.weight(.light))
								}
							}
						}
					}
					// swiftlint:enable line_length

					if entry.restTag.count > 4 {
						HStack {
							Spacer()
							Text("+ \(entry.restTag.count-4) mehr")
								.font(.caption2.weight(.light))
						}
					}
					Spacer()
					HStack {
						Spacer()
						Text("Ende um " + kalkuliereEndzeit()).font(.caption.weight(.semibold))
					}
				}
				.foregroundColor(.white)
				.padding()
				.padding(.leading, -30)
				.padding(.trailing, -1)
			}
		}
		.background(appearance == .dark ? Color.themeColor : Color.themeColor) // TODO: dark variant
	}
	/// Füge 45 Minuten zu der Startzeit der letzten Stunde
	private func kalkuliereEndzeit() -> String {
		let startZeitLetzteStunde = entry.restTag.last?.startZeit ?? entry.startZeit
		return DateF.timeFromMinute(time: startZeitLetzteStunde + 45)
	}
}
