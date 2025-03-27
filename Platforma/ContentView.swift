//
//  ContentView.swift
//  Platforma
//
//  Created by Daniil Razbitski on 02/12/2024.
//

import Combine
import Foundation

import SwiftUI
import WebKit
import Network
import ActivityKit
import WidgetKit

struct ContentView: View {
    @Environment(\.openURL) var openURL
    
    private let webView = WKWebView()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject var reqWidgetAnaliticData: ReqWidgetAnaliticData = ReqWidgetAnaliticData()
    @State var userAccessToken: String = ""
    
    @State var urlToShowHeader: Bool = false
    @State var textUrl: String = ""
    
    @State private var showingSheetPrivacy = false
    @State private var showingSheetTermsOfUse = false
    
    @State private var additionActionMenu = false
    
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    
    @State var topActionMenuOffset = 0
    @State var rightActionMenuRotateBack = -180
    
    @State private var showProductInfo = false
    
    @StateObject var webViewState = WebViewState()
    
    func changeOffset() {
        if (topActionMenuOffset < 100) {
            withAnimation {
                topActionMenuOffset = 0
                rightActionMenuRotateBack = -180
            }
        } else {
            withAnimation {
                topActionMenuOffset = -120
                rightActionMenuRotateBack = 0
            }
        }
    }
    
    @State var isVisibleNowLoadingScreen: Bool = false
    @State var loadingOnlyOneTime: Bool = false
    //    https://platformapro.com/login
    //    https://platformapro.com/register
//    func networkMonitoring() {
//        let monitor = NWPathMonitor()
//        let queue = DispatchQueue(label: "monitoring")
//        monitor.start(queue: queue)
//        monitor.pathUpdateHandler = { path in
//            DispatchQueue.main.async {
//                switch path.status {
//                case .satisfied:
//                    //                      print("path of internet: \(path.status)")
//                    internetConnectionIsOKorNOT = path.status
//                    //ok
//                case .unsatisfied:
//                    //                      print("path of internet: \(path.status)")
//                    internetConnectionIsOKorNOT = path.status
//                    //ne ok
//                case .requiresConnection:
//                    internetConnectionIsOKorNOT = .unsatisfied
//                    //                      internetConnectionIsOKorNOT = path.status
//                    //internet connect but not work
//                @unknown default:  fatalError()
//                }
//            }
//        }
//    }
    
    @State var internetConnectionIsOKorNOT: NWPath.Status = .satisfied
    
    @State var showPrivacePolicyAlert: Bool = false
    @State var showEULAAlert: Bool = false
    
    @State private var isScannerPresented = false
    @State private var scannedCode: String?
    
    @State private var isRefreshing = false
    
    @State private var availableApps: [TransportApplication] = []
    @State var showAppSelection = false
    
    @StateObject private var activityManager = ActivityManager.shared

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { reader in
                Color.headerLogBackgr
                    .frame(height: reader.safeAreaInsets.top, alignment: .top)
                    .ignoresSafeArea()
            }
            .zIndex(4)
            
            Color.black.ignoresSafeArea()
            
            WebView(data: WebViewData(url: StateContent.url), webViewState: webViewState, urlToShowHeader: $urlToShowHeader, textUrl: $textUrl, isScannerPresented: $isScannerPresented, showAppSelection: $showAppSelection, userAccessToken: $userAccessToken)
                .equatable()
                .blur(radius: networkMonitor.status == .satisfied ? 0 : 5)
                .zIndex(internetConnectionIsOKorNOT == .satisfied ? 2 : 1)
                .onAppear {
                    textUrl = String(describing: StateContent.url)
                }
                .onOpenURL { incomingURL in
//                    print("App was opened via URL: \(incomingURL)")
                    let baseDeepLink = "platforma://open-restore-password/"
                    let baseDeepLinkOpenAnything = "platforma://open-any-url/"
                    
                    if (String(describing: incomingURL).contains("platformapro.com") && !String(describing: incomingURL).contains("platforma://")) {
                        StateContent.url = incomingURL
                    } else if (String(describing: incomingURL).contains("platforma://")) {
                        if (String(describing: incomingURL).contains("open-restore-password")) {
                            if let extractedURL = extractURL(from: String(describing: incomingURL), base: baseDeepLink) {
                                print("extractedURL1: \(extractedURL)")
                                StateContent.url = URL(string: extractedURL)!
                            }
                        } else if (String(describing: incomingURL).contains("open-any-url")) {
                            if let extractedURL = extractURL(from: String(describing: incomingURL), base: baseDeepLinkOpenAnything) {
                                print("extractedURL2: \(extractedURL)")
                                StateContent.url = URL(string: extractedURL)!
                            }
                        } else {
                            StateContent.url = URL(string: "https://platformapro.com/login?webview&lang=en")!
                        }
                    } else {
                        openURL(incomingURL)
                    }
                }
                .confirmationDialog("content_view.select_an_app_tranport", isPresented: $showAppSelection) {
                    ForEach(availableApps) { app in
                        Button {
                            app.open()
                        } label: {
                            HStack(spacing: 0) {
                                Text(app.name)
                                    .font(.custom("Montserrat-Medium", size: 14))
                            }
                        }
                    }
                }
                .onAppear {
                    reqInvoiceAnaliticsDataWidget(userAccessToken: userAccessToken)
                    
                    availableApps = TransportApplication.getAvailableApps()
                }
                .onChange(of: userAccessToken) { newValue in
                    reqInvoiceAnaliticsDataWidget(userAccessToken: userAccessToken)
                }
            
