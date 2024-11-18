import SwiftUI
import AVKit

struct EpisodePlayerView: View {
    let videoURL: URL

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .ignoresSafeArea()
            .onAppear {
                setLandscapeOrientation()
            }
            .onDisappear {
                resetOrientation()
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
    }

    /// Forces the device into landscape orientation
    private func setLandscapeOrientation() {
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }

    /// Resets the orientation to allow all directions
    private func resetOrientation() {
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
    }
}