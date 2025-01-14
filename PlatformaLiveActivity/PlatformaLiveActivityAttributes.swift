//
//  PlatformaLiveActivityAttributes.swift
//  Platforma
//
//  Created by Daniil Razbitski on 13/01/2025.
//

import Foundation
import ActivityKit

struct PlatformaLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var startTime: String //start time of the event (получать разницу между началом и текущим и запускать таймер на это время)
        var eventName: String //name of event
        var eventType: String //online, offline
        var eventAddress: String //address of event, where it will be start
        var eventURL: String //address of event, where it will be start
        var activityID: String //address of event, where it will be start
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    var title: String
    var countsDown: String

}
//{
//    "aps": {
//        "timestamp": 1736788510,
//        "event": "update",
//        "content-state": {
//            "emoji": "HUI",
//            "eventName": "Some new event",
//            "timeRemaining": "60"
//        },
//        "attributes-type": "PlatformaLiveActivityAttributes",
//        "attributes": {
//            "name": "Daniil",
//            "title": "TestHUI"
//        },
//        "alert": {
//            "title": "Test title",
//            "body": "Test body"
//        }
//    }
//}
