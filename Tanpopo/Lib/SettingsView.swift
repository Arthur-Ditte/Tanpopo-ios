import SwiftUI

struct SettingsView : View {
    @State private var aniListService = AniListService()
    
    var body : some View {
        NavigationView {
            VStack {
                // User Information Section
                HStack {
                    Image("anilist")
                        .resizable()
                        .aspectRatio(contentMode : .fit)
                        .frame(width : 75, height : 75)
                        .padding(.leading, 25)
                    Spacer()
                    Text("Guest")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.trailing, 25)
                }
                .padding(.top)

                // Settings Form Section
                Form {
                    Section(header : Text("About")) {
                        Button(action : login) {
                            Text("Login")
                        }
                    }
                }
            }
            
        }
        
    }

    func login() {
       if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
           aniListService.getAuthorizationCode(from : rootViewController)
       }
   }
}

struct SettingsView_Previews : PreviewProvider {
    static var previews : some View {
       SettingsView()
   }
}
