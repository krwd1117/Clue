//
//  LoginView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 로그인 뷰
struct LoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 그라디언트
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // 앱 로고 및 제목
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Clue")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("로그인하여 시작하세요")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // OAuth 로그인 버튼들
                    VStack(spacing: 16) {
                        // Google 로그인
                        OAuthButton(
                            provider: .google,
                            isLoading: viewModel.isLoading
                        ) {
                            viewModel.signInWithGoogle()
                        }
                        
                        // Apple 로그인
                        OAuthButton(
                            provider: .apple,
                            isLoading: viewModel.isLoading
                        ) {
                            viewModel.signInWithApple()
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // 로딩 인디케이터
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                    
                    Spacer()
                    
                    // 개인정보 처리방침 등
                    VStack(spacing: 8) {
                        Text("로그인하면 서비스 약관 및 개인정보 처리방침에 동의하게 됩니다")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        }
        .alert("로그인 오류", isPresented: $viewModel.showingAlert) {
            Button("확인") { }
        } message: {
//            Text(viewModel.alertMessage)
        }
        .onAppear {
            viewModel.setAppRouter(appRouter)
//            viewModel.setup()
        }
    }
}

// MARK: - OAuth 제공자 열거형
enum OAuthProvider {
    case google
    case apple
    
    var displayName: String {
        switch self {
        case .google: return "Google"
        case .apple: return "Apple"
        }
    }
    
    var iconName: String {
        switch self {
        case .google: return "globe"
        case .apple: return "applelogo"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .google: return .white
        case .apple: return .black
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .google: return .black
        case .apple: return .white
        }
    }
}

// MARK: - OAuth 버튼 컴포넌트
struct OAuthButton: View {
    let provider: OAuthProvider
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: provider.iconName)
                    .font(.system(size: 20, weight: .medium))
                
                Text("\(provider.displayName)로 로그인")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(provider.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(provider.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppRouter())
} 
