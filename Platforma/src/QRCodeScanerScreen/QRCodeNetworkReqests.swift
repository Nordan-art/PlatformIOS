//
//  QRCodeNetworkReqests.swift
//  Platforma
//
//  Created by Daniil Razbitski on 19/12/2024.
//

import Foundation

struct UserConfirmationDataModel: Decodable {
    var status: Bool
    var error: String?
//    var data: String?
}

struct UserFromQRCodeDataModel: Decodable {
    var status: Bool
    var error: String?
    var result: QRCodeResulData?
    
    struct QRCodeResulData: Decodable {
        var title: String
        var datetime: String
        var userName: String
        var photo: String
        var is_actual: Bool
    }
}

class QRCodeNetworkReqests: ObservableObject{
    enum NetworkError: Error {
        case invalidURL
        case missingToken
        case invalidResponse
        case invalidSendedData
        case unauthorized
    }
    
    @Published var userFromQRCodeDataModel: UserFromQRCodeDataModel = UserFromQRCodeDataModel(status: true)
    
    func sendQrCodeData(search_id: String, check_id: String, completion: @escaping(Result<(response: HTTPURLResponse, data: Data, stringKey: String), Error>) -> Void) {
        guard let url = URL(string: "https://platformapro.com/qr-code-app-scan?search_id=\(search_id)&check_id=\(check_id)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        do {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(StateContent.userAdminQrCodeSendToken)", forHTTPHeaderField: "access")
            
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
                            print("JSON Response req with QR code: \(jsonString)")
                        }
                        
                        let decodedInvoice = try JSONDecoder().decode(UserFromQRCodeDataModel.self, from: responseData)

                        print("decodedInvoice: \(decodedInvoice)")
                        
                                                                        
                        DispatchQueue.main.async {
                            self.userFromQRCodeDataModel = decodedInvoice
                            
                            boolReqStatus = decodedInvoice.status
//                            checkUserSessionTokenState.saveUserDataInEachResp(model: decodedInvoice.user)
                        }
                    } catch {
                        print(error)
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
    
    
    @Published var userConfirmationDataModel: UserConfirmationDataModel = UserConfirmationDataModel(status: true)

    func sendConfirmUserValidQR(search_id: String, check_id: String, completion: @escaping(Result<(response: HTTPURLResponse, data: Data, stringKey: String), Error>) -> Void) {
        guard let url = URL(string: "https://platformapro.com/api/confirm-user-event-by-qr") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Replace "YOUR_BEARER_TOKEN" with your actual Bearer token
//        guard let bearerToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
//            completion(.failure(NetworkError.missingToken))
//            return
//        }

        let requestData: [String: String] = [
            "event_id": search_id,
            "user_event": check_id
        ]

        print("requestData: \(requestData)")
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("\(String(describing: requestData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
            request.setValue("\(StateContent.userAdminQrCodeSendToken)", forHTTPHeaderField: "access")
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
                            print("JSON Response request confirm: \(jsonString)")
                        }
                        
                        let decodedInvoice = try JSONDecoder().decode(UserConfirmationDataModel.self, from: responseData)
                        
                        print("decodedInvoice: \(decodedInvoice)")
                                                                        
                        DispatchQueue.main.async {
                            self.userConfirmationDataModel = decodedInvoice
                            
                            boolReqStatus = decodedInvoice.status
//                            checkUserSessionTokenState.saveUserDataInEachResp(model: decodedInvoice.user)
                        }
                    } catch {
                        print(error)
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
