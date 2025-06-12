//
//  DynamicPickerViews.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 동적 Taxonomy Picker 뷰
struct DynamicTaxonomyPickerView: View {
    let category: TaxonomyCategory
    let items: [TaxonomyItem]
    @Binding var selectedItemId: Int?
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(items) { item in
                DynamicOptionCard(
                    item: item,
                    isSelected: selectedItemId == item.id
                ) {
                    selectedItemId = item.id
                }
            }
        }
    }
}

// MARK: - 동적 옵션 카드 컴포넌트
struct DynamicOptionCard: View {
    let item: TaxonomyItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(item.description)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var displayName: String {
        // name을 사용자 친화적인 이름으로 변환
        switch item.name {
        case "fantasy": return "판타지"
        case "sci-fi": return "SF"
        case "romance": return "로맨스"
        case "mystery": return "추리"
        case "horror": return "호러"
        case "historical": return "역사"
        case "modern": return "현대"
        case "cyberpunk": return "사이버펑크"
        case "redemption": return "구원"
        case "revenge": return "복수"
        case "love": return "사랑"
        case "sacrifice": return "희생"
        case "discovery": return "발견"
        case "survival": return "생존"
        case "betrayal": return "배신"
        case "power": return "권력"
        case "medieval-kingdom": return "중세 왕국"
        case "modern-city": return "현대 도시"
        case "space-station": return "우주 정거장"
        case "magic-academy": return "마법 학원"
        case "post-apocalyptic": return "포스트 아포칼립스"
        case "victorian-era": return "빅토리아 시대"
        case "cyberpunk-city": return "사이버펑크 도시"
        case "pirate-sea": return "해적의 바다"
        default: return item.name.capitalized
        }
    }
}

// MARK: - Taxonomy 그룹 섹션 뷰
struct TaxonomyGroupSection: View {
    let group: TaxonomyGroup
    @Binding var selectedItemId: Int?
    
    var body: some View {
        SettingsSection(
            title: group.displayName,
            description: group.description
        ) {
            DynamicTaxonomyPickerView(
                category: group.category,
                items: group.items,
                selectedItemId: $selectedItemId
            )
        }
    }
}

// MARK: - 로딩 상태 뷰
struct TaxonomyLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            Text("옵션을 불러오는 중...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 에러 상태 뷰
struct TaxonomyErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            Text("옵션 로드 실패")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도") {
                onRetry()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 미리보기
#Preview("Dynamic Picker") {
    let mockItems = [
        TaxonomyItem(id: 1, name: "fantasy", category: .genre, parentId: nil, sortOrder: 1),
        TaxonomyItem(id: 1, name: "sci-fi", category: .genre, parentId: nil, sortOrder: 2)
    ]
    
    DynamicTaxonomyPickerView(
        category: .genre,
        items: mockItems,
        selectedItemId: .constant(1)
    )
    .padding()
}

#Preview("Loading State") {
    TaxonomyLoadingView()
        .padding()
}

#Preview("Error State") {
    TaxonomyErrorView(message: "네트워크 연결을 확인해주세요") {
        print("Retry tapped")
    }
    .padding()
} 
