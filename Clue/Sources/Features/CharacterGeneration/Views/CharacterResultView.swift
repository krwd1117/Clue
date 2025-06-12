//
//  CharacterResultView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 캐릭터 결과 표시 뷰
struct CharacterResultView: View {
    let character: GeneratedCharacter
    let onDismiss: () -> Void
    
    @State private var showingShareSheet = false
    @State private var showingCopyAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("캐릭터 생성 완료!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("새로운 캐릭터가 탄생했습니다")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 캐릭터 정보 카드
                    VStack(spacing: 16) {
                        // 이름과 나이
                        CharacterInfoCard(
                            icon: "person.fill",
                            title: "기본 정보",
                            content: "\(character.name), \(character.age)"
                        )
                        
                        // 외모
                        CharacterInfoCard(
                            icon: "eye.fill",
                            title: "외모",
                            content: character.appearance
                        )
                        
                        // 배경 스토리
                        CharacterInfoCard(
                            icon: "book.fill", 
                            title: "배경 스토리",
                            content: character.backstory
                        )
                        
                        // 갈등
                        CharacterInfoCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "갈등",
                            content: character.conflict
                        )
                    }
                    
                    // 액션 버튼들
                    VStack(spacing: 12) {
                        // 복사 버튼
                        Button(action: copyCharacter) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("클립보드에 복사")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 공유 버튼
                        Button(action: shareCharacter) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("공유하기")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 새로 생성하기 버튼
                        Button(action: onDismiss) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("새로 생성하기")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("생성 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        onDismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [characterShareText])
        }
        .alert("복사 완료", isPresented: $showingCopyAlert) {
            Button("확인") { }
        } message: {
            Text("캐릭터 정보가 클립보드에 복사되었습니다.")
        }
    }
    
    // MARK: - Actions
    
    private func copyCharacter() {
        UIPasteboard.general.string = characterShareText
        showingCopyAlert = true
        print("📋 CharacterResultView: Character copied to clipboard")
    }
    
    private func shareCharacter() {
        showingShareSheet = true
        print("📤 CharacterResultView: Opening share sheet")
    }
    
    private var characterShareText: String {
        return """
        🎭 캐릭터 프로필
        
        📛 이름: \(character.name)
        🎂 나이: \(character.age)
        👤 외모: \(character.appearance)
        📖 배경: \(character.backstory)
        ⚡ 갈등: \(character.conflict)
        
        ---
        Clue 앱으로 생성된 캐릭터입니다
        """
    }
}

// MARK: - 캐릭터 정보 카드 컴포넌트
struct CharacterInfoCard: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 공유 시트 컴포넌트
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 미리보기
#Preview {
    CharacterResultView(
        character: GeneratedCharacter(
            name: "리안느",
            age: "27세",
            appearance: "짙은 갈색 머리와 은빛 눈동자, 단단한 갑옷 차림",
            backstory: "왕국의 몰락한 기사 가문 출신으로, 잃어버린 명예를 되찾기 위해 여행 중",
            conflict: "과거 동료의 배신으로 믿음과 복수 사이에서 갈등"
        ),
        onDismiss: {}
    )
} 
