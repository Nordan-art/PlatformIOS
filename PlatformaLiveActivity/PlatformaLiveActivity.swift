//
//  PlatformaLiveActivity.swift
//  PlatformaLiveActivity
//
//  Created by Daniil Razbitski on 13/01/2025.
//

import WidgetKit
import SwiftUI


//MARK: -- Provider for all events what exist in platform
struct Provider: TimelineProvider {
    private let userDefaults = UserDefaults(suiteName: "group.com.MCGroup.Platforma")
    
    func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [], dataUserEvent: []), image: [UIImage(systemName: "photo")])
//        SimpleEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let eventsData = loadEvents()
        let imageUrls = eventsData.dataAllEvents.compactMap { $0.imageUrl }
        fetchImages(imageUrls: imageUrls) { image in
            let entry = SimpleEntry(date: Date(), eventsData: eventsData, image: image)
            
            //        let entry = SimpleEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
            
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let eventsData = loadEvents()
        let imageUrls = eventsData.dataAllEvents.compactMap { $0.imageUrl }
        
        fetchImages(imageUrls: imageUrls) { image in
            let entry = SimpleEntry(date: Date(), eventsData: eventsData, image: image)
//            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
//            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                        let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    // Load favorite screens from UserDefaults
    private func loadEvents() -> AllWdigetsDataModel {
        guard let data = userDefaults?.data(forKey: "widgetEvents"),
              let returnData = try? JSONDecoder().decode(AllWdigetsDataModel.self, from: data) else {
            //            return AllWdigetsDataModel(status: false, dataAllEvents: [], dataUserEvent: [])
                        return AllWdigetsDataModel(status: true, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/uploads/front/img/logo.svg", link: "")], dataUserEvent: [EventDataModel(id: 2, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/uploads/front/img/logo.svg", link: "")])
        }
        return returnData
    }
    
    private func fetchImages(imageUrls: [String], completion: @escaping ([UIImage?]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage?] = Array(repeating: nil, count: imageUrls.count)
        
        for (index, urlString) in imageUrls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    images[index] = image
                }
                dispatchGroup.leave()
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let eventsData: AllWdigetsDataModel
    let image: [UIImage?]
}

struct PlatformaLiveActivityEntryView : View {
    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(family == .systemLarge ? "widgets.closest_events" : "widgets.closest_event")
                    .font(.custom("Montserrat-SemiBold", size: 15))
                    .foregroundStyle(Color.white)

                Spacer()
                
                Image("logo-mini")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                if (!entry.eventsData.dataAllEvents.isEmpty) {
                    if (family == .systemLarge) {
                        ForEach(Array(entry.eventsData.dataAllEvents.enumerated().prefix(5)), id: \.element.id) { index, value in
                            Link(destination: URL(string: value.link)!) {
                                HStack(spacing: 0) {
                                    if let image = entry.image[index] {
                                        ZStack(alignment: .center) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .cornerRadius(10)
                                                .frame(width: 40, height: 40)
                                            
                                            Image(value.type == 1 ? "online" : "offline")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }
                                    } else {
                                        // Fallback image or a placeholder
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(10)
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text("\(value.title)")
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .font(.custom("Montserrat-Medium", size: 14))
                                        .padding(.leading, 10)
                                        .foregroundStyle(Color.lightGrayColorB7B7B7)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                                .frame(width: nil)
                            }
                            .padding(.bottom, 15)
                        }
                    } else {
                        ForEach(Array(entry.eventsData.dataAllEvents.enumerated().prefix(1)), id: \.element.id) { index, value in
                            Link(destination: URL(string: value.link)!) {
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        if let image = entry.image[index] {
                                            ZStack(alignment: .center) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .cornerRadius(10)
                                                    .frame(width: 40, height: 40)
                                                
                                                Image(value.type == 1 ? "online" : "offline")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                            }
                                        } else {
                                            // Fallback image or a placeholder
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(10)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text("\(value.title)")
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .font(.custom("Montserrat-Medium", size: 14))
                                            .padding(.leading, 10)
                                            .foregroundStyle(Color.lightGrayColorB7B7B7)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                    }
                                    .frame(width: nil)
                                    .padding(.bottom, 20)
                                    
                                    HStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            let time =  value.start.components(separatedBy: " ")
                                            Image(systemName: "clock")
                                                .resizable()
                                                .frame(width: 13, height: 13)
                                                .foregroundStyle(Color.gray)
                                                .padding(.leading, 20)
                                                .padding(.vertical, 5)
                                            
                                            Text(time[1])
                                                .font(.custom("Montserrat-Regular", size: 13))
                                                .foregroundStyle(Color.lightGrayColorB7B7B7)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 20)
                                                .padding(.vertical, 5)
                                        }
                                        .background(Color.black)
                                        .cornerRadius(13)
                                        .padding(.trailing, 5)

                                        HStack(spacing: 0) {
                                            Image("adres")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 10, height: 13)
                                                .foregroundStyle(Color.gray)
                                                .padding(.leading, 10)
                                                .padding(.vertical, 5)
                                            
                                            Text(value.address)
                                                .font(.custom("Montserrat-Regular", size: 13))
                                                .foregroundStyle(Color.lightGrayColorB7B7B7)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 10)
                                                .padding(.vertical, 5)
                                        }
                                        .background(Color.black)
                                        .cornerRadius(13)

                                    }
                                }
                            }
