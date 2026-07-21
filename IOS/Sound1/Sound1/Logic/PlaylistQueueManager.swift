//
//  PlaylistQueueManager.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class PlaylistQueueManager: ObservableObject {
    @Published var queue: [SongModel] = []
    @Published var currentIndex: Int = 0 // Control del índice activo sin borrar elementos
    @Published var currentSong: SongModel?
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    // --- 1. AGREGAR A LA LISTA ---
    func agregarACola(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let nombre = url.deletingPathExtension().lastPathComponent.uppercased()
        let extensionArchivo = url.pathExtension.uppercased()
        let nombreCompleto = "\(nombre).\(extensionArchivo)"
        
        var duracionFormateada = "--:--"
        if let player = try? AVAudioPlayer(contentsOf: url) {
            let minutos = Int(player.duration) / 60
            let segundos = Int(player.duration) % 60
            duracionFormateada = String(format: "%d:%02d", minutos, segundos)
        }
        
        let nuevaCancion = SongModel(
            name: nombreCompleto,
            url: url,
            durationFormatted: duracionFormateada
        )
        
        DispatchQueue.main.async {
            self.queue.append(nuevaCancion)
            
            // Si es la primera canción cargada, se selecciona sin borrar
            if self.currentSong == nil {
                self.currentIndex = 0
                self.cargarCancionActual()
            }
        }
    }
    
    // --- 2. CONTROLES DE NAVEGACIÓN Y REPRODUCCIÓN ---
    func cargarCancionActual() {
        detener()
        guard !queue.isEmpty, queue.indices.contains(currentIndex) else {
            currentSong = nil
            return
        }
        
        let cancion = queue[currentIndex]
        currentSong = cancion
        iniciarReproduccion(url: cancion.url)
    }
    
    func siguienteCancion() {
        guard !queue.isEmpty else { return }
        if currentIndex + 1 < queue.count {
            currentIndex += 1
        } else {
            currentIndex = 0 // Vuelve al inicio si llega al final
        }
        cargarCancionActual()
    }
    
    func anteriorCancion() {
        guard !queue.isEmpty else { return }
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = queue.count - 1
        }
        cargarCancionActual()
    }
    
    func reiniciarCancion() {
        guard let player = audioPlayer else { return }
        player.currentTime = 0
        currentTime = 0
        if !player.isPlaying {
            player.play()
            isPlaying = true
        }
    }
    
    func playPause() {
        guard let player = audioPlayer else {
            if currentSong != nil {
                cargarCancionActual()
            }
            return
        }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func detener() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0.0
        timer?.invalidate()
        timer = nil
    }

    func buscarTiempo(_ tiempo: Double) {
        guard let player = audioPlayer else { return }
        player.currentTime = tiempo
        self.currentTime = tiempo
    }
    
    // --- 3. REPRODUCCIÓN DE AUDIO (Canal Izquierdo) ---
    private func iniciarReproduccion(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            // 🎧 Panorámica al canal IZQUIERDO (-1.0) para la pista de audio
            audioPlayer?.pan = -1.0
            
            duration = audioPlayer?.duration ?? 0.0
            audioPlayer?.play()
            isPlaying = true
            
            iniciarTimerProgreso()
        } catch {
            print("Error al reproducir audio: \(error.localizedDescription)")
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    private func iniciarTimerProgreso() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
            
            // Avance automático a la siguiente canción al finalizar
            if !player.isPlaying && self.isPlaying {
                self.siguienteCancion()
            }
        }
    }
}
