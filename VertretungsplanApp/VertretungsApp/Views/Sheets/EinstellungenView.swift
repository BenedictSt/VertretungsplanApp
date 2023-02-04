//
//  EinstellungenView.swift
//  
//
//  Created by Benedict on 27.05.22.
//

import SwiftUI

struct EinstellungenView: View {
	let data: DataModel
	@Binding var shownSheet: SheetTyp?
	@Binding var update: UUID

	var body: some View {
		ZStack {
			ScrollView(showsIndicators: false) {
				VStack {
					Group {
						Text("Einstellungen")
							.bold()
							.font(.largeTitle)
							.padding(.top, 50)

						MovingLogo()
							.id(update)
							.onLongPressGesture {
								update = UUID()
								hapticFeedback(style: .medium)
							}
					}

					// MARK: Logout
					if let cred = data.apiCredentials {
						EinstellungsItem(icon: "lock",
										 beschreibung: "Angemeldet als:\n\(cred.username)",
										 buttonText: "Abmelden",
										 action: {
											data.apiCredentials = nil
											shownSheet = .anmelden
										})
					}

					// MARK: ändere Stufe
					EinstellungsItem(icon: "person.2.crop.square.stack",
									 beschreibung: "Stufe: \(data.meineStufe ?? "-")",
									 buttonText: "Ändern",
									 action: {shownSheet = .stufen})

					// MARK: StundenplanAktualisieren
					if let stundenplanStand = data.letzterUpdateFetch {
						EinstellungsItem(icon: "arrow.triangle.2.circlepath",
										 beschreibung: "Stundenplan Stand: \(DateF.deutschesDatum.string(from: stundenplanStand))",
										 buttonText: "Aktualisieren",
										 action: {data.versucheStundenplanUpdate(inBackground: false)})
					}

					// MARK: Farbe ändern
					ColorTheme(update: $update)

					// MARK: Background App Refresh
					switch UIApplication.shared.backgroundRefreshStatus {
					case .available:
						EinstellungsItem(icon: "battery.100",
										 beschreibung: "Lade Daten im Hintergrund",
										 buttonText: "Deaktivieren",
										 action: {
											shownSheet = nil
											UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
										})
					case .denied:
						EinstellungsItem(icon: "battery.75",
										 beschreibung: "Lädt Daten nicht im Hintergrund",
										 buttonText: "Aktivieren",
										 action: {
											shownSheet = nil
											UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
										})
					default:
						EmptyView()
					}


					// MARK: Stundenplan zu iOS-Kalender exportieren
					EinstellungsItem(icon: "calendar.badge.plus",
									 beschreibung: "Stundenplan zum iOS Kalender hinzufügen",
									 buttonText: UpdateCalender.exportEnabled ? "Entfernen" : "Hinzufügen",
									 action: {
						UpdateCalender.exportEnabled.toggle()
						update = UUID()
						if UpdateCalender.exportEnabled {
							_ = UpdateCalender(data: data)
						}
					})

					// MARK: VertretungsApplender
					EinstellungsItem(icon: "calendar.badge.plus",
									 beschreibung: "VertretungsApplender zum iOS Kalender hinzufügen",
									 buttonText: "Hinzufügen",
									 action: {
										if let url = URL(string: "webcal://www.st-VertretungsApp-schule.de/iCal/calendars/VertretungsApplender.ics") {
											UIApplication.shared.open(url)
										}
									})
					.id("VertretungsApplender \(update)")

					// MARK: Kontakt
					EinstellungsItem(icon: "info.circle", beschreibung: "Kontakt &\nDatenschutz", buttonText: "Ansehen", action: {
						shownSheet = .info
					})

					Spacer()
				}
				.padding([.trailing, .leading], 25)
			}

			VStack {
				HStack {
					GeometryReader { reader in
						Button(action: {
							shownSheet = nil
						}) {
							Image(systemName: "xmark")
								.font(.title)
								.hoverEffect(.highlight)

								.foregroundColor(Color.secondary)
						}.frame(width: reader.size.width, alignment: .trailing)
					}
				}
				.frame(height: 25)
				.padding(20)
				Spacer()
			}
		}
	}
}

private struct EinstellungsItem: View {
	let icon: String
	let beschreibung: String
	let buttonText: LocalizedStringKey
	let action: () -> Void

	var body: some View {
		VStack {
			Divider()

			HStack(alignment: .center) {
				Image(systemName: icon)
					.resizable()
					.scaledToFit()
					.frame(width: 20, height: 20)
					.padding(.trailing, 5)

				HStack {
					Text(beschreibung)
					Spacer()
				}

				Button(action: {
					action()
				}) {
					ZStack {
						Color.themeColor
						Text(buttonText)
							.foregroundColor(Color.white)
							.bold()
					}
				}
				.padding()
				.background(Color.themeColor)
				.cornerRadius(10)
				.frame(width: 150)
				.hoverEffect(.highlight)
			}
		}
	}
}