//                            .padding(.bottom, 10)
                        }
                    }
                } else {
                    Text(LocalizedStringKey("widgets.no_information_about_events_await_update"))
                            .font(.custom("Montserrat-Medium", size: 15))
                            .foregroundStyle(Color.lightGrayLiveActive)
                            .padding(.top, 75)
                }
            }
            
            Spacer()
        }
    }
}

//MARK: -- Entry for widgets where ALL EVENTS from platfroma
struct PlatformaLiveActivity: Widget {
    let kind: String = "PlatformaLiveActivity"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PlatformaLiveActivityEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PlatformaLiveActivityEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .containerBackgroundRemovable(false)
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName(LocalizedStringKey("widgets.all_events.upcoming_all_events_title"))
        .description(LocalizedStringKey("widgets.all_events.upcoming_all_events_description"))
    }
}


//MARK: -- Provider for all events what exist in platform
struct ProviderUser: TimelineProvider {
    private let userDefaults = UserDefaults(suiteName: "group.com.MCGroup.Platforma")
    
    func placeholder(in context: Context) -> SimpleUserWidgetEntry {
//        SimpleUserWidgetEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f6.jpg", link: "")], dataUserEvent: []), image: [])
        SimpleUserWidgetEntry(date: Date(), eventsData: AllWdigetsDataModel(status: true, dataAllEvents: [], dataUserEvent: []), image: [UIImage(systemName: "photo")])
//        SimpleUserWidgetEntry(date: Date(), eventsData: AllWdigetsDataModel(status: true, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleUserWidgetEntry) -> Void) {
        let eventsData = loadEvents()
        let imageUrls = eventsData.dataUserEvent.compactMap { $0.imageUrl }
        fetchImages(imageUrls: imageUrls) { image in
            
            let entry = SimpleUserWidgetEntry(date: Date(), eventsData: eventsData, image: image)
            //        let entry = SimpleUserWidgetEntry(date: Date(), eventsData: AllWdigetsDataModel(status: true, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
            
            completion(entry)
        }
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let eventsData = loadEvents()
        let imageUrls = eventsData.dataUserEvent.compactMap { $0.imageUrl }
        
        fetchImages(imageUrls: imageUrls) { image in
            let entry = SimpleUserWidgetEntry(date: Date(), eventsData: eventsData, image: image)
//            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
//            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                        let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    // Load favorite screens from UserDefaults
    private func loadEvents() -> AllWdigetsDataModel {
        guard let data = userDefaults?.data(forKey: "widgetEvents"),
              let returnData = try? JSONDecoder().decode(AllWdigetsDataModel.self, from: data) else {
//            return AllWdigetsDataModel(status: false, dataAllEvents: [], dataUserEvent: [])
            return AllWdigetsDataModel(status: true, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/uploads/front/img/logo.svg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/uploads/front/img/logo.svg", link: "")])
        }
        return returnData
    }
    
    private func fetchImages(imageUrls: [String], completion: @escaping ([UIImage?]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage?] = Array(repeating: nil, count: imageUrls.count)
        
        for (index, urlString) in imageUrls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    images[index] = image
                }
                dispatchGroup.leave()
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
}

struct SimpleUserWidgetEntry: TimelineEntry {
    let date: Date
    let eventsData: AllWdigetsDataModel
    let image: [UIImage?]
}

struct PlatformaWidgetUserEventView : View {
    @Environment(\.widgetFamily) var family

    var entry: ProviderUser.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(family == .systemLarge ? "widgets.closest_events" : "widgets.closest_event")
                    .font(.custom("Montserrat-SemiBold", size: 15))
                
                Spacer()
                
                Image("logo-mini")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                if (!entry.eventsData.dataUserEvent.isEmpty) {
                    if (family == .systemLarge) {
                        ForEach(Array(entry.eventsData.dataUserEvent.enumerated().prefix(5)), id: \.element.id) { index, value in
                            Link(destination: URL(string: value.link)!) {
                                HStack(spacing: 0) {
                                    if let image = entry.image[index] {
                                        ZStack(alignment: .center) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .cornerRadius(10)
                                                .frame(width: 40, height: 40)
                                            
                                            Image(value.type == 1 ? "online" : "offline")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }
                                    } else {
                                        // Fallback image or a placeholder
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(10)
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text("\(value.title)")
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .font(.custom("Montserrat-Medium", size: 14))
                                        .padding(.leading, 10)
                                        .foregroundStyle(Color.lightGrayColorB7B7B7)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                                .frame(width: nil)
                            }
                            .padding(.bottom, 15)
                        }
                    } else {
                        ForEach(Array(entry.eventsData.dataUserEvent.sorted(by: {$0.start < $1.start}).enumerated().prefix(1)), id: \.element.id) { index, value in
                            Link(destination: URL(string: value.link)!) {
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        if let image = entry.image[index] {
                                            ZStack(alignment: .center) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .cornerRadius(10)
                                                    .frame(width: 40, height: 40)
                                                
                                                Image(value.type == 1 ? "online" : "offline")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                            }
                                        } else {
                                            // Fallback image or a placeholder
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(10)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text("\(value.title)")
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .font(.custom("Montserrat-Medium", size: 14))
                                            .padding(.leading, 10)
                                            .foregroundStyle(Color.lightGrayColorB7B7B7)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                    }
                                    .frame(width: nil)
                                    .padding(.bottom, 20)
                                    
                                    HStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            let time =  value.start.components(separatedBy: " ")
                                            Image(systemName: "clock")
                                                .resizable()
                                                .frame(width: 13, height: 13)
                                                .foregroundStyle(Color.gray)
                                                .padding(.leading, 20)
                                                .padding(.vertical, 5)
                                            
                                            Text(time[1])
                                                .font(.custom("Montserrat-Regular", size: 13))
                                                .foregroundStyle(Color.lightGrayColorB7B7B7)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 20)
                                                .padding(.vertical, 5)
                                        }
                                        .background(Color.black)
                                        .cornerRadius(13)
                                        .padding(.trailing, 5)
                                        
                                        HStack(spacing: 0) {
                                            Image("adres")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 10, height: 13)
                                                .foregroundStyle(Color.gray)
                                                .padding(.leading, 10)
                                                .padding(.vertical, 5)
                                            
                                            Text(value.address)
                                                .font(.custom("Montserrat-Regular", size: 13))
                                                .foregroundStyle(Color.lightGrayColorB7B7B7)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 10)
                                                .padding(.vertical, 5)
                                        }
                                        .background(Color.black)
                                        .cornerRadius(13)
                                        
                                    }
                                }
                            }
                        }
                    }
                } else {
                        Text("widgets.no_information_about_events_need_authorize_await_update")
                            .font(.custom("Montserrat-Medium", size: 15))
                            .foregroundStyle(Color.lightGrayLiveActive)
                            .padding(.top, 75)
                }
            }
            
            Spacer()
        }
    }
}

