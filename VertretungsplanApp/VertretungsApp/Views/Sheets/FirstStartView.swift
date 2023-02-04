//
//  FirstStartView.swift
//  
//
//  Created by Benedict on 24.05.22.
//

import SwiftUI

// struct FirstStartView: View {
//	@State var data: DataModel
//	@State var step = 0
//	@Binding var showSheet: Bool
//	
//	var body: some View {
//		ZStack{
//			switch step {
//			case 0:
//				AnmeldedatenView(data: data, oboardingStep: $step)
//			case 1:
//				StufenAuswahl(data: data, oboardingStep: $step)
//			case 2:
//				StundenAuswahlView(data: data, oboardingStep: $step, showSheet: $showSheet)
//			default:
//				Text("Fehler")
//			}
//		}.modify({
//			if #available(iOS 15, *){
//				$0.interactiveDismissDisabled(true)
//			}
//		})
//	}
//	
// }
