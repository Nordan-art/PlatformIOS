//
//  QRScaneerSheetPreview.swift
//  Platforma
//
//  Created by Daniil Razbitski on 19/12/2024.
//

import SwiftUI

struct QRScaneerSheetPreview: View {
    @Environment(\.dismiss) var dismiss
    
    //    @Binding private var isScannerPresented = false
    @Binding var isScannerPresented: Bool
    @Binding var scannedCode: String?
    @State var scannedCodeError: String = ""
    @State var isScanning: Bool = true
    
    @State var scanerStatusError: Bool = false
    
    @State var scannerResultStatus: Bool = false
    
    @State var searchId: String = ""
    @State var checkId: String = ""
    @State var userType: String = ""
    @State var type: String = ""
    
    
    @State var showRequestError: Bool = false
    @State var showRequestErrorText: String = ""
    
    @State var showQrCodeResponseAlert: Bool = false
    @State var showQrCodeResponseAlertError: String = ""

//    @ObservedObject var qrCodeNetworkReqests: QRCodeNetworkReqests = QRCodeNetworkReqests()
//    UserFromQRCodeDataModel(status: true)
    @StateObject var qrCodeNetworkReqests: QRCodeNetworkReqests = QRCodeNetworkReqests()
    
    func sendDataFirstQR(search_id: String, check_id: String, userType: String) {
        withAnimation(.easeInOut(duration: 0.35)) {
            qrCodeNetworkReqests.sendQrCodeData(search_id: search_id, check_id: check_id, userType: userType) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        if (qrCodeNetworkReqests.userConfirmationDataModel.status == true) {
                            showQrCodeResponseAlert = true
                        } else {
                            showRequestErrorText = qrCodeNetworkReqests.userConfirmationDataModel.error ?? "Unknown Error while sending QR Code data"
                            showRequestError = true
                        }
                        isSendedQRData = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        showRequestErrorText = qrCodeNetworkReqests.userConfirmationDataModel.error ?? "Error: \(error.localizedDescription) | \(error)"
                        showRequestError = true
                        isSendedQRData = false
                    }
                }
            }
        }
    }
    
    func sendConfirmationForUser(search_id: String, check_id: String) {
        withAnimation(.easeInOut(duration: 0.35)) {
            qrCodeNetworkReqests.sendConfirmUserValidQR(search_id: search_id, check_id: check_id) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        if (qrCodeNetworkReqests.userFromQRCodeDataModel.status == true) {
                            isScanning = true
                            scanerStatusError = false
                        } else {
                            showRequestErrorText = qrCodeNetworkReqests.userConfirmationDataModel.error ?? "Unknown Error while confirming QR"
                            showRequestError = true
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        showRequestErrorText = qrCodeNetworkReqests.userConfirmationDataModel.error ?? "Error: \(error.localizedDescription) | \(error) "
                        showRequestError = true
                    }
                }
            }
        }
    }

    @State var isSendedQRData: Bool = false
    var body: some View {
        GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        
                        QRScannerView(completion: { result in
                            searchId = ""
                            checkId = ""
                            type = ""
                            switch result {
                            case .success(let code):
//                                if (code.contains("search_id") && code.contains("check_id")) {
                                    scannedCode = code
                                    scannerResultStatus = true

                                    let result = parseSearchAndCheckId(from: code)
                                    print("result parse: \(result) from code: \(code)")
                                    
                                    if (isSendedQRData != true) {
                                        sendDataFirstQR(search_id: searchId, check_id: checkId, userType: userType)
                                        isSendedQRData = true
                                    }

                                    isScanning = false
//                                } else {
//                                    print("Unknown code: \(code)")
//                                    showQrCodeResponseAlert = true
//                                    isScanning = false
//                                }
                            case .failure(let error):
                                qrCodeNetworkReqests.userFromQRCodeDataModel.error = error.localizedDescription
                                scannedCodeError = "Error: \(error.localizedDescription)"
                                scanerStatusError = true
                                showQrCodeResponseAlert = true
                                isScanning = false
                            }
                        }, isScanning: $isScanning)
//                        .overlay(
//                            ScanOverlayView()
//                                .ignoresSafeArea(.all)
//                        )
                    }
                    .zIndex(1)
                    
                    VStack(spacing: 0) {
                        if (scanerStatusError) {
                            Text(scannedCodeError)
                                .font(.custom("Montserrat-Medium", size: 18))
                                .padding([.top, .bottom], 20)
                                .foregroundColor(Color.white)  // Text color
                            
                            Button {
                                isScanning = true
                                scanerStatusError = false
                            } label: {
                                Text("qrscaner.repeat_try_to_scan")
                                    .font(.custom("Montserrat-Medium", size: 16))
                                    .padding([.top, .bottom], 10)
                                    .frame(width: geometry.size.width / 2)
                                    .background(Color.headerLogBackgr) // Background color inside the border
                                    .foregroundColor(Color.white)  // Text color
                                    .cornerRadius(100)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding(.bottom, 10)
                        }
                        
                        Button {
                            isScannerPresented = false
                            dismiss()
                        } label: {
                            Text("qrscaner.cancel_scan")
                                .font(.custom("Montserrat-Medium", size: 16))
                                .padding([.top, .bottom], 10)
                                .frame(width: geometry.size.width / 2)
                                .background(Color.headerLogBackgr) // Background color inside the border
                                .foregroundColor(Color.white)  // Text color
                                .cornerRadius(100)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 120)
                    .zIndex(2)
                                        
                }
        }
        .disabled(showRequestError)
        .disabled(showQrCodeResponseAlert)
        .overlay(
            ZStack() {
                //    UserFromQRCodeDataModel(status: true)
//                    @StateObject var qrCodeNetworkReqests: QRCodeNetworkReqests = QRCodeNetworkReqests()
                if (showQrCodeResponseAlert) {
                    let gradient: Gradient = Gradient(colors: [Color.headerLogBackgr, Color.gradientDarkGray])
                    GeometryReader { geo in
                        // Display the custom alert as an overlay
                        QRCodeAlertWindwo(show: $showQrCodeResponseAlert, infoTextAlert: "", qrCodeNetworkReqests: qrCodeNetworkReqests, cnacelaction: {
                            showQrCodeResponseAlert = false
                            isScanning = true
//                            dismiss()
//                            qrCodeNetworkReqests.userFromQRCodeDataModel = UserFromQRCodeDataModel(status: true)
                        }, mainAction: {
                            if (qrCodeNetworkReqests.userFromQRCodeDataModel.status == true && qrCodeNetworkReqests.userFromQRCodeDataModel.result?.is_actual == true) {
                                sendConfirmationForUser(search_id: searchId, check_id: checkId)
                                isScanning = true
                                scanerStatusError = false
                            } else {
//                                isScannerPresented = false
                                showQrCodeResponseAlert = false
                                isScanning = true
//                                dismiss()
                            }
//                            qrCodeNetworkReqests.userFromQRCodeDataModel = UserFromQRCodeDataModel(status: true)
                        })
                            .frame(width: geo.size.width - 30, height: nil)
//                            .frame(width: geo.size.width - 30, height: geo.size.height / 2)
                            .background(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(15)
                        //                        .background(Color.headerLogBackgr.opacity(0.7))
                            .opacity(showQrCodeResponseAlert ? 1 : 0)
                            .animation(.easeInOut, value: showQrCodeResponseAlert)
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

                if (showRequestError) {
                    let gradient: Gradient = Gradient(colors: [Color.headerLogBackgr, Color.gradientDarkGray])
                    GeometryReader { geo in
                        // Display the custom alert as an overlay
                        RequestErrors(show: $showRequestError, infoTextAlert: "\(showRequestErrorText)", cnacelaction: {
//                            dismiss()
                            showQrCodeResponseAlert = false
                            scanerStatusError = false
                            isScanning = true
                            showRequestErrorText = ""
                        }, mainAction: {
//                                dismiss()
                            showQrCodeResponseAlert = false
                            scanerStatusError = false
                            isScanning = true
                            showRequestErrorText = ""
                        })
                            .frame(width: geo.size.width - 30, height: nil)
//                            .frame(width: geo.size.width - 30, height: geo.size.height / 2)
                            .background(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(15)
                        //                        .background(Color.headerLogBackgr.opacity(0.7))
                            .opacity(showRequestError ? 1 : 0)
                            .animation(.easeInOut, value: showRequestError)
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
                
                //                if (!networkMonitor.isConnected) {
                //                    NoInternetView()
                //                }
            }
                .ignoresSafeArea(.all)
        )
    }
    
    func parseSearchAndCheckId(from urlString: String) -> String? {
        //                                https://platformapro.com/qr-code-app-scan/userId:12/eventId:102
        //                                https://platformapro.com/qr-code-app-scan?search_id=12&check_id=102
        //                                check_id - clientId
        //                                search_id - eventId
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let queryItems = components.queryItems
        
        let searchId = queryItems?.first(where: { $0.name == "search_id" })?.value
        let checkId = queryItems?.first(where: { $0.name == "check_id" })?.value
        let userType = queryItems?.first(where: { $0.name == "type" })?.value
        
        if let searchId = searchId, let checkId = checkId, let userType = userType {
            self.searchId = searchId
            self.checkId = checkId
            self.userType = userType
            
            return "Search ID: \(searchId), Check ID: \(checkId)"
        }
        
        return nil
    }
}

//#Preview {
//    QRScaneerSheetPreview()
//}

struct ScanOverlayView: View {
    var cutoutWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
//            let cutoutWidth: CGFloat = min(geometry.size.width, geometry.size.height) / 1.5
            
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black)
                    .frame(width: cutoutWidth, height: cutoutWidth, alignment: .center)
                    .blendMode(.destinationOut)
            }.compositingGroup()
            
            Path { path in
                
                let left = (geometry.size.width - cutoutWidth) / 2.0
                let right = left + cutoutWidth
                let top = (geometry.size.height - cutoutWidth) / 2.0
                let bottom = top + cutoutWidth
                
                path.addPath(
                    createCornersPath(
                        left: left, top: top,
                        right: right, bottom: bottom,
                        cornerRadius: 40, cornerLength: 20
                    )
                )
                
            }
            .stroke(Color.blue, lineWidth: 8)
            .frame(width: cutoutWidth, height: cutoutWidth, alignment: .center)
            .aspectRatio(1, contentMode: .fit)
//            .modifier(GlowEffect())
            
        }
    }
    
    private func createCornersPath(
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        cornerRadius: CGFloat,
        cornerLength: CGFloat
    ) -> Path {
        var path = Path()
        
        // top left
        path.move(to: CGPoint(x: left, y: (top + cornerRadius / 2.0)))
        path.addArc(
            center: CGPoint(x: (left + cornerRadius / 2.0), y: (top + cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 180.0),
            endAngle: Angle(degrees: 270.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: left + (cornerRadius / 2.0), y: top))
        path.addLine(to: CGPoint(x: left + (cornerRadius / 2.0) + cornerLength, y: top))
        
        path.move(to: CGPoint(x: left, y: top + (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: left, y: top + (cornerRadius / 2.0) + cornerLength))
        
        // top right
        path.move(to: CGPoint(x: right - cornerRadius / 2.0, y: top))
        path.addArc(
            center: CGPoint(x: (right - cornerRadius / 2.0), y: (top + cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 270.0),
            endAngle: Angle(degrees: 360.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: right - (cornerRadius / 2.0), y: top))
        path.addLine(to: CGPoint(x: right - (cornerRadius / 2.0) - cornerLength, y: top))
        
        path.move(to: CGPoint(x: right, y: top + (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: right, y: top + (cornerRadius / 2.0) + cornerLength))
        
        // bottom left
        path.move(to: CGPoint(x: left + cornerRadius / 2.0, y: bottom))
        path.addArc(
            center: CGPoint(x: (left + cornerRadius / 2.0), y: (bottom - cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 90.0),
            endAngle: Angle(degrees: 180.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: left + (cornerRadius / 2.0), y: bottom))
        path.addLine(to: CGPoint(x: left + (cornerRadius / 2.0) + cornerLength, y: bottom))
        
        path.move(to: CGPoint(x: left, y: bottom - (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: left, y: bottom - (cornerRadius / 2.0) - cornerLength))
        
        // bottom right
        path.move(to: CGPoint(x: right, y: bottom - cornerRadius / 2.0))
        path.addArc(
            center: CGPoint(x: (right - cornerRadius / 2.0), y: (bottom - cornerRadius / 2.0)),
            radius: cornerRadius / 2.0,
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 90.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: right - (cornerRadius / 2.0), y: bottom))
        path.addLine(to: CGPoint(x: right - (cornerRadius / 2.0) - cornerLength, y: bottom))
        
        path.move(to: CGPoint(x: right, y: bottom - (cornerRadius / 2.0)))
        path.addLine(to: CGPoint(x: right, y: bottom - (cornerRadius / 2.0) - cornerLength))
        
        return path
    }
}
