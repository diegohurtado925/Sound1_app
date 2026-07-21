import SwiftUI

// Botón de Plástico Rígido Estándar (PREV, REW, PLAY, NEXT)
struct BotonHardware: View {
    var icon: String
    var label: String
    var action: () -> Void = {} // 👈 Agregamos el closure de acción
    
    var body: some View {
        VStack(spacing: 3) {
            Button(action: action) { // 👈 Conectamos la acción aquí
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 2)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.92, green: 0.90, blue: 0.86))
                        .padding(3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white, .black.opacity(0.4)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.2
                                )
                                .padding(3)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                }
                .frame(width: 60, height: 42)
            }
            
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.black.opacity(0.85))
        }
    }
}

// Botón Grande de Plástico Rígido (STOP, PLAY)
struct BotonHardwareGrange: View {
    var icon: String
    var label: String
    var isActive: Bool = false // 👈 Asegúrate de que esta línea exista
    
    var body: some View {
        VStack(spacing: 3) {
            Text("COMMAND")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.black.opacity(0.7))
            
            ZStack {
                // Marco con luz roja si está activo
                RoundedRectangle(cornerRadius: 5)
                    .fill(isActive ? Color.red : Color(red: 0.2, green: 0.2, blue: 0.2))
                    .shadow(color: isActive ? Color.red.opacity(0.6) : .black.opacity(0.3), radius: isActive ? 6 : 2)
                
                // Tecla retroiluminada
                RoundedRectangle(cornerRadius: 4)
                    .fill(isActive ? Color(red: 1.0, green: 0.95, blue: 0.8) : Color(red: 0.90, green: 0.88, blue: 0.84))
                    .padding(3.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                LinearGradient(
                                    colors: [.white, .black.opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .padding(3.5)
                    )
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isActive ? Color.red.opacity(0.9) : .black.opacity(0.8))
            }
            .frame(width: 75, height: 48)
            
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.black.opacity(0.85))
        }
    }
}

// Botón de Presets (1, 2, 3, 4) en Plástico Baquelita con LED Físico
struct BotonPresetPlastico: View {
    var numero: Int
    var bpmValue: Double?
    var isSelected: Bool
    var onSelect: () -> Void
    var onSave: () -> Void
    
    @State private var isSavingAnimation: Bool = false
    @State private var isPressing: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text("PRESET \(numero)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.black.opacity(0.75))
            
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        isSelected ? Color(red: 0.85, green: 0.15, blue: 0.15) : Color(red: 0.25, green: 0.23, blue: 0.22)
                    )
                    .shadow(color: isSelected ? Color.red.opacity(0.8) : .black.opacity(0.4), radius: isSelected ? 8 : 2, x: 0, y: 2)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        isSavingAnimation
                        ? Color.green
                        : (isSelected
                            ? Color(red: 1.0, green: 0.95, blue: 0.8)
                            : Color(red: 0.88, green: 0.86, blue: 0.82))
                    )
                    .padding(4)
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
                
                Text("\(numero)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? Color.red.opacity(0.9) : .black.opacity(0.75))
                    .shadow(color: isSelected ? .orange.opacity(0.5) : .clear, radius: 2)
            }
            .frame(width: 58, height: 48)
            .scaleEffect(isPressing ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressing)
            .onLongPressGesture(minimumDuration: 1.2, maximumDistance: 10, pressing: { pressing in
                self.isPressing = pressing
            }, perform: {
                onSave()
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                withAnimation(.easeIn(duration: 0.15)) {
                    isSavingAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isSavingAnimation = false
                    }
                }
            })
            .onTapGesture {
                onSelect()
            }
            
            if isSavingAnimation {
                Text("SAVED!")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else if let bpm = bpmValue {
                Text("\(Int(bpm)) BPM")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? Color.red : .black.opacity(0.8))
            } else {
                Text("---")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }
}
