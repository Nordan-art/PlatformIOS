//
//  PlatformaApp.swift
//  Platforma
//
//  Created by Daniil Razbitski on 02/12/2024.
//

import SwiftUI
import WebKit
import UserNotifications

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
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //        // Handle the notification when it is received while the app is in the foreground
    //        completionHandler(.banner)
    //    }
    //
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //        // Handle the notification when it is received while the app is in the background or not running
    //        completionHandler()
    //    }
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print userInfo for debugging
//           print("UserInfo: \(userInfo)")

           // Convert userInfo to Data
           if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []) {
//               print("Converted to Data:", jsonData)

               do {
                   // Decode JSON data into NotificationDataModel
                   let model = try JSONDecoder().decode(NotificationDataModel.self, from: jsonData)
//                   print("Decoded Model: \(model)")
                   
                   // Handle specific fields
                   if let action = model.custom?.action {
//                       print("Notification Action: \(action)")
                       StateContent.url = URL(string: action) ?? URL(string: "https://platformapro.com/login?webview")!
                   }
               } catch {
//                   print("Error decoding JSON: \(error.localizedDescription)")
               }
           } else {
//               print("Failed to serialize dictionary to Data.")
           }

//               if let messageID = userInfo[gcmMessageIDKey] {
//                 print("Message ID from userNotificationCenter didReceive: \(messageID)")
//               }

        completionHandler()
    }
}


struct NotificationDataModel: Codable {
    let custom: Custom?
    let aps: APS

    struct Custom: Codable {
        let action: String?
        let openPage: String?
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
