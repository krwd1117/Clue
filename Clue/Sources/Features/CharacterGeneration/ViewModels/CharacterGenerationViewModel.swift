//
//  CharacterGenerationViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class CharacterGenerationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // 동적 선택 데이터 (10개 카테고리)
    @Published var selectedGenreId: Int?
    @Published var selectedThemeId: Int?
    @Published var selectedEraId: Int?
    @Published var selectedMoodId: Int?
    @Published var selectedPersonalityId: Int?
    @Published var selectedOriginId: Int?
    @Published var selectedWeaknessId: Int?
    @Published var selectedMotivationId: Int?
    @Published var selectedGoalId: Int?
    @Published var selectedTwistId: Int?
    
    // 계층적 선택 관리
    @Published var expandedCategories: Set<TaxonomyCategory> = []
    @Published var selectedParents: [TaxonomyCategory: TaxonomyItem] = [:]
    
    // '모두' 선택 및 직접 입력 관리
    @Published var selectAllCategories: Set<TaxonomyCategory> = []
    @Published var customInputs: [TaxonomyCategory: String] = [:]
    @Published var showingCustomInput: Set<TaxonomyCategory> = []
    
    @Published var isGenerating = false
    @Published var generatedCharacter: GeneratedCharacter?
    @Published var showingResult = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    // Taxonomy 데이터
    @Published var isLoadingTaxonomy = false
    @Published var taxonomyError: String?
    
    // MARK: - Services
    
    private let generationService = CharacterGenerationService.shared
    private let taxonomyService = TaxonomyService.shared
    private let storageService = CharacterStorageService.shared
    private var navigationRouter: NavigationRouter?
    
    // MARK: - Setup
    
    func setNavigationRouter(_ router: NavigationRouter) {
        self.navigationRouter = router
    }
    
    func loadTaxonomyData() {
        print("🎭 CharacterGenerationViewModel: Loading taxonomy data")
        isLoadingTaxonomy = true
        taxonomyError = nil
        
        Task {
            do {
                // 실제 Supabase 데이터 로드 시도, 실패 시 목업 데이터 사용
                try await taxonomyService.loadTaxonomyData()
            } catch {
                print("⚠️ Failed to load from Supabase, using mock data: \(error)")
            }
            
            await MainActor.run {
                self.isLoadingTaxonomy = false
                self.setDefaultSelections()
            }
        }
    }
    
    func retryLoadingTaxonomy() {
        loadTaxonomyData()
    }
    
    private func setDefaultSelections() {
        // 기본값을 설정하지 않고 모든 선택을 비워둠
        // 사용자가 직접 선택해야 함
        print("🎭 CharacterGenerationViewModel: Default selections cleared - user must make selections")
    }
    
    // MARK: - Character Generation
    
    func generateCharacter() {
        print("🎭 CharacterGenerationViewModel: Starting character generation")
        
        // 각 카테고리별로 설정 값 확인 및 생성
        let genreValue = getValueForCategory(.genre)
        let themeValue = getValueForCategory(.theme)
        let eraValue = getValueForCategory(.era)
        let moodValue = getValueForCategory(.mood)
        let personalityValue = getValueForCategory(.personality)
        let originValue = getValueForCategory(.origin)
        let weaknessValue = getValueForCategory(.weakness)
        let motivationValue = getValueForCategory(.motivation)
        let goalValue = getValueForCategory(.goal)
        let twistValue = getValueForCategory(.twist)
        
        print("🎯 Settings - Genre: \(genreValue), Theme: \(themeValue), Era: \(eraValue), Mood: \(moodValue)")
        print("🎯 Personality: \(personalityValue), Origin: \(originValue), Weakness: \(weaknessValue)")
        print("🎯 Motivation: \(motivationValue), Goal: \(goalValue), Twist: \(twistValue)")
        
        isGenerating = true
        showingError = false
        
        let settings = createEnhancedCharacterSettings(
            genre: genreValue, theme: themeValue, era: eraValue, mood: moodValue,
            personality: personalityValue, origin: originValue, weakness: weaknessValue,
            motivation: motivationValue, goal: goalValue, twist: twistValue
        )
        
        Task {
            do {
                let character = try await generationService.generateEnhancedCharacter(with: settings)
                
                await MainActor.run {
                    self.generatedCharacter = character
                    self.showingResult = true
                    self.isGenerating = false
                    print("✅ CharacterGenerationViewModel: Character generated successfully - \(character.name)")
                    
                    // 자동 저장 (선택사항)
                    if AuthService.shared.isAuthenticated {
                        Task {
                            await self.autoSaveCharacter(character)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isGenerating = false
                    self.showError(error.localizedDescription)
                    print("❌ CharacterGenerationViewModel: Generation failed - \(error)")
                }
            }
        }
    }
    
    private func getValueForCategory(_ category: TaxonomyCategory) -> String {
        // '모두' 선택된 경우
        if selectAllCategories.contains(category) {
            return "모든 \(category.displayName.lowercased())"
        }
        
        // 커스텀 입력이 있는 경우
        if let customInput = customInputs[category], !customInput.isEmpty {
            return customInput
        }
        
        // 일반 선택된 아이템이 있는 경우
        if let selectedItem = getSelectedItem(for: category) {
            return selectedItem.name
        }
        
        return "미선택"
    }
    
    private func createEnhancedCharacterSettings(
        genre: String, theme: String, era: String, mood: String,
        personality: String, origin: String, weakness: String,
        motivation: String, goal: String, twist: String
    ) -> EnhancedCharacterSettings {
        return EnhancedCharacterSettings(
            genre: genre,
            theme: theme,
            era: era,
            mood: mood,
            personality: personality,
            origin: origin,
            weakness: weakness,
            motivation: motivation,
            goal: goal,
            twist: twist
        )
    }
    
    private func createDynamicCharacterSettings(
        genre: TaxonomyItem, theme: TaxonomyItem, era: TaxonomyItem, mood: TaxonomyItem,
        personality: TaxonomyItem, origin: TaxonomyItem, weakness: TaxonomyItem,
        motivation: TaxonomyItem, goal: TaxonomyItem, twist: TaxonomyItem
    ) -> DynamicCharacterSettings {
        return DynamicCharacterSettings(
            genreId: genre.id,
            themeId: theme.id,
            eraId: era.id,
            moodId: mood.id,
            personalityId: personality.id,
            originId: origin.id,
            weaknessId: weakness.id,
            motivationId: motivation.id,
            goalId: goal.id,
            twistId: twist.id,
            genre: genre,
            theme: theme,
            era: era,
            mood: mood,
            personality: personality,
            origin: origin,
            weakness: weakness,
            motivation: motivation,
            goal: goal,
            twist: twist
        )
    }
    
    // MARK: - Settings Management
    
    func resetSettings() {
        print("🔄 CharacterGenerationViewModel: Resetting all selections")
        selectedGenreId = nil
        selectedThemeId = nil
        selectedEraId = nil
        selectedMoodId = nil
        selectedPersonalityId = nil
        selectedOriginId = nil
        selectedWeaknessId = nil
        selectedMotivationId = nil
        selectedGoalId = nil
        selectedTwistId = nil
    }
    
    var canGenerate: Bool {
        return !isGenerating && 
               hasValidSelection(for: .genre) &&
               hasValidSelection(for: .theme) &&
               hasValidSelection(for: .era) &&
               hasValidSelection(for: .mood) &&
               hasValidSelection(for: .personality) &&
               hasValidSelection(for: .origin) &&
               hasValidSelection(for: .weakness) &&
               hasValidSelection(for: .motivation) &&
               hasValidSelection(for: .goal) &&
               hasValidSelection(for: .twist) &&
               taxonomyService.hasData
    }
    
    private func hasValidSelection(for category: TaxonomyCategory) -> Bool {
        // '모두' 선택된 경우
        if selectAllCategories.contains(category) {
            return true
        }
        
        // 커스텀 입력이 있는 경우
        if let customInput = customInputs[category], !customInput.isEmpty {
            return true
        }
        
        // 일반 선택이 있는 경우 (양수 ID만)
        let selectedId: Int?
        switch category {
        case .genre: selectedId = selectedGenreId
        case .theme: selectedId = selectedThemeId
        case .era: selectedId = selectedEraId
        case .mood: selectedId = selectedMoodId
        case .personality: selectedId = selectedPersonalityId
        case .origin: selectedId = selectedOriginId
        case .weakness: selectedId = selectedWeaknessId
        case .motivation: selectedId = selectedMotivationId
        case .goal: selectedId = selectedGoalId
        case .twist: selectedId = selectedTwistId
        }
        
        return selectedId != nil && selectedId! > 0
    }
    
    // MARK: - 캐릭터 저장
    
    /// 캐릭터 자동 저장 (백그라운드)
    private func autoSaveCharacter(_ character: GeneratedCharacter) async {
        do {
            let savedCharacter = try await storageService.saveCharacter(character)
            print("💾 Character auto-saved: \(savedCharacter.name)")
            
            await MainActor.run {
                // 저장된 캐릭터로 업데이트
                self.generatedCharacter = savedCharacter
            }
        } catch {
            print("⚠️ Auto-save failed: \(error.localizedDescription)")
            // 자동 저장 실패는 사용자에게 알리지 않음 (UX 고려)
        }
    }
    
    /// 캐릭터 수동 저장 (사용자 버튼 클릭)
    func saveCharacter() async {
        guard let character = generatedCharacter else { return }
        
        do {
            let savedCharacter = try await storageService.saveCharacter(character)
            print("💾 Character manually saved: \(savedCharacter.name)")
            
            await MainActor.run {
                self.generatedCharacter = savedCharacter
                // 성공 알림은 UI에서 처리
            }
        } catch {
            await MainActor.run {
                self.showError("캐릭터 저장에 실패했습니다: \(error.localizedDescription)")
            }
        }
    }
    
    /// 현재 캐릭터가 저장되었는지 확인
    var isCurrentCharacterSaved: Bool {
        guard let character = generatedCharacter else { return false }
        return storageService.isCharacterSaved(character)
    }
    
    // MARK: - Navigation
    
    func showCharacterResult() {
        guard let character = generatedCharacter else { return }
        navigationRouter?.push(.characterResult(character: character))
    }
    
    func dismissResult() {
        showingResult = false
        generatedCharacter = nil
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    // MARK: - Computed Properties
    
    var settingsDescription: String {
        var descriptions: [String] = []
        
        for category in availableCategories {
            if selectAllCategories.contains(category) {
                descriptions.append("\(category.displayName): 모두")
            } else if let customInput = customInputs[category], !customInput.isEmpty {
                descriptions.append("\(category.displayName): \(customInput)")
            } else if let selectedItem = getSelectedItem(for: category) {
                descriptions.append("\(category.displayName): \(selectedItem.name)")
            }
        }
        
        if descriptions.isEmpty {
            return "설정을 선택해주세요"
        }
        
        let validSelections = descriptions.count
        let totalCategories = availableCategories.count
        
        if validSelections == totalCategories {
            return descriptions.joined(separator: " • ")
        } else {
            let remaining = totalCategories - validSelections
            return "\(descriptions.joined(separator: " • ")) (남은 선택: \(remaining)개)"
        }
    }
    
    private func getSelectedItem(for category: TaxonomyCategory) -> TaxonomyItem? {
        let selectedId: Int?
        switch category {
        case .genre: selectedId = selectedGenreId
        case .theme: selectedId = selectedThemeId
        case .era: selectedId = selectedEraId
        case .mood: selectedId = selectedMoodId
        case .personality: selectedId = selectedPersonalityId
        case .origin: selectedId = selectedOriginId
        case .weakness: selectedId = selectedWeaknessId
        case .motivation: selectedId = selectedMotivationId
        case .goal: selectedId = selectedGoalId
        case .twist: selectedId = selectedTwistId
        }
        
        guard let id = selectedId, id > 0 else { return nil }
        return taxonomyService.getItem(by: id)
    }
    
    var taxonomyGroups: [TaxonomyGroup] {
        return taxonomyService.taxonomyGroups
    }
    
    // MARK: - 계층적 선택 관리
    
    var availableCategories: [TaxonomyCategory] {
        return TaxonomyCategory.allCases
    }
    
    func getParentItems(for category: TaxonomyCategory) -> [TaxonomyItem] {
        return taxonomyService.getItems(for: category).filter { $0.parentId == nil }
    }
    
    func getChildItems(for parentItem: TaxonomyItem) -> [TaxonomyItem] {
        // 같은 카테고리 내에서 해당 부모의 자식들을 찾음
        return taxonomyService.taxonomyGroups
            .flatMap { $0.items }
            .filter { $0.parentId == parentItem.id }
    }
    
    func selectParentItem(_ item: TaxonomyItem) {
        print("🎯 Selected parent item: \(item.name) in category: \(item.category)")
        
        // 부모 아이템 선택 저장
        selectedParents[item.category] = item
        updateSelectionForCategory(item.category, itemId: item.id)
        
        // 해당 카테고리 확장
        expandedCategories.insert(item.category)
        
        // 자식이 있는지 확인하고 로그 출력
        let children = getChildItems(for: item)
        print("📋 Found \(children.count) children for \(item.name)")
        for child in children {
            print("  - Child: \(child.name) (id: \(child.id), parentId: \(child.parentId ?? -1))")
        }
    }
    
    func selectChildItem(_ item: TaxonomyItem) {
        print("🎯 Selected child item: \(item.name)")
        updateSelectionForCategory(item.category, itemId: item.id)
    }
    
    func toggleCategory(_ category: TaxonomyCategory) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }
    
    func isCategoryExpanded(_ category: TaxonomyCategory) -> Bool {
        return expandedCategories.contains(category)
    }
    
    func resetHierarchicalSelection() {
        expandedCategories.removeAll()
        selectedParents.removeAll()
        selectAllCategories.removeAll()
        customInputs.removeAll()
        showingCustomInput.removeAll()
        resetSettings()
    }
    
    // MARK: - '모두' 선택 및 직접 입력 관리
    
    func selectAllForCategory(_ category: TaxonomyCategory) {
        if selectAllCategories.contains(category) {
            // 이미 '모두'가 선택된 경우 해제
            print("🎯 Deselected 'All' for category: \(category)")
            selectAllCategories.remove(category)
            
            // 해당 카테고리의 선택을 완전히 비움
            updateSelectionForCategory(category, itemId: nil)
        } else {
            // '모두' 선택
            print("🎯 Selected 'All' for category: \(category)")
            selectAllCategories.insert(category)
            
            // 기존 선택 해제
            selectedParents.removeValue(forKey: category)
            customInputs.removeValue(forKey: category)
            showingCustomInput.remove(category)
            expandedCategories.remove(category)
            
            // 해당 카테고리의 선택을 특별한 값으로 설정 (예: -1)
            updateSelectionForCategory(category, itemId: -1)
        }
    }
    
    func toggleCustomInput(for category: TaxonomyCategory) {
        if showingCustomInput.contains(category) {
            // 커스텀 입력 해제
            showingCustomInput.remove(category)
            customInputs.removeValue(forKey: category)
            
            // 해당 카테고리의 선택을 완전히 비움
            updateSelectionForCategory(category, itemId: nil)
        } else {
            // 커스텀 입력 활성화
            showingCustomInput.insert(category)
            // 기존 선택들 해제
            selectedParents.removeValue(forKey: category)
            selectAllCategories.remove(category)
            expandedCategories.remove(category)
            
            // 커스텀 입력 상태로 설정 (빈 문자열이므로 아직 유효하지 않음)
            updateSelectionForCategory(category, itemId: -2)
        }
    }
    
    func updateCustomInput(for category: TaxonomyCategory, text: String) {
        customInputs[category] = text
        if !text.isEmpty {
            // 커스텀 입력이 있으면 특별한 값으로 설정 (예: -2)
            updateSelectionForCategory(category, itemId: -2)
        }
    }
    
    func isSelectAllActive(for category: TaxonomyCategory) -> Bool {
        return selectAllCategories.contains(category)
    }
    
    func isCustomInputActive(for category: TaxonomyCategory) -> Bool {
        return showingCustomInput.contains(category)
    }
    
    func getCustomInput(for category: TaxonomyCategory) -> String {
        return customInputs[category] ?? ""
    }
    
    private func updateSelectionForCategory(_ category: TaxonomyCategory, itemId: Int?) {
        switch category {
        case .genre: selectedGenreId = itemId
        case .theme: selectedThemeId = itemId
        case .era: selectedEraId = itemId
        case .mood: selectedMoodId = itemId
        case .personality: selectedPersonalityId = itemId
        case .origin: selectedOriginId = itemId
        case .weakness: selectedWeaknessId = itemId
        case .motivation: selectedMotivationId = itemId
        case .goal: selectedGoalId = itemId
        case .twist: selectedTwistId = itemId
        }
    }
    
    // MARK: - Helper Methods
    
    func getSelectedItems() -> [TaxonomyItem] {
        var items: [TaxonomyItem] = []
        
        if let genreId = selectedGenreId, let genre = taxonomyService.getItem(by: genreId) {
            items.append(genre)
        }
        if let themeId = selectedThemeId, let theme = taxonomyService.getItem(by: themeId) {
            items.append(theme)
        }
        if let eraId = selectedEraId, let era = taxonomyService.getItem(by: eraId) {
            items.append(era)
        }
        if let moodId = selectedMoodId, let mood = taxonomyService.getItem(by: moodId) {
            items.append(mood)
        }
        if let personalityId = selectedPersonalityId, let personality = taxonomyService.getItem(by: personalityId) {
            items.append(personality)
        }
        if let originId = selectedOriginId, let origin = taxonomyService.getItem(by: originId) {
            items.append(origin)
        }
        if let weaknessId = selectedWeaknessId, let weakness = taxonomyService.getItem(by: weaknessId) {
            items.append(weakness)
        }
        if let motivationId = selectedMotivationId, let motivation = taxonomyService.getItem(by: motivationId) {
            items.append(motivation)
        }
        if let goalId = selectedGoalId, let goal = taxonomyService.getItem(by: goalId) {
            items.append(goal)
        }
        if let twistId = selectedTwistId, let twist = taxonomyService.getItem(by: twistId) {
            items.append(twist)
        }
        
        return items
    }
    
    var progressPercentage: Double {
        let validSelectionCount = availableCategories.filter { hasValidSelection(for: $0) }.count
        guard !availableCategories.isEmpty else { return 0 }
        return Double(validSelectionCount) / Double(availableCategories.count)
    }
    
    private func getSelectedIdForCategory(_ category: TaxonomyCategory) -> Int? {
        switch category {
        case .genre: return selectedGenreId
        case .theme: return selectedThemeId
        case .era: return selectedEraId
        case .mood: return selectedMoodId
        case .personality: return selectedPersonalityId
        case .origin: return selectedOriginId
        case .weakness: return selectedWeaknessId
        case .motivation: return selectedMotivationId
        case .goal: return selectedGoalId
        case .twist: return selectedTwistId
        }
    }
} 
