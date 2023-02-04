//
//  StundenAuswahlView.swift
//  
//
//  Created by Benedict on 25.05.22.
//

import SwiftUI

struct StundenAuswahlView: View {
	@ObservedObject var data: DataModel
	let finish: () -> Void
	@ObservedObject var keyboardObserver = KeyboardObserver()
	@State var filterString = ""
	@State var viewMode = 0

	var body: some View {
		VStack {
			Text("Wähle deine Kurse aus")
				.font(.title.bold())
				.padding(.top, 40)

			HStack {
				CustomButton(title: "Fächer", action: {viewMode = 0}, selected: viewMode == 0)
				CustomButton(title: "Lehrer", action: {viewMode = 1}, selected: viewMode == 1)
				CustomButton(title: "Meine\(data.meineKurseAK.isEmpty ? "" : ": \(data.meineKurseAK.count)")",
							 action: {viewMode = 2},
							 selected: viewMode == 2)

				if !data.meineFehlerKurse.isEmpty {
					Button(action: {viewMode = 3}) {
						HStack(alignment: .center) {
							Image(systemName: "exclamationmark.triangle")
								.foregroundColor(.white)
						}

					}
					.padding(8)
					.background(Color.yellow)
					.cornerRadius(8)
				}
			}

			if viewMode != 3 {
				TextField("\(Image(systemName: "magnifyingglass")) suchen", text: $filterString)
					.padding()
					.background(Color(UIColor.secondarySystemBackground))
					.cornerRadius(10)
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
					.disableAutocorrection(true)
					.onChange(of: filterString, perform: { _ in

					})
					.onAppear {UITextField.appearance().clearButtonMode = .always}
			} else {
				Text("Hinweise:")
					.font(.title2.bold())
					.padding(.top, 15)
			}

			ScrollView {
				if data.alleKurse.filter({$0.filter(filterString: filterString)}).isEmpty {
					Text("Kurs nicht gefunden")
						.font(.callout)
				}
				switch viewMode {
				case 0:
					// MARK: Fächer
					VStack {
						let sortiert = data.getFaecher(filter: filterString)
						ForEach([String](sortiert.keys).sorted(by: {$0.uppercased() < $1.uppercased()}), id: \.self) { fach in
							HStack {
								Text("\(fach):")
									.font(.title2.bold())
								Spacer()
							}.frame(height: 30)
								.padding(.top, 20)
							ForEach(sortiert[fach]!, id: \.self) { kurs in
								Button(action: {data.meineKurse.toggle(kurs.name)}) {
									let istMeinKurs = data.meineKurse.contains(kurs.name)
									Text(kurs.fach)
										.font(.body.weight(.heavy).monospacedDigit())
										.frame(width: 100, height: 25, alignment: .center)
										.background(istMeinKurs ? Color(red: 0, green: 0.81, blue: 0.18, opacity: 1.0) : Color.gray)
										.foregroundColor(.primary)

									Text(kurs.lehrer)
										.font(.body.weight(.semibold).monospacedDigit())
										.frame(height: 25, alignment: .leading)
										.foregroundColor(data.meineFehlerKurse.contains(where: {$0 == kurs.name}) ? Color.yellow : .primary)

									Spacer()
								}
							}
							Divider()
						}
					}

				case 1:
					// MARK: Lehrer
					VStack {
						let sortiert = data.getSortiertNachLehrer(filter: filterString)
						ForEach([String](sortiert.keys).sorted(by: {$0.uppercased() < $1.uppercased()}), id: \.self) { lehrer in
							HStack {
								Text("\(lehrer):")
									.font(.title2.bold())
								Spacer()
							}.frame(height: 30)
								.padding(.top, 20)
							ForEach(sortiert[lehrer]!, id: \.self) { kurs in
								Button(action: {data.meineKurse.toggle(kurs.name)}) {
									HStack {
										let istMeinKurs = data.meineKurse.contains(kurs.name)
										Text(kurs.fach)
											.font(.body.weight(.heavy).monospacedDigit())
											.frame(width: 100, height: 25, alignment: .center)
											.background(istMeinKurs ? Color(red: 0, green: 0.81, blue: 0.18, opacity: 1.0) : Color.gray)
											.foregroundColor(.primary)

										Text(kurs.lehrer)
											.font(.body.weight(.semibold).monospacedDigit())
											.frame(height: 25, alignment: .leading)
											.foregroundColor(data.meineFehlerKurse.contains(where: {$0 == kurs.name}) ? Color.yellow : .primary)

										Spacer()

									}
								}
							}
							Divider()
						}
					}

				case 2:
					VStack {
						if data.meineKurseAK.isEmpty {
							Text("keine Kurse hinzugefügt")
								.font(.callout)
						}

						ForEach(data.meineKurseAK.filter({$0.filter(filterString: filterString)}), id: \.self) { kurs in
							Button(action: {data.meineKurse.toggle(kurs.name)}) {
								HStack {
									let istMeinKurs = data.meineKurse.contains(kurs.name)
									Text(kurs.fach)
										.font(.body.weight(.heavy).monospacedDigit())
										.frame(width: 100, height: 25, alignment: .center)
										.background(istMeinKurs ? Color(red: 0, green: 0.81, blue: 0.18, opacity: 1.0) : Color.gray)
										.foregroundColor(.primary)

									Text(kurs.lehrer)
										.font(.body.weight(.semibold).monospacedDigit())
										.frame(height: 25, alignment: .leading)
										.foregroundColor(data.meineFehlerKurse.contains(where: {$0 == kurs.name}) ? Color.yellow : .primary)

									Spacer()
									Image(systemName: "xmark.circle")
										.foregroundColor(.gray)
								}
							}
							Divider()
						}
					}
				case 3:
					ForEach(data.meineFehlerKurseBeschreibung.beschreibungen, id: \.self) { fehler in
						HStack {
							Text(fehler)
								.multilineTextAlignment(.leading)
								.lineLimit(nil)
							Spacer()
						}
						Divider()
					}
				default:
					Text("Fehler")
				}
			}

			if !keyboardObserver.isShown {
				if viewMode == 2 {
					Button(action: {
						let pdfData = exportToPDF(data: data)
						let activityViewController = UIActivityViewController(activityItems: [pdfData],
																			  applicationActivities: nil)

						let viewController = Coordinator.topViewController()
						activityViewController.popoverPresentationController?.sourceView = viewController?.view
						viewController?.present(activityViewController, animated: true, completion: nil)
					}) {
						HStack(alignment: .center) {
							Spacer()
							Text("Stundenplan Teilen")
								.foregroundColor(Color.white)
								.bold()
							Spacer()
						}
					}
					.padding()
					.background(Color(UIColor.tertiaryLabel))
					.cornerRadius(10)
				}

				Button(action: {
					data.saveToDisk()
					finish()
				}) {
					HStack(alignment: .center) {
						Spacer()
						Text(data.meineKurseAK.isEmpty ? "Überspringen" : "Fertig")
							.foregroundColor(Color.white)
							.bold()
						Spacer()
					}

				}.padding()
					.background(Color.themeColor)
					.cornerRadius(10)
			}
		}.padding()
			.onAppear {
				NotificationCenter.default.addObserver(keyboardObserver,
													   selector: #selector(keyboardObserver.keyboardWillShow(notification:)),
													   name: UIResponder.keyboardWillShowNotification,
													   object: nil)
				NotificationCenter.default.addObserver(keyboardObserver,
													   selector: #selector(keyboardObserver.keyboardWillHide(notification:)),
													   name: UIResponder.keyboardWillHideNotification,
													   object: nil)
			}
	}
}

private struct CustomButton: View {
	let title: String
	let action: () -> Void
	let selected: Bool
	var body: some View {
		Button(action: {
			action()
		}) {
			HStack(alignment: .center) {
				Spacer()
				Text(title)
					.foregroundColor(.white)
					.bold()
				Spacer()
			}
		}
		.padding(8)
		.background(selected ? Color.themeColor : Color.gray)
		.cornerRadius(8)
	}
}

enum Coordinator {
	static func topViewController(_ viewController: UIViewController? = nil) -> UIViewController? {
		let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
		let viewCon = viewController ?? windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
		if let navigationController = viewCon as? UINavigationController {
			return topViewController(navigationController.topViewController)
		} else if let tabBarController = viewCon as? UITabBarController {
			return tabBarController.presentedViewController != nil ?
			topViewController(tabBarController.presentedViewController) :
			topViewController(tabBarController.selectedViewController)
		} else if let presentedViewController = viewCon?.presentedViewController {
			return topViewController(presentedViewController)
		}
		return viewCon
	}
}
