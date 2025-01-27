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
    
    func getDateTime(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.date(from: time)!
    }
    
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
                expandedContent(context: context)
                //                DynamicIslandExpandedRegion(.leading) {
                //
                //                }
                //                DynamicIslandExpandedRegion(.trailing) {
                //                }
                //                DynamicIslandExpandedRegion(.bottom) {
                ////                        Text("Bottom \(context.state.emoji)")
                //                    // more content
                //                }
            } compactLeading: {
                ZStack {
                    Image("logo-mini")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .clipped()
                        .padding([.leading, .trailing], 5)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 20)
                .padding(0)
            } compactTrailing: {
                //                Image(systemName: "timer")
                //                Text("\(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)min")
                //                Text(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)
                Text("\(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)")
                    .font(.custom("Montserrat-Medium", size: 11))
                    .foregroundColor(Color.privacyPolicyCloseButton)
                    .frame(maxWidth: 45)
                    .fixedSize(horizontal: true, vertical: false)
                ////                    .font(.custom("Montserrat-Bold", size: 11))
                ////                    .font(.custom("Montserrat-Medium", size: 11))
                //                    .font(.system(size: 11, weight: .medium))
                //                    .foregroundColor(Color.privacyPolicyCloseButton)
                //                    .multilineTextAlignment(.leading)
            } minimal: {
                //                    Text("\(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)")
                //                    .font(.custom("Montserrat-Medium", size: 11))
                //                    .font(.system(size: 11, weight: .medium))
                ProgressView(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, label: { Text("") }, currentValueLabel: { Text("") })
                    .progressViewStyle(CircularProgressViewStyle())
                //                      .progressViewStyle(LinearProgressViewStyle())
                    .tint(Color.privacyPolicyCloseButton)
                    .frame(width: 20, height: 20)
                    .scaleEffect(x: 1, y: 1, anchor: .center)
                
            }
            .widgetURL(URL(string: "\(context.state.eventURL)"))
            //            .widgetURL(URL(string: "https://platformapro.com/user-single-event/6"))
            //            .keylineTint(Color.red)
        }
    }
    
    @DynamicIslandExpandedContentBuilder
    private func expandedContent(context: ActivityViewContext<PlatformaLiveActivityAttributes>) -> DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            HStack(spacing: 0) {
                Image("logo-mini")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(.trailing, 5)
                
                Text(extractTime(from: context.state.startTime) ?? "")
                    .font(.custom("Montserrat-Medium", size: 17))
                //                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.white)
            }
            .padding(.leading, 5)
        }
        
        DynamicIslandExpandedRegion(.trailing) {
            HStack(spacing: 0) {
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color.privacyPolicyCloseButton)
                    .scaleEffect(x: -1, y: 1)
                    .padding(.trailing, 5)
                //                ProgressView(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, label: { Text("") }, currentValueLabel: { Text("") })
                //                    .progressViewStyle(CircularProgressViewStyle())
                ////                      .progressViewStyle(LinearProgressViewStyle())
                //                      .tint(Color.privacyPolicyCloseButton)
                //                      .frame(width: 20, height: 20)
                //                      .scaleEffect(x: 1, y: 1, anchor: .center)
                
                
                Text("\(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false)")
                    .font(.custom("Montserrat-Medium", size: 17))
                //                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.privacyPolicyCloseButton)
                    .frame(maxWidth: 70)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.leading, 5)
        }
        
        DynamicIslandExpandedRegion(.bottom) {
            VStack(spacing: 0) {
                Text("\(context.state.eventName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
                    .padding(.top, 5)
//                    .lineLimit(2...)
                
                if (context.state.eventType == "online") {
                    
                } else {
                    HStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image("offline-grey")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 12, height: 15)
                                .foregroundStyle(Color.lightGrayLiveActive)
                            
                            Text(" ")
                            
                            Text("\(context.state.eventType)")
                                .textCase(.uppercase)
                                .font(.custom("Montserrat-Regular", size: 14))
                            //                            .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.lightGrayLiveActive)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.lightGrayLiveActiveBackground)
                        .cornerRadius(15)
                        .padding(.trailing, 5)
                        
                        HStack(spacing: 0) {
                            Image("adres")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 11, height: 15)
                                .foregroundStyle(Color.lightGrayLiveActive)
                            
                            Text(" ")
                            
                            Text("\(context.state.eventAddress)")
                                .font(.custom("Montserrat-Regular", size: 14))
                            //                            .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.lightGrayLiveActive)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 20)
                        .frame(width: .infinity)
                        .background(Color.lightGrayLiveActiveBackground)
                        .cornerRadius(15)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                }
            }
        }
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

