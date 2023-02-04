//
//  Navbar.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import SwiftUI

struct Navbar: View {
	@ObservedObject var data: DataModel
	@Binding var appState: AppState
	let width: CGFloat

	@Environment(\.colorScheme) var colorScheme
	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				if colorScheme == .dark {
					Divider()
				}
				Color(UIColor.secondarySystemBackground)
					.edgesIgnoringSafeArea(.bottom)
					.shadow(radius: 1.5)
			}

			HStack {
				NavBarIcon(image: "arrow.left.arrow.right",
						   width: width / 4,
						   selfState: .vertretung,
						   name: "Vertretung",
						   state: $appState)
				.keyboardShortcut("1", modifiers: [.command])

				NavBarIcon(image: "calendar",
						   width: width / 4,
						   selfState: .stundenplan,
						   name: "Stundenplan",
						   state: $appState)
				.keyboardShortcut("2", modifiers: [.command])

				NavBarIcon(image: "graduationcap",
						   width: width / 4,
						   selfState: .klausuren,
						   name: "Klausuren",
						   state: $appState)
				.keyboardShortcut("3", modifiers: [.command])

				NavBarIcon(image: data.hatUngeleseneNachrichten ? "envelope.badge" : "envelope",
						   width: width / 4,
						   selfState: .nachrichten,
						   name: "Nachrichten",
						   state: $appState)
				.keyboardShortcut("4", modifiers: [.command])
			}
			.frame(width: width, alignment: .center)
			.padding(.top, 5)

			.fixedSize()
		}.fixedSize()
	}
}

private struct NavBarIcon: View {
	let image: String
	let width: CGFloat
	let selfState: AppState
	let name: String
	@Binding var state: AppState
	var body: some View {
		Button(action: {
			state = selfState
		}) {
			VStack {
				Image(systemName: image)
					.font(.title2)
					.foregroundColor(state == selfState ? .themeColor : Color(UIColor.secondaryLabel))
					.frame(height: 25, alignment: .center)
				Text(name)
					.font(.caption2)
					.frame(height: 10)
					.foregroundColor(state == selfState ? .themeColor : .secondary)
			}
			.animation(Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.5), value: state)
		}
		.frame(width: width, alignment: .center)
		.padding(.bottom, 5)
		.contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
		.hoverEffect(.lift)
	}
}
