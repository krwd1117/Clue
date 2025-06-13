//
//  CharacterSuccessView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct CharacterSuccessView: View {
    let character: Character
    let onViewCharacter: () -> Void
    let onGoHome: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 성공 애니메이션 영역
            VStack(spacing: 32) {
                // 축하 아이콘
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.78, blue: 0.35),
                                    Color(red: 0.1, green: 0.9, blue: 0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(showConfetti ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showConfetti)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showConfetti)
                }
                
                // 축하 메시지
                VStack(spacing: 16) {
                    Text("🎉 축하합니다!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(showConfetti ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.4), value: showConfetti)
                    
                    VStack(spacing: 8) {
                        Text("'\(character.name)' 캐릭터가")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                        
                        Text("성공적으로 생성되었습니다")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .opacity(showConfetti ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: showConfetti)
                }
                
                // 캐릭터 미리보기
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(themeColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Text(String(character.name.prefix(1)))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeColor)
                    }
                    
                    VStack(spacing: 4) {
                        Text(character.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            if let gender = character.gender {
                                Text(gender)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            
                            if let age = character.age {
                                Text(age)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                    }
                }
                .opacity(showConfetti ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(0.8), value: showConfetti)
            }
            
            Spacer()
            
            // 액션 버튼들
            VStack(spacing: 16) {
                // 캐릭터 보기 버튼 (메인)
                Button(action: onViewCharacter) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("캐릭터 자세히 보기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.48, blue: 1.0),
                                Color(red: 0.2, green: 0.6, blue: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(showConfetti ? 1.0 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: showConfetti)
                
                // 홈으로 가기 버튼 (서브)
                Button(action: onGoHome) {
                    Text("홈으로 돌아가기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.05))
                        )
                }
                .scaleEffect(showConfetti ? 1.0 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.1), value: showConfetti)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .opacity(showConfetti ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(1.0), value: showConfetti)
        }
        .background(Color.white)
        .onAppear {
            showConfetti = true
        }
    }
    
    private var themeColor: Color {
        let colors: [Color] = [
            Color(red: 0.0, green: 0.48, blue: 1.0),    // Blue
            Color(red: 0.2, green: 0.78, blue: 0.35),   // Green
            Color(red: 1.0, green: 0.58, blue: 0.0),    // Orange
            Color(red: 0.55, green: 0.27, blue: 0.95),  // Purple
            Color(red: 1.0, green: 0.23, blue: 0.19),   // Red
            Color(red: 0.0, green: 0.78, blue: 0.75)    // Teal
        ]
        let hash = character.name.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
}

#Preview {
    CharacterSuccessView(
        character: Character(name: "테스트 캐릭터"),
        onViewCharacter: {},
        onGoHome: {}
    )
} 