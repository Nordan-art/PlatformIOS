//
//  PlatformaApp.swift
//  Platforma
//
//  Created by Daniil Razbitski on 02/12/2024.
//

import SwiftUI
import WebKit
import UserNotifications
import ActivityKit

@main
struct PlatformaApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    private var delegate: NotificationDelegate = NotificationDelegate()
    
    @State private var bluringAppInBackground: Bool = false
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .ignoresSafeArea(.keyboard)
            /// Проверка и устанвока состояние где находиться приложение, по типу свёрнуто полность, то это background,
            /// при просмотре открытых приложенеи(list всех приложение), то это inactive,
            /// иначе active
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        withAnimation {
                            bluringAppInBackground = false
                        }
                    } else if newPhase == .inactive {
                        withAnimation {
                            bluringAppInBackground = true
                        }
                    } else if newPhase == .background {
                        withAnimation {
                            bluringAppInBackground = true
                        }
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//    var stateDeviceIDContent = StateDeviceIDContent()
    @ObservedObject private var activityManager = ActivityManager.shared

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Request authorization to display notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            // Handle the authorization result
            //print("Granted or not? : \(granted)")
        }
        center.delegate = self
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []) {
            //               print("Converted to Data:", jsonData)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }
        }
        
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Send the device token to your server
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceToken = tokenParts.joined()
        StateContent.deviceID = deviceToken
//        stateDeviceIDContent.deviceID = deviceToken
                print("Device Token: \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle the registration error
    }
        
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print userInfo for debugging
        //           print("UserInfo: \(userInfo)")

        //        updateLiveActivity(endTime: <#T##Date#>)

        //        runLiveActivity
        // Convert userInfo to Data
           if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []) {
//               print("Converted to Data:", jsonData)

               do {
                   if let jsonString = String(data: jsonData, encoding: .utf8) {
                       print("JSON Response: \(jsonString)")
                   }

                   // Decode JSON data into NotificationDataModel
                   let model = try JSONDecoder().decode(NotificationDataModel.self, from: jsonData)
//                   print("Decoded Model: \(model)")
                   
                   // Handle specific fields
                   if let action = model.custom?.action {
//                       print("Notification Action: \(action)")
                       StateContent.url = URL(string: action) ?? URL(string: "https://platformapro.com/login?webview")!
                   }
                   
                   if let liveactivity = model.live_activity {
                       if (activityManager.activityID?.isEmpty == false) {
                           Task {
                               await activityManager.cancelAllRunningActivities()
                           }
                       } else {
                           Task {
                               activityManager.initialContentState = PlatformaLiveActivityAttributes.ContentState(startTime: model.live_activity?.startTime ?? "", eventName: model.live_activity?.eventName ?? "", eventType: model.live_activity?.eventType ?? "", eventAddress: model.live_activity?.eventAddress ?? "", eventURL: model.live_activity?.eventURL ?? "", activityID: model.live_activity?.activityID ?? "")
                               await activityManager.start(activityID: model.live_activity?.activityID ?? "")
                           }
                       }
                   }
                   
//                   JSON Response: {"custom":{"openPage":"notification","action":"https:\/\/platformapro.com\/user-single-event\/6"},"aps":{"alert":{"title":"PLATFORMA PRO","subtitle":"ТЕСТ с Platformapro.com","body":"Тестовое название мероприятия"},"timestamp":"1705168800","event":"update","content-state":{"awayTeamScore":"2","lastEvent":"Привет мир!","homeTeamScore":"1"},"sound":"testRingNotification"}}
//                   JSON Response: {"live_activity":{"start_time":"2025-01-13 18:00:00","event_name":"Тестовое название мероприятия"},"custom":{"openPage":"notification","action":"https:\/\/platformapro.com\/user-single-event\/6"},"aps":{"alert":{"title":"PLATFORMA PRO","subtitle":"ТЕСТ с Platformapro.com","body":"Тестовое название мероприятия"},"sound":"testRingNotification"}}

               } catch {
//                   print("Error decoding JSON: \(error.localizedDescription)")
               }
           } else {
//               print("Failed to serialize dictionary to Data.")
           }

        completionHandler()
    }
    
//    func updateLiveActivity(endTime: Date) {
//        guard let activity = Activity<MIALiveActivityAttributes>.activities.first else { return }
//
//        Task {
//            await activity.update(using: .init(endTime: endTime))
//        }
//    }
    
}

struct NotificationDataModel: Codable {
    let custom: Custom?
    let live_activity: LiveActivity?
    let aps: APS

    struct Custom: Codable {
        let action: String?
        let openPage: String?
    }
    
    struct LiveActivity: Codable {
        var startTime: String? //start time of the event (получать разницу между началом и текущим и запускать таймер на это время)
        var eventName: String? //name of event
        var eventType: String? //online, offline
        var eventAddress: String? //address of event, where it will be start
        var eventURL: String? //address of event, where it will be start
        var activityID: String? //address of event, where it will be start
    }

    struct APS: Codable {
        let alert: Alert
        let sound: String?

        struct Alert: Codable {
            let body: String
            let subtitle: String
            let title: String
        }
    }
}


//{
//    "live_activity": {
//        "start_time": "2025-01-13 18:00:00",
//        "event_name": "Тестовое название мероприятия"
//    },
//    "custom": {
//        "openPage": "notification",
//        "action": "https://platformapro.com/user-single-event/6"
//    },
//    "aps": {
//        "alert": {
//            "title": "PLATFORMA PRO",
//            "subtitle": "ТЕСТ с Platformapro.com",
//            "body": "Тестовое название мероприятия"
//        },
//        "sound": "testRingNotification"
//    }
//}