private var userColors: [Color] = [
	Color(red: 0.33, green: 0.69, blue: 0.22, opacity: 1.0), // #53af38
	Color(red: 0.19, green: 0.45, blue: 0.93, opacity: 1.0), // #3174ed gut
	Color(red: 0.74, green: 0.16, blue: 0.74, opacity: 1.0), // gut
	Color(red: 0.91, green: 0.29, blue: 0.19, opacity: 1.0),
	Color(red: 0.77, green: 0.59, blue: 0.43, opacity: 1.0), // #kp

	Color(red: 0.38, green: 0.63, blue: 0.09, opacity: 1.0), // #60a117
	Color(red: 0, green: 0.59, blue: 1, opacity: 1.0), // #096ff gut
	Color(red: 0.64, green: 0.46, blue: 0.81, opacity: 1.0), // #a376cf gut
	Color(red: 0.93, green: 0.47, blue: 0.19, opacity: 1.0), // #ec7830 gut
	Color(red: 0.17, green: 0.69, blue: 0.8, opacity: 1.0) // #2bb0cc
]

private struct ColorTheme: View {
	@Binding var update: UUID
	@State var showSelection = false

	var body: some View {
		VStack {
			Divider()
			HStack {
				Image(systemName: "paintbrush")
					.resizable()
					.scaledToFit()
					.frame(width: 20, height: 20)
					.padding(.trailing, 5)
				HStack {
					Text("Farbgebung ändern")
					Spacer()
				}
				HStack {

					Button(action: {
						showSelection.toggle()
					}) {
						ZStack {
							Text(" ")
						HStack(alignment: .center) {
							Spacer()
							Image(systemName: showSelection ? "xmark" : "paintbrush")
								.foregroundColor(Color.white)
								.frame(width: 15, height: 15, alignment: .center)
							Spacer()
						}
						}

					}
					.padding()
					.background(Color.themeColor)
					.cornerRadius(10)
					.hoverEffect(.highlight)

					Button(action: {
						if Color.themeColor.cgColor?.components != Color.defaultThemeColor.cgColor?.components {
							setzteFarbe(color: .defaultThemeColor)
							update = UUID()
						}
						showSelection = false
					}) {
						ZStack {
							Text(" ")

							HStack(alignment: .center) {
								Spacer()
								Image(systemName: "gobackward")
									.foregroundColor(Color.white)
									.frame(width: 15, height: 15, alignment: .center)
								Spacer()
							}
						}

					}
					.padding()
					.background(LinearGradient(colors: [.themeColor, .defaultThemeColor],
											   startPoint: .topLeading,
											   endPoint: .bottomTrailing))
					.cornerRadius(10)
					.hoverEffect(.highlight)
				}.frame(width: 150)
			}
			if showSelection {
				VStack {
					HStack {
						ForEach(userColors.prefix(5), id: \.self) {color in
							ColorButton(update: $update, showSelection: $showSelection, color: color)
						}
					}
					HStack {
						ForEach(userColors.suffix(5), id: \.self) {color in
							ColorButton(update: $update, showSelection: $showSelection, color: color)
						}
					}
					Spacer(minLength: 30)
				}
			}
		}
	}
}

private struct ColorButton: View {
	@Binding var update: UUID
	@Binding var showSelection: Bool

	let color: Color
	var body: some View {
		Button(action: {
			setzteFarbe(color: color)
			showSelection = false
			update = UUID()
		}) {
			ZStack {
				color
			}
		}
		.padding()
		.background(color)
		.cornerRadius(10)
		.hoverEffect(.highlight)
	}
}

private struct MovingLogo: View {
	@State var roatation: Angle = .degrees(30)
	@State var scale = 0.2

	var body: some View {
		Image("Schullogo")
			.resizable()
			.aspectRatio(contentMode: ContentMode.fit)
			.frame(width: 300, height: 100.0)
			.padding(20)
			.padding(.top, 50)
			.padding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0))
			.foregroundColor(Color.themeColor)
			.rotation3DEffect(roatation, axis: (-1, 0, 0))
			.scaleEffect(scale)
			.onAppear {
				withAnimation(Animation.interpolatingSpring(mass: 0.12, stiffness: 8.1, damping: 1.05, initialVelocity: 3.05)) {
					roatation = .zero
					scale = 1
				}
			}
	}
}
