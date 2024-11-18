struct SplashScreenView: View {
    @Binding var isActive: Bool

    var body: some View {
        VStack {
            Image("splashLogo") // Replace with your splash screen image
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // Adjust as needed
            
            Text("Welcome to Tanpopo")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SplashBackground")) // Optional: Replace with your custom color
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}