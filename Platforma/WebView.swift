//
//  WebView.swift
//  MIACRM
//
//  Created by Danik on 8.01.23.
//
import PDFKit
import UIKit
import Foundation
import SwiftUI
@preconcurrency import WebKit
import PushKit
import UserNotifications
import UniformTypeIdentifiers

//URL data store for webview
class WebViewData: NSObject, ObservableObject {
    @Published var url: URL?
    
    init(url: URL) {
        self.url = url
    }
}

//Main func of webview
struct WebView: UIViewRepresentable, Equatable {
    static func == (lhs: WebView, rhs: WebView) -> Bool {
        lhs.data.url == rhs.data.url
    }
    
    
    @ObservedObject var data: WebViewData
    @ObservedObject var webViewState: WebViewState
    //    @ObservedObject var linkData: URLLinkData
    @Binding var urlToShowHeader: Bool
    @Binding var textUrl: String
    @Binding var isScannerPresented: Bool
    @Binding var showAppSelection: Bool
    @Binding var userAccessToken: String
    //    @Binding var isRefreshing: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        // Create a WKWebViewConfiguration
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true // Example: Set configuration appropriately
        //webConfiguration.allowsPictureInPictureMediaPlayback = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webConfiguration.dataDetectorTypes = [.link]
        
        // Create the WKWebView with the configuration
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        // Assign delegates
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        // Set the refresh control in the web view's scroll view
        webView.scrollView.refreshControl = refreshControl
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

                // Store the webView in the coordinator
        context.coordinator.webView = webView
        loadURLIfNeeded(webView: webView)
                
        return webView
    }
    
    func updateUIView(_ UIView: WKWebView, context: Context) {
        loadURLIfNeeded(webView: UIView)
//        if let url = data.url {
//            let request = URLRequest(url: url)
//
//            UIView.load(request)
//            UIView.allowsBackForwardNavigationGestures = true;
//        }
    }
    
    // Можно убрать loadURLIfNeeded и вернуть загрузку в updateUIView
    private func loadURLIfNeeded(webView: WKWebView) {
            if let url = data.url, webView.url != url {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    
    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(
            data: data,
            webViewState: webViewState,
            urlToShowHeader: $urlToShowHeader,
            textUrl: $textUrl,
            isScannerPresented: $isScannerPresented,
            showAppSelection: $showAppSelection,
            userAccessToken: $userAccessToken
        )
    }
}

class WebViewCoordinator: NSObject, ObservableObject, WKUIDelegate, WKNavigationDelegate, WKDownloadDelegate, UIDocumentInteractionControllerDelegate {
    @ObservedObject var data: WebViewData
    @Published var webViewState: WebViewState
    @Binding var urlToShowHeader: Bool
    @Binding var textUrl: String
    @Binding var isScannerPresented: Bool
    @Binding var showAppSelection: Bool
    @Binding var userAccessToken: String
    
    @StateObject var documentController = DocumentController()
        
    var webView: WKWebView = WKWebView()
    
    var fileForOpen: URL? = URL(string: "")
    
    init(data: WebViewData, webViewState: WebViewState, urlToShowHeader: Binding<Bool>, textUrl: Binding<String>, isScannerPresented: Binding<Bool>, showAppSelection: Binding<Bool>, userAccessToken: Binding<String>) {
        self.data = data
        self.webViewState = webViewState
        self._urlToShowHeader = urlToShowHeader
        self._textUrl = textUrl
        self._isScannerPresented = isScannerPresented
        self._showAppSelection = showAppSelection
        self._userAccessToken = userAccessToken
        
        super.init()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        guard !webView.isLoading else { sender.endRefreshing(); return }
            sender.beginRefreshing()
            webView.reload()    }
        
    //    this function uses when neew to open new page, new tab or browser
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let navURL: String = String(describing: navigationAction.request.url!)
        
        if (!navURL.contains("platformapro.com")) {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                return nil
            }
        } else if (navURL.contains("privacy-policy") || navURL.contains("stdeula")) {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                return nil
            }
        } else if (navURL.contains("web-crm")) {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                return nil
            }
        } else if (navURL.contains("apple_link")) {
            //            PurchaseCustomProduct(urlData: navigationAction.request.url, webView: webView)
            return nil
        } else if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
        } else {
            print("navURL target frame nill: \(navURL)")
        }
        return nil
    }
    
    //    Remember user, set title
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        if let refreshControl = webView.scrollView.refreshControl {
            refreshControl.endRefreshing()
        }
        
        let compaire = URL(string: "https://platformapro.com/login?webview&lang=en")
        let compaire1 = URL(string: "https://platformapro.com/login")
        
        
        if let url = webView.url {
            textUrl = url.absoluteString
            StateContent.url = url
        }
