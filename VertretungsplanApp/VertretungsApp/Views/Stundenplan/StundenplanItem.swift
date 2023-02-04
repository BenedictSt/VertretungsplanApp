//
//  StundenplanItem.swift
//  
//
//  Created by Benedict on 18.08.22.
//

import Foundation
import SwiftUI

struct StundenPlanItemView: View {
	@Environment(\.colorScheme) var appearance
	init(entry: StundenPlanItem, data: DataModel, stpCon: StundenplanConvenience,
		 editMode: Binding<Bool>, iStunde: Int, istAktuell: Bool) {
		self.entry = entry
		self.data = data
		self.stpCon = stpCon
		_editMode = editMode
		self.iStunde = iStunde
		self.istAktuell = istAktuell
	}
	@ObservedObject var stpCon: StundenplanConvenience
	@ObservedObject var data: DataModel
	@Binding var editMode: Bool
	let entry: StundenPlanItem
	let iStunde: Int
	let istAktuell: Bool

	var body: some View {
		ZStack(content: {
			HStack(spacing: 15) {
				if stpCon.zeigeAlle == false && editMode == false {
					Text("\(Stunde.init(iStunde).numberStr)")
						.font(.title.weight(.heavy))
						.opacity(istAktuell ? 1 : 0.6)
						.frame(width: 40)
						.foregroundColor(Color.themeColor)
				} else if editMode == true {
					Image(systemName: data.meineKurse.contains(where: {$0 == entry.kurs.name}) ?
						  "checkmark.circle.fill" : "circle")
					.resizable()
					.scaledToFit()
					.frame(width: 15)
					.foregroundColor(data.meineKurse.contains(where: {$0 == entry.kurs.name}) ? Color.themeColor : .primary)
				}
				VStack(alignment: .leading, spacing: 0) {
					HStack(spacing: 5) {
						Text(entry.kurs.fach)
							.font(.headline.weight(.heavy).monospacedDigit())
						Text(entry.kurs.lehrer)
							.font(.headline.weight(.regular))
					}
					if stpCon.zeigeAlle == false && editMode == false {
						Text("\(Stunde.init(iStunde).label)")
							.font(.caption)
							.foregroundColor(data.meineKurse.contains(entry.kurs.name) && stpCon.zeigeAlle ||
											 istAktuell ? Color.themeColor : .gray)
					}
				}
				Spacer()
				Text(entry.raum)
					.font(.headline.weight(.regular))
			}
			.padding([.leading, .trailing])
		}).frame(height: editMode || stpCon.zeigeAlle ? 40 : 50)
			.padding(.leading, 0)
			.padding(.trailing, 5)
			.padding([.top, .bottom], 5)
			.foregroundColor((data.meineKurse.contains(entry.kurs.name) && stpCon.zeigeAlle) ||
							 (editMode && data.meineKurse.contains(where: {$0 == entry.kurs.name}) ||
							  (istAktuell && !stpCon.zeigeAlle && !editMode)) ?  Color.themeColor : .primary)
			.onTapGesture {
				if editMode {
					if(data.meineKurse.contains(where: {$0 == entry.kurs.name})) {
						data.meineKurse.removeAll(where: {$0 == entry.kurs.name})
					} else {
						data.meineKurse.append(entry.kurs.name)
					}
				}
			}
	}
}
