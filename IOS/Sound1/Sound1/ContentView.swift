//
//  ContentView.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI

struct ContentView: View {
    // Estados principales
    @State private var volumeL: Double = 5.0
    @State private var volumeR: Double = 10.0
    @State private var bpm: Double = 120.0
    @State private var selectedPreset: Int = 2
    @State private var isMuted: Bool = false
    @State private var songPosition: Double = 0.3

    // Control de visibilidad del teclado numérico (Popover)
    @State private var mostrarTecladoPop: Bool = false

    // Lista simulada de canciones
    let songs = [
        "1. ALBUM M'LAM.WAV     3:45",
        "2. SONG TITLE.WAV      4:12",
        "3. KEEPING ROSIDODI.WAV 4:16",
        "4. DESTRORATION.WAV    4:12",
        "5. BONY STABERS.WAV    3:09",
        "6. THE WVIUM.WAV       3:35"
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo de Chasis Metálico (Llamado desde RetroModifiers.swift)
                ChasisMetalBackground()

                // Panel de Control Principal
                VStack {
                    Spacer(minLength: 20)

                    // --- PARTE SUPERIOR (Pantallas y Deslizadores) ---
                    HStack(alignment: .top, spacing: 30) {

                        // 1. PANTALLA CRT VERDE (Liquid Glass Ahumado)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "cellularbars")
                                Spacer()
                                Text("9:33 AM")
                                Spacer()
                                Image(systemName: "battery.75")
                            }
                            .font(.system(.caption, design: .monospaced))
                            .retroNeonStyle()
                            .padding(.bottom, 5)

                            Text("Directory of C:\\MUSIC")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .retroNeonStyle()
                            
                            Text("[DIR] ...")
                                .font(.system(.subheadline, design: .monospaced))
                                .retroNeonStyle()

                            ForEach(songs, id: \.self) { song in
                                Text(song)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .retroNeonStyle(color: song.contains("2.") ? Color.yellow : Color(red: 0.4, green: 0.8, blue: 0.2))
                            }

                            Spacer()
                            Text("C:\\MUSIC> _")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .retroNeonStyle()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(
                            ZStack {
                                Color(red: 0.03, green: 0.08, blue: 0.03)
                                Rectangle().fill(.ultraThinMaterial).opacity(0.2)
                            }
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .black.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 2, y: 4)

                        // 2. SECCIÓN CENTRAL (Master Mute y Volumen L/R)
                        VStack(spacing: 12) {
                            Text("MASTER MUTE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.8))

                            Toggle("", isOn: $isMuted)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .padding(.bottom, 5)

                            HStack(spacing: 40) {
                                // --- CONTROL IZQUIERDO (L) ---
                                VStack(spacing: 8) {
                                    Text("L")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))

                                    ZStack {
                                        Slider(value: $volumeL, in: -30...30)
                                            .accentColor(.green)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 140, height: 20)
                                            .disabled(isMuted)
                                    }
                                    .frame(width: 40, height: 140)

                                    Text("VOLUME L")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                }

                                // --- CONTROL DERECHO (R) ---
                                VStack(spacing: 8) {
                                    Text("R")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))

                                    ZStack {
                                        Slider(value: $volumeR, in: -30...30)
                                            .accentColor(.green)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 140, height: 20)
                                            .disabled(isMuted)
                                    }
                                    .frame(width: 40, height: 140)

                                    Text("VOLUME R")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                }
                            }
                            .foregroundColor(.black.opacity(0.85))
                        }
                        .frame(width: 220)
                        .padding(.top, 10)

                        // 3. PANTALLA DIGITAL METRÓNOMO (LCD)
                        VStack(spacing: 12) {
                            Text("METRONOME")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.85))

                            ZStack(alignment: .bottomTrailing) {
                                Color(red: 0.05, green: 0.1, blue: 0.05)

                                Text(String(format: "%.2f", bpm))
                                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                                    .retroNeonStyle(color: Color(red: 0.4, green: 0.95, blue: 0.3))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                                Text("BPM")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .retroNeonStyle(color: Color(red: 0.4, green: 0.95, blue: 0.3))
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 160)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .black.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: Color.green.opacity(0.15), radius: 12)

                            Text("MEMORY PRESET")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.7))

                            // Presets estilo Liquid Glass
                            HStack(spacing: 12) {
                                    ForEach(1...4, id: \.self) { num in
                                        BotonPresetPlastico(
                                            numero: num,
                                            isSelected: selectedPreset == num,
                                            action: { selectedPreset = num }
                                        )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // --- PARTE INFERIOR (Barra de Posición y Botones) ---
                    VStack(spacing: 15) {
                        VStack(spacing: 4) {
                            Text("SONG POSITION")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.8))
                            Slider(value: $songPosition)
                                .accentColor(.green)
                        }
                        .padding(.horizontal, 30)

                        HStack(spacing: 15) {
                            // Botones inferiores izquierdos (Llamados desde BotonesHardware.swift)
                            HStack(spacing: 10) {
                                BotonHardware(icon: "backward.end.fill", label: "PREV")
                                BotonHardware(icon: "backward.fill", label: "REW")
                                BotonHardware(icon: "gobackward", label: "RESTART")
                                BotonHardware(icon: "play.fill", label: "PLAY")
                                BotonHardware(icon: "forward.fill", label: "NEXT")
                            }

                            Spacer()

                            // Botones grandes de Stop, Play y Rejilla
                            HStack(alignment: .bottom, spacing: 15) {
                                BotonHardwareGrange(icon: "square.fill", label: "STOP")
                                BotonHardwareGrange(icon: "play.fill", label: "PLAY")

                                VStack(spacing: 4) {
                                    Button(action: {
                                        mostrarTecladoPop = true
                                    }) {
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
                                    .popover(
                                        isPresented: $mostrarTecladoPop,
                                        arrowEdge: .bottom
                                    ) {
                                        TecladoNumericoView(bpm: $bpm)
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
                    // Tornillos mecánicos (Llamados desde TornilloMetalico.swift o Tornillo.swift)
                    ZStack {
                        TornilloMetalico().position(x: 25, y: 25)
                        TornilloMetalico().position(x: geometry.size.width - 25, y: 25)
                        TornilloMetalico().position(x: 25, y: geometry.size.height - 25)
                        TornilloMetalico().position(
                            x: geometry.size.width - 25,
                            y: geometry.size.height - 25
                        )
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView().previewInterfaceOrientation(.landscapeLeft)
}
