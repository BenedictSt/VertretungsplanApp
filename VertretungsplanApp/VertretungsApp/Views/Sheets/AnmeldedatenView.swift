//
//  AnmeldedatenView.swift
//  
//
//  Created by Benedict on 24.05.22.
//

import SwiftUI

struct AnmeldedatenView: View {
	@ObservedObject var data: DataModel

	@State var username = ""
	@State var password = ""

	var body: some View {
		ZStack {
			VStack {
				Spacer()

				Image("Schullogo")
					.resizable()
					.aspectRatio(contentMode: ContentMode.fit)
					.frame(width: 200, height: 74.0)
					.padding(Edge.Set.bottom, 20)
					.foregroundColor(.themeColor)

				Text("Anmelden").bold().font(.title)

				Text("Melde dich mit deinen Moodle Zugangsdaten an.")
					.font(.body)
					.padding(EdgeInsets(top: -10, leading: 0, bottom: 70, trailing: 0))

				TextField("Benutzername", text: $username)
					.padding()
					.background(Color(UIColor.secondarySystemBackground))
					.cornerRadius(10)
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
					.disableAutocorrection(true)
					.onChange(of: username, perform: { _ in
						username = username.replacingOccurrences(of: " ", with: "")
					})

				SecureField("Passwort", text: $password, onCommit: {anmelden()})
					.padding()
					.background(Color(UIColor.secondarySystemBackground))
					.cornerRadius(10)
					.padding(.bottom, 10)
					.disableAutocorrection(true)
					.onChange(of: password, perform: { _ in
						password = password.replacingOccurrences(of: " ", with: "")
					})

				HStack {
					GeometryReader { reader in
						Button(action: {
							if let resetURL = URL.resetMoodlePassword() {
								UIApplication.shared.open(resetURL)
							}
						}) {
							Text("Passwort vergessen?")
								.alignmentGuide(.leading) { dimension in dimension[.trailing] }
								.foregroundColor(Color.secondary)
						}.frame(width: reader.size.width, alignment: .trailing)
					}
				}.frame(height: 25)

				Spacer()

				Button(action: {anmelden()}) {
					HStack(alignment: .center) {
						Spacer()
						if data.busy {
							ProgressView()
						} else {
							Text("Anmelden")
								.foregroundColor(Color.white)
								.bold()
						}
						Spacer()
					}

				}
				.padding()
				.background(username == "" || password == "" ? Color(UIColor.tertiaryLabel) : Color.themeColor)
				.cornerRadius(10)
				.disabled(username == "" || password == "" || data.busy)

			}
			.padding()
		}

	}

	private func anmelden() {
		let credentials = ApiCredentials(username: username, password: password)
		data.apiCredentials = credentials
		self.endTextEditing()
		data.ladeStufen()
	}
}
