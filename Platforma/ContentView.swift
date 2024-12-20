//
//  ContentView.swift
//  Platforma
//
//  Created by Daniil Razbitski on 02/12/2024.
//

import SwiftUI
import WebKit
import Network


struct StateContent {
//        static var url: URL = URL(string: "https://crm.mcgroup.pl/")!
//        static var url: URL = URL(string: "https://hurafaktura.pl")!
    static var url: URL = URL(string: "https://platformapro.com/login?webview")!
    
    static var currentUrl: URL = URL(string: "https://platformapro.com/login?webview")!
    
    
    static var deviceID: String = ""
    static var userAdminQrCodeSendToken: String = ""
    static var purchaseSingl: [String] = []
    static var purchaseSubscription: [String] = []
    static var purchaseAllIDs: [String] = []
}


struct ContentView: View {
    @Environment(\.openURL) var openURL

    private let webView = WKWebView()
    
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
    func networkMonitoring() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "monitoring")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                switch path.status {
                case .satisfied:
                    //                      print("path of internet: \(path.status)")
                    internetConnectionIsOKorNOT = path.status
                    //ok
                case .unsatisfied:
                    //                      print("path of internet: \(path.status)")
                    internetConnectionIsOKorNOT = path.status
                    //ne ok
                case .requiresConnection:
                    internetConnectionIsOKorNOT = .unsatisfied
                    //                      internetConnectionIsOKorNOT = path.status
                    //internet connect but not work
                @unknown default:  fatalError()
                }
            }
        }
    }
    
    @State var internetConnectionIsOKorNOT: NWPath.Status = .satisfied
    
    @State var showPrivacePolicyAlert: Bool = false
    @State var showEULAAlert: Bool = false
    
    @State private var isScannerPresented = false
    @State private var scannedCode: String?

    var body: some View {
        ZStack(alignment: .top) {
//            Color.red // This changes the background of the entire screen, including the safe area.
//                .edgesIgnoringSafeArea(.top) // Ignore the top safe area
            GeometryReader { reader in
                Color.headerLogBackgr
                    .frame(height: reader.safeAreaInsets.top, alignment: .top)
                    .ignoresSafeArea()
            }
            .zIndex(4)

            Color.black.ignoresSafeArea()
            
//            Text("textUrl: \(textUrl)")
//                .foregroundStyle(Color.clear)
//                .font(.system(size: 20))
//                .zIndex(4)
            
//            WebView(data: WebViewData(url: stateContent.url))
            WebView(data: WebViewData(url: StateContent.url), urlToShowHeader: $urlToShowHeader, textUrl: $textUrl, isScannerPresented: $isScannerPresented)
                .equatable()
                .onChange(of: webView.estimatedProgress, perform: { value in
                    print(value)
                })
                .zIndex(internetConnectionIsOKorNOT == .satisfied ? 2 : 1)
                .blur(radius: internetConnectionIsOKorNOT == .satisfied ? 0 : 5)
                .onAppear {
                    textUrl = String(describing: StateContent.url)
//                    print("onAppear currentUrl \(StateContent.currentUrl) ")
//                    print("onAppear stateContent.url \(StateContent.url) ")
                }
                .onOpenURL { incomingURL in
                    print("App was opened via URL: \(incomingURL)")
//                    let deepLink = "platforma://open-restore-password/https%3A%2F%2Fplatformapro.com%2Fforgot-password"
                    let baseDeepLink = "platforma://open-restore-password/"
                    
//                    https://platformapro.com/forgot-password/ilNkhjFmM2nzJcYvfUGXzMHiZDWNdvd7QjN8bMUMbP2IIa3Qy1
                    if (String(describing: incomingURL).contains("https://platformapro.com/")) {
                        
                        StateContent.url = incomingURL
                    } else {
                        if let extractedURL = extractURL(from: String(describing: incomingURL), base: baseDeepLink) {
//                            print("Extracted URL: \(extractedURL)")
                            StateContent.url = URL(string: extractedURL)!
                            //                        StateContent.currentUrl = URL(string: extractedURL)!
                            // Result: https://platformapro.com/forgot-password
                        }
                    }
                }
            
            
            GeometryReader{ geometry in
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    if (internetConnectionIsOKorNOT != .satisfied) {
                        VStack {
                            ProgressView("No internet connection")
                                .font(.custom("Montserrat-Medium", size: 14))
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .font(.system(size: 16))
                            Button("Reconnect") {
                                withAnimation {
                                    internetConnectionIsOKorNOT = .satisfied
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        networkMonitoring()
                                    }
                                }
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
//            if (stateContent.currentUrl == URL(string: "http://platformapro.com/login?webview") || stateContent.currentUrl == URL(string: "http://platformapro.com/login")) {
//            if (stateContent.currentUrl == URL(string: "http://platformapro.com/login?webview") || stateContent.currentUrl == URL(string: "http://platformapro.com/login")) {
                VStack(spacing: 0) {

                    HStack(alignment: .top) {
                        //Spacer()
                        Group {
                            HStack(alignment: .top, spacing: 0) {
                                Image("logo-mini")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .padding(.top, 1)
                                    .padding(.trailing, 5)
                                
                                Spacer()
                                
//                                Button("Scan QR Code") {
//                                    isScannerPresented = true
//                                }
//                                .padding()
//                                .sheet(isPresented: $isScannerPresented) {
//                                    QRCodeScannerView(scannedCode: $scannedCode)
//                                }

                                Button {
                                    ///openURL(URL(string: "https://platformapro.com/privacy-policy")!)
                                    ///openURL(URL(string: "https://miacrm.pl/privacy-policy/")!)
                                    
                                    showPrivacePolicyAlert = true
//                                    isScannerPresented = true
                                } label: {
                                    Text("Privacy Policy")
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
                                    Text("Terms of use")
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
                        //                    Spacer()
                    }
                    
                }
                .padding(.horizontal, 15)
                .frame(minWidth: SGConvenience.deviceWidth, minHeight: 75, maxHeight: 75)
//                .frame(minWidth: UIScreen.main.bounds.width, minHeight: 75, maxHeight: 75)
//                .frame(minWidth: UIScreen.main.bounds.width, minHeight: urlToShowHeader ? 75 : 0, maxHeight: urlToShowHeader ? 75 : 0)
                .background(Color.headerLogBackgr.opacity(0.5))
                //            .background(Color(red: 100 / 255, green: 108 / 255, blue: 154 / 255).opacity(0.8))
                //            .cornerRadius(radius: 15.0, corners: [.topLeft, .bottomLeft])
                //            .frame(minWidth: UIScreen.main.bounds.width, minHeight: 75, maxHeight: 75, alignment: .top)
                //            .frame(width: UIScreen.main.bounds.width, height: 50, alignment: .top)
//                .transition(.move(edge: .trailing))
//                .offset(y: CGFloat(topActionMenuOffset))
                //            .gesture(
                //                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                //                    .onEnded { value in
                //                        if (rightActionMenuOffset < 100) {
                //                            //opening
                //                            if value.translation.width > 0 {
                //                                // left
                //                                changeOffset()
                //                            }
                //                        } else {
                //                            if value.translation.width < 0 {
                //                                // right
                //                                changeOffset()
                //                            }
                //                            //closing
                //                        }
                //                    }
                //            )
                .zIndex(3)
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            networkMonitoring()
        }
        .disabled(showPrivacePolicyAlert)
        .overlay(
            ZStack() {
                if (showPrivacePolicyAlert) {
                    let gradient: Gradient = Gradient(colors: [Color.headerLogBackgr, Color.gradientDarkGray])
                    GeometryReader { geo in
                        // Display the custom alert as an overlay
                        AlertPrivacyPolice(show: $showPrivacePolicyAlert, infoTextAlert: "")
                            .frame(width: geo.size.width - 30, height: geo.size.width / 2)
//                            .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width / 2)
                        //                        .frame(width: SGConvenience.deviceWidth - 30, height: SGConvenience.deviceHeight / 2)
                        //                        .frame(width: UIScreen.main.bounds.width / 1.1, height: UIScreen.main.bounds.height / 2)
                            .background(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        //                        .background(Color.headerLogBackgr.opacity(0.7))
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
//                            .frame(width: .infinity, height: .infinity)
                            .zIndex(1)
                    }
                }
                //                if (!networkMonitor.isConnected) {
                //                    NoInternetView()
                //                }
            }
                .ignoresSafeArea(.all)
        )
        .fullScreenCover(isPresented: $isScannerPresented, content: {QRScaneerSheetPreview(isScannerPresented: $isScannerPresented, scannedCode: $scannedCode).ignoresSafeArea(.all)})
    }
    
    func extractURL(from deepLink: String, base: String) -> String? {
        guard deepLink.hasPrefix(base) else {
            print("Deep link does not match the base")
            return nil
        }
        let startIndex = deepLink.index(deepLink.startIndex, offsetBy: base.count)
        let extractedURL = String(deepLink[startIndex...])
        
        // Decode the URL if it was percent-encoded
        return extractedURL.removingPercentEncoding
    }
}


#Preview {
    ContentView()
}


class SGConvenience {
    #if os(watchOS)
    static var deviceWidth:CGFloat = WKInterfaceDevice.current().screenBounds.size.width
    static var deviceHeight:CGFloat = WKInterfaceDevice.current().screenBounds.size.height
    #elseif os(iOS)
    static var deviceWidth:CGFloat = UIScreen.main.bounds.size.width
    static var deviceHeight:CGFloat = UIScreen.main.bounds.size.height
    #elseif os(macOS)
    static var deviceWidth:CGFloat? = NSScreen.main?.visibleFrame.size.width // You could implement this to force a CGFloat and get the full device screen size width regardless of the window size with .frame.size.width
    static var deviceHeight:CGFloat? = NSScreen.main?.visibleFrame.size.height // You could implement this to force a CGFloat and get the full device screen size width regardless of the window size with .frame.size.width
    #endif
}
