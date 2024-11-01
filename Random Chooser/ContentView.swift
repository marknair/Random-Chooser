//
//  ContentView.swift
//  Random Chooser
//
//  Created by Mark Nair on 10/31/24.
//

import SwiftUI
import AVFoundation

// MARK: - Person Model

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

// MARK: - SoundManager

class SoundManager {
    static let shared = SoundManager()
    
    private var spinningSound: AVAudioPlayer?
    private var winSound: AVAudioPlayer?
    
    private func loadSound(named name: String, type: String) -> AVAudioPlayer? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            return try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        }
        return nil
    }
    
    func playSpinningSound() {
        if spinningSound == nil {
            spinningSound = loadSound(named: "spinning", type: "mp3")
            spinningSound?.numberOfLoops = -1
        }
        spinningSound?.play()
    }
    
    func stopSpinningSound() {
        spinningSound?.stop()
        spinningSound?.currentTime = 0
    }
    
    func playWinSound() {
        if winSound == nil {
            winSound = loadSound(named: "win", type: "mp3")
        }
        winSound?.play()
    }
}

// MARK: - ContentView

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
                Text(isSpinning ? "Thinking..." : "Choose")
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
    
    // MARK: - Start Spinning
    
    private func startSpinning() {
        isSpinning = true
        spinCount = 0
        SoundManager.shared.playSpinningSound()
        
        // Start spinning with a scale animation and timer
        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
            scale = 0.95
        }
        
        // Initialize timer for updating display
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            currentIndex = (currentIndex + 1) % people.count
            selectedPerson = people[currentIndex]
            
            if currentIndex == people.count - 1 {
                spinCount += 1
                if spinCount >= 3 {
                    stopSpinning()
                }
            }
        }
    }
    
    // MARK: - Stop Spinning
    
    private func stopSpinning() {
        spinTimer?.invalidate()
        spinTimer = nil
        isSpinning = false
        
        // Stop spinning sound
        SoundManager.shared.stopSpinningSound()
        
        // Choose a random final person who is different from the current `selectedPerson`
        var newPerson: Person
        repeat {
            newPerson = people.randomElement()!
        } while newPerson.id == selectedPerson?.id
        
        selectedPerson = newPerson
        
        // Play win sound and victory animation
        SoundManager.shared.playWinSound()
        
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
