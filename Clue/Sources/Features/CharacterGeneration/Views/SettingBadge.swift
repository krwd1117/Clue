//
//  SettingBadge.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//


import SwiftUI

// MARK: - 설정 뱃지 컴포넌트
struct SettingBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
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
