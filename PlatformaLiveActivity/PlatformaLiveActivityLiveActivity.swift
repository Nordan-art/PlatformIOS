//
//  PlatformaLiveActivityLiveActivity.swift
//  PlatformaLiveActivity
//
//  Created by Daniil Razbitski on 13/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PlatformaLiveActivityLiveActivity: Widget {
    @State private var differenceText: String = ""

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PlatformaLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            EventActivityView(context: context)
            .activityBackgroundTint(Color.black.opacity(0.27))
//            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 0) {
//                        Text("Bottom \(context.state.emoji)")
                        Text("\(context.state.eventName)")
                    }
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.eventType)")
            } minimal: {
                Text(context.state.eventType)
            }
            .widgetURL(URL(string: "\(context.state.eventURL)"))
//            .widgetURL(URL(string: "https://platformapro.com/user-single-event/6"))
//            .keylineTint(Color.red)
        }
    }

}

extension PlatformaLiveActivityAttributes {
    fileprivate static var preview: PlatformaLiveActivityAttributes {
        PlatformaLiveActivityAttributes(name: "World", title: "", countsDown: "")
    }
}

extension PlatformaLiveActivityAttributes.ContentState {
    fileprivate static var smiley: PlatformaLiveActivityAttributes.ContentState {
        PlatformaLiveActivityAttributes.ContentState(startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", activityID: "")
     }
     
     fileprivate static var starEyes: PlatformaLiveActivityAttributes.ContentState {
         PlatformaLiveActivityAttributes.ContentState(startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", activityID: "")
     }
}

//#Preview("Notification", as: .content, using: PlatformaLiveActivityAttributes.preview) {
//   PlatformaLiveActivityLiveActivity()
//} contentStates: {
//    PlatformaLiveActivityAttributes.ContentState.smiley
//    PlatformaLiveActivityAttributes.ContentState.starEyes
//}

struct EventActivityView: View {
    let context: ActivityViewContext<PlatformaLiveActivityAttributes>
    
    var body: some View {
        VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("logo-svg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 122, height: 20)
                    
                    Spacer()
                    
                    //                    Text(calculateTime(calcTime: context.state.startTime))
                    Text(extractTime(from: context.state.startTime) ?? "")
                        .font(.custom("Montserrat-Medium", size: 17))
                        .foregroundColor(Color.white)
                    
                    Text(" ")
                    //                    Text(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)
                    ////                    Text(timerInterval: context.attributes.startDate...context.attributes.endDate, countsDown: context.attributes.countsDown, showsHours: false)
                    //                        .font(.custom("Montserrat-Medium", size: 17))
                    //                        .foregroundColor(Color.privacyPolicyCloseButton)
                    
                    Image(systemName: "clock")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color.privacyPolicyCloseButton)
                    //                        .scaleEffect(x: -1, y: 1)
                    
                    Text(" ")
                    //                    Text("\(differenceText) min")
                    //                        .font(.custom("Montserrat-Medium", size: 17))
                    //                        .foregroundColor(Color.privacyPolicyCloseButton)
                    Text(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)
                        .font(.custom("Montserrat-Medium", size: 17))
                        .foregroundColor(Color.privacyPolicyCloseButton)
                    
                    Text(" min")
                        .font(.custom("Montserrat-Medium", size: 17))
                        .foregroundColor(Color.privacyPolicyCloseButton)
                }
                .multilineTextAlignment(.trailing)
                .padding(.top, 15)
            
            Text("\(context.state.eventName)")
                .font(.custom("Montserrat-SemiBold", size: 16))
                .foregroundColor(Color.white)
                .padding(.top, 15)
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(systemName: "house")
                        .resizable()
                        .frame(width: 12, height: 13)
                        .foregroundStyle(Color.lightGrayLiveActive)
                        .padding(.trailing, 5)
                    
                    Text("\(context.state.eventType)")
                        .font(.custom("Montserrat-Regular", size: 14))
                        .foregroundStyle(Color.lightGrayLiveActive)
                    
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 13)
                .background(Color.lightGrayLiveActiveBackground)
                .cornerRadius(15)
                .padding(.trailing, 5)
                
                HStack(spacing: 0) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .frame(width: 10, height: 13)
                        .foregroundStyle(Color.lightGrayLiveActive)
                        .padding(.trailing, 5)
                    
                    Text("\(context.state.eventAddress)")
                        .font(.custom("Montserrat-Regular", size: 14))
                        .foregroundStyle(Color.lightGrayLiveActive)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
                .background(Color.lightGrayLiveActiveBackground)
                .cornerRadius(15)
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
        }
    }
    func getDateTime(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.date(from: time)!
    }
    
    func extractTime(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Input format
        dateFormatter.timeZone = TimeZone.current
        
        // Convert the string to a Date
        if let date = dateFormatter.date(from: dateString) {
            // Create a formatter for the time only
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm" // Desired output format
            timeFormatter.timeZone = TimeZone.current
            
            return timeFormatter.string(from: date)
        }
        return nil
    }

}


