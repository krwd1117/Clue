import SwiftUI

struct HomeView: View {
    @StateObject private var router = HomeRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Main Action Section
                    mainActionSection
                    
                    // Features Section
                    featuresSection
                    
                    // About Section
                    aboutSection
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.white)
            .navigationDestination(for: HomeRoute.self) { route in
                router.navigate(for: route)
            }
            .sheet(item: Binding<HomeRoute?>(
                get: { router.presentedSheet },
                set: { _ in router.dismissSheet() }
            )) { route in
                router.navigate(for: route)
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // 앱 아이콘과 제목
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.48, blue: 1.0),
                                        Color(red: 0.2, green: 0.6, blue: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Clue")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("AI와 함께 만드는 나만의 캐릭터")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                
                // 환영 메시지
                VStack(spacing: 8) {
                    Text("안녕하세요! 👋")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("창의적인 캐릭터를 만들고\n나만의 이야기를 시작해보세요")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .background(
            LinearGradient(
                colors: [Color.white, Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Main Action Section
    private var mainActionSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("시작하기")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            // 캐릭터 생성 버튼
            Button(action: {
                router.navigate(to: .characterCreationMode)
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("캐릭터 생성")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("AI가 도와주는 12단계 캐릭터 생성")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.3))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("주요 기능")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(spacing: 16) {
                featureCard(
                    icon: "brain.head.profile",
                    title: "AI 기반 생성",
                    description: "ChatGPT가 도와주는 지능적인 캐릭터 생성",
                    color: Color(red: 0.55, green: 0.27, blue: 0.95)
                )
                
                featureCard(
                    icon: "list.clipboard",
                    title: "12단계 시스템",
                    description: "체계적인 단계별 캐릭터 설정 과정",
                    color: Color(red: 0.2, green: 0.78, blue: 0.35)
                )
                
                featureCard(
                    icon: "folder.badge.person.crop",
                    title: "캐릭터 보관함",
                    description: "생성한 캐릭터들을 안전하게 저장하고 관리",
                    color: Color(red: 1.0, green: 0.58, blue: 0.0)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(red: 0.99, green: 0.99, blue: 1.0))
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Clue에 대해")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                aboutItem(
                    icon: "lightbulb",
                    title: "창의적 영감",
                    description: "막막한 캐릭터 설정, AI가 창의적인 아이디어를 제공합니다"
                )
                
                aboutItem(
                    icon: "gearshape.2",
                    title: "체계적 설계",
                    description: "세계관부터 성격까지, 완성도 높은 캐릭터를 만들어보세요"
                )
                
                aboutItem(
                    icon: "heart",
                    title: "나만의 스토리",
                    description: "생성된 캐릭터로 당신만의 특별한 이야기를 시작하세요"
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
    
    // MARK: - Helper Views
    private func featureCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func aboutItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
} 
