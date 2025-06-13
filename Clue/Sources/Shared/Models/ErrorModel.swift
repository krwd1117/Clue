import Foundation

enum AppError: LocalizedError {
    case network(Error)
    case authentication(Error)
    case custom(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .authentication(let error):
            return "Authentication error: \(error.localizedDescription)"
        case .custom(let message):
            return message
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
} 