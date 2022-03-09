//
//  ble_demo_iosApp.swift
//  Shared
//
//  Created by Adam Toennis on 3/4/22.
//

import SwiftUI

@main
struct ble_demo_iosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BleManager())
        }
    }
}
