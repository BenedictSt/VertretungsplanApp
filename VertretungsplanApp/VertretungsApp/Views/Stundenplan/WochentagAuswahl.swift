//
//  WochentagAuswahl.swift
//  
//
//  Created by Benedict on 19.08.22.
//

import Foundation
import SwiftUI


struct WeekdaySelectionView: View {
	@ObservedObject var stpCon: StundenplanConvenience
	let width: CGFloat
	let scrollReader: ScrollViewProxy

	var body: some View {
		HStack(spacing: 2) {
			ForEach(Wochentag.alle, id: \.self) { iTag in
				if iTag != .montag {
					Spacer()
				}
				Button(action: {
					stpCon.selectedDay = iTag
					hapticFeedback(style: .light)
					withAnimation {
						scrollReader.scrollTo("topAnchor", anchor: .top)
					}
				}) {

					CircledText(text: iTag.stringShort)
						.font(.headline)
						.foregroundColor(stpCon.selectedDay == iTag ? .themeColor : .primary)
				}
				.hoverEffect(.lift)
			}

		}.frame(width: width - 20)
			.padding([.trailing, .leading], 10)
	}
}

private struct CircledText: View {
	let text: String
	@Environment(\.colorScheme) var appearance

	var body: some View {
		ZStack(alignment: .center) {
			RoundedRectangle(cornerRadius: 8)
				.frame(width: 50, height: 50)
				.foregroundColor(appearance == .dark ?
								 Color(red: 0.15, green: 0.15, blue: 0.15, opacity: 1.0) :
								 Color(red: 0.86, green: 0.86, blue: 0.87, opacity: 1.0))

			Text(text)
		}
	}
}