//final class ActivityManager: ObservableObject {
//    @MainActor @Published private(set) var activityID: String?
//    @MainActor @Published private(set) var activityToken: String?
//    
//    let attributes = PlatformaLiveActivityAttributes(name: "Jhon", title: "Upcoming Event")
//    let initialContentState = PlatformaLiveActivityAttributes.ContentState(emoji: "😀", eventName: "My Event", timeRemaining: 300)
//
//    static let shared = ActivityManager()
//    
//    func start() async {
//        await endActivity()
//        await startNewLiveActivity()
//    }
//    
//    private func startNewLiveActivity() async {
//        do {
//        let activity = try Activity<PlatformaLiveActivityAttributes>.request(
//            attributes: attributes,
//            contentState: initialContentState,
//            pushType: .token
//        )
//        
//        Task {
//            for await pushToken in activity.pushTokenUpdates {
//                let pushTokenString = pushToken.reduce("") {
//                      $0 + String(format: "%02x", $1)
//                }
//
////                        Logger().log("New push token: \(pushTokenString)")
//                        print("New push token: \(pushTokenString)")
////                        try await self.sendPushToken(hero: hero, pushTokenString: pushTokenString)
//            }
//        }
//
////        guard let activity = activity else {
////            return
////        }
//            
//        await MainActor.run { activityID = activity.id }
//        
//        for await data in activity.pushTokenUpdates {
//            let token = data.map {String(format: "%02x", $0)}.joined()
//            print("Activity token: \(token)")
//            await MainActor.run { activityToken = token }
//            // HERE SEND THE TOKEN TO THE SERVER
//        }
//        } catch {
//            print("""
//                        Couldn't start activity
//                        ------------------------
//                        \(String(describing: error))
//                        """)
//        }
//
//    }
//    
//    func updateActivityRandomly() async {
////        guard let activityID = await activityID,
////              let runningActivity = Activity<MatchLiveScoreAttributes>.activities.first(where: { $0.id == activityID }) else {
////            return
////        }
////        let newRandomContentState = MatchLiveScoreAttributes.ContentState(homeTeamScore: Int.random(in: 1...9),
////                                                                          awayTeamScore: Int.random(in: 1...9),
////                                                                          lastEvent: "Something random happened!")
////        await runningActivity.update(using: newRandomContentState)
//    }
//    
//    func endActivity() async {
////        guard let activityID = await activityID,
////              let runningActivity = Activity<MatchLiveScoreAttributes>.activities.first(where: { $0.id == activityID }) else {
////            return
////        }
////        let initialContentState = MatchLiveScoreAttributes.ContentState(homeTeamScore: 0,
////                                                                        awayTeamScore: 0,
////                                                                        lastEvent: "Match Start")
////
////        await runningActivity.end(
////            ActivityContent(state: initialContentState, staleDate: Date.distantFuture),
////            dismissalPolicy: .immediate
////        )
////        
////        await MainActor.run {
////            self.activityID = nil
////            self.activityToken = nil
////        }
//    }
//    
//    func cancelAllRunningActivities() async {
//        for activity in Activity<PlatformaLiveActivityAttributes>.activities {
//            let initialContentState = PlatformaLiveActivityAttributes.ContentState(emoji: "😀", eventName: "My Event", timeRemaining: 300)
//            
//            await activity.end(
//                ActivityContent(state: initialContentState, staleDate: Date()),
//                dismissalPolicy: .immediate
//            )
//        }
//        
//        await MainActor.run {
//            activityID = nil
//            activityToken = nil
//        }
//    }
//    
//}
