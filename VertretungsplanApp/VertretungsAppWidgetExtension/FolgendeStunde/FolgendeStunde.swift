//
//  FolgendeStunde.swift
//  VertretungsApp3WidgetExtension
//
//  Created by Benedict on 04.07.22.
//

import Foundation
import SwiftUI

/*
 Bei small:
 nur nächste Stunde
 
 bei medium: rechts dran was als nächstes Folgt
 
 Combo:
 medium
 mit aktuell
 vertretung
 
 big:
 aktuell
 nächstes
 vertretung
 Nachrichten???
 
 */

struct FolgendeStundeWidget: View {
	@Environment(\.widgetFamily) var size
	var entry: FolgendeStunde

	var body: some View {
		if size == .systemSmall {
			FolgendeStundeWidgetSmall(entry: entry)
		} else {
			FolgendeStundeWidgetMedium(entry: entry)
		}
	}
}
