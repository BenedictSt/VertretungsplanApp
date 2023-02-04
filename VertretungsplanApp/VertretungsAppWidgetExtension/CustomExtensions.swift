//
//  CustomExtensions.swift
//  
//
//  Created by Benedict on 29.06.22.
//

import Foundation
import SwiftUI

extension Stunde {
	public var intValue: Int {
		return Stunde.intMap.swapKeyValues()[self] ?? -1
	}
}

extension Dictionary where Value: Hashable {
	/// Tauscht Key und Value Werte
	/// [a : b] => [b:a]
	func swapKeyValues() -> [Value: Key] {
		assert(Set(self.values).count == self.keys.count, "Values must be unique")
		var newDict = [Value: Key]()
		for (key, value) in self {
			newDict[value] = key
		}
		return newDict
	}
}
