// ErrorView.swift
import SwiftUI

struct ErrorView: View {
    @ObservedObject var errorHandler = ErrorHandlingManager.shared

    var body: some View {
        VStack {
            if let errorMessage = errorHandler.errorMessage {
                VStack {
                    Text("Error Occurred")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding()

                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 20)

                    Button(action: {
                        errorHandler.clearError()
                    }) {
                        Text("Dismiss")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}