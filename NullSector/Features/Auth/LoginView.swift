//
//  LoginView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct LoginView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var animateIn: Bool = false

    var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        // Purple gradient header block
                        LinearGradient(
                            colors: [
                                Color(red: 0.31, green: 0.27, blue: 0.90),
                                Color(red: 0.45, green: 0.35, blue: 0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: geo.size.height * 0.42)

                        Color(red: 0.96, green: 0.96, blue: 0.98)
                            .frame(height: geo.size.height * 0.58)
                    }
                }
                .ignoresSafeArea()

                // Decorative circles on header
                GeometryReader { geo in
                    Circle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 220, height: 220)
                        .offset(x: geo.size.width * 0.6, y: -40)

                    Circle()
                        .fill(.white.opacity(0.04))
                        .frame(width: 140, height: 140)
                        .offset(x: -30, y: 20)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Top Nav
                    HStack {
                        Spacer()
                        Button {
                            showSignUp = true
                        } label: {
                            HStack(spacing: 6) {
                                Text("Don't have an account?")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.85))

                                Text("Get Started")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // MARK: - Header Title
                    VStack(spacing: 6) {
                        Text("NullSector")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 32)

                    Spacer()

                    // MARK: - Card
                    VStack(alignment: .leading, spacing: 0) {

                        Text("Welcome Back")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15))

                        Text("Enter your details below")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                            .padding(.top, 4)

                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                                .padding(.top, 28)

                            TextField("", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .font(.system(size: 15))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.97, green: 0.97, blue: 0.99))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.88, green: 0.88, blue: 0.93), lineWidth: 1)
                                )
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                                .padding(.top, 16)

                            HStack {
                                Group {
                                    if isPasswordVisible {
                                        TextField("", text: $password)
                                    } else {
                                        SecureField("", text: $password)
                                    }
                                }
                                .font(.system(size: 15))
                                .autocapitalization(.none)
                                .autocorrectionDisabled()

                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.72))
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.97, green: 0.97, blue: 0.99))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.88, green: 0.88, blue: 0.93), lineWidth: 1)
                            )
                        }

                        // MARK: - Error
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.system(size: 12))
                                .padding(.top, 10)
                        }

                        // MARK: - Sign In Button
                        Button {
                            Task {
                                await authViewModel.signIn(
                                    email: email,
                                    password: password
                                )
                            }
                        } label: {
                            Group {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign in")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.45, green: 0.35, blue: 0.95),
                                        Color(red: 0.75, green: 0.35, blue: 0.90)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color(red: 0.45, green: 0.35, blue: 0.95).opacity(0.35), radius: 12, y: 6)
                        }
                        .padding(.top, 28)
                        .disabled(authViewModel.isLoading)

                        // MARK: - Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot your password?") {}
                                .font(.system(size: 13))
                                .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                            Spacer()
                        }
                        .padding(.top, 16)
                    }
                    .padding(28)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.08), radius: 24, y: 8)
                    .padding(.horizontal, 20)
                    .offset(y: animateIn ? 0 : 40)
                    .opacity(animateIn ? 1 : 0)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authViewModel: authViewModel)
            }
            .onAppear {
                withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                    animateIn = true
                }
            }
        }
    }
}