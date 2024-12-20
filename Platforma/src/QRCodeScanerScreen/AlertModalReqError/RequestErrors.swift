//
//  RequestErrors.swift
//  Platforma
//
//  Created by Daniil Razbitski on 20/12/2024.
//

import SwiftUI

struct RequestErrors: View {
    // Binding variable to control the visibility from the parent view
    @Binding var show: Bool
    
    var infoTextAlert: String?
        
    var pageName: String? = ""
    
    var cnacelaction: (() -> Void)?
    var mainAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 0) {
                Text("Ошибка")
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
                    VStack (spacing: 0) {
                        Text(infoTextAlert ?? "")
                            .foregroundStyle(Color.white)
                            .font(.custom("Montserrat-Regular", size: 16))
                            .padding(.bottom, 55)
                        
                        Image("errormark")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 55)
                    }
                

                Button {
                    show = false
                    mainAction?() ?? {}()
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
