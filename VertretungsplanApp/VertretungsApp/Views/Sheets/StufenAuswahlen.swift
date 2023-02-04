//
//  StufenAuswahl.swift
//  
//
//  Created by Benedict on 24.05.22.
//

import SwiftUI

struct StufenAuswahl: View {
	@ObservedObject var data: DataModel
	@State var selectedStufe: String?
	let onboarding: Bool

	var body: some View {
		ZStack {
			VStack {
				Text("Wähle deine Stufe aus!")
					.font(.title.bold())
					.padding(.top, 40)

				ScrollView {
					// TODO: hier vielleich ein grid in dem die einzelnen Stufen in einer Reihe sind. vlt. noch mal mit IK nachgucken
					VStack {
						ForEach(data.alleStufenNamen.sorted(by: {$0.numberPartAsInt < $1.numberPartAsInt}), id: \.self) { stufenName in
							HStack {
								Image(systemName: stufenName == selectedStufe ? "checkmark.circle" : "circle")
								Text(stufenName)
							}
							.frame(height: 30, alignment: .leading)
							.onTapGesture {
								selectedStufe = stufenName
							}
							.clipped()

							Divider()
						}
					}
				}

				Spacer()

				Button(action: {
					data.meineStufe = selectedStufe
					data.saveToDisk()
					data.ladeStundenplan()
				}) {
					HStack(alignment: .center) {
						Spacer()
						if data.busy {
							ProgressView()
						} else {
							Text(onboarding ? "Weiter" : "Fertig")
								.foregroundColor(Color.white)
								.bold()
						}
						Spacer()
					}

				}.padding()
					.background(selectedStufe != nil ? Color.themeColor : Color(UIColor.tertiaryLabel))
					.disabled(selectedStufe == nil || data.busy)
					.cornerRadius(10)
			}.padding()

		}
	}
}