//        textUrl = String(describing: webView.url)
//        StateContent.url = webView.url!
        
        
        //      MARK: -- after navigation anyone navigation change url to standart for opening new normal window on new tab
        //        StateContent.url = URL(string: "https://platformapro.com/login?webview")!
        
        //MARK: -- Use JavaScript интеграци JS явы скрипта
//        print(String(describing: webView.url!).contains("forgot-password"))
        //        print("webView.url: \(webView.url) || compaire: \(compaire)")
        if (webView.url! != URL(string: "https://platformapro.com/login?webview&lang=en") && webView.url! != URL(string: "https://platformapro.com/login") && webView.url! != URL(string: "https://platformapro.com/register")) {
            if (String(describing: webView.url!).contains("forgot-password")) {
                urlToShowHeader = true
            } else {
                urlToShowHeader = false
            }
        } else {
            urlToShowHeader = true
        }
                
        if(webView.url == compaire || webView.url == compaire1){
            let loadDeviceID = """
            const deviceId = document.getElementById('deviceId');
            const loginType = document.getElementById('loginType');
            if(deviceId && loginType){
                deviceId.value = "\(StateContent.deviceID)";
                loginType.value = "\(UIDevice.current.localizedModel)";
            }
            """
            
            //            in iPad only pass iPad value to understand what this device
            webView.evaluateJavaScript(loadDeviceID, in: nil, in: .defaultClient) { result in
                switch result {
                case .success(_):
                    ()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        if let url = webView.url {
            //            Если писать без "for: url.host", то будут получены все кукки, и те что не относяться к сайту
            webView.getCookies(for: url.host) { data in
//                print("ZZZ data: \(data)")
                for (key, value) in data {
//                    print("ZZZ ID data: \(key)")
                    if(key == "access") {
                        let myStringDict = value as? [String:AnyObject]
                        for (key1, value1) in myStringDict! {
                            if (key1 == "Value") {
//                                print("ZZZ USE ACCESS TOEKN: \(value1)")

                                self.userAccessToken = value1 as! String
                                StateContent.userAdminQrCodeSendToken = value1 as! String
                            }
                        }
                    }
                }
            }
        }
    }
    
    //    File Download function
    //    this function use when link/button/action deffined like download action
    /// Если есть эта функция, то если нужно предотвратить открытие какой-либо страницы, то использовать тут ниже ГДЕ MARK
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let fileExtension: [String] = ["HEIC", "doc", "docx", "xml"]
//        print("Test print webview 2 url: \(webView.url ?? "")")
        
        
        let checkURL: String = String(describing: navigationAction.request.url!)
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download, preferences)
        } else if (fileExtension.contains( navigationAction.request.url!.pathExtension )) {
            decisionHandler(.download, preferences)
            return
        } else if (checkURL.contains("view-doc")) {
            decisionHandler(.download, preferences)
            return
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //        StateContent.currentUrl = webView.url!
        print("Test print webview 1 url: \(webView.url!.absoluteString)")
        
//        if (webView.url!.absoluteString.contains("courses")) {
//            https://platformapro.com/courses
//        }
        
        if (webView.url!.absoluteString.contains("open-transport-app")) {
            showAppSelection = true
            print("webView.url!.absoluteString: \(webView.url!.absoluteString)")
//            https://platformapro.com/open-transport-app?city=Warszawa&town=Vogla%2028
//            uber://?action=setPickup&dropoff[formatted_address]=<address>
            if let url = URL(string: webView.url!.absoluteString),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                // Extract query items
                if let queryItems = components.queryItems {
                    let city = queryItems.first(where: { $0.name == "city" })?.value
                    let town = queryItems.first(where: { $0.name == "town" })?.value

                    StateContent.addressCityOpenApp = city ?? ""
                    StateContent.addressTownOpenApp = town ?? ""
                    StateContent.addressOpenApp = "\(town ?? "") \(city ?? "")"
                }
            }
            decisionHandler(.cancel)
            return
        }
        
        if (webView.url!.absoluteString.contains("start-scan-qr")) {
            parseSearchAndCheckId(from: webView.url!.absoluteString)
            isScannerPresented = true
            decisionHandler(.cancel)
            return
        }
        
        if navigationResponse.canShowMIMEType {
            // MARK: -- применяется это если надо предотвратить открытие страницы какой-либо по умолчанию оставить в canShowMIMEType только allow и download
            if let urlStr = navigationResponse.response.url?.absoluteString {
                if (urlStr.contains("item=live_consult") || urlStr.contains("item=my_accountant")) {
                    //                    PurchaseCustomProduct(urlData: webView.url, webView: webView)
                    print("Предотвратить открытие какого-лбио файла")
                    decisionHandler(.cancel)
                    return
                } else {
                    decisionHandler(.allow)
                }
            }
            
        } else {
            decisionHandler(.download)
        }
    }
    
    func parseSearchAndCheckId(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let queryItems = components.queryItems
        
        let startId = queryItems?.first(where: { $0.name == "start_id" })?.value
        let eventType = queryItems?.first(where: { $0.name == "type" })?.value
        
        if let startId = startId {
            StateContent.scanerOpenEvent = startId
            print("startId: \(startId)")
//            return "startId: \(startId)"
        }
        
        if let eventType = eventType {
            StateContent.scanerEvnetType = eventType
            print("eventType: \(eventType)")
//            return "eventType: \(eventType)"
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void)  {
        clearAllFiles()
        //        let documentsUrlPooType:URL =  (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first as URL?)!
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        
        let fileExtension: [String] = ["HEIC", "doc", "dot", "dotm", "dotx", "htm", "html", "odt", "docx", "docm", "xml", "xls", "xlsx", "gif", "bmp", "emf", "mp4", "odp", "pot", "potm", "rtf", "tif", "wmf", "wmv", "xps", "dif", "emv", "csv", "mht", "mhtml", "pptm", "pptx", "ppsm", "ppsx", "pps", "ppa", "PSD", "tiff", "TIFF", "EPS", "eps", "pdf"]
        
        let fileName = suggestedFilename.components(separatedBy: ".")[0]
        let fileTypeSecond = suggestedFilename.components(separatedBy: ".")[1]
        let fileType = response.mimeType?.components(separatedBy: "/")[1]
        
        let fileDownload: URL! = documentsUrl.appendingPathComponent("\(fileName).\(fileType!)")
        let fileDownloadNoType: URL! = documentsUrl.appendingPathComponent("\(fileName).\(fileTypeSecond)")
        
        if (fileType! != "octet-stream" || fileExtension.contains( fileTypeSecond ) ) {
            
            print("first part")
            if (fileExtension.contains( fileTypeSecond )) {
                fileForOpen = fileDownloadNoType
                completionHandler(fileDownloadNoType)
            } else {
                fileForOpen = fileDownload
                completionHandler(fileDownload)
            }
            
        } else {
            print("Seconde print")
            fileForOpen = fileDownloadNoType
            
            completionHandler(fileDownloadNoType)
        }
    }
    
    //    Here i can write all what need to use after end of download process
    func downloadDidFinish(_ download: WKDownload) {
        documentController.presentDocument(url: fileForOpen!)
    }
        
    func clearAllFiles() {
        let fileManager = FileManager.default
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
            
            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                
                try fileManager.removeItem(at: filePath)
            }
        } catch let error {
            print(error)
        }
    }
}

