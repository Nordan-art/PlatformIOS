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
        var userID: String
        var eventID: String
        var startTime: String //start time of the event (получать разницу между началом и текущим и запускать таймер на это время)
        var eventName: String //name of event
        var eventType: String //online, offline
        var eventAddress: String //address of event, where it will be start
        var eventURL: String //address of event, where it will be start
        var eventToken: String
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
//            "startTime": "2025-01-15 02:01:00",
//            "eventName": "HUI",
//            "eventType": "offline",
//            "eventAddress": "Sejmu Czteroletniego 2/146",
//            "eventURL": "https://platformapro.com/user-single-event/6",
//            "activityID": "123123"
//        },
//        "attributes-type": "PlatformaLiveActivityAttributes",
//        "attributes": {
//            "name": "Daniil",
//            "title": "TestHUI",
//            "countsDown": "aaa"
//        },
//        "alert": {
//            "title": "Test title",
//            "body": "Test body",
//            "sound":"testRingNotification"
//        }
//    }
//}


//{
//  "aps": {
//    "timestamp": 1685952000,
//    "event": "update",
//    "content-state": {
//      "startTime": 0.0,
//      "eventDescription": "Power Panda has been knocked down!",
//      "eventName": "Power Panda has been knocked down!",
//      "eventType": "offline"
//      "eventAddress": "Sejmu Czteroletniego 2/146"
//      "eventURL": "https://platformapro.com/user-single-event/6"
//      "activityID": "123123"
//    },
//    "alert": {
//      "title": "Power Panda is knocked down!",
//      "body": "Use a potion to heal Power Panda!",
//      "sound": "testRingNotification"
//    }
//  }
//}

//{
//    "aps": {
//        "timestamp": 1736899888,
//        "event": "update",
//        "relevance-score": 100,
//        "stale-date": 1736899837,
//        "content-state": {
//            "startTime": "2025-01-15 10:00:00",
//            "eventName": "Update 23 23 23",
//            "eventType": "offline",
//            "eventAddress": "Sejmu Czteroletniego 2/146",
//            "eventURL": "https://platformapro.com/user-single-event/6",
//            "activityID": "123123"
//        },
//        "attributes-type": "PlatformaLiveActivityAttributes",
//        "attributes": {
//            "name": "Vova",
//            "title": "Test title",
//            "countsDown": "aa"
//        },
//        "alert": {
//            "title": "PLATFORMA PRO",
//            "subtitle": "test",
//            "body": "Тестовое название мероприятия"
//        },
//        "sound": "testRingNotification"
//    },
//    "custom": {
//        "openPage": "notification",
//        "action": "https://platformapro.com/user-single-event/6"
//    }
//}
