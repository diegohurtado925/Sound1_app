import SwiftUI

// Botón de Plástico Rígido Estándar (PREV, REW, PLAY, NEXT)
struct BotonHardware: View {
    var icon: String
    var label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: {}) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black.opacity(0.75))
                    .frame(width: 68, height: 46)
                    // Color de plástico beige/gris mate
                    .background(Color(red: 0.82, green: 0.80, blue: 0.76))
                    .cornerRadius(8)
                    // Bisel superior claro y sombra inferior oscura (Relieve 3D)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .black.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 3, x: 2, y: 3)
            }
            
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.black.opacity(0.85))
        }
    }
}

// Botón Grande de Plástico Rígido (STOP, PLAY)
struct BotonHardwareGrange: View {
    var icon: String
    var label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: {}) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.black.opacity(0.75))
                    .frame(width: 88, height: 52)
                    .background(Color(red: 0.82, green: 0.80, blue: 0.76))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .black.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 3, x: 2, y: 3)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.black.opacity(0.85))
        }
    }
}

// Botón de Presets (1, 2, 3, 4) en Plástico Baquelita con LED Físico
struct BotonPresetPlastico: View {
    var numero: Int
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            
            Button(action: action) {
                ZStack {
                    // BASE/MARCO EXTERIOR (Marco oscuro o marco iluminado cuando se activa)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            isSelected ? Color(red: 0.85, green: 0.15, blue: 0.15) : Color(red: 0.25, green: 0.23, blue: 0.22)
                        )
                        .shadow(color: isSelected ? Color.red.opacity(0.8) : .black.opacity(0.4), radius: isSelected ? 8 : 2, x: 0, y: 2)
                    
                    // TECLA INTERNA (Blanca semitraslúcida / Retroiluminada)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            isSelected
                            ? Color(red: 1.0, green: 0.95, blue: 0.8) // Brillo incandescente cálido
                            : Color(red: 0.88, green: 0.86, blue: 0.82) // Plástico mate apagado
                        )
                        .padding(4) // Crea el espacio del marco exterior
                        // Bisel interno 3D
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            isSelected ? .white : .white.opacity(0.8),
                                            .black.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .padding(4)
                        )
                    
                    // Número en la tecla
                    Text("\(numero)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(isSelected ? Color.red.opacity(0.9) : .black.opacity(0.75))
                        .shadow(color: isSelected ? .orange.opacity(0.5) : .clear, radius: 2)
                }
                .frame(width: 58, height: 48)
            }
            
            // Etiqueta inferior en el panel

        }
    }
}

