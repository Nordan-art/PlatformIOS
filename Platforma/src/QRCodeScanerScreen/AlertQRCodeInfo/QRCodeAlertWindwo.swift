//
//  QRCodeAlertWindwo.swift
//  Platforma
//
//  Created by Daniil Razbitski on 19/12/2024.
//

import SwiftUI

struct QRCodeAlertWindwo: View {
    // Binding variable to control the visibility from the parent view
    @Binding var show: Bool
    
    var infoTextAlert: String?
    
    @ObservedObject var qrCodeNetworkReqests: QRCodeNetworkReqests
    
    var pageName: String? = ""
    
    var cnacelaction: (() -> Void)?
    var mainAction: (() -> Void)?
    
    @State private var notificationStatus: UNAuthorizationStatus?
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 0) {
                Text(qrCodeNetworkReqests.userFromQRCodeDataModel.status ? "QR-код участника мероприятия" : "Неверный QR-код")
                    .foregroundStyle(Color.white)
                    .font(.custom("Montserrat-Medium", size: 20))
                
                Spacer()
                
                Button {
                    show = false
                    cnacelaction?() ?? {}()
                } label: {
                    Image("cross-blue")
                    //                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color.privacyPolicyCloseButton)
                }
            }
            .padding(.bottom, 10)
            
            //            ScrollView {
            VStack(spacing: 0) {
//                if (1 == 2) {
                if (qrCodeNetworkReqests.userFromQRCodeDataModel.status) {
                    let photoLink = qrCodeNetworkReqests.userFromQRCodeDataModel.result?.photo
                    AsyncImage(
                        url: URL(
                            string: photoLink ?? "https://picsum.photos/100")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 150, maxWidth: 150, minHeight: 150, maxHeight: 150, alignment: .center)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 55, height: 55)
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 15)
                            .opacity(1.0)
                            .zIndex(1)
                    
                    Text(qrCodeNetworkReqests.userFromQRCodeDataModel.result?.userName ?? "")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                        .padding(.bottom, 20)
                    
                    
                    let gradient: Gradient = Gradient(colors: [Color.greenLightColor2, Color.greenLightColor1])
                    let gradientOrange: Gradient = Gradient(colors: [Color.orangeLight, Color.orangeLight])
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Название мероприятия:")
                                    .foregroundStyle(Color.white)
                                    .font(.custom("Montserrat-SemiBold", size: 16))
                                
                                Text(qrCodeNetworkReqests.userFromQRCodeDataModel.result?.title ?? "")
                                    .foregroundStyle(Color.white)
                                    .font(.custom("Montserrat-Regular", size: 16))
                                    .padding(.bottom, 20)
                            }
                            Spacer()
                        }
                        
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Дата и время проведения:")
                                    .foregroundStyle(Color.white)
                                    .font(.custom("Montserrat-SemiBold", size: 16))
                                
                                Text(qrCodeNetworkReqests.userFromQRCodeDataModel.result?.datetime ?? "")
                                    .foregroundStyle(Color.white)
                                    .font(.custom("Montserrat-Regular", size: 16))
                            }
                            Spacer()
                        }
                    }
                    .padding(.all, 10)
                    .background(LinearGradient(gradient: qrCodeNetworkReqests.userFromQRCodeDataModel.result?.is_actual ?? true ? gradient : gradientOrange, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(15)
                    .padding(.bottom, 20)
                } else {
                    VStack (spacing: 0) {
                        Text(qrCodeNetworkReqests.userFromQRCodeDataModel.error ?? "Отсканированный код оказался недействительным. Убедитесь, что Вы используете правильный QR-код.")
                            .foregroundStyle(Color.white)
                            .font(.custom("Montserrat-Regular", size: 16))
                            .padding(.bottom, 55)
                        
                        Image("errormark")
                            .resizable()
                            .frame(width: 220, height: 220)
                            .padding(.bottom, 55)
                    }
                }

                Button {
                    show = false
                    mainAction?() ?? {}()
                } label: {
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Text(qrCodeNetworkReqests.userFromQRCodeDataModel.status ? "Продолжить" : "Повторить")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }
                    .padding([.top, .bottom], 15)
                    .padding([.leading, .trailing], 20)
                    .background(Color.privacyPolicyCloseButton) // Background color inside the border
                    .foregroundColor(Color.white)  // Text color
                    .cornerRadius(100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.privacyPolicyCloseButton, lineWidth: 1)
                    )
                    .padding(.horizontal, 1)
                }
            }
            
        }
        .padding(.all, 20)
    }
    
}

//#Preview {
//    QRCodeAlertWindwo()
//}
