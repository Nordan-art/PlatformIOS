//
//  AlertPrivacyPolice.swift
//  Platforma
//
//  Created by Daniil Razbitski on 03/12/2024.
//

import SwiftUI

struct AlertPrivacyPolice: View {
    // Binding variable to control the visibility from the parent view
    @Binding var show: Bool
    
    var infoTextAlert: String?
    
    var pageName: String? = ""
    
    var cnacelaction: (() -> Void)?
    var mainAction: (() -> Void)?
    
    @State private var notificationStatus: UNAuthorizationStatus?
    
    @State var positiveButtonText: String = "info_message.alert_turn_on_notification"
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
                Text("additional_element.privacy_policy")
                    .foregroundStyle(Color.white)
                    .font(.custom("Montserrat-Medium", size: 20))
                    .onTapGesture {
                        openURL(URL(string: "https://platformapro.com/privacy-policy")!)
                    }
                    .padding(.trailing, 3)
                
                Image(systemName: "hand.rays.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.white)
                
                Spacer()
                Button {
                    show = false
                } label: {
                    Image("cross-blue")
                    //                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color.privacyPolicyCloseButton)
                }
            }
            .padding(.bottom, 10)
            
            //            Text("additional_element.privacy_policy_link_to_web")
            //                .foregroundStyle(Color.white)
            //                .font(.custom("Montserrat-Medium", size: 10))
            //                .onTapGesture {
            //                    openURL(URL(string: "https://platformapro.com/privacy-policy")!)
            //                }
            
            
            ScrollView {
                VStack(spacing: 0) {
                    Text(LocalizedStringKey("privacy_policy_translate"))
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Regular", size: 16))
                        .padding(.bottom, 20)
                    
                    Button {
                        show = false
                    } label: {
                        HStack(spacing: 0) {
                            Spacer()
                            
                            Text("OK")
                                .font(.custom("Montserrat-Medium", size: 16))
                                .foregroundStyle(Color.white)
                            
                            Spacer()
                        }
                        .padding([.top, .bottom], 15)
                        .padding([.leading, .trailing], 20)
                        .background(Color.privacyPolicyCloseButton) // Background color inside the border
                        //                        .background(Color.headerLogBackgr) // Background color inside the border
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
            
        }
        .padding(.all, 20)
    }
    
}

#Preview {
    AlertPrivacyPolice(show: .constant(true), infoTextAlert: "")
}
