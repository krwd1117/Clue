//
//  HomeView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI
import Supabase

// MARK: - 홈 뷰
struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var navigationRouter: NavigationRouter
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = HomeViewModel()
    @State private var isAnimating = false
    @State private var featuresVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 헤더 섹션
                        TossHeaderSection(user: authService.currentUser, isAnimating: $isAnimating)
                            .padding(.top, 20)
                        
                        // 메인 액션 버튼
                        TossCharacterGenerationButton {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                viewModel.startCharacterGeneration()
                            }
                        }
                        
                        // 기능 카드들
                        TossFeaturesSection(featuresVisible: $featuresVisible)
                        
                        // 가이드 섹션
                        TossGuideSection()
                        
                        // 영감 섹션
                        TossInspirationSection()
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setRouters(appRouter: appRouter, navigationRouter: navigationRouter)
            viewModel.setup()
            
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                featuresVisible = true
            }
        }
    }
}

// MARK: - Toss 스타일 헤더 섹션
struct TossHeaderSection: View {
    let user: User?
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 심플한 아이콘
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            // 환영 메시지
            VStack(spacing: 12) {
                if let user = user {
                    Text("안녕하세요, \(user.displayName ?? "창작자")님")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                } else {
                    Text("창작의 세계에 오신 것을 환영합니다")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                
                Text("오늘은 어떤 캐릭터를 만나보실까요?")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Toss 스타일 캐릭터 생성 버튼
struct TossCharacterGenerationButton: View {
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
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("새 캐릭터 창조하기")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text("상상력이 현실이 되는 순간")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: isPressed ? 4 : 12, x: 0, y: isPressed ? 2 : 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Toss 스타일 기능 섹션
struct TossFeaturesSection: View {
    @Binding var featuresVisible: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("창작 도구")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                TossFeatureCard(
                    icon: "gamecontroller.fill",
                    title: "장르 선택",
                    description: "판타지, SF, 로맨스\n미스터리 등 다양한 세계",
                    color: .purple,
                    delay: 0.0
                )
                
                TossFeatureCard(
                    icon: "heart.circle.fill",
                    title: "테마 설정",
                    description: "구원, 복수, 사랑\n성장의 깊이 있는 주제",
                    color: .pink,
                    delay: 0.1
                )
                
                TossFeatureCard(
                    icon: "location.circle.fill",
                    title: "배경 환경",
                    description: "중세 왕국, 우주정거장\n신비로운 마법 세계",
                    color: .cyan,
                    delay: 0.2
                )
                
                TossFeatureCard(
                    icon: "square.and.arrow.up.fill",
                    title: "즉시 활용",
                    description: "복사, 공유로\n창작물에 바로 적용",
                    color: .green,
                    delay: 0.3
                )
            }
        }
        .opacity(featuresVisible ? 1 : 0)
        .offset(y: featuresVisible ? 0 : 20)
    }
}

// MARK: - Toss 스타일 기능 카드
struct TossFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isVisible ? 1 : 0.9)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Toss 스타일 가이드 섹션
struct TossGuideSection: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("창작 가이드")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                TossGuideStep(
                    number: 1,
                    text: "장르·테마·배경 선택으로 세계관 구축",
                    color: .blue
                )
                
                TossGuideStep(
                    number: 2,
                    text: "AI가 당신의 상상력을 현실로 변환",
                    color: .purple
                )
                
                TossGuideStep(
                    number: 3,
                    text: "완성된 캐릭터를 저장하고 활용",
                    color: .green
                )
            }
        }
    }
}

// MARK: - Toss 스타일 가이드 스텝
struct TossGuideStep: View {
    let number: Int
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Toss 스타일 영감 섹션
struct TossInspirationSection: View {
    private let inspirations = [
        "\"모든 캐릭터에는 이야기가 있다\"",
        "\"상상력이 현실을 만든다\"",
        "\"당신의 창작물이 세상을 바꾼다\"",
        "\"예술은 영혼의 언어다\""
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("오늘의 영감")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            ZStack {
                ForEach(0..<inspirations.count, id: \.self) { index in
                    VStack(spacing: 12) {
                        Text("💡")
                            .font(.system(size: 24))
                        
                        Text(inspirations[index])
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(currentIndex == index ? 1 : 0)
                    .scaleEffect(currentIndex == index ? 1 : 0.9)
                    .animation(.easeInOut(duration: 0.5), value: currentIndex)
                }
            }
            .frame(height: 80)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % inspirations.count
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AppRouter())
        .environmentObject(NavigationRouter())
        .environmentObject(AuthService.shared)
}
