//
//  RefreshableScrollingView.swift
//  
//
//  Created by Benedict on 05.06.22.
//

import Foundation
import SwiftUI

struct RefreshableScrollView<Content: View>: View {
	// credit: https://gist.github.com/swiftui-lab/3de557a513fbdb2d8fced41e40347e01
	@State private var previousScrollOffset: CGFloat = 0
	@State private var scrollOffset: CGFloat = 0
	@State private var frozen: Bool = false
	@State private var rotation: Angle = .degrees(0)

	var threshold: CGFloat = 150
	@Binding var refreshing: Bool
	let content: Content

	init(height: CGFloat = 150, refreshing: Binding<Bool>, @ViewBuilder content: () -> Content) {
		self.threshold = height
		self._refreshing = refreshing
		self.content = content()

	}

	var body: some View {
		return VStack {
			ScrollView(showsIndicators: false) {
				ZStack(alignment: .top) {
					MovingView()

					VStack { self.content }.alignmentGuide(.top, computeValue: { _ in  0.0 })

				}
			}
			.background(FixedView())
			.onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
				self.refreshLogic(values: values)
			}
		}
	}

	func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
		DispatchQueue.main.async {
			// Calculate scroll offset
			let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
			let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero

			self.scrollOffset  = movingBounds.minY - fixedBounds.minY

			// Crossing the threshold on the way down, we start the refresh process
			if !self.refreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) {
				self.refreshing = true
			}

			if self.refreshing {
				// Crossing the threshold on the way up, we add a space at the top of the scrollview
				if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold {
					self.frozen = true

				}
			} else {
				// remove the sapce at the top of the scroll view
				self.frozen = false
			}

			// Update last scroll offset
			self.previousScrollOffset = self.scrollOffset
		}
	}

	struct MovingView: View {
		var body: some View {
			GeometryReader { proxy in
				Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self,
									   value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
			}.frame(height: 0)
		}
	}

	struct FixedView: View {
		var body: some View {
			GeometryReader { proxy in
				Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self,
									   value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
			}
		}
	}
}

struct RefreshableKeyTypes {
	enum ViewType: Int {
		case movingView
		case fixedView
	}

	struct PrefData: Equatable {
		let vType: ViewType
		let bounds: CGRect
	}

	struct PrefKey: PreferenceKey {
		static var defaultValue: [PrefData] = []

		static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
			value.append(contentsOf: nextValue())
		}
	}
}
