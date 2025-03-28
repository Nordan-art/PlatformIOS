//
//  StateContentData.swift
//  Platforma
//
//  Created by Daniil Razbitski on 15/01/2025.
//

import Foundation

struct StateContent {
    static var url: URL                             = URL(string: "https://platformapro.com/login?webview&lang=en")!
    
    static var currentUrl: URL                      = URL(string: "https://platformapro.com/login?webview&lang=en")!
    
    static var isLoading: Bool                      = false
    
    static var addressOpenApp: String               = ""
    static var addressCityOpenApp: String           = ""
    static var addressTownOpenApp: String           = ""
    
    static var scanerOpenEvent: String              = ""
    static var scanerEvnetType: String              = ""
    
    static var deviceID: String                     = ""
    static var userAdminQrCodeSendToken: String     = ""
    static var purchaseSingl: [String]              = []
    static var purchaseSubscription: [String]       = []
    static var purchaseAllIDs: [String]             = []
}

class WebViewState : ObservableObject {
    @Published var url:URL?
    @Published var userSetUrl:URL?
    @Published var showLoader: Bool                 = false
    @Published var estimatedProgress:Double?
}
