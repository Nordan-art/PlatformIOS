//
//  ClosestAndAllEventWidgetRequest.swift
//  Platforma
//
//  Created by Daniil Razbitski on 27/01/2025.
//

import SwiftUI
import Foundation

struct AllWdigetsDataModel: Codable {
    var status: Bool
    var error: String?
    var dataAllEvents: [EventDataModel]
    var dataUserEvent: [EventDataModel]
}

struct EventDataModel: Codable {
    var id: Int
    var type: Int
    var title: String
    var city: String
    var address: String
    var start: String
    var imageUrl: String
    var link: String
}

class ReqWidgetAnaliticData: ObservableObject {
    enum NetworkError: Error {
        case invalidURL
        case missingToken
        case invalidResponse
        case invalidSendedData
        case unauthorized
    }
    
    func saveForWidget(someData: AllWdigetsDataModel) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.MCGroup.Platforma")

        let checkDataEmpty = sharedDefaults?.data(forKey: "widgetEvents")
        
        if (checkDataEmpty != nil) {
            sharedDefaults?.removeObject(forKey: "widgetEvents")
            
            if let encoded = try? JSONEncoder().encode(someData) {
                sharedDefaults?.set(encoded, forKey: "widgetEvents")
            }
        } else {
            if let encoded = try? JSONEncoder().encode(someData) {
                sharedDefaults?.set(encoded, forKey: "widgetEvents")
            }
        }
    }

    static let shared = ReqWidgetAnaliticData()

//    @Published var fullReqInvoicesArray: ModelFileReq  = ModelFileReq(status: false, user_id: 0, years: [""], invoices: [], user: UserAuthArrayData(id: 0))
    @Published var analiticsWidgetRequestDataModel: AllWdigetsDataModel = AllWdigetsDataModel(status: false, dataAllEvents: [], dataUserEvent: [])
    
    func fetchClosestEvents(userAccessToken: String, completion: @escaping(Result<(response: HTTPURLResponse, data: Data, stringKey: String), Error>) -> Void) {
        guard let url = URL(string: "https://platformapro.com/api/widget") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Replace "YOUR_BEARER_TOKEN" with your actual Bearer token
//        guard let bearerToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
//            completion(.failure(NetworkError.missingToken))
//            return
//        }
        
//        @State var whatMonthToShow: Int = Calendar.current.dateComponents([.month, .year], from: Date()).month ?? 0
//        @State var whatYearToShow: Int = Calendar.current.dateComponents([.month, .year], from: Date()).year ?? 0

        let requestData: [String: String] = [
            "userToken": userAccessToken
//            "year": "2024",
//            "month": "08"
//            "year": "\(Calendar.current.dateComponents([.month, .year], from: Date()).year ?? 0)",
//            "month": "\(Calendar.current.dateComponents([.month, .year], from: Date()).month ?? 0)"
        ]

        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("\(String(describing: requestData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, let responseData = data else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
//                    checkUserSessionTokenState.checkUserForLogout(statusCode: httpResponse.statusCode)
                    completion(.failure(NetworkError.unauthorized))
//                    print("ERROR httpResponse.statusCode: \(httpResponse.statusCode)")
                } else if (httpResponse.statusCode == 500) {
//                    checkUserSessionTokenState.checkUserForLogout(statusCode: httpResponse.statusCode)
                    completion(.failure(NetworkError.invalidSendedData))
//                    print("ERROR httpResponse.statusCode: \(httpResponse.statusCode)")
                } else {
//                    print("SUCCESS httpResponse.statusCode: \(httpResponse.statusCode)")
                    var boolReqStatus: Bool = false
                    do {
                        if let jsonString = String(data: responseData, encoding: .utf8) {
//                            print("JSON Response request closes event widget: \(jsonString)")
                        }
                        
                        let decodedInvoice = try JSONDecoder().decode(AllWdigetsDataModel.self, from: responseData)

                        DispatchQueue.main.async {
                            self.saveForWidget(someData: decodedInvoice)
                            self.analiticsWidgetRequestDataModel = decodedInvoice
                        }
                        
                        
                        boolReqStatus = decodedInvoice.status
                                                
                    } catch {
                        print(error)
                        print(error.localizedDescription)
                    }
                    
                    if boolReqStatus != false {
                        completion(.success((response: httpResponse, data: responseData, stringKey: "true")))
                    } else {
                        completion(.success((response: httpResponse, data: responseData, stringKey: "false")))
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
