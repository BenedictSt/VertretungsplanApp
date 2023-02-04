//
//  VertretungsView.swift
//  
//
//  Created by Benedict on 31.05.22.
//

import SwiftUI

struct VertretungsView: View {
	@Environment(\.colorScheme) var appearance
	@ObservedObject var data: DataModel

	@State var refreshing = false
	@ObservedObject var stpCon: StundenplanConvenience
	@State var zeigeVergangene = false

	init(data: DataModel) {
		self.data = data
		stpCon = data.stundenplanConvenience
	}

	var body: some View {
		VStack(spacing: 10) {
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Text("Vertretung")
						.font(.largeTitle.bold())
					Spacer()
					Button(action: {stpCon.zeigeAlle.toggle()}) {
						Image(systemName: stpCon.zeigeAlle ? "person.3" : "person")
							.font(.title2)
							.foregroundColor(.themeColor)
					}
				}
				if stpCon.zeigeAlle {
					Text("Alle Vertretungen")
						.font(.body.weight(.regular))
						.foregroundColor(.gray)
				} else {
					Text("Meine Vertretungen")
						.font(.body.weight(.regular))
						.foregroundColor(.gray)
				}
			}.padding(.top, -5)
				.padding()

			RefreshableScrollView( refreshing: $refreshing, content: {

				LazyVStack(alignment: .center, pinnedViews: [.sectionHeaders]) {
					if !vertretungenVorhanden() {
						HStack {
							if data.datenAktuell {
								Text("Keine Änderungen \(stpCon.zeigeAlle ? "" : "in deinem Stundenplan ")vorhanden.")
							} else {
								Text("Keine Änderungen \(stpCon.zeigeAlle ? "" : "für deinen Stundenplan ")geladen.")
							}
							Spacer()
						}.font(.callout)
						.foregroundColor(.gray)
							.padding([.leading, .top, .bottom])
					}

					let allKeys = Array(Set(data.vertretung.keys).union(Set(data.vertretungKopfzeilen.keys)))
					ForEach(allKeys.sorted()) { day in
						let vertretungen = vertretungen(tag: day)
						let kopfzeile = data.vertretungKopfzeilen[day]

						let sameDay = DateF.ausfuerlichDatum.string(from: day) == DateF.ausfuerlichDatum.string(from: Date())
						let alteVertretungen = vertretungen.filter({$0.stunde.end + 5 < Date().minutesInDay && sameDay})
						let aktuelleVertretungen = vertretungen.filter({!alteVertretungen.contains($0)})

						if kopfzeile != nil || !vertretungen.isEmpty {
							Section(content: {
								VStack(spacing: 0) {
									if let kopfzeile = kopfzeile {
										HStack {
											RoundedRectangle(cornerRadius: 100)
												.fill(Color.themeColor)
												.frame(width: 3)
											Text(kopfzeile)
												.font(.callout)
												.foregroundColor(.gray)
											Spacer()
										}
										.padding([.leading, .trailing])
										.padding([.top, .bottom], 5)
									}
									if !vertretungenVorhanden() || (aktuelleVertretungen.isEmpty && !zeigeVergangene) {
										HStack {
											if data.datenAktuell {
												Text("Keine weiteren Änderungen \(stpCon.zeigeAlle ? "" : "in deinem Stundenplan ")vorhanden.")
											} else {
												Text("Keine weiteren Änderungen \(stpCon.zeigeAlle ? "" : "für deinen Stundenplan ")geladen.")
											}
											Spacer()
										}
										.font(.callout)
											.foregroundColor(.gray)
											.padding([.leading, .trailing])
											.padding([.top], 5)
									}
									if !alteVertretungen.isEmpty && zeigeVergangene {
										VertretungsListe(vertretungen: alteVertretungen)
										HStack(spacing: 0) {
										Circle()
												.frame(width: 10, height: 10)
												.foregroundColor(.themeColor)
										Rectangle()
												.frame(height: 1.5)
											.foregroundColor(.themeColor)
										}.padding(3)
									}
									VertretungsListe(vertretungen: aktuelleVertretungen)
								}.padding(.top, -10)
							}, header: {
								VStack {
									HStack {
										if !alteVertretungen.isEmpty {
											Button(action: {
												zeigeVergangene.toggle()
											}) {
												Image(systemName: zeigeVergangene ? "eye.slash" : "clock.arrow.circlepath")
													.resizable()
													.scaledToFit()
													.frame(width: 17.5)
													.foregroundColor(.themeColor)
											}
										}

										Text(DateF.ersetzeHeuteMorgen(date: day, formatter: DateF.ausfuerlichDatum))
												.font(.body.weight(.semibold))
												.foregroundColor(Color.themeColor)
										Spacer()
										VStack {
											Divider().background(Color.themeColor)
										}
									}
									.padding([.leading, .trailing], 15)
									.padding(.top, 10)
									.background(appearance == .dark ? Color.black : Color.white)
								}
							})
						}
					}
				}
			}).padding(.top, -20)
			.onChange(of: refreshing, perform: { neu in
				if neu {
					data.aktualisiere()
				}
			})
			.onChange(of: data.busy) { neu in
				refreshing = neu
			}
		}
		.onTapGesture(count: 2) {
			hapticFeedback(style: .soft)
			stpCon.zeigeAlle.toggle()
		}
	}

	private func vertretungen(tag: Date) -> [VertretungsItem ] {
		return data.vertretung[tag]?.filter({
			stpCon.zeigeAlle || data.meineKurse.contains($0.kurs)
		}) ?? []
	}

	private func vertretungenVorhanden() -> Bool {
		return data.vertretung.keys.contains(where: { tag in
			!vertretungen(tag: tag).isEmpty
		}) || !data.vertretungKopfzeilen.isEmpty
	}
}

private struct VertretungsItemView: View {
	@Environment(\.colorScheme) var appearance
	let item: VertretungsItem
	var body: some View {
		ZStack(content: {
			HStack(spacing: 15) {
				Text("\(item.stunde.numberStr)")
					.font(.title.weight(.heavy))
					.opacity(appearance == .dark ? 0.75 : 0.3)
					.frame(width: 40)
				VStack(alignment: .leading, spacing: 0) {
					Text(item.kurs)
						.font(.headline.weight(.heavy).monospacedDigit())
					if item.vText != ""{
						Text(item.vText)
							.font(.caption.weight(.regular))
					}
				}
				Spacer()
				VStack(alignment: .trailing, spacing: 0) {
					if item.vRaum != ""{
						Text(item.vRaum)
							.font(.headline.weight(.regular))
					}
					if item.bemerkung != ""{
						Text(item.bemerkung)
							.font(.caption.weight(.regular))
					}
				}
			}
			.padding([.leading, .trailing])
		}).frame(height: 50)
			.padding(.leading, 0)
			.padding(.trailing, 5)
			.padding([.top, .bottom], 5)
			.foregroundColor(Color.primary)
	}
}

struct VertretungsListe: View {
	let vertretungen: [VertretungsItem]
	var body: some View {
		ForEach(vertretungen, id: \.self) { vertretung in
			VertretungsItemView(item: vertretung)
			if vertretung != vertretungen.last! {
				Divider()
			}
		}
	}
}
