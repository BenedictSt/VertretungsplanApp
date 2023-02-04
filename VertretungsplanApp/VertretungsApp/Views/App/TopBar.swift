//
//  TopBar.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import SwiftUI

struct TopBar: View {
	@ObservedObject var data: DataModel
	@Binding var shownSheet: SheetTyp?
	@State var showLastFetch = false

	var body: some View {
		ZStack {
			HStack {
				Spacer()
				if showLastFetch {
					if let lastFetch = data.lastFetch {
						Text(DateF.ausfuerlichDatumUhr.string(from: lastFetch))
							.font(.system(.callout, design: .monospaced))
							.onTapGesture { showLastFetch.toggle() }
							.frame(height: 30, alignment: .center)
					} else {
						Text("nicht geladen")
							.onTapGesture { showLastFetch.toggle() }
							.frame(height: 30, alignment: .center)
					}
				} else {
					Image("Schullogo")
						.resizable()
						.scaledToFit()
						.frame(height: 30, alignment: .center)
						.foregroundColor(.themeColor)
						.onLongPressGesture { showLastFetch.toggle() }
				}
				Spacer()
			}

			HStack {
				TopButton(shownSheet: $shownSheet, systemName: "ellipsis.circle", sheet: .einstellungen)

				Spacer()

				Button(action: {
					data.aktualisiere()
				}) {
					if !data.busy {
						Image(systemName: "arrow.clockwise")
							.resizable()
							.scaledToFit()
							.frame(width: 25, height: 25, alignment: .center)
							.foregroundColor(data.lastFetch != nil ? (
								!data.datenAktuell ? Color(red: 0.94, green: 0.61, blue: 0, opacity: 1.0) : .green) : .red)
							.hoverEffect(.highlight)
					} else {
						ProgressView()
							.frame(width: 25, height: 25, alignment: .center)
					}
				}
			}
		}
		.padding([.leading, .trailing], 15)
	}
}

private struct TopButton: View {
	@Binding var shownSheet: SheetTyp?
	let systemName: String
	let sheet: SheetTyp

	var body: some View {
		Button(action: {
			shownSheet = sheet
		}) {
			Image(systemName: systemName)
				.resizable()
				.scaledToFit()
				.frame(width: 25, height: 25, alignment: .center)
				.foregroundColor(Color.themeColor)
		}
		.hoverEffect(.highlight)
	}
}
