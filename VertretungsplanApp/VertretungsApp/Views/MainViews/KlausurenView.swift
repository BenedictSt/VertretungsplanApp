//
//  KlausurenView.swift
//  
//
//  Created by Benedict on 27.05.22.
//

import SwiftUI

struct KlausurenView: View {
    @Environment(\.colorScheme) var appearance
	@ObservedObject var data: DataModel

    var dateFormatterDatum: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = ", dd.MM.YY"
		dateFormatter.locale = Locale(identifier: "de_DE")
		return dateFormatter
	}

	var body: some View {
		GeometryReader { reader in
			VStack(spacing: 10) {
				HStack {
					Text("Klausuren")
						.font(.largeTitle.bold())
					Spacer()
				}.padding([.leading, .trailing, .top])

				ScrollView {
					LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
						VStack {
							if data.klausuren.isEmpty {
								if data.datenAktuell {
									HStack {
										Text("Keine Klausuren vorhanden.")
										Spacer()
									}
								} else {
									HStack {
										Text("Keine Klausuren geladen.")
										Spacer()
									}
								}
							}
						}.font(.callout)
						.foregroundColor(.gray)
						.padding([.leading, .trailing])
						.padding([.top], 5)
						ForEach(data.klausuren.keys.sorted()) { day in
							Section(content: {
								VStack(spacing: 0) {
									let klausuren = data.klausuren[day]!
									ForEach(klausuren) { klausur in
										HStack {
											ZeitView(klausur: klausur)
												.frame(width: min(reader.size.width * 0.25, 200), alignment: .leading)
											Text(klausur.bemerkung)
												.font(.body.bold())
											Spacer()
											Text(klausur.raum)
												.font(.body.weight(.regular))
										}
										.padding([.leading, .trailing])
										.frame(height: 60)
										if klausur != klausuren.last! {
											Divider()
										}
									}
								}
							}, header: {
								ZStack {
									Divider().background(Color.themeColor)

									HStack {
										Text(DateF.ersetzeHeuteMorgen(date: day, formatter: DateF.ausfuerlichDatum))
											.font(.title2.bold())
											.foregroundColor(Color.themeColor)
											.padding(.trailing, 5)
											.background(Color(UIColor.systemBackground))
										Spacer()
									}
								}
								.padding([.leading, .trailing], 15)
								.padding(.top, 10)
								.background(appearance == .dark ? Color.black : Color.white)
							})
						}
					}
				}
			}
		}
	}
}

extension Date: Identifiable {
	public var id: Int {
		self.hashValue
	}
}

private struct ZeitView: View {
	@Environment(\.colorScheme) var appearance
	let klausur: Klausur
	var body: some View {
		VStack {
			Text("\(klausur.von.numberStr). bis \(klausur.bis.numberStr).")
				.font(.title3.weight(.heavy))
				.opacity(appearance == .dark ? 0.75 : 0.3)

			let startZeit = klausur.von.start
			let dauer = 45 * (klausur.bis.number - klausur.von.number)
			Text(klausur.von.sek2StartTimeLabel + " - " + DateFormatter.timeFromMinute(time: startZeit + dauer))
				.font(.caption2)
				.foregroundColor(.gray)
		}
	}
}
