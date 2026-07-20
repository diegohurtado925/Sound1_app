//
//  ContentView.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI

struct ContentView: View {
    // Estados para simular interactividad básica
    @State private var volumeL: Double = 5.0
    @State private var volumeR: Double = 10.0
    @State private var bpm: Double = 120.0
    @State private var selectedPreset: Int = 2
    @State private var isMuted: Bool = false
    @State private var songPosition: Double = 0.3

    // Control de visibilidad del teclado numérico
    @State private var mostrarTecladoPop: Bool = false

    // Lista simulada de canciones
    let songs = [
        "1. ALBUM M'LAM.WAV     3:45",
        "2. SONG TITLE.WAV      4:12",
        "3. KEEPING ROSIDODI.WAV 4:16",
        "4. DESTRORATION.WAV    4:12",
        "5. BONY STABERS.WAV    3:09",
        "6. THE WVIUM.WAV       3:35",
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo general del chasis retro que ocupa toda la pantalla
                Color(red: 0.92, green: 0.89, blue: 0.84)
                    .ignoresSafeArea()

                // Panel de Control Principal distribuido
                VStack {
                    Spacer(minLength: 20)

                    // --- PARTE SUPERIOR (Pantallas y Deslizadores) ---
                    HStack(alignment: .top, spacing: 30) {

                        // 1. PANTALLA CRT VERDE (Explorador de Archivos)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "cellularbars")
                                Spacer()
                                Text("9:33 AM")
                                Spacer()
                                Image(systemName: "battery.75")
                            }
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(
                                Color(red: 0.4, green: 0.8, blue: 0.2)
                            )
                            .padding(.bottom, 5)

                            Text("Directory of C:\\MUSIC")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                            Text("[DIR] ...")

                            ForEach(songs, id: \.self) { song in
                                Text(song)
                                    .font(
                                        .system(
                                            .subheadline,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(
                                        song.contains("2.")
                                            ? .yellow
                                            : Color(
                                                red: 0.4,
                                                green: 0.8,
                                                blue: 0.2
                                            )
                                    )
                            }

                            Spacer()
                            Text("C:\\MUSIC> _")
                                .font(.system(.body, design: .monospaced))
                        }
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.2))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(Color(red: 0.05, green: 0.12, blue: 0.05))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 4)
                        )

                        // 2. SECCIÓN CENTRAL (Master Mute y Volumen L/R)
                        VStack(spacing: 12) {
                            Text("MASTER MUTE")
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .bold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(.black)

                            Toggle("", isOn: $isMuted)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .padding(.bottom, 5)

                            HStack(spacing: 40) {
                                // --- CONTROL IZQUIERDO (L) ---
                                VStack(spacing: 8) {
                                    Text("L")
                                        .font(
                                            .system(
                                                size: 14,
                                                weight: .bold,
                                                design: .monospaced
                                            )
                                        )
                                        .foregroundColor(.black)

                                    ZStack {
                                        Slider(value: $volumeL, in: -30...30)
                                            .accentColor(.green)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 140, height: 20)
                                            .disabled(isMuted)
                                    }
                                    .frame(width: 40, height: 140)

                                    Text("VOLUME L")
                                        .font(
                                            .system(
                                                size: 10,
                                                weight: .bold,
                                                design: .monospaced
                                            )
                                        )
                                        .foregroundColor(.black)
                                }

                                // --- CONTROL DERECHO (R) ---
                                VStack(spacing: 8) {
                                    Text("R")
                                        .font(
                                            .system(
                                                size: 14,
                                                weight: .bold,
                                                design: .monospaced
                                            )
                                        )
                                        .foregroundColor(.black)

                                    ZStack {
                                        Slider(value: $volumeR, in: -30...30)
                                            .accentColor(.green)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 140, height: 20)
                                            .disabled(isMuted)
                                    }
                                    .frame(width: 40, height: 140)

                                    Text("VOLUME R")
                                        .font(
                                            .system(
                                                size: 10,
                                                weight: .bold,
                                                design: .monospaced
                                            )
                                        )
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .frame(width: 220)
                        .padding(.top, 10)

                        // 3. PANTALLA DIGITAL METRÓNOMO (LCD)
                        VStack(spacing: 12) {
                            Text("METRONOME")
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .bold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(.black)

                            ZStack(alignment: .bottomTrailing) {
                                Color(red: 0.1, green: 0.15, blue: 0.1)

                                Text(String(format: "%.2f", bpm))
                                    .font(
                                        .system(
                                            size: 60,
                                            weight: .bold,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(
                                        Color(red: 0.5, green: 0.9, blue: 0.3)
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: .infinity,
                                        alignment: .center
                                    )
                                    .shadow(
                                        color: Color(
                                            red: 0.5,
                                            green: 0.9,
                                            blue: 0.3
                                        ).opacity(0.5),
                                        radius: 5
                                    )

                                Text("BPM")
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .bold,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(
                                        Color(red: 0.5, green: 0.9, blue: 0.3)
                                    )
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 160)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        Color(red: 0.4, green: 0.4, blue: 0.4),
                                        lineWidth: 4
                                    )
                            )

                            Text("MEMORY PRESET")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                ForEach(1...4, id: \.self) { num in
                                    Button(action: { selectedPreset = num }) {
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(
                                                    selectedPreset == num
                                                        ? Color.orange
                                                        : Color.gray.opacity(
                                                            0.4
                                                        )
                                                )
                                                .frame(width: 8, height: 8)
                                                .shadow(
                                                    color: selectedPreset == num
                                                        ? .orange : .clear,
                                                    radius: 3
                                                )
                                            Text("\(num)")
                                                .font(
                                                    .system(
                                                        size: 20,
                                                        weight: .bold,
                                                        design: .monospaced
                                                    )
                                                )
                                                .foregroundColor(
                                                    .black.opacity(0.85)
                                                )
                                        }
                                        .frame(
                                            maxWidth: 90,
                                            maxHeight: 58,
                                            alignment: .init(
                                                horizontal: .center,
                                                vertical: .center
                                            )
                                        )  // Incrementada la altura a 58pt
                                        .background(
                                            Color(
                                                red: 0.80,
                                                green: 0.78,
                                                blue: 0.74
                                            )
                                        )
                                        .cornerRadius(8)
                                        .shadow(
                                            color: .black.opacity(0.3),
                                            radius: 3,
                                            x: 1,
                                            y: 2
                                        )
                                    }
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
                                .font(
                                    .system(
                                        size: 11,
                                        weight: .semibold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(.black)
                            Slider(value: $songPosition)
                                .accentColor(.green)
                        }
                        .padding(.horizontal, 30)

                        HStack(spacing: 15) {
                            // Botones inferiores izquierdos
                            HStack(spacing: 10) {
                                BotonHardware(
                                    icon: "backward.end.fill",
                                    label: "PREV"
                                )
                                BotonHardware(
                                    icon: "backward.fill",
                                    label: "REW"
                                )
                                BotonHardware(
                                    icon: "gobackward",
                                    label: "RESTART"
                                )
                                BotonHardware(icon: "play.fill", label: "PLAY")
                                BotonHardware(
                                    icon: "forward.fill",
                                    label: "NEXT"
                                )
                            }

                            Spacer()

                            // Botones grandes de Stop, Play y Rejilla
                            HStack(alignment: .bottom, spacing: 15) {
                                BotonHardwareGrange(
                                    icon: "square.fill",
                                    label: "STOP"
                                )
                                BotonHardwareGrange(
                                    icon: "play.fill",
                                    label: "PLAY"
                                )

                                VStack(spacing: 4) {
                                    Button(action: {
                                        mostrarTecladoPop = true
                                    }) {
                                        Image(
                                            systemName: "square.grid.3x3.fill"
                                        )
                                        .font(.title3)
                                        .foregroundColor(.black.opacity(0.7))
                                        .frame(width: 60, height: 50)
                                        .background(
                                            Color(
                                                red: 0.75,
                                                green: 0.73,
                                                blue: 0.68
                                            )
                                        )
                                        .cornerRadius(8)
                                        .shadow(
                                            color: .black.opacity(0.3),
                                            radius: 2,
                                            x: 1,
                                            y: 2
                                        )
                                    }
                                    .popover(
                                        isPresented: $mostrarTecladoPop,
                                        arrowEdge: .bottom
                                    ) {
                                        TecladoNumericoView(bpm: $bpm)
                                            .frame(width: 280, height: 460)
                                    }

                                    Text(" ")
                                        .font(
                                            .system(
                                                size: 11,
                                                weight: .bold,
                                                design: .monospaced
                                            )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    // Tornillos fijados a las esquinas del iPad
                    ZStack {
                        Tornillo().position(x: 25, y: 25)
                        Tornillo().position(x: geometry.size.width - 25, y: 25)
                        Tornillo().position(x: 25, y: geometry.size.height - 25)
                        Tornillo().position(
                            x: geometry.size.width - 25,
                            y: geometry.size.height - 25
                        )
                    }
                )
            }
        }
    }
}

struct BotonHardware: View {
    var icon: String
    var label: String
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                Image(systemName: icon).font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black.opacity(0.7)).frame(
                        width: 70,
                        height: 45
                    )
                    .background(Color(red: 0.78, green: 0.76, blue: 0.72))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 2)
            }
            Text(label).font(
                .system(size: 10, weight: .bold, design: .monospaced)
            ).foregroundColor(.black)
        }
    }
}

struct BotonHardwareGrange: View {
    var icon: String
    var label: String
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                Image(systemName: icon).font(.title3)
                    .foregroundColor(.black.opacity(0.7)).frame(
                        width: 90,
                        height: 50
                    )
                    .background(Color(red: 0.78, green: 0.76, blue: 0.72))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 2)
            }
            Text(label).font(
                .system(size: 11, weight: .bold, design: .monospaced)
            ).foregroundColor(.black)
        }
    }
}

struct Tornillo: View {
    var body: some View {
        Circle().fill(Color.gray).frame(width: 14, height: 14)
            .overlay(
                Rectangle().fill(Color(red: 0.2, green: 0.2, blue: 0.2)).frame(
                    width: 9,
                    height: 2
                ).rotationEffect(.degrees(45))
            )
    }
}

#Preview {
    ContentView().previewInterfaceOrientation(.landscapeLeft)
}
