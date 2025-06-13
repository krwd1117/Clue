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
        
        categorySelections[index] = CategorySelection(category: category, selectedOption: option)
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
        guard !characterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              canCreateCharacter else {
            return false
        }
        
        isCreatingCharacter = true
        error = nil
        
        do {
            // 각 카테고리별 선택된 옵션을 매핑
            var selectedOptionsMap: [Int: Int] = [:]
            for selection in categorySelections {
                if let selectedOption = selection.selectedOption {
                    selectedOptionsMap[selection.category.id] = selectedOption.id
                }
            }
            
            let request = CharacterCreateRequest(
                name: characterName.trimmingCharacters(in: .whitespacesAndNewlines),
                selectedOptions: selectedOptionsMap,
                description: characterDescription.isEmpty ? nil : characterDescription
            )
            
            _ = try await service.createCharacter(request)
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
        !characterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !categorySelections.isEmpty &&
        categorySelections.allSatisfy({ $0.isComplete }) &&
        !isCreatingCharacter
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