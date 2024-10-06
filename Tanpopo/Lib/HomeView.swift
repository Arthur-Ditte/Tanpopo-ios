import SwiftUI

struct HomeView: View {
    @State private var selectedSite = "Currently Watching"
    let sites = ["Currently Watching", "Planned to Watch", "Dropped", "Finished"]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)

            VStack {
                GeometryReader { geometry in
                    HStack {
                        Menu {
                            ForEach(sites, id: \.self) { site in
                                Button(action: {
                                    selectedSite = site
                                }) {
                                    Text(site)
                                }
                            }
                        } label: {
                            Label {
                                Text(selectedSite)
                                    .font(.system(size: 25, weight: .heavy))
                                    .lineLimit(1)
                                    .frame(width: geometry.size.width * 0.75, alignment: .leading) // 3/4 width
                                    .layoutPriority(1)
                            } icon: {
                                Image(systemName: "chevron.down")
                            }
                            .padding(8)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding([.leading, .top], 16)

                    }
                }
                .frame(height: 50) // Fixed height for the menu area

                // Display the selected view
                selectedView()
            }
        }
    }

    @ViewBuilder
    private func selectedView() -> some View {
        switch selectedSite {
        case "Currently Watching":
            CurrentlyWatching()
        case "Planned to Watch":
            PlannedToWatch()
        case "Dropped":
            Dropped()
        case "Finished":
            Finished()
        default:
            CurrentlyWatching() // Default view
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
