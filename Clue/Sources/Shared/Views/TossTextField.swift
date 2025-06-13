import SwiftUI

struct TossTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    let showValidation: Bool
    let validationIcon: String?
    let errorMessage: String?
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isRequired: Bool = false,
        showValidation: Bool = true,
        validationIcon: String? = nil,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
        self.showValidation = showValidation
        self.validationIcon = validationIcon
        self.errorMessage = errorMessage
    }
    
    private var isValid: Bool {
        if isRequired {
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
    
    private var hasError: Bool {
        errorMessage != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Title with validation indicator
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                
                Spacer()
                
                if showValidation && !text.isEmpty {
                    Image(systemName: validationIcon ?? (isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(hasError ? DesignSystem.Colors.accent : (isValid ? DesignSystem.Colors.primary : DesignSystem.Colors.accent))
                }
            }
            
            // Text field
            TextField(placeholder, text: $text)
                .textFieldStyle(TossTextFieldStyle(hasError: hasError))
            
            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
    }
}

struct TossTextFieldStyle: TextFieldStyle {
    let hasError: Bool
    
    init(hasError: Bool = false) {
        self.hasError = hasError
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .medium))
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.sectionBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        hasError ? DesignSystem.Colors.accent : DesignSystem.Colors.borderLight,
                        lineWidth: hasError ? 2 : 1
                    )
            )
            .cornerRadius(12)
    }
}

struct TossTextFieldCard: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    let showValidation: Bool
    let validationIcon: String?
    let errorMessage: String?
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isRequired: Bool = false,
        showValidation: Bool = true,
        validationIcon: String? = nil,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
        self.showValidation = showValidation
        self.validationIcon = validationIcon
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        TossCard {
            TossTextField(
                title: title,
                placeholder: placeholder,
                text: $text,
                isRequired: isRequired,
                showValidation: showValidation,
                validationIcon: validationIcon,
                errorMessage: errorMessage
            )
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        TossTextField(
            title: "이름",
            placeholder: "이름을 입력하세요",
            text: .constant(""),
            isRequired: true
        )
        
        TossTextField(
            title: "이메일",
            placeholder: "이메일을 입력하세요",
            text: .constant("test@example.com"),
            showValidation: true
        )
        
        TossTextField(
            title: "비밀번호",
            placeholder: "비밀번호를 입력하세요",
            text: .constant("123"),
            errorMessage: "비밀번호는 최소 8자 이상이어야 합니다"
        )
        
        TossTextFieldCard(
            title: "카드 안의 텍스트필드",
            placeholder: "입력하세요",
            text: .constant("")
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 