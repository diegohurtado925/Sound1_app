//
//  ContentView.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var metronomo = MetronomeManager()
    @StateObject private var playlist = PlaylistQueueManager()
    
    @State private var mostrarImportadorArchivos: Bool = false
    @State private var volumeL: Double = 5.0
    @State private var volumeR: Double = 10.0
    @State private var isMuted: Bool = false
    @State private var mostrarTecladoPop: Bool = false
    
    // Estado para controlar cuando estás arrastrando el slider manualmente
    @State private var isEditingSlider: Bool = false
    @State private var sliderTempTime: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ChasisMetalBackground()

                VStack {
                    Spacer(minLength: 20)

                    HStack(alignment: .top, spacing: 30) {

                        // 1. PANTALLA CRT VERDE (Explorador / Playlist)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("C:\\MUSIC\\PLAYLIST")
                                Spacer()
                                Button(action: {
                                    mostrarImportadorArchivos = true
                                }) {
                                    Label("ADD FILE", systemImage: "doc.badge.plus")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color(red: 0.4, green: 0.8, blue: 0.2).opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                            .retroNeonStyle()
                            .padding(.bottom, 5)

                            if let actual = playlist.currentSong {
                                Text("> PLAYING: \(actual.name)")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .bold()
                                    .retroNeonStyle(color: .yellow)
                                    .padding(.bottom, 4)
                            } else {
                                Text("> PLAYLIST EMPTY. PRESS ADD FILE.")
                                    .font(.system(.caption, design: .monospaced))
                                    .retroNeonStyle(color: .gray)
                            }

                            Divider()
                                .background(Color(red: 0.4, green: 0.8, blue: 0.2))

                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(playlist.queue.enumerated()), id: \.element.id) { index, song in
                                        HStack {
                                            Text("\(index == playlist.currentIndex && playlist.currentSong != nil ? "►" : " ") \(index + 1). \(song.name)")
                                            Spacer()
                                            Text(song.durationFormatted)
                                        }
                                        .font(.system(.caption, design: .monospaced))
                                        .retroNeonStyle(color: index == playlist.currentIndex && playlist.currentSong != nil ? .yellow : Color(red: 0.4, green: 0.8, blue: 0.2))
                                        .onTapGesture {
                                            playlist.currentIndex = index
                                            playlist.cargarCancionActual()
                                        }
                                    }
                                }
                            }

                            Spacer()
                            Text("C:\\MUSIC> _")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .retroNeonStyle()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .background(Color(red: 0.03, green: 0.08, blue: 0.03))
                        .retroScreenFrame()
                        .fileImporter(
                            isPresented: $mostrarImportadorArchivos,
                            allowedContentTypes: [.audio, .wav, .mp3],
                            allowsMultipleSelection: true
                        ) { result in
                            switch result {
                            case .success(let urls):
                                for url in urls {
                                    playlist.agregarACola(url: url)
                                }
                            case .failure(let error):
                                print("Error seleccionando archivo: \(error.localizedDescription)")
                            }
                        }

                        // 2. CONTROLES DE VOLUMEN MASTER
                        VStack(spacing: 12) {
                            Text("MASTER MUTE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.8))

                            Toggle("", isOn: $isMuted)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .red))
                                .padding(.bottom, 5)

                            HStack(spacing: 40) {
                                VStack(spacing: 8) {
                                    Text("L").font(.system(size: 14, weight: .bold, design: .monospaced))
                                    ZStack {
                                        Slider(value: $volumeL, in: -30...30)
                                            .accentColor(.green)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 140, height: 20)
                                            .disabled(isMuted)
                                    }
                                    .frame(width: 40, height: 140)
                                    Text("VOLUME L").font(.system(size: 10, weight: .bold, design: .monospaced))
                                }

                                VStack(spacing: 8) {
                                    Text("R").font(.system(size: 14, weight: .bold, design: .monospaced))
                                    ZStack {
                                        Slider(value: $volumeR, in: -30...30)
                                            .accentColor(.green)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 140, height: 20)
                                            .disabled(isMuted)
                                    }
                                    .frame(width: 40, height: 140)
                                    Text("VOLUME R").font(.system(size: 10, weight: .bold, design: .monospaced))
                                }
                            }
                            .foregroundColor(.black.opacity(0.85))
                        }
                        .frame(width: 220)
                        .padding(.top, 10)

                        // 3. PANTALLA LCD METRÓNOMO
                        VStack(spacing: 8) {
                            Text("METRONOME")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.85))

                            ZStack {
                                Color(red: 0.05, green: 0.1, blue: 0.05)

                                VStack {
                                    HStack {
                                        Circle()
                                            .fill(metronomo.isTickVisualActive ? Color.red : Color.red.opacity(0.2))
                                            .frame(width: 12, height: 12)
                                            .shadow(color: metronomo.isTickVisualActive ? .red : .clear, radius: 6)

                                        Spacer()

                                        Text("PRESET [P\(metronomo.selectedPreset)]")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .retroNeonStyle(color: Color(red: 0.4, green: 0.95, blue: 0.3))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.top, 10)

                                    Spacer()
                                }

                                Text(String(format: "%.2f", metronomo.bpm))
                                    .font(.system(size: 52, weight: .bold, design: .monospaced))
                                    .retroNeonStyle(color: Color(red: 0.4, green: 0.95, blue: 0.3))
                                    .frame(maxWidth: .infinity, alignment: .center)

                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("BPM")
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                            .retroNeonStyle(color: Color(red: 0.4, green: 0.95, blue: 0.3))
                                            .padding(8)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .retroScreenFrame(outerRadius: 10, innerRadius: 6)

                            Text("MEMORY PRESET")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.7))

                            HStack(spacing: 12) {
                                ForEach(1...4, id: \.self) { num in
                                    BotonPresetPlastico(
                                        numero: num,
                                        bpmValue: metronomo.presetValues[num],
                                        isSelected: metronomo.selectedPreset == num,
                                        onSelect: { metronomo.seleccionarPreset(num) },
                                        onSave: { metronomo.guardarPresetActual(en: num) }
                                    )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // --- PARTE INFERIOR ---
                    VStack(spacing: 15) {
                        VStack(spacing: 4) {
                            Text("SONG POSITION")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.8))
                            
                            // 🎚️ BARRA INTERACTIVA CON BÚSQUEDA DIRECTA (SEEK)
                            Slider(
                                value: Binding(
                                    get: { isEditingSlider ? sliderTempTime : playlist.currentTime },
                                    set: { newValue in sliderTempTime = newValue }
                                ),
                                in: 0...(playlist.duration > 0 ? playlist.duration : 1.0),
                                onEditingChanged: { editing in
                                    isEditingSlider = editing
                                    if !editing {
                                        // Al soltar el Slider, cambia la posición del audio
                                        playlist.buscarTiempo(sliderTempTime)
                                    }
                                }
                            )
                            .accentColor(.green)
                        }
                        .padding(.horizontal, 30)

                        HStack(spacing: 15) {
                            // 🎛️ BOTONES DE TRANSPORTE CONECTADOS DIRECTAMENTE CON ACCIONES
                            HStack(spacing: 10) {
                                BotonHardware(icon: "backward.end.fill", label: "PREV", action: {
                                    playlist.anteriorCancion()
                                })
                                
                                BotonHardware(icon: "stop.fill", label: "STOP", action: {
                                    playlist.detener()
                                })
                                
                                BotonHardware(icon: "gobackward", label: "RESTART", action: {
                                    playlist.reiniciarCancion()
                                })
                                
                                BotonHardware(
                                    icon: playlist.isPlaying ? "pause.fill" : "play.fill",
                                    label: "PLAY",
                                    action: { playlist.playPause() }
                                )
                                
                                BotonHardware(icon: "forward.fill", label: "NEXT", action: {
                                    playlist.siguienteCancion()
                                })
                            }

                            Spacer()

                            // BOTONES DEL METRÓNOMO
                            HStack(alignment: .bottom, spacing: 15) {
                                Button(action: { metronomo.stop() }) {
                                    BotonHardwareGrange(icon: "square.fill", label: "STOP", isActive: !metronomo.isPlaying)
                                }
                                
                                Button(action: { metronomo.toggle() }) {
                                    BotonHardwareGrange(icon: "play.fill", label: "PLAY", isActive: metronomo.isPlaying)
                                }

                                VStack(spacing: 4) {
                                    Button(action: { mostrarTecladoPop = true }) {
                                        Image(systemName: "square.grid.3x3.fill")
                                            .font(.title3)
                                            .foregroundColor(.black.opacity(0.7))
                                            .frame(width: 60, height: 50)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        LinearGradient(colors: [.white.opacity(0.6), .black.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                        lineWidth: 1.5
                                                    )
                                            )
                                            .shadow(color: .black.opacity(0.25), radius: 3, x: 1, y: 2)
                                    }
                                    .popover(isPresented: $mostrarTecladoPop, arrowEdge: .bottom) {
                                        TecladoNumericoView(bpm: $metronomo.bpm)
                                            .frame(width: 280, height: 460)
                                    }

                                    Text(" ")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    ZStack {
                        TornilloMetalico().position(x: 25, y: 25)
                        TornilloMetalico().position(x: geometry.size.width - 25, y: 25)
                        TornilloMetalico().position(x: 25, y: geometry.size.height - 25)
                        TornilloMetalico().position(x: geometry.size.width - 25, y: geometry.size.height - 25)
                    }
                )
            }
        }
    }
}