extension PlatformaLiveActivityAttributes {
    fileprivate static var preview: PlatformaLiveActivityAttributes {
        PlatformaLiveActivityAttributes(name: "World", title: "", countsDown: "")
    }
}

extension PlatformaLiveActivityAttributes.ContentState {
    fileprivate static var smiley: PlatformaLiveActivityAttributes.ContentState {
        PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "")
    }
    
    fileprivate static var starEyes: PlatformaLiveActivityAttributes.ContentState {
        PlatformaLiveActivityAttributes.ContentState(userID: "", eventID: "", startTime: "", eventName: "", eventType: "", eventAddress: "", eventURL: "", eventToken: "", activityID: "")
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
                HStack(spacing: 0) {
                    Image("full-logo-new")
                    //                            Image("logo-transparent")
                    //                            Image("logoSVGLiveAct")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 122, height: 20)
                    
                    //                                .background(Color.red)
                    //                                .foregroundStyle(Color.purple)
                    //                                .frame(width: 10, height: 20)
                }
                .padding(.leading, 20)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Text(extractTime(from: context.state.startTime) ?? "")
                    //                                .font(.custom("Montserrat-Medium", size: 17))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.white)
                    
                    Text(" ")
                    
                    Image(systemName: "clock")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color.privacyPolicyCloseButton)
                        .scaleEffect(x: -1, y: 1)
                    
                    Text(" ")
                    //                        Text(" \(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false) min")
                    Text("\(timerInterval: Date()...getDateTime(time: context.state.startTime), countsDown: true, showsHours: false) min")
                    //                                .font(.custom("Montserrat-ExtraBold", size: 17))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.privacyPolicyCloseButton)
                        .frame(maxWidth: 95)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    //                        Text(" min")
                    //                            .font(.custom("Montserrat-Medium", size: 17))
                    //                            .foregroundColor(Color.privacyPolicyCloseButton)
                }
                .padding(.trailing, 5)
                //                        .frame(width: .infinity, alignment: .trailing)
            }
            //                .multilineTextAlignment(.trailing)
            .padding(.top, 15)
            
            Text("\(context.state.eventName)")
            //                .font(.custom("Montserrat-SemiBold", size: 16))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.white)
                .padding(.top, 15)
            if (context.state.eventType == "online") {
                
            } else {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Image("offline-grey")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 12, height: 15)
                            .foregroundStyle(Color.lightGrayLiveActive)
                        
                        Text(" ")
                        
                        Text("\(context.state.eventType)")
                            .textCase(.uppercase)
                        //                        .font(.custom("Montserrat-Regular", size: 14))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.lightGrayLiveActive)
                        
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 13)
                    .background(Color.lightGrayLiveActiveBackground)
                    .cornerRadius(15)
                    .padding(.trailing, 5)
                    
                    HStack(spacing: 0) {
                        Image("adres")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 11, height: 15)
                            .foregroundStyle(Color.lightGrayLiveActive)
                        
                        Text(" ")
                        
                        Text("\(context.state.eventAddress)")
                        //                        .font(.custom("Montserrat-Regular", size: 14))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.lightGrayLiveActive)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .frame(width: .infinity)
                    .background(Color.lightGrayLiveActiveBackground)
                    .cornerRadius(15)
                }
                .padding(.top, 15)
                .padding(.bottom, 15)
            }
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


//80da519f5825ea108c810ea7894a61fe7abdbbcd993e52d6deb0537db63af9c6c5cb965f9e956ada74fc69fcb22566035b1db748bcc32977e07de9e31efde40b56638160f84496fd6777a774a48e142e
//460f0ac54cc3277e9ccf38f6ae595e2fa9c60983f5018b9541a772bb87f9f1a8
//JSON Response: {"live_activity":{"startTime":"2025-01-15 01:00:00","eventAddress":"Sejmu Czteroletniego 2\/146","eventName":"Нетворкинг-встреча - Связи будущего в современном мире","eventType":"offline","activityID":"123123"},"aps":{"alert":{"title":"PLATFORMA PRO","subtitle":"ТЕСТ с Platformapro.com","body":"Тестовое название мероприятия"},"sound":"testRingNotification"},"custom":{"openPage":"notification","action":"https:\/\/platformapro.com\/user-single-event\/6"}}
