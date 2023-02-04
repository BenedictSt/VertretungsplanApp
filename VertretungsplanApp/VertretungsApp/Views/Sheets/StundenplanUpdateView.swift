//
//  StundenplanUpdateView.swift
//  
//
//  Created by Benedict on 13.06.22.
//

import SwiftUI

struct StundenplanUpdateView: View {
	let updateResult: StundenplanUpdateResult
	@ObservedObject var data: DataModel
	@Binding var zeigeSPU: Bool
	@State var meine = true

	var body: some View {
		VStack(alignment: .leading) {
			Text("Veränderungen")
				.font(.largeTitle.bold())
			Text("im neuen Stundenplan")
				.font(.body.italic())

			HStack {
				Button(action: {meine = false}) {
					HStack(alignment: .center) {
						Spacer()
						Text("alle")
							.foregroundColor(Color.white)
							.bold()
						Spacer()
					}
				}
				.padding(7)
				.background(!meine ? Color.themeColor : Color(UIColor.tertiaryLabel))
				.cornerRadius(7)

				Button(action: {meine = true}) {
					HStack(alignment: .center) {
						Spacer()
						Text("meine")
							.foregroundColor(Color.white)
							.bold()
						Spacer()
					}
				}
				.padding(7)
				.background(meine ? Color.themeColor : Color(UIColor.tertiaryLabel))
				.cornerRadius(7)
			}

			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading) {
					Spacer(minLength: 20)
					let meineKurse = data.meineKurse

					if meine && !updateResult.hatMeineAenderungen(data: data) {
						Text("An deinem Stundenplan hat sich nichts verändert.")
							.multilineTextAlignment(.leading)
					}


					// MARK: - Raumverlegungen
					let raumVerlegungen = updateResult.raumVerlegungen.davonMeine(meineKurse, active: meine)
					if !raumVerlegungen.isEmpty {
						Text("\(Image(systemName: "arrow.triangle.swap")) Raumverlegungen")
							.font(.title.bold())
						ForEach(raumVerlegungen, id: \.self) { verlegung in
							let kurs = verlegung.stunde.kurs
							HStack {
								Text("\(kurs.fach) \(kurs.lehrer) ")
									.font(.body.weight(.heavy).monospacedDigit())
									.frame(width: 150, height: 25, alignment: .center)
									.background(Color.gray)
									.foregroundColor(.primary)

								Text(verlegung.stundeStr)
									.font(.body.weight(.bold))

								Spacer()
								Text(verlegung.alterRaum)
								Image(systemName: "arrow.right")
									.foregroundColor(.themeColor)
								Text(verlegung.stunde.raum)
									.font(.body.weight(.semibold))

							}
						}
						Divider()
							.padding(.bottom, 20)
					}

					// MARK: - neue Kurse
					let neueKurse = updateResult.neueKurse
					if !neueKurse.isEmpty {
						Text("\(Image(systemName: "plus")) Neue Kurse")
							.font(.title.bold())
						ForEach(neueKurse, id: \.self) { kurs in
							HStack {
								Text(kurs.fach)
									.font(.body.weight(.heavy).monospacedDigit())
									.frame(width: 100, height: 25, alignment: .center)
									.background(Color.gray)
									.foregroundColor(.primary)

								Text(kurs.lehrer)
									.font(.body.weight(.semibold).monospacedDigit())
									.frame(height: 25, alignment: .leading)
								Spacer()

								Button(action: {
									data.meineKurse.toggle(kurs.name)
								}) {
									Image(systemName: data.meineKurse.contains(where: { kurs.name == $0}) ? "minus.circle" : "plus.circle")
										.foregroundColor(.themeColor)
								}
							}
						}
						Divider()
							.padding(.bottom, 20)
					}

					// MARK: - gelöschte Kurse
					let gelöschteKurse = updateResult.gelöschteKurse.davonMeine(meineKurse, active: meine)
					if !gelöschteKurse.isEmpty {
						Text("\(Image(systemName: "minus")) Fehlende Kurse")
							.font(.title.bold())
						ForEach(gelöschteKurse, id: \.self) { kurs in
							HStack {
								Text(kurs.fach)
									.font(.body.weight(.heavy).monospacedDigit())
									.frame(width: 100, height: 25, alignment: .center)
									.background(Color.gray)
									.foregroundColor(.primary)

								Text(kurs.lehrer)
									.font(.body.weight(.semibold).monospacedDigit())
									.frame(height: 25, alignment: .leading)
								Spacer()
							}
						}
						Divider()
							.padding(.bottom, 20)
					}

					// MARK: neueStunden
					let neueStunden = updateResult.neueStunden.davonMeine(meineKurse, active: meine)
					if !neueStunden.isEmpty {
						Text("\(Image(systemName: "plus")) Neue Stunden")
							.font(.title.bold())
						ForEach(neueStunden, id: \.self) { stunde in
							let kurs = stunde.stunde.kurs
							HStack {

								Text(stunde.zeit)
									.frame(width: 100, height: 25, alignment: .center)
									.background(Color(UIColor.quaternaryLabel))
									.font(.body.weight(.bold).monospacedDigit())

								Text("\(kurs.fach) \(kurs.lehrer) ")
									.font(.body.monospacedDigit())

								Spacer()

								Text(stunde.stunde.raum)
									.font(.callout.weight(.light))
							}
						}
						Divider()
							.padding(.bottom, 20)
					}

					// MARK: fehlende Stunden
					let fehlendeStunden = updateResult.fehlendeStunden.davonMeine(meineKurse, active: meine)
					if !fehlendeStunden.isEmpty {
						Text("\(Image(systemName: "minus")) Fehlende Stunden")
							.font(.title.bold())
						ForEach(fehlendeStunden, id: \.self) { stunde in
							let kurs = stunde.stunde.kurs
							HStack {

								Text(stunde.zeit)
									.frame(width: 100, height: 25, alignment: .center)
									.background(Color(UIColor.quaternaryLabel))
									.font(.body.weight(.bold).monospacedDigit())

								Text("\(kurs.fach) \(kurs.lehrer) ")
									.font(.body.monospacedDigit())

								Spacer()

								Text(stunde.stunde.raum)
									.font(.callout.weight(.light))
							}
						}
						Divider()
							.padding(.bottom, 20)
					}
				}
			}

