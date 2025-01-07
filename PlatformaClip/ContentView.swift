//
//  ContentView.swift
//  PlatformaClip
//
//  Created by Daniil Razbitski on 20/12/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack() {
            
            Color.gradientDarkGray
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                // Logo
                VStack(spacing: 0) {
                    Image("logo-mini")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .padding(.top, 35 + 75)
                        .padding(.bottom, 50)
                    
                    // Title
                    Text("Будьте вместе с Platforma!")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    Text("Начни сейчас и получите возможность поделиться своими достижениями, идеями и советом с другими")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 25)
                    
                }
                .padding(.horizontal, 25)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.white.opacity(0.1))
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 30,
                        bottomTrailingRadius: 30,
                        topTrailingRadius: 0
                    )
                )
                
                Button {
                    openURL(URL(string: "https://platformapro.com")!)
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "book")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 20)
                            .padding(.leading, 25)
                            .foregroundColor(Color.white)
                        
                        Text("Больше о нас")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.privacyPolicyCloseButton)
                    .cornerRadius(10)
                    .padding(.horizontal, 25)
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
                
                Button {
                    openURL(URL(string: "https://platformapro.com/contact")!)
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 20)
                            .padding(.leading, 25)
                            .foregroundColor(Color.white)
                        
                        Text("У Вас есть вопросы? Напишите нам!")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.privacyPolicyCloseButton)
                    .cornerRadius(10)
                    .padding(.horizontal, 25)
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)
                
                Spacer()
                // Action Button
                Button {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id6739066917") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Скачайте Platforma")
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.privacyPolicyCloseButton)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 25)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
                
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

#Preview {
    ContentView()
}

//Missing entitlement. Since this app contains an App Clip, the com.apple.developer.associated-appclip-app-identifiers entitlement should be present and include the value of the App Clip's application identifier. Please add this entitlement, then resubmit.
//AppClipCodeGenerator generate --url https://platformapro.com --foreground FF5500 --background FEF3DE  --output ~/Downloads/platforma.svg
//AppClipCodeGenerator generate --url https://costracoffee.com/ --foreground FF5500 --background FEF3DE --type nfc --output ~/Downloads/americanonfc.svg