// global veriable to set
extension WKWebView {
    //extension WKWebView {
    @objc func LoadBack(_ sender: Any) {
        if (StateContent.currentUrl !=  URL(string: "https://platformapro.com/login?webview&lang=en")) {
            if self.canGoBack {
                self.goBack()
            }
        }
    }
    
    @objc func LoadForward(_ sender: Any) {
        if self.canGoForward {
            self.goForward()
        }
    }
    
    @objc func Reload(_ sender: Any) {
        self.reload()
        
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        
        // Reload the web view
        if let webView = sender.superview as? WKWebView {
            webView.reload()
        }
    }
    
    @objc func goHome(_ sender: Any) {
        self.load( URLRequest(url: URL(string:  "https://platformapro.com/login?webview&lang=en")!))
    }
    
    //    @objc func goWindows(_ sender: Any) {
    //        self.load( URLRequest(url: URL(string:  "https://webstationmcg.quickconnect.to/sharing/UzcjzsShS")!))
    //    }
    
    //    @objc func goCloud(_ sender: Any) {
    //        self.load( URLRequest(url: URL(string:  "https://cloudmcg.quickconnect.to/CloudMCG")!))
    //    }
    
    //    @objc func ReloadProductsIAP(_ sender: Any) {
    //        Task {
    //            do {
    //                try await PurchaseManager().loadProducts()
    //            } catch {
    //                print(error)
    //            }
    //        }
    //    }
}

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var isMP3: Bool { typeIdentifier == "public.mp3" }
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}

class DocumentController: NSObject, ObservableObject, UIDocumentInteractionControllerDelegate {
    let controller = UIDocumentInteractionController()
    
    func presentDocument(url: URL) {
        controller.delegate = self
        controller.url = url
        controller.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        return (UIApplication.shared.currentUIWindow()?.rootViewController)!
    }
}

public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({$0 as? UIWindowScene})
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        
        return window
    }
}

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension WKWebView {
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
    
    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}
