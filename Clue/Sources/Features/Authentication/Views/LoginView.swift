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
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 캐릭터 창작 테마 배경 그라디언트
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.1, blue: 0.4), // 깊은 보라
                        Color(red: 0.4, green: 0.2, blue: 0.6), // 중간 보라
                        Color(red: 0.6, green: 0.3, blue: 0.8), // 밝은 보라
                        Color(red: 0.8, green: 0.4, blue: 0.9)  // 연한 보라-핑크
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 떠다니는 창작 요소들
                ForEach(0..<6, id: \.self) { index in
                    FloatingElement(index: index)
                        .opacity(0.3)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // 앱 로고 및 제목 - 캐릭터 창작 테마
                    VStack(spacing: 25) {
                        ZStack {
                            // 배경 원형 효과
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            
                            // 메인 아이콘 - 캐릭터 창작 도구
                            Image(systemName: "person.crop.artframe")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .cyan.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .white.opacity(0.3), radius: 10)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Clue")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color.cyan.opacity(0.9),
                                            Color.purple.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .white.opacity(0.3), radius: 5)
                            
                            Text("당신만의 캐릭터를 창조하세요")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                            
                            Text("✨ 상상력을 현실로 ✨")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.cyan.opacity(0.8))
                                .offset(y: floatingOffset)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: floatingOffset)
                        }
                    }
                    
                    Spacer()
                    
                    // OAuth 로그인 버튼들 - 캐릭터 테마
                    VStack(spacing: 20) {
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
                    
                    // 로딩 인디케이터 - 창작 테마
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(
                                        AngularGradient(
                                            colors: [.cyan, .purple, .pink, .cyan],
                                            center: .center
                                        ),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                            }
                            
                            Text("캐릭터 세계로 연결 중...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // 약관 동의 - 캐릭터 테마
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "paintbrush.pointed.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan.opacity(0.7))
                            
                            Text("창작의 여정을 시작하면 서비스 약관에 동의하게 됩니다")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        
                        Text("🎨 • 🎭 • ✏️ • 🌟")
                            .font(.system(size: 16))
                            .opacity(0.6)
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
                floatingOffset = -5
            }
//            viewModel.setup()
        }
    }
}

// MARK: - 떠다니는 창작 요소
struct FloatingElement: View {
    let index: Int
    @State private var isMoving = false
    
    private let symbols = ["paintbrush", "pencil", "wand.and.stars", "person.fill", "heart.fill", "star.fill"]
    private let colors: [Color] = [.cyan, .purple, .pink, .orange, .yellow, .mint]
    
    var body: some View {
        Image(systemName: symbols[index % symbols.count])
            .font(.system(size: CGFloat.random(in: 20...40)))
            .foregroundColor(colors[index % colors.count])
            .offset(
                x: isMoving ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50),
                y: isMoving ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100)
            )
            .rotationEffect(.degrees(isMoving ? Double.random(in: 0...360) : 0))
            .animation(
                .easeInOut(duration: Double.random(in: 3...6))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.5),
                value: isMoving
            )
            .onAppear {
                isMoving = true
            }
    }
}

// MARK: - OAuth 제공자 열거형 (캐릭터 테마)
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

// MARK: - 창작 테마 OAuth 버튼
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
                        .fill(provider.accentColor.opacity(0.2))
                        .frame(width: 35, height: 35)
                    
                    Image(systemName: provider.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(provider.foregroundColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(provider.displayName)로 시작하기")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(provider.foregroundColor)
                    
                    Text("캐릭터 창작 여정을 시작해보세요")
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
                    .shadow(
                        color: provider.backgroundColor == .white ? .black.opacity(0.1) : .white.opacity(0.1),
                        radius: isPressed ? 5 : 10,
                        x: 0,
                        y: isPressed ? 2 : 5
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
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
