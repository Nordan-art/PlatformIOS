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
    var initialContentState = PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "", staleDate: "")

    static let shared = ActivityManager()
    
    func start(activityID: String) async {
        await endActivity()
        await startNewLiveActivity()
        print("activityManager.initialContentState: \(initialContentState)")
    }
    
    func getDateTime(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")  // Ensure it reads as UTC
        
        return dateFormatter.date(from: time)!
    }

    private func startNewLiveActivity() async {
        // 1. Check if Live Activities are enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled on this device.")
            return
        }
        
        do {
            // 2. Create initial content for the Live Activity
            let content = ActivityContent(
                state: initialContentState,
                staleDate: getDateTime(time: initialContentState.staleDate),
                relevanceScore: 1.0
            )
            
            // 3. Request a new Live Activity with push updates enabled (.token)
            let activity = try Activity.request(
//            let activity = try Activity<PlatformaLiveActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: .token // Required if you plan to update via push
            )
            
            // 4. Store the Activity ID on the main actor (UI-related properties)
            await MainActor.run {
                self.activityID = activity.id
            }
            
            print("Started new activity with ID: \(activity.id)")
            
//            scheduleEnd(activity: activity, endTime: getDateTime(time: initialContentState.staleDate))

            // 5. Listen for push token updates in an async Task
            Task {
                for await pushTokenData in activity.pushTokenUpdates {
                    let pushTokenString = pushTokenData.map {
                        String(format: "%02x", $0)
                    }.joined()
                    
                    // Print or log the token as needed
                    print("New push token: \(pushTokenString)")
                    
                    // Optionally store the token on the main actor
                    await MainActor.run {
                        self.activityToken = pushTokenString
                    }
                    
                    // 6. Send the updated token + activity info to your server
                    sendActivityData(
                        userID: initialContentState.userID,
                        eventID: initialContentState.eventID,
                        eventToken: pushTokenString,
                        activityID: activity.id,
                        dateEnd: initialContentState.startTime
                    )
                }
            }
        } catch {
            print("Couldn't start activity. Error: \(error.localizedDescription)")
        }
    }
    
    func endActivity() async {
        guard let activityID = await activityID, let runningActivity = Activity<PlatformaLiveActivityAttributes>.activities.first(where: { $0.id == activityID }) else {
            return
        }
        
        let initialContentState = PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "", staleDate: "")

        await runningActivity.end(
            ActivityContent(state: initialContentState, staleDate: Date.distantFuture),
            dismissalPolicy: .immediate
        )

        await MainActor.run {
            self.activityID = nil
            self.activityToken = nil
        }
    }
    
    func scheduleEnd(activity: Activity<PlatformaLiveActivityAttributes>, endTime: Date) {
        Task {
               let timeRemaining = endTime.timeIntervalSinceNow
               
            print("endTime: \(endTime) inti staleDate: \(initialContentState.staleDate)")
            print("timeRemaining: \(timeRemaining)")
            print("initialContentState: \(initialContentState.startTime)")
               // Ensure there's time left to wait
               if timeRemaining > 0 {
                   try? await Task.sleep(nanoseconds: UInt64(timeRemaining * 1_000_000_000))
               }

               // Check if the activity is still active before ending it
               if let currentActivity = Activity<PlatformaLiveActivityAttributes>.activities.first(where: { $0.id == activity.id }) {
                   print("⏳ Time is up! Ending Live Activity automatically.")

                   await currentActivity.end(dismissalPolicy: .immediate)

               } else {
                   print("⚠️ Activity already ended or not found.")
               }
           }
    }

    func cancelAllRunningActivities() async {
        for activity in Activity<PlatformaLiveActivityAttributes>.activities {
            let initialContentState = PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "", staleDate: "")
            
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
                case .success(let _data):
                    DispatchQueue.main.async {
                        print("Error while sending activity update token: Success")
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
                        print("Error while sending activity update token: \(error)")
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













//    private func startNewLiveActivity() async {
//        if ActivityAuthorizationInfo().areActivitiesEnabled {
//            do {
//                let content = ActivityContent(state: initialContentState, staleDate: nil, relevanceScore: 1.0)
//
//                let activity = try Activity<PlatformaLiveActivityAttributes>.request(
//                    attributes: attributes,
//                    content: content,
//                    pushType: .token
//                )
//
//                Task {
//                    for await pushToken in activity.pushTokenUpdates {
//                        let pushTokenString = pushToken.reduce("") {
//                            $0 + String(format: "%02x", $1)
//                        }
//                        print("New push token: \(pushTokenString)")
//                    }
//                }
//
//                await MainActor.run { activityID = activity.id }
//                print("ZZZ NEW Activity id: \(activity.id)")
//
//                for await data in activity.pushTokenUpdates {
//                    let token = data.map {String(format: "%02x", $0)}.joined()
//                    print("Activity token: \(token)")
//                    await MainActor.run { activityToken = token }
//                    // HERE SEND THE TOKEN TO THE SERVER
//                    sendActivityData(userID: initialContentState.userID, eventID: initialContentState.eventID, eventToken: token, activityID: activity.id, dateEnd: initialContentState.startTime)
////                    sendActivityData(userID: userID, eventID: eventID, eventToken: eventToken, activityID: activityID, dateEnd: dateEnd)
////                    activityActionNetwork.sendActiivityData(userID: <#T##String#>, eventID: <#T##String#>, eventToken: <#T##String#>, activityID: <#T##String#>, dateEnd: <#T##String#>)
//                }
//            } catch {
//                print("""
//                        Couldn't start activity
//                        ------------------------
//                        \(String(describing: error))
//                        """)
//            }
//        }
//    }
