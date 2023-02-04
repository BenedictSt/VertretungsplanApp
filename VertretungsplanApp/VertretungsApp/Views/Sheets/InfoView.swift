//
//  InfoView.swift
//  
//
//  Created by Benedict on 26.05.22.
//

import SwiftUI

struct InfoView: View {
	let hide: () -> Void

	var body: some View {
		ZStack {

			ScrollView(showsIndicators: false) {
				VStack {

					Image("Schullogo")
						.resizable()
						.aspectRatio(contentMode: ContentMode.fit)
						.frame(width: 200, height: 74.0)
						.padding(20)
						.padding(.top, 50)
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0))
						.foregroundColor(.themeColor)

					// KONTAKT
					Text("Kontakt").bold().font(.title)
						.padding(.bottom, 20)

					HStack {
					Text("Lorem ipsum dolor sit amet, \nconsectetur adipiscing elit, sed\n" +
						 "do eiusmod tempor\nincididunt ut labore\net dolore magna\naliqua.")
						.font(.body)
						.padding(EdgeInsets(top: -10, leading: 0, bottom: 70, trailing: 0))
						Spacer()
					}

					// ANDERES
					Text("Anderes").bold().font(.title)
						.padding(.bottom, 20)

					Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut " +
						 "labore et dolore magna aliqua. Sapien pellentesque habitant morbi tristique senectus et netus et" +
						 "malesuada. Risus commodo viverra maecenas accumsan lacus vel facilisis volutpat est. Est ante in" +
						 "nibh mauris cursus. Neque aliquam vestibulum morbi blandit. Sed nisi lacus sed viverra tellus in hac.")
						.font(.body)
						.padding(EdgeInsets(top: -10, leading: 0, bottom: 70, trailing: 0))

					Spacer()

				}
				.padding([.trailing, .leading], 25)
			}

			VStack {
				HStack {
					GeometryReader { reader in
						Button(action: {
							hide()
						}) {
							Image(systemName: "xmark")
								.font(.title)

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
