//
//  ContentView.swift
//  Random Chooser
//
//  Created by Mark Nair on 10/31/24.
//

import SwiftUI
import AVFoundation

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

class SoundManager {
    static let shared = SoundManager()
    
    var spinningSound: AVAudioPlayer?
    var winSound: AVAudioPlayer?
    
    init() {
        // Initialize sound players
        if let spinningPath = Bundle.main.path(forResource: "spinning", ofType: "mp3") {
            spinningSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: spinningPath))
            spinningSound?.numberOfLoops = -1  // Loop indefinitely
        }
        
        if let winPath = Bundle.main.path(forResource: "win", ofType: "mp3") {
            winSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: winPath))
        }
    }
    
    func playSpinningSound() {
        spinningSound?.play()
    }
    
    func stopSpinningSound() {
        spinningSound?.stop()
        spinningSound?.currentTime = 0
    }
    
    func playWinSound() {
        winSound?.play()
    }
}

struct ContentView: View {
    // Sample data
    let people = [
        Person(name: "Max", imageName: "Max"),
               Person(name: "Jameson", imageName: "Jameson"),
               Person(name: "Gabe", imageName: "Gabe"),
               Person(name: "Chaden", imageName: "Chaden"),
    ]
    
    @State private var selectedPerson: Person?
    @State private var isSpinning = false
    @State private var currentIndex = 0
    @State private var spinTimer: Timer?
    @State private var spinCount = 0
    
    // Animation properties
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            // Display area
            VStack {
                if let person = selectedPerson ?? people.first {
                    Image(person.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .scaleEffect(scale)
                        .animation(.spring(), value: scale)
                    
                    Text(person.name)
                        .font(.title)
                        .bold()
                        .padding(.top, 10)
                }
            }
            .frame(height: 250)
            
            // Spin button
            Button(action: {
                startSpinning()
            }) {
                Text(isSpinning ? "Spinning..." : "Spin!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(isSpinning ? Color.gray : Color.blue)
                    .cornerRadius(25)
            }
            .disabled(isSpinning)
        }
        .padding()
    }
    
    private func startSpinning() {
        isSpinning = true
        spinCount = 0
        
        // Start spinning sound
        SoundManager.shared.playSpinningSound()
        
        // Initialize timer to update display
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // Update current display
            currentIndex = (currentIndex + 1) % people.count
            selectedPerson = people[currentIndex]
            
            // Add subtle scale animation during spinning
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 0.95
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    scale = 1.0
                }
            }
            
            // Count frames and slow down/stop after 3 complete cycles
            if currentIndex == people.count - 1 {
                spinCount += 1
                
                if spinCount >= 3 {
                    stopSpinning()
                }
            }
        }
    }
    
    private func stopSpinning() {
        spinTimer?.invalidate()
        spinTimer = nil
        isSpinning = false
        
        // Stop spinning sound
        SoundManager.shared.stopSpinningSound()
        
        // Select final random person
        selectedPerson = people.randomElement()
        
        // Play win sound and animate final selection
        SoundManager.shared.playWinSound()
        
        // Victory animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
    }
}






#Preview {
    ContentView()
}
