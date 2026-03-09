//
//  SplashView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import SwiftUI

struct SplashView: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.brandGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App icon or logo
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
                
                // App name
                VStack(spacing: 8) {
                    Text("NullSector")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Task & Reminder Manager")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SplashView()
}
