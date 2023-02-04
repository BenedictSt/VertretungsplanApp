//
//  ThemeColor.swift
//  
//
//  Created by Benedict on 19.07.22.
//

import Foundation
import SwiftUI
import WidgetKit

extension Color {
	/// Vom Nutzer ausgewaeltes Farbschema
	static var themeColor: Color {
		let defaults = UserDefaults(suiteName: "group.VertretungsApp") ?? UserDefaults()
		if let color = defaults.colorForKey(key: "defaultColor") {
			return Color(color)
		}
		return defaultThemeColor
	}

	/// Standard Farbschema der VertretungsApp
	static var defaultThemeColor: Color {
		return Color(red: 200/255, green: 50/255, blue: 50/255)
	}
}

/// Setzt das Farbschema der App
func setzteFarbe(color: Color) {
	let defaults = UserDefaults(suiteName: "group.VertretungsApp") ?? UserDefaults()
	defaults.setColor(color: UIColor(color), forKey: "defaultColor")
	WidgetCenter.shared.reloadAllTimelines()
}

fileprivate extension UserDefaults {
	/// Gibt gespeicherte Farben aus den User Defaults zurück
	func colorForKey(key: String) -> UIColor? {
		var colorReturnded: UIColor?
		if let colorData = data(forKey: key) {
			do {
				if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
					colorReturnded = color
				}
			} catch {
				print("Error UserDefaults")
			}
		}
		return colorReturnded
	}

	/// Speichert Farbe in den Userdefaults
	func setColor(color: UIColor?, forKey key: String) {
		var colorData: NSData?
		if let color = color {
			do {
				let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
				colorData = data
			} catch {
				print("Error UserDefaults")
			}
		}
		set(colorData, forKey: key)
	}
}
