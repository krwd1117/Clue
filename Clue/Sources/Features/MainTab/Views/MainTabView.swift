import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            
            LibraryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("보관함")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("프로필")
                }
                .environmentObject(appState)
        }
        .accentColor(DesignSystem.Colors.primary)
    }
}

#Preview {
    MainTabView()
} 
