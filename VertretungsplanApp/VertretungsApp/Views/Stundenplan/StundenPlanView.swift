//
//  StundenPlanView.swift
//
//
//  Created by Benedict on 13.05.22.
//

import SwiftUI

struct StundenPlanView: View {
	@Environment(\.colorScheme) var appearance
	@ObservedObject var data: DataModel
	@ObservedObject var stpCon: StundenplanConvenience
	@Binding var shownSheet: SheetTyp?
	@Binding var editMode: Bool

	init(data: DataModel, shownSheet: Binding<SheetTyp?>, editMode: Binding<Bool>) {
		self.data = data
		stpCon = data.stundenplanConvenience
		self._shownSheet = shownSheet
		self._editMode = editMode
	}

	var body: some View {
		GeometryReader { reader in
			VStack {
				StundenplanViewHeader(data: data, shownSheet: $shownSheet, editMode: $editMode)
					.padding()
				ScrollViewReader { scrollReader in
					ZStack {
						ScrollView(showsIndicators: false) {
							if !data.hatEigeneKurseAnTag(stpCon.selectedDay) && !stpCon.zeigeAlle && !editMode {
								// MARK: keine eignenen Kurse
								VStack(alignment: .leading, spacing: 25) {
									Text("Du hast keine Stunden für dich selber für den \(stpCon.selectedDay.string) ausgewählt.")
										.multilineTextAlignment(.leading)
										.foregroundColor(.gray)

									VStack(spacing: 15) {
										Button(action: {
											stpCon.zeigeAlle = true
										}) {
											Image(systemName: "arrow.right")
											Text("Zeige den Stundenplan mit allen Kursen an")
											Spacer()
										}


										Button(action: {
											editMode = true
										}) {
											Image(systemName: "arrow.right")
											Text("Meine Kurse auswählen")
											Spacer()
										}
										Spacer()
									}.foregroundColor(.themeColor)
								}.padding()
							} else {
								LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
								ForEach(1...12, id: \.self) {iStunde in
									if !data.getSlot(stpCon.selectedDay, .init(iStunde), meine: !stpCon.zeigeAlle && !editMode).isEmpty {
										let istAktuell = data.getIstAktuelleStundeInStundenplan(tag: stpCon.selectedDay,
																									 stunde: iStunde,
																									 meine: !stpCon.zeigeAlle)
										Section(content: {
											// MARK: Stundenplan-Items
											let entries = data.getSlot(stpCon.selectedDay, .init(iStunde), meine: !stpCon.zeigeAlle && !editMode)
											ForEach(entries, id: \.self) { entry in
												StundenPlanItemView(entry: entry,
																	data: data,
																	stpCon: stpCon,
																	editMode: $editMode,
																	iStunde: iStunde,
																	istAktuell: istAktuell)
												if editMode || stpCon.zeigeAlle {
													if entries.last != entry {
														Divider()
															.padding([.leading, .trailing])
													}
												} else {
													if Stunde.intMap[iStunde] ?? .andere != (Stunde.alle.last(where: { stunde in
														!(data.stundenplan[stpCon.selectedDay]?[stunde]?.davonMeine(data.meineKurse).isEmpty ?? true)
													}) ?? .andere) {
														Divider()
													}
												}
											}
										}, header: {
											// MARK: Stundenzeitangabe
											if stpCon.zeigeAlle == true || editMode == true {
												HStack {
													Text("\(Stunde.init(iStunde).numberStr).")
														.font(.body.weight(.heavy))
													Text("\(Stunde.init(iStunde).label)")
														.font(.callout)
													VStack {
														Divider().background(Color.themeColor)
													}
													if istAktuell {
														Text("Jetzt")
															.font(.caption)
															.foregroundColor(Color.themeColor)
													}
												}
												.padding([.leading, .trailing], 15)
												.padding(.top, 10)
												.foregroundColor(istAktuell ? Color.themeColor : .gray)
												.background(appearance == .dark ? Color.black : Color.white)
											}
										})
									}
								}
								Spacer(minLength: 100)
							}
							}
						}.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
								withAnimation {
									scrollReader.scrollTo("zeiger", anchor: .center)
								}
							}
						}
						.onChange(of: stpCon.selectedDay) { _ in
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
								withAnimation {
									scrollReader.scrollTo("zeiger", anchor: .center)
								}
							}
						}

						.onTapGesture(count: 2) {
							if editMode {
								hapticFeedback(style: .heavy)
								editMode = false
								stpCon.zeigeAlle = false
							} else {
								hapticFeedback(style: .soft)
								stpCon.zeigeAlle.toggle()
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
									withAnimation {
										scrollReader.scrollTo("zeiger", anchor: .center)
									}
								}
							}

						}
						.onLongPressGesture(perform: {
							hapticFeedback(style: .heavy)
							editMode.toggle()
						})

						VStack {
							Spacer()
							WeekdaySelectionView(stpCon: stpCon, width: reader.size.width, scrollReader: scrollReader)
								.padding(.bottom, 15)
						}
					}.padding(.top, -20)

				}
			}.frame(width: reader.size.width, alignment: .bottom)
				.onAppear {
					data.updateLetzteMinuteInTag() // TODO: da gibts bestimmt eine bessere Stelle
					stpCon.stundenplanAppear()
				}
				.onDisappear {
					editMode = false
				}
		}
	}
}

// swiftlint:disable private_over_fileprivate
fileprivate struct StundenplanViewHeader: View {
	@ObservedObject var data: DataModel
	@ObservedObject var stpCon: StundenplanConvenience
	@Binding var shownSheet: SheetTyp?
	@Binding var editMode: Bool

	init(data: DataModel, shownSheet: Binding<SheetTyp?>, editMode: Binding<Bool>) {
		self.data = data
		stpCon = data.stundenplanConvenience
		self._shownSheet = shownSheet
		self._editMode = editMode
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text(stpCon.selectedDay.string)
					.font(Font.largeTitle.bold())
				Spacer()
				if editMode {
					Button(action: {
						exportToPDFAndOpenDialog(data: data)
					}) {
						Image(systemName: "square.and.arrow.up")
							.font(.title2)
							.foregroundColor(.themeColor)

					}.padding(.trailing, 10)

					Button(action: {
						shownSheet = .stunden
					}) {
						Image(systemName: "list.bullet")
							.font(.title2)
							.foregroundColor(.themeColor)

					}.padding(.trailing, 10)
				}

				Button(action: {editMode.toggle()}) {
					Image(systemName: editMode ? "checkmark" : "calendar.badge.plus")
						.font(.title2)
						.foregroundColor(.themeColor)
				}

				if !editMode {
					Button(action: {stpCon.zeigeAlle.toggle()}) {
						Image(systemName: stpCon.zeigeAlle ? "person.3" : "person")
							.font(.title2)
							.foregroundColor(.themeColor)
					}.padding(.leading, 10)
				}
			}
			HStack(spacing: 3) {
				if editMode {
					Text("Stundenplan bearbeiten")
				} else if stpCon.zeigeAlle {
					Text("Stundenplan")
				} else {
					Text("Mein Stundenplan")
				}
			}
			.font(.body.weight(.regular))
			.foregroundColor(.gray)
		}
	}

}
