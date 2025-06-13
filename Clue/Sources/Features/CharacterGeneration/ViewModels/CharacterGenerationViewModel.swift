import SwiftUI

@MainActor
class CharacterGenerationViewModel: ObservableObject {
    @Published var categories: [CharacterCategory] = []
    @Published var categorySelections: [CategorySelection] = []
    @Published var currentCategoryIndex = 0
    @Published var characterName = ""
    @Published var characterDescription = ""
    
    @Published var isLoadingCategories = false
    @Published var isLoadingOptions = false
    @Published var isCreatingCharacter = false
    @Published var error: AppError?
    
    // 기타 옵션 관련 상태
    @Published var customOptionTexts: [Int: String] = [:] // 카테고리 ID별 커스텀 텍스트
    @Published var showingCustomInput: [Int: Bool] = [:] // 카테고리 ID별 커스텀 입력 표시 여부
    
    // 미리보기 펼침 상태
    @Published var isPreviewExpanded = false
    
    // 각 카테고리별 옵션들을 저장
    private var optionsByCategory: [Int: [CharacterOption]] = [:]
    private let service: CharacterGenerationServiceProtocol
    
    init(service: CharacterGenerationServiceProtocol = CharacterGenerationService.shared) {
        self.service = service
    }
    
    func loadCategories() async {
        isLoadingCategories = true
        error = nil
        
        do {
            categories = try await service.fetchCategories()
            
            // CategorySelection 배열 초기화
            categorySelections = categories.map { CategorySelection(category: $0, selectedOption: nil) }
            
            // 모든 카테고리의 옵션들을 미리 로드
            await loadAllOptions()
            
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.network(error)
        }
        
        isLoadingCategories = false
    }
    
    private func loadAllOptions() async {
        isLoadingOptions = true
        
        for category in categories {
            do {
                let options = try await service.fetchOptions(for: category.id)
                optionsByCategory[category.id] = options.sorted { ($0.displayOrder ?? 0) < ($1.displayOrder ?? 0) }
                
                // 기본값이 있는 경우 자동 선택
                if let defaultOption = options.first(where: { $0.isDefault == true }) {
                    selectOption(defaultOption, for: category)
                }
            } catch {
                print("Failed to load options for category \(category.id): \(error)")
            }
        }
        
        isLoadingOptions = false
    }
    
    func selectOption(_ option: CharacterOption, for category: CharacterCategory) {
        guard let index = categorySelections.firstIndex(where: { $0.category.id == category.id }) else { return }
        
        // 이미 선택된 옵션을 다시 누르면 선택 해제
        if let currentSelection = categorySelections[index].selectedOption,
           currentSelection.id == option.id {
            deselectOption(for: category)
            return
        }
        
        categorySelections[index] = CategorySelection(category: category, selectedOption: option)
        
        // 기타 옵션이 아닌 경우 커스텀 입력 숨기기
        if !isOtherOption(option) {
            showingCustomInput[category.id] = false
            customOptionTexts[category.id] = ""
        }
    }
    
    func deselectOption(for category: CharacterCategory) {
        guard let index = categorySelections.firstIndex(where: { $0.category.id == category.id }) else { return }
        
        categorySelections[index] = CategorySelection(category: category, selectedOption: nil)
        
        // 커스텀 입력 상태도 초기화
        showingCustomInput[category.id] = false
        customOptionTexts[category.id] = ""
    }
    
