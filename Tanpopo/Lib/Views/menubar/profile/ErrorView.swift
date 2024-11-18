//
//  ErrorView.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 15.11.24.
//


// ErrorView.swift
import SwiftUI

struct ErrorView: View {
    @ObservedObject var errorHandler = ErrorHandlingManager.shared

    var body: some View {
        ZStack {
            Color.systemColor.edgesIgnoringSafeArea(.all)
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

                        Text("Dismiss")
                                .font(.headline)
                                .padding()
                                .foregroundStyle(Color.systemColor)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        
    }
}
