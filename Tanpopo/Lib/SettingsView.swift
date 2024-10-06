import SwiftUI
import AuthenticationServices


struct SettingsView : View {
    @StateObject private var viewModel = SignInViewModel()

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
                        Button(action : viewModel.signIn) {
                            Text("Login")
                        }
                    }
                }
            }
            
        }
    }
    
}




struct SettingsView_Previews : PreviewProvider {
    static var previews : some View {
       SettingsView()
   }
}
