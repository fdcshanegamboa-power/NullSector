//
//  SignUpView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct SignUpView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var passwordMismatch: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmVisible: Bool = false
    @State private var animateIn: Bool = false

    @Environment(\.dismiss) private var dismiss

    var authViewModel: AuthViewModel

    // Simple password strength
    private var passwordStrength: (label: String, color: Color, bars: Int) {
        let count = password.count
        if count == 0 { return ("", .clear, 0) }
        if count < 6  { return ("Weak", .red, 1) }
        if count < 10 { return ("Fair", .orange, 2) }
        return ("Strong", Color(red: 0.18, green: 0.75, blue: 0.45), 3)
    }

    var body: some View {
        ZStack {
            // MARK: - Background
            GeometryReader { geo in
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.31, green: 0.27, blue: 0.90),
                            Color(red: 0.45, green: 0.35, blue: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: geo.size.height * 0.38)

                    Color(red: 0.96, green: 0.96, blue: 0.98)
                        .frame(height: geo.size.height * 0.62)
                }
            }
            .ignoresSafeArea()

            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .offset(x: geo.size.width * 0.65, y: -30)

                Circle()
                    .fill(.white.opacity(0.04))
                    .frame(width: 120, height: 120)
                    .offset(x: -20, y: 30)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Top Nav
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.85))

                        Button {
                            dismiss()
                        } label: {
                            Text("Sign in")
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
                Text("NullSector")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                Spacer()

                // MARK: - Card
                VStack(alignment: .leading, spacing: 0) {

                    Text("Get started free.")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15))

                    Text("Organise your tasks, your way.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                        .padding(.top, 4)

                    // Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                            .padding(.top, 24)

                        TextField("Enter your email", text: $email)
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
                            .padding(.top, 14)

                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                            }
                            .font(.system(size: 15))
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                            // Strength indicator
                            if password.count > 0 {
                                HStack(spacing: 3) {
                                    ForEach(0..<3, id: \.self) { i in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(i < passwordStrength.bars ? passwordStrength.color : Color(red: 0.88, green: 0.88, blue: 0.93))
                                            .frame(width: 18, height: 4)
                                    }
                                    Text(passwordStrength.label)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(passwordStrength.color)
                                }
                            }

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

                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62))
                            .padding(.top, 14)

                        HStack {
                            Group {
                                if isConfirmVisible {
                                    TextField("Confirm your password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                }
                            }
                            .font(.system(size: 15))
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                            Button {
                                isConfirmVisible.toggle()
                            } label: {
                                Image(systemName: isConfirmVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.72))
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.97, green: 0.97, blue: 0.99))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    passwordMismatch
                                        ? Color.red.opacity(0.6)
                                        : Color(red: 0.88, green: 0.88, blue: 0.93),
                                    lineWidth: 1
                                )
                        )
                    }

                    // MARK: - Errors
                    if passwordMismatch {
                        Text("Passwords do not match.")
                            .foregroundStyle(.red)
                            .font(.system(size: 12))
                            .padding(.top, 8)
                    }

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.system(size: 12))
                            .padding(.top, 8)
                    }

                    // MARK: - Sign Up Button
                    Button {
                        guard password == confirmPassword else {
                            passwordMismatch = true
                            return
                        }
                        passwordMismatch = false
                        Task {
                            await authViewModel.signUp(
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
                                Text("Sign up")
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
                    .padding(.top, 24)
                    .disabled(authViewModel.isLoading)
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
        .navigationBarBackButtonHidden()
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                animateIn = true
            }
        }
    }
}