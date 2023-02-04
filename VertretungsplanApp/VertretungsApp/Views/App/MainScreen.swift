//
//  MainScreen.swift
//  
//
//  Created by Benedict on 07.06.22.
//

import SwiftUI

struct MainScreen: View {
	@ObservedObject var data: DataModel
	@Binding var appState: AppState
	@Binding var shownSheet: SheetTyp?
	@Binding var stundenplanEditMode: Bool

	@State var dragLeft = false
	@State var dragRight = false
	@State var amount: CGFloat = 0 // in percent(0...1)

	/// gibt den MainView basierend auf dem appState zurück
	var mainView: AnyView {
		switch appState {
		case .vertretung:
			return AnyView(VertretungsView(data: data).padding(.top, 5))
		case .stundenplan:
			return AnyView(StundenPlanView(data: data, shownSheet: $shownSheet, editMode: $stundenplanEditMode))
		case .klausuren:
			return AnyView(KlausurenView(data: data))
		case .nachrichten:
			return AnyView(NachrichtenView(data: data))
		}
	}

	@State var timer = Timer.init(timeInterval: 1, repeats: false, block: { _ in print("timer")})

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				mainView
					.gesture(
						DragGesture()
							.onChanged({gesture in
								let order: [AppState] = [.vertretung, .stundenplan, .klausuren, .nachrichten]
								let threshhold = 0.4 * geometry.size.width
								let dragDistance = gesture.translation.width
								guard let currentIndex = order.firstIndex(of: appState) else {
									return
								}

								let directionLeft: Bool = dragDistance < 0
								if directionLeft {
									if currentIndex >= order.count - 1 {
										return
									}
								} else {
									if currentIndex == 0 {
										return
									}
								}

								updateVisualDragIndicator(progress: dragDistance / threshhold)

								if abs(dragDistance) > threshhold {
									if directionLeft {
										appState = order[currentIndex + 1]
									} else {
										appState = order[currentIndex - 1]
									}
								}
							})
							.onEnded({ _ in
								updateVisualDragIndicator(progress: 0)
							})
					)
			}
			.onChange(of: appState, perform: { _ in
				updateVisualDragIndicator(progress: 0)
			})

			// MARK: Indicator overlay
			if dragLeft || dragRight {
				HStack {
					if dragRight {
						Spacer()
					}
					VStack {
						Spacer()
						ZStack {
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(.themeColor)
								.frame(width: max(20, 100 * amount), height: 80, alignment: .center)
							if amount > 0.3 {
								Image(systemName: dragLeft ? "chevron.left" : "chevron.right")
									.font(.largeTitle)
									.foregroundColor(.white)
									.offset(x: dragLeft ? 5 : -5, y: 0)
							}
						}
						.offset(x: dragLeft ? -10 : 10, y: 0)
						Spacer()
					}
					if dragLeft {
						Spacer()
					}
				}
			}
		}
	}

	/// - Parameter amount: wie viel prozent schon abgeschlossen sind (0...1)
	private func updateVisualDragIndicator(progress: CGFloat) {
		if abs(progress) < 0.1 {
			dragLeft = false
			dragRight = false
			amount = 0
			return
		}

		if progress > 0 {
			dragLeft = true
			dragRight = false
		} else {
			dragLeft = false
			dragRight = true
		}

		amount = abs(progress)
		timer.invalidate()
		timer = Timer.init(timeInterval: 1, repeats: false, block: { _ in updateVisualDragIndicator(progress: 0)})
		RunLoop.main.add(timer, forMode: .common)
	}
}
