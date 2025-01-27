//
//  ActivityManager.swift
//  Platforma
//
//  Created by Daniil Razbitski on 13/01/2025.
//

import ActivityKit
import Combine
import Foundation
import SwiftUICore

final class ActivityManager: ObservableObject {
    @MainActor @Published private(set) var activityID: String?
    @MainActor @Published private(set) var activityToken: String?
    
    @ObservedObject var activityActionNetwork: ActivityActionNetwork = ActivityActionNetwork()
    
    let attributes = PlatformaLiveActivityAttributes(name: "Jhon", title: "Upcoming Event", countsDown: "")
    var initialContentState = PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "")

    static let shared = ActivityManager()
    
    func start(activityID: String) async {
        await endActivity()
        await startNewLiveActivity()
    }
    
    private func startNewLiveActivity() async {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let content = ActivityContent(state: initialContentState, staleDate: nil, relevanceScore: 1.0)
                
                let activity = try Activity<PlatformaLiveActivityAttributes>.request(
                    attributes: attributes,
                    content: content,
                    pushType: .token
                )
                
                Task {
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.reduce("") {
                            $0 + String(format: "%02x", $1)
                        }
                        
                        //                        Logger().log("New push token: \(pushTokenString)")
                        print("New push token: \(pushTokenString)")
                        //                        try await self.sendPushToken(hero: hero, pushTokenString: pushTokenString)
                    }
                }
                
                //        guard let activity = activity else {
                //            return
                //        }
//                JSON Response: {"aps":{"alert":{"title":"PLATFORMA PRO","subtitle":"ТЕСТ с Platformapro.com","body":"Тестовое название мероприятия"},"sound":"testRingNotification"},"live_activity":{"start_time":"2025-01-13 18:00:00","event_name":"Тестовое название мероприятия"},"custom":{"openPage":"notification","action":"https:\/\/platformapro.com\/user-single-event\/6"}}

                await MainActor.run { activityID = activity.id }
                print("Activity id: \(activity.id)")

                for await data in activity.pushTokenUpdates {
                    let token = data.map {String(format: "%02x", $0)}.joined()
                    print("Activity token: \(token)")
                    await MainActor.run { activityToken = token }
                    // HERE SEND THE TOKEN TO THE SERVER
                    sendActivityData(userID: initialContentState.userID, eventID: initialContentState.eventID, eventToken: token, activityID: activity.id, dateEnd: initialContentState.startTime)
//                    sendActivityData(userID: userID, eventID: eventID, eventToken: eventToken, activityID: activityID, dateEnd: dateEnd)
//                    activityActionNetwork.sendActiivityData(userID: <#T##String#>, eventID: <#T##String#>, eventToken: <#T##String#>, activityID: <#T##String#>, dateEnd: <#T##String#>)
                }
            } catch {
                print("""
                        Couldn't start activity
                        ------------------------
                        \(String(describing: error))
                        """)
            }
        }

    }
    
    func updateActivityRandomly() async {
//        guard let activityID = await activityID,
//              let runningActivity = Activity<MatchLiveScoreAttributes>.activities.first(where: { $0.id == activityID }) else {
//            return
//        }
//        let newRandomContentState = MatchLiveScoreAttributes.ContentState(homeTeamScore: Int.random(in: 1...9),
//                                                                          awayTeamScore: Int.random(in: 1...9),
//                                                                          lastEvent: "Something random happened!")
//        await runningActivity.update(using: newRandomContentState)
    }
    
    func endActivity() async {
        guard let activityID = await activityID,
              let runningActivity = Activity<PlatformaLiveActivityAttributes>.activities.first(where: { $0.id == activityID }) else {
            return
        }
        let initialContentState = PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "")

        await runningActivity.end(
            ActivityContent(state: initialContentState, staleDate: Date.distantFuture),
            dismissalPolicy: .immediate
        )

        await MainActor.run {
            self.activityID = nil
            self.activityToken = nil
        }
    }
    
    func cancelAllRunningActivities() async {
        for activity in Activity<PlatformaLiveActivityAttributes>.activities {
            let initialContentState = PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "")
            
            await activity.end(
                ActivityContent(state: initialContentState, staleDate: Date()),
                dismissalPolicy: .immediate
            )
        }
        
        await MainActor.run {
            activityID = nil
            activityToken = nil
        }
    }
    
    func sendActivityData(userID: String, eventID: String, eventToken: String, activityID: String, dateEnd: String) {
        withAnimation(.easeInOut(duration: 0.35)) {
            activityActionNetwork.sendActiivityData(userID: userID, eventID: eventID, eventToken: eventToken, activityID: activityID, dateEnd: dateEnd) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
//                        if (qrCodeNetworkReqests.userConfirmationDataModel.status == true) {
//                            showQrCodeResponseAlert = true
//                        } else {
//                            showRequestErrorText = qrCodeNetworkReqests.userConfirmationDataModel.error ?? "Unknown Error while sending QR Code data"
//                            showRequestError = true
//                        }
//                        isSendedQRData = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
//                        showRequestErrorText = qrCodeNetworkReqests.userConfirmationDataModel.error ?? "Error: \(error.localizedDescription) | \(error)"
//                        showRequestError = true
//                        isSendedQRData = false
                    }
                }
            }
        }
    }
    
}

//{
//    "aps": {
//        "timestamp": 1234,
//        "event": "start",
//        "content-state": {
//            "numberOfUnreadEntries": 100,
//            "entries": [
//                {
//                    "id": "liveBlogEntryId1",
//                    "time": "09.23",
//                    "description": "Rollrykten! Vem som ska spela dina favoritkaraktärer?"
//                }
//            ]
//        },
//        "attributes-type": "LiveBlogAttributes",
//        "attributes": {
//            "title": "Warner Bros planerar Harry Potter-serie.",
//            "categoryName": "Senaste nytt",
//            "startTime": "09.00"
//        },
//        "alert": {
//            "title": "Your event in 1 hour start",
//            "body": "Event name for debug"
//        }
//    }
//}
