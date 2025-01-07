//
//  PlatformaClipApp.swift
//  PlatformaClip
//
//  Created by Daniil Razbitski on 20/12/2024.
//

import SwiftUI

@main
struct PlatformaClipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let incomingURL = activity.webpageURL else { return }
                    print("incomingURL: \(incomingURL)")
                    guard let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else { return }
                    print("components: \(components)")
                    // Navigate to a certain part of the App Clip based in the URL
                }
        }
    }
//    https://platformapro.com/.well-known/apple-app-site-association
}

//<meta name="apple-itunes-app" content="app-clip-bundle-id=com.MCGroup.Platforma.Clip, app-id=6739066917">