    func selectOtherOption(for category: CharacterCategory) {
        // 이미 기타 옵션이 선택된 경우 선택 해제
        if isShowingCustomInput(for: category) {
            deselectOption(for: category)
            return
        }
        
        showingCustomInput[category.id] = true
        // 기타 옵션을 위한 임시 옵션 생성 (실제로는 서버에서 처리)
        let otherOption = CharacterOption(
            id: -1, // 임시 ID
            categoryId: category.id,
            value: "기타",
            description: "사용자 정의 옵션",
            metadata: [:],
            isDefault: false,
            displayOrder: 999,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // 직접 categorySelections 업데이트 (selectOption 호출 시 중복 체크 방지)
        guard let index = categorySelections.firstIndex(where: { $0.category.id == category.id }) else { return }
        categorySelections[index] = CategorySelection(category: category, selectedOption: otherOption)
    }
    
    func selectRandomOption(for category: CharacterCategory) {
        // 이미 무작위 옵션이 선택된 경우 선택 해제
        if isRandomSelected(for: category) {
            deselectOption(for: category)
            return
        }
        
        // 무작위 옵션을 위한 임시 옵션 생성
        let randomOption = CharacterOption(
            id: -2, // 무작위용 임시 ID
            categoryId: category.id,
            value: "무작위",
            description: "랜덤 선택 옵션",
            metadata: [:],
            isDefault: false,
            displayOrder: -1,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // 직접 categorySelections 업데이트 (selectOption 호출 시 중복 체크 방지)
        guard let index = categorySelections.firstIndex(where: { $0.category.id == category.id }) else { return }
        categorySelections[index] = CategorySelection(category: category, selectedOption: randomOption)
    }
    
    func isRandomSelected(for category: CharacterCategory) -> Bool {
        guard let selectedOption = getSelectedOption(for: category) else { return false }
        return selectedOption.id == -2 || selectedOption.value == "무작위"
    }
    
    func updateCustomOptionText(_ text: String, for category: CharacterCategory) {
        customOptionTexts[category.id] = text
    }
    
    func isOtherOption(_ option: CharacterOption) -> Bool {
        return option.id == -1 || option.value == "기타"
    }
    
    func isRandomOption(_ option: CharacterOption) -> Bool {
        return option.id == -2 || option.value == "무작위"
    }
    
    func isShowingCustomInput(for category: CharacterCategory) -> Bool {
        return showingCustomInput[category.id] ?? false
    }
    
    func getCustomOptionText(for category: CharacterCategory) -> String {
        return customOptionTexts[category.id] ?? ""
    }
    
    func togglePreview() {
        isPreviewExpanded.toggle()
    }
    
    func getOptions(for category: CharacterCategory) -> [CharacterOption] {
        return optionsByCategory[category.id] ?? []
    }
    
    func getSelectedOption(for category: CharacterCategory) -> CharacterOption? {
        return categorySelections.first(where: { $0.category.id == category.id })?.selectedOption
    }
    
    func nextCategory() {
        if currentCategoryIndex < categories.count - 1 {
            currentCategoryIndex += 1
        }
    }
    
    func previousCategory() {
        if currentCategoryIndex > 0 {
            currentCategoryIndex -= 1
        }
    }
    
    func createCharacter() async -> Bool {
        guard canCreateCharacter else {
            return false
        }
        
        isCreatingCharacter = true
        error = nil
        
        do {
            // 각 카테고리별 선택된 옵션의 값(문자열)을 매핑
            var selectedOptionsMap: [String: String] = [:]
            
            for selection in categorySelections {
                if let selectedOption = selection.selectedOption {
                    let categoryIdString = String(selection.category.id)
                    
                    if isOtherOption(selectedOption) {
                        // 커스텀 옵션인 경우 사용자 입력 텍스트 저장 (빈 값도 허용)
                        let customText = getCustomOptionText(for: selection.category).trimmingCharacters(in: .whitespacesAndNewlines)
                        selectedOptionsMap[categoryIdString] = customText.isEmpty ? "" : customText
                    } else {
                        // 일반 옵션인 경우 옵션의 값(value) 저장
                        selectedOptionsMap[categoryIdString] = selectedOption.value
                    }
                }
            }
            
            // 이름 처리: 빈 값이거나 "무작위"인 경우 ChatGPT가 생성하도록 빈 문자열 전송
            let finalName = characterName.trimmingCharacters(in: .whitespacesAndNewlines)
            let nameToSend = finalName.isEmpty || finalName.lowercased() == "무작위" ? "" : finalName
            
            let request = CharacterCreateRequest(
                name: nameToSend,
                selectedOptions: selectedOptionsMap,
                description: nil
            )
            
            let character = try await service.createCharacter(request)
            
            return true
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.network(error)
        }
        
        isCreatingCharacter = false
        return false
    }
    
    var canCreateCharacter: Bool {
        guard !categorySelections.isEmpty,
              !isCreatingCharacter else {
            return false
        }
        
        // 모든 카테고리가 완료되었는지 확인 (기타 옵션의 경우 텍스트 필드는 선택사항)
        return categorySelections.allSatisfy({ $0.isComplete })
    }
    
    var currentCategory: CharacterCategory? {
        guard currentCategoryIndex < categories.count else { return nil }
        return categories[currentCategoryIndex]
    }
    
    var isFirstCategory: Bool {
        currentCategoryIndex == 0
    }
    
    var isLastCategory: Bool {
        currentCategoryIndex == categories.count - 1
    }
    
    var completedCategoriesCount: Int {
        categorySelections.filter { $0.isComplete }.count
    }
    
    var progressPercentage: Double {
        guard !categories.isEmpty else { return 0 }
        return Double(completedCategoriesCount) / Double(categories.count)
    }
} 
