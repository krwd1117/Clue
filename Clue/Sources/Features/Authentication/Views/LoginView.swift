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
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 50) {
                    Spacer()
                    
                    // 앱 로고 및 제목
                    VStack(spacing: 30) {
                        ZStack {
                            // 배경 원형 효과
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 120, height: 120)
                                .scaleEffect(isAnimating ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            
                            // 메인 아이콘
                            Image(systemName: "person.crop.artframe")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(.blue)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Clue")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            
                            Text("당신만의 캐릭터를 창조하세요")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Text("✨ 상상력을 현실로 ✨")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    // OAuth 로그인 버튼들
                    VStack(spacing: 16) {
                        // Google 로그인
                        CreativeOAuthButton(
                            provider: .google,
                            isLoading: viewModel.isLoading
                        ) {
                            viewModel.signInWithGoogle()
                        }
                        
                        // Apple 로그인
                        CreativeOAuthButton(
                            provider: .apple,
                            isLoading: viewModel.isLoading
                        ) {
                            viewModel.signInWithApple()
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // 로딩 인디케이터
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                            }
                            
                            Text("로그인 중...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // 약관 동의
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            
                            Text("로그인하면 서비스 약관에 동의하게 됩니다")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
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
            withAnimation {
                isAnimating = true
            }
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
    
    var accentColor: Color {
        switch self {
        case .google: return .blue
        case .apple: return .gray
        }
    }
}

// MARK: - OAuth 버튼
struct CreativeOAuthButton: View {
    let provider: OAuthProvider
    let isLoading: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(provider.accentColor.opacity(0.1))
                        .frame(width: 35, height: 35)
                    
                    Image(systemName: provider.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(provider.foregroundColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(provider.displayName)로 시작하기")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(provider.foregroundColor)
                    
                    Text("간편하게 로그인하세요")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(provider.foregroundColor.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(provider.foregroundColor.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(provider.backgroundColor)
                    .shadow(color: .black.opacity(0.05), radius: isPressed ? 2 : 8, x: 0, y: isPressed ? 1 : 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppRouter())
} 
