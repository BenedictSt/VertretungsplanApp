//
//  VertretungsAppWidgetExtension.swift
//  
//
//  Created by Benedict on 19.07.22.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct VertretungsAppWidget: Widget {
	let kind: String = "VertretungsAppWidget"

	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: FolgendeStundeWidgetProvider()) { entry in
			FolgendeStundeWidget(entry: entry)
		}
		.supportedFamilies([.systemSmall, .systemMedium])
		.configurationDisplayName("Nächste Stunde")
		.description("Zeigt die nächste Stunde in deinem Stundenplan an.")
	}
}
