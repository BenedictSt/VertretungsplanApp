//
//  extensions.swift
//  
//
//  Created by Benedict on 12.05.22.
//

import Foundation
import SwiftUI

/// String to array of ascii values
extension StringProtocol {
	var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}

// keyboard ausblenden
extension View {
	func endTextEditing() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
										to: nil, from: nil, for: nil)
	}
}

extension Array where Element: Equatable {
	mutating func toggle(_ element: Element) {
		if self.contains(where: {$0 == element}) {
			self.removeAll(where: {$0 == element})
		} else {
			self.append(element)
		}
	}
}

func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
	let feedback = UIImpactFeedbackGenerator(style: style)
	feedback.prepare()
	feedback.impactOccurred()
}