            GeometryReader{ geometry in
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    if (networkMonitor.status != .satisfied) {
                        LazyVStack {
                            ProgressView("No internet connection")
                                .font(.custom("Montserrat-Medium", size: 14))
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .font(.system(size: 16))
                            Button {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    internetConnectionIsOKorNOT = .satisfied
                                }
                            } label: {
                                Text("Reconnect")
                                    .font(.custom("Montserrat-Medium", size: 14))

                            }
                            .padding(.top, 25)
                        }
                    }
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .zIndex(internetConnectionIsOKorNOT != .satisfied ? 4 : 1)
            
            if (urlToShowHeader == true) {
                LazyVStack(spacing: 0) {
                    
                    HStack(alignment: .top) {
                        Group {
                            HStack(alignment: .top, spacing: 0) {
                                Image("logo-mini")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .padding(.top, 1)
                                    .padding(.trailing, 5)
                                
                                Spacer()
                                
                                
                                Button {
                                    //MARK: -- MAIN
                                    showPrivacePolicyAlert = true
                                    
                                } label: {
                                    Text(LocalizedStringKey("content_view.privacy_policy"))
                                        .font(.custom("Montserrat-Medium", size: 16))
                                        .padding([.top, .bottom], 10)
                                        .padding([.leading, .trailing], 20)
                                        .background(Color.headerLogBackgr) // Background color inside the border
                                        .foregroundColor(Color.white)  // Text color
                                        .cornerRadius(100)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                .padding(.trailing, 7)
                                
                                Button {
                                    openURL(URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                    //                                UIApplication.shared.open("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                                } label: {
                                    Text(LocalizedStringKey("content_view.terms_of_use"))
                                        .font(.custom("Montserrat-Medium", size: 16))
                                        .padding([.top, .bottom], 10)
                                        .padding([.leading, .trailing], 20)
                                        .background(Color.headerLogBackgr) // Background color inside the border
                                        .foregroundColor(Color.white)  // Text color
                                        .cornerRadius(100)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                
                                //                            Link("About us", destination: URL(string: "https://miacrm.pl/")!)
                                //                                .font(.system(size: 16))
                                //                                .foregroundColor(.white)
                                //                                .padding(.bottom, 5)
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .frame(width: SGConvenience.deviceWidth, height: 75)
                .background(Color.headerLogBackgr.opacity(0.5))
                .zIndex(3)
            }
            
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            updateWidget()
        }
        .disabled(showPrivacePolicyAlert)
        .overlay(
            ZStack() {
                if (showPrivacePolicyAlert) {
                    let gradient: Gradient = Gradient(colors: [Color.headerLogBackgr, Color.gradientDarkGray])
                    GeometryReader { geo in
                        // Display the custom alert as an overlay
                        AlertPrivacyPolice(show: $showPrivacePolicyAlert, infoTextAlert: "")
                            .frame(width: geo.size.width - 30, height: geo.size.height / 2)
                            .background(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(15)
                            .opacity(showPrivacePolicyAlert ? 1 : 0)
                            .animation(.easeInOut, value: showPrivacePolicyAlert)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .zIndex(2)
                            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                        
                        Color.black.opacity(0.25)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .zIndex(1)
                    }
                }
            }
                .ignoresSafeArea(.all)
        )
        .fullScreenCover(isPresented: $isScannerPresented, content: {QRScaneerSheetPreview(isScannerPresented: $isScannerPresented, scannedCode: $scannedCode).ignoresSafeArea(.all)})
    }
    
    func updateWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @State var errorMessage: String? = ""
    
    func extractURL(from deepLink: String, base: String) -> String? {
        guard deepLink.hasPrefix(base) else {
            //            print("Deep link does not match the base")
            return nil
        }
        let startIndex = deepLink.index(deepLink.startIndex, offsetBy: base.count)
        let extractedURL = String(deepLink[startIndex...])
        
        // Decode the URL if it was percent-encoded
        return extractedURL.removingPercentEncoding
    }
    
    func reqInvoiceAnaliticsDataWidget(userAccessToken: String) {
        withAnimation(.easeInOut(duration: 0.35)) {
            reqWidgetAnaliticData.fetchClosestEvents(userAccessToken: userAccessToken) { result in
                switch result {
                case .success(let data):
                    print("")
                    updateWidget()
                case .failure(let error):
                    updateWidget()
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}


#Preview {
    ContentView()
}


class SGConvenience {
#if os(watchOS)
    //    static var deviceWidth:CGFloat = WKInterfaceDevice.current().screenBounds.size.width
    //    static var deviceHeight:CGFloat = WKInterfaceDevice.current().screenBounds.size.height
    static var deviceWidth: CGFloat {
        return WKInterfaceDevice.current().screenBounds.size.width
    }
    static var deviceHeight: CGFloat {
        return WKInterfaceDevice.current().screenBounds.size.height
    }
#elseif os(iOS)
    static var deviceWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                return window.frame.size.width
            }
        }
        return UIScreen.main.bounds.size.width
    }
    static var deviceHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                return window.frame.size.height
            }
        }
        return UIScreen.main.bounds.size.height
    }
#elseif os(macOS)
    //    static var deviceWidth:CGFloat? = NSScreen.main?.visibleFrame.size.width // You could implement this to force a CGFloat and get the full device screen size width regardless of the window size with .frame.size.width
    //    static var deviceHeight:CGFloat? = NSScreen.main?.visibleFrame.size.height // You could implement this to force a CGFloat and get the full device screen size width regardless of the window size with .frame.size.width
    static var deviceWidth: CGFloat? {
        if let window = NSApplication.shared.windows.first {
            return window.frame.size.width
        }
        return NSScreen.main?.visibleFrame.size.width
    }
    static var deviceHeight: CGFloat? {
        if let window = NSApplication.shared.windows.first {
            return window.frame.size.height
        }
        return NSScreen.main?.visibleFrame.size.height
    }
#endif
}


