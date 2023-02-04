//
//  LoadingBackground.swift
//  
//
//  Created by Benedict on 24.09.22.
//

import SwiftUI

struct LoadingBackground: View {
	// TODO: animation
	var body: some View {
		ZStack {
			Image("Schullogo")
				.resizable()
				.scaledToFit()
				.scaleEffect(0.4)
				.foregroundColor(.gray)
			Image(systemName: "graduationcap")
				.foregroundColor(.gray)
				.offset(x: 60, y: -80)
			Image(systemName: "x.squareroot")
				.foregroundColor(.gray)
				.offset(x: -60, y: -60)
			Image(systemName: "network")
				.foregroundColor(.gray)
				.offset(x: 75, y: 60)
		}
	}
}

struct LoadingBackground_Previews: PreviewProvider {
	static var previews: some View {
		LoadingBackground()
	}
}
