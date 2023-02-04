//
//  PdfRenderer.swift
//  
//
//  Created by Benedict on 12.08.22.
//

import Foundation
import SwiftUI

func exportToPDF(data: DataModel) -> Data {
	let pageSize = CGSize(width: 1754, height: 1240)

	// View to render on PDF
	let renderView = StundenplanRendererPDF(data: data)
		.scaleEffect(1.2)
		.background(Color.white)
	let myUIHostingController = UIHostingController(rootView: renderView)
	myUIHostingController.view.frame = CGRect(origin: .zero, size: pageSize)
	myUIHostingController.view.backgroundColor = UIColor.white


	// Render the view behind all other views
	let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
	let window = windowScene?.windows.first
	guard let rootVC = window?.rootViewController else {
		print("ERROR: Could not find root ViewController.")
		return Data() // TODO: throw
	}
	rootVC.addChild(myUIHostingController)
	// at: 0 -> draws behind all other views
	// at: UIApplication.shared.windows.count -> draw in front
	rootVC.view.insertSubview(myUIHostingController.view, at: 0)


	// Render the PDF
	let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
			let pdfData = pdfRenderer.pdfData(actions: { (context) in
				context.beginPage()
				myUIHostingController.view.layer.render(in: context.cgContext)
			})
		myUIHostingController.removeFromParent()
		myUIHostingController.view.removeFromSuperview()
	return pdfData
}


let cellWidth: CGFloat = 180
let stundeWidth: CGFloat = 180
let cellHeight: CGFloat = 60

struct StundenplanRendererPDF: View {
	let data: DataModel

	var body: some View {
		VStack {
			Text("\(data.apiCredentials?.username ?? "Mein")'s Stundenplan")
				.font(.system(size: 30, weight: .bold, design: .default))
				.foregroundColor(.black)
				.padding(.bottom, 20)
			StundenplanRenderer(data: data)
			HStack {
				Spacer()
				Text("Stand: \(DateF.deutschesDatum.string(from: Date()))")
					.foregroundColor(.black)
					.font(.system(size: 16, weight: .medium, design: .default))
					.italic()
			}
		}.frame(width: cellWidth * 5 + stundeWidth)
			.background(Color.white)
	}
}


struct StundenplanRenderer: View {
	let data: DataModel

	var body: some View {
		ZStack(alignment: .topLeading) {
			HStack(spacing: 0) {
				VStack(spacing: 0) {
					TableEntryStunde(stunde: .andere)
					ForEach(Stunde.alle, id: \.self) { stunde in
						TableEntryStunde(stunde: stunde)
					}
				}

				ForEach(Wochentag.alle, id: \.self) { tag in
					VStack(spacing: 0) {
						TableEntryWochenTag(tag.string)
						ForEach(Stunde.alle, id: \.self) { stunde in
							if let item = data.stundenplan[tag]?[stunde]?.davonMeine(data.meineKurse).first {
								TableKursEntry(kurs: item.kurs, raum: item.raum)
							} else {
								TableEntryEmpty()
							}
						}
					}
				}
			}

			// MARK: vertikale
			Rectangle()
				.frame(width: 1, height: cellHeight * 12, alignment: .center)
				.foregroundColor(.black)
				.offset(x: 0, y: cellHeight)
			ForEach((0..<6), id: \.self) { xPos in
				Rectangle()
					.frame(width: 1, height: cellHeight * 13, alignment: .center)
					.foregroundColor(.black)
					.offset(x: stundeWidth + CGFloat(xPos) * cellWidth, y: 0)
			}

			// MARK: horizontale
			Rectangle()
				.frame(width: cellWidth * 5, height: 1, alignment: .center)
				.foregroundColor(.black)
				.offset(x: stundeWidth, y: 0)
			ForEach((1..<14), id: \.self) { yPos in
				Rectangle()
					.frame(width: cellWidth * 5 + stundeWidth, height: 1, alignment: .center)
					.foregroundColor(.black)
					.offset(x: 0, y: CGFloat(yPos) * cellHeight)
			}

		}
	}
}
// swiftlint:disable private_over_fileprivate

fileprivate struct TableEntryStunde: View {
	let stunde: Stunde

	var body: some View {
		VStack {
			if stunde != .andere {
				Text(stunde.numberStr)
					.font(.system(size: 25, weight: .bold, design: .monospaced))
					.foregroundColor(.black)
				Text(stunde.label)
					.font(.system(size: 14, weight: .light, design: .monospaced))
					.foregroundColor(.black)
			} else {
				Image("Schullogo")
					.resizable()
					.scaledToFit()
					.foregroundColor(Color.defaultThemeColor)
					.frame(width: stundeWidth, height: 200, alignment: .center)
					.offset(x: 0, y: -20)
			}
		}
			.frame(width: stundeWidth, height: cellHeight, alignment: .center)
	}
}

fileprivate struct TableEntryWochenTag: View {
	let text: String
	init(_ text: String) {
		self.text = text
	}

	var body: some View {
		Text(text)
			.font(.system(size: 25, weight: .bold, design: .monospaced))
			.frame(width: 180, height: 60, alignment: .center)
			.foregroundColor(.black)
	}
}


fileprivate struct TableEntry: View {
	let text: String
	init(_ text: String) {
		self.text = text
	}

	var body: some View {
		Text(text)
			.frame(width: 180, height: 60, alignment: .center)
			.foregroundColor(.black)
	}
}



fileprivate struct TableEntryEmpty: View {
	var body: some View {
		Color.gray
			.opacity(0.3)
			.frame(width: 180, height: 60, alignment: .center)
	}
}

fileprivate struct TableKursEntry: View {
	let kurs: Kurs
	let raum: String

	var body: some View {
		VStack {
			HStack {
				Text(kurs.kursKategorie != Kurs.andereFachName ? kurs.kursKategorie : kurs.fach)
					.foregroundColor(.black)
					.font(.system(size: 20, weight: .heavy, design: .default))
				Spacer()
			}
			Spacer()
			HStack {
				Text(kurs.lehrer)
					.font(.system(size: 14, weight: .light, design: .default))
					.foregroundColor(.black)
				Spacer()
				Text(raum)
					.font(.system(size: 14, weight: .medium, design: .monospaced))
					.foregroundColor(.black)
			}
		}
		.padding()
		.frame(width: 180, height: 60, alignment: .center)
	}
}


func exportToPDFAndOpenDialog(data: DataModel) {
	let pdfData = exportToPDF(data: data)
	let activityViewController = UIActivityViewController(activityItems: [pdfData],
														  applicationActivities: nil)

	let viewController = Coordinator.topViewController()
	activityViewController.popoverPresentationController?.sourceView = viewController?.view
	viewController?.present(activityViewController, animated: true, completion: nil)
}
