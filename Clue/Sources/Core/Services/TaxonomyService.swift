//
//  TaxonomyService.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation
import Supabase

// MARK: - Taxonomy 데이터 서비스
class TaxonomyService: ObservableObject {
    static let shared = TaxonomyService()
    
    @Published var isLoading = false
    @Published var taxonomyGroups: [TaxonomyGroup] = []
    
    private let supabase: SupabaseClient
    private var cachedTaxonomyItems: [TaxonomyItem] = []
    
    private init() {
        // 공유 Supabase 클라이언트 사용
        self.supabase = SupabaseConfig.client
    }
    
    // MARK: - 데이터 로드
    
    func loadTaxonomyData() async throws {
        print("📊 TaxonomyService: Loading taxonomy data from Supabase")
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // Supabase에서 taxonomy 테이블 조회
            let response: [TaxonomyItem] = try await supabase
                .from("taxonomy")
                .select()
                .order("sort_order")
                .execute()
                .value
            
            await MainActor.run {
                self.cachedTaxonomyItems = response
                self.organizeDataIntoGroups()
                self.isLoading = false
                print("✅ TaxonomyService: Loaded \(response.count) taxonomy items")
            }
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                print("❌ TaxonomyService: Failed to load taxonomy data - \(error)")
            }
            throw TaxonomyError.loadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 데이터 조직화
    
    private func organizeDataIntoGroups() {
        let grouped = Dictionary(grouping: cachedTaxonomyItems) { $0.category }
        
        taxonomyGroups = TaxonomyCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            let sortedItems = items.sorted { $0.sortOrder < $1.sortOrder }
            return TaxonomyGroup(category: category, items: sortedItems)
        }
        
        print("📊 TaxonomyService: Organized into \(taxonomyGroups.count) groups")
    }
    
    // MARK: - 카테고리별 데이터 가져오기
    
    func getItems(for category: TaxonomyCategory) -> [TaxonomyItem] {
        return taxonomyGroups.first { $0.category == category }?.items ?? []
    }
    
    func getItem(by id: Int) -> TaxonomyItem? {
        return cachedTaxonomyItems.first { $0.id == id }
    }
    
    // MARK: - 유틸리티
    
    var hasData: Bool {
        return !taxonomyGroups.isEmpty
    }
    
    func refreshData() async throws {
        cachedTaxonomyItems.removeAll()
        taxonomyGroups.removeAll()
        try await loadTaxonomyData()
    }
}

// MARK: - 에러 타입
enum TaxonomyError: LocalizedError {
    case loadFailed(String)
    case noData
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .loadFailed(let message):
            return "데이터 로드 실패: \(message)"
        case .noData:
            return "사용 가능한 데이터가 없습니다"
        case .invalidData:
            return "데이터 형식이 올바르지 않습니다"
        }
    }
} 