//MARK: -- Entry for widgets where USER EVENTS from platfroma
struct PlatformaMyEventWdiget: Widget {
    let kind: String = "PlatformaUserEvent"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProviderUser()) { entry in
            if #available(iOS 17.0, *) {
                PlatformaWidgetUserEventView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PlatformaWidgetUserEventView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .containerBackgroundRemovable(false)
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName(LocalizedStringKey("widgets.all_events.upcoming_my_event_title"))
        .description(LocalizedStringKey("widgets.all_events.upcoming_my_event_description"))
    }
}

//#Preview(as: .systemMedium) {
//    PlatformaLiveActivity()
////    PlatformaMyEventWdiget()
//} timeline: {
//    SimpleEntry(date: Date(), eventsData: AllWdigetsDataModel(status: true, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 2, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
//}

//#Preview(as: .systemMedium) {
//    PlatformaLiveActivity()
//} timeline: {
//    SimpleEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
////    SimpleEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "", link: "")], dataUserEvent: []), image: [UIImage(systemName: "photo")])
////    SimpleUserWidgetEntry(date: Date(), eventsData: AllWdigetsDataModel(status: false, dataAllEvents: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")], dataUserEvent: [EventDataModel(id: 1, type: 0, title: "Example event", city: "Warszawa", address: "Address of event", start: "2025-01-01 18:00", imageUrl: "https://platformapro.com/storage/app/public/uploads/event/cover_default/f20.jpg", link: "")]), image: [UIImage(systemName: "photo")])
//}
