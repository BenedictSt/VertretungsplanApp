//
//  NachrichtenView.swift
//  
//
//  Created by Benedict on 19.05.22.
//

import SwiftUI

// swiftlint:disable private_over_fileprivate
fileprivate let aufgabenFarbe = Color(red: 0.96, green: 0.53, blue: 0, opacity: 1.0)

struct NachrichtenView: View {
	@Environment(\.colorScheme) var appearance
	@ObservedObject var data: DataModel
	@State var refreshing = false
	var body: some View {
		VStack {
			RefreshableScrollView(refreshing: $refreshing, content: {
				LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
					Section(content: {
						if data.nachrichten.isEmpty {
							if data.datenAktuell {
								Text("Keine Nachrichten vorhanden.")
							} else {
								Text("Keine Nachrichten geladen.")
							}
						}
						VStack {
							ForEach(data.nachrichten, id: \.self) { nachricht in
								HStack(spacing: 11.5) {
									RoundedRectangle(cornerRadius: 100)
										.fill(Color.themeColor)
										.opacity(0.9)
										.frame(width: 5)
									VStack(alignment: .leading, spacing: 8) {
										Text(nachricht.title)
											.font(.body.weight(.semibold))
											.foregroundColor(Color.themeColor)
										Text(nachricht.text)
											.font(.callout)
											.multilineTextAlignment(.leading)
											.lineLimit(nil)
									}
									Spacer()
								}.padding([.top, .bottom], 10)
									.fixedSize(horizontal: false, vertical: true)
								if data.nachrichten.last != nachricht {
									Divider()
								}
							}
						}.padding(.top, -20)
					}, header: {
						HStack {
							Text("Nachrichten")
								.font(.largeTitle.bold())
							Spacer()
							if !data.nachrichten.isEmpty {
								Image(systemName: "\(data.nachrichten.count).circle.fill")
									.font(.title)
									.opacity(0.9)
									.foregroundColor(Color.themeColor)
							}
						}
						.padding(.top)
						.background(appearance == .dark ? Color.black : Color.white)
					}).padding(.bottom, 10)

					if !data.toDos.isEmpty {
						Section(content: {
							VStack(alignment: .leading) {
								ForEach(data.toDos, id: \.self) { todo in
									ToDoView(todo: todo)
										.padding([.top, .bottom], 10)
									if data.toDos.last != todo {
										Divider()
									}
								}
							}.padding(.top, -20)
						}, header: {
							HStack {
								Text("Aufgaben")
									.font(.largeTitle.bold())
								Text("auf Moodle")
									.foregroundColor(.gray)
									.padding(.top, 12)
								Spacer()
								Image(systemName: "\(data.toDos.count).circle.fill")
									.opacity(0.9)
									.font(.title)
									.foregroundColor(aufgabenFarbe)
							}.background(appearance == .dark ? Color.black : Color.white)
						}).padding(.bottom, 10)
					}
				}
			}).padding(.top, -16)
		}
		.onChange(of: refreshing, perform: { neu in
			if neu {
				data.aktualisiere()
			}
		})
		.onChange(of: data.busy) { neu in
			refreshing = neu
		}
		.onAppear {
			data.hatUngeleseneNachrichten = false
		}
		.onDisappear {
			data.hatUngeleseneNachrichten = false
		}
		.padding()
	}
}

private struct ToDoView: View {
	let todo: MoodleToDo

	var body: some View {
		ZStack {
			HStack(spacing: 11.5) {
				RoundedRectangle(cornerRadius: 100)
					.fill(aufgabenFarbe)
					.opacity(0.9)
					.frame(width: 5)

				VStack(alignment: .leading, spacing: 5) {
					Text(todo.title)
						.multilineTextAlignment(.leading)
						.font(.body.weight(.semibold))
						.lineLimit(nil)

					Text(todo.kursName)
						.fontWeight(.semibold)
						.foregroundColor(aufgabenFarbe)
						.font(.callout)
						.lineLimit(nil)

					Button(action: {
						if let url = URL.moodleWebsiteKurs(kursId: todo.kursId) {
							UIApplication.shared.open(url)
						}
					}) {
						Text("Abgabe: \(DateF.ausfuerlichDatumUhr.string(from: todo.datum))")
							.font(.callout)
							.foregroundColor(.secondary)
							.underline(color: .secondary)
					}

					if todo.beschreibung != "" {
						ExpandableText(text: todo.beschreibung)
							.expandButton(TextSet(text: "mehr", font: .body, color: aufgabenFarbe))
							.collapseButton(TextSet(text: "weniger", font: .body, color: aufgabenFarbe))
							.lineLimit(2)
							.padding(.top, 7)
					}
				}
			}
			.fixedSize(horizontal: false, vertical: true)
		}
	}
}