			// MARK: buttons
			Button(action: {
				zeigeSPU = false
			}) {
				HStack(alignment: .center) {
					Spacer()
					Text("nicht aktualisieren")
						.foregroundColor(Color.white)
						.bold()
					Spacer()
				}

			}
			.padding()
			.background(Color(UIColor.tertiaryLabel))
			.cornerRadius(10)

			Button(action: {
				data.ladeStundenplan()
				zeigeSPU = false
			}) {
				HStack(alignment: .center) {
					Spacer()
					Text("Änderungen übernehmen")
						.foregroundColor(Color.white)
						.bold()
					Spacer()
				}
			}
			.padding()
			.background(Color.themeColor)
			.cornerRadius(10)

		}.padding()
			.interactiveDismissDisabled(true)
			.onAppear {
				if !updateResult.hatMeineAenderungen(data: data) {
					meine = false
				}
			}
	}
}

// TODO: muss wahrscheinlich weg
struct StundenplanUpdateViewDemoData {

	public static func re() -> StundenplanUpdateResult {
		typealias StundeMitDatum = StundenplanUpdateResult.StundeMitDatum
		typealias RaumUpdate = StundenplanUpdateResult.RaumUpdate
		let updateResult = StundenplanUpdateResult()
		updateResult.neueKurse = [Kurs(lehrer: "FEIC", fach: "ML2"), Kurs(lehrer: "FINN", fach: "ML1")]
		updateResult.gelöschteKurse = [Kurs(lehrer: "LERS", fach: "D5"), Kurs(lehrer: "HOPF", fach: "SWL2")]
		updateResult.fehlendeStunden = [
			StundeMitDatum(stunde: StundenPlanItem(raum: "9:05", kurs: Kurs(lehrer: "LERS", fach: "D5")), zeit: "Mo, 4")
		]

		updateResult.neueStunden = [
			StundeMitDatum(stunde: StundenPlanItem(raum: "9:05", kurs: Kurs(lehrer: "LERS", fach: "D5")), zeit: "Di, 1")
		]

		updateResult.raumVerlegungen = [
			RaumUpdate(stunde: updateResult.fehlendeStunden[0].stunde, stundeStr: "Mo, 1", alterRaum: "bad")
		]

		updateResult.failed = false

		return updateResult
	}
}
