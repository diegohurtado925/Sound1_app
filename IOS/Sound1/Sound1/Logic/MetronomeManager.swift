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
    @Published var isTickVisualActive: Bool = false
    
    // Estado de memoria de presets
    @Published var selectedPreset: Int = 2
    @Published var presetValues: [Int: Double] = [
        1: 80.0,
        2: 120.0,
        3: 140.0,
        4: 165.0
    ]
    
    @Published var volume: Float = 1.0
    @Published var isMuted: Bool = false {
        didSet { actualizarVolumen() }
    }

    func actualizarVolumen(sliderValue: Double? = nil, isMuted: Bool? = nil) {
        if let isMuted = isMuted {
            self.isMuted = isMuted
        }
        
        if let sliderValue = sliderValue {
            // Mapeo del Slider (-30 a +30) a (0.0 a 1.0)
            let volumenNormalizado = Float(max(0, (sliderValue + 30) / 60.0))
            self.volume = volumenNormalizado
        }
        
        let volumenFinal = self.isMuted ? 0.0 : self.volume
        playerNode.volume = volumenFinal
    }
    
    private var timer: Timer?
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    private var bufferClick: AVAudioPCMBuffer?
    
    init() {
        configurarAudioEngine()
        generarSonidoClick()
    }
    
    // --- MÉTODOS DE MEMORIA PRESET ---
    func seleccionarPreset(_ numero: Int) {
        selectedPreset = numero
        if let valorGuardado = presetValues[numero] {
            self.bpm = valorGuardado
        }
    }
    
    func guardarPresetActual(en numero: Int) {
        selectedPreset = numero
        presetValues[numero] = self.bpm
    }
    
    // --- CONFIGURACIÓN DE AUDIO ESTÉRIL / CANAL DERECHO ---
    private func configurarAudioEngine() {
        audioEngine.attach(playerNode)
        let mainMixer = audioEngine.mainMixerNode
        
        // 1. Formato estéreo explícito (2 canales)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else { return }
        
        // 2. Conectamos el nodo forzando formato de 2 canales
        audioEngine.connect(playerNode, to: mainMixer, format: format)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error al iniciar AVAudioEngine: \(error)")
        }
    }
    
    private func generarSonidoClick() {
        let sampleRate = 44100.0
        let duration = 0.03
        let numSamples = Int(sampleRate * duration)
        
        // 3. Formato ESTÉREO (2 Canales) para coincidir exactamente con la conexión del nodo
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples)) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numSamples)
        
        let leftChannel = buffer.floatChannelData![0]  // Canal 0 = Izquierda
        let rightChannel = buffer.floatChannelData![1] // Canal 1 = Derecha
        
        for i in 0..<numSamples {
            let time = Double(i) / sampleRate
            let frequency = 1200.0
            let decay = exp(-time * 150.0)
            let sample = Float(sin(2.0 * .pi * frequency * time) * decay * 0.7)
            
            // 🎧 RUTEADO DE AUDIO EXCLUSIVO:
            leftChannel[i] = 0.0        // Izquierda completamente en silencio
            rightChannel[i] = sample    // Derecha reproduce el click
        }
        
        self.bufferClick = buffer
    }
    
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
        playerNode.stop()
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
        guard isPlaying, let buffer = bufferClick else { return }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        if !playerNode.isPlaying {
            playerNode.play()
        }
        
        DispatchQueue.main.async {
            self.isTickVisualActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.isTickVisualActive = false
            }
        }
    }
}
