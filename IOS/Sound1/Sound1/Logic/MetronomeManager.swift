//
//  MetronomeManager.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import Foundation
import AVFoundation
import Combine

class MetronomeManager: ObservableObject {
    @Published var bpm: Double = 120.0 {
        didSet {
            if isPlaying {
                reiniciarTimer()
            }
        }
    }
    
    @Published var isPlaying: Bool = false
    @Published var isTickVisualActive: Bool = false // Para el destello del LED visual en pantalla
    
    private var timer: Timer?
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    private var bufferClick: AVAudioPCMBuffer?
    
    init() {
        configurarAudioEngine()
        generarSonidoClick()
    }
    
    // --- 1. CONFIGURACIÓN DE AUDIO ENGINE ---
    private func configurarAudioEngine() {
        audioEngine.attach(playerNode)
        let mainMixer = audioEngine.mainMixerNode
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
        audioEngine.connect(playerNode, to: mainMixer, format: format)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error al iniciar AVAudioEngine: \(error)")
        }
    }
    
    // --- 2. GENERACIÓN DEL SONIDO SINTÉTICO (CLICK RETRO) ---
    private func generarSonidoClick() {
        let sampleRate = 44100.0
        let duration = 0.03 // 30 milisegundos de pulso percusivo
        let numSamples = Int(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples)) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numSamples)
        let channels = buffer.floatChannelData![0]
        
        // Genera una onda senoidal corta de 1000 Hz con caída exponencial
        for i in 0..<numSamples {
            let time = Double(i) / sampleRate
            let frequency = 1200.0
            let decay = exp(-time * 150.0) // Envolvente de decaimiento percusivo
            channels[i] = Float(sin(2.0 * .pi * frequency * time) * decay * 0.7)
        }
        
        self.bufferClick = buffer
    }
    
    // --- 3. CONTROLES DE REPRODUCCIÓN ---
    func toggle() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        guard !isPlaying else { return }
        if !audioEngine.isRunning {
            try? audioEngine.start()
        }
        isPlaying = true
        ejecutarTick()
        reiniciarTimer()
    }
    
    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        isTickVisualActive = false
    }
    
    private func reiniciarTimer() {
        timer?.invalidate()
        let interval = 60.0 / bpm
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.ejecutarTick()
        }
    }
    
    private func ejecutarTick() {
        // Reproducir sonido
        if let buffer = bufferClick {
            playerNode.play()
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        }
        
        // Feedback Visual
        DispatchQueue.main.async {
            self.isTickVisualActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.isTickVisualActive = false
            }
        }
    }
}
