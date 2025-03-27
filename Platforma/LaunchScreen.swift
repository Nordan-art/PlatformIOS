//
//  LaunchScreen.swift
//  Platforma
//
//  Created by Daniil Razbitski on 27/03/2025.
//

import SwiftUI

struct MainLaunchScreen: View {
    @Binding var showLoadingPage: Bool
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                
                Image("logo_launch_scr")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            scale = 1.2
                            opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                scale = 0.5
                                opacity = 0.0

                                showLoadingPage = false
                            }
                        }
                    }
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .frame(minWidth: geo.size.width, maxWidth: geo.size.width, minHeight: geo.size.height, maxHeight: geo.size.height, alignment: .center)
            .navigationBarBackButtonHidden(true)
            .background(Color.black.opacity(0.7))
        }
    }
}
