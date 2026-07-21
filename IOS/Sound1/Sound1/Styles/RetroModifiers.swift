//
//  RetroModifiers.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI

// Modificador para efecto de texto neón / tubo CRT
struct RetroNeonTextModifier: ViewModifier {
    var color: Color = Color(red: 0.4, green: 0.9, blue: 0.3)
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 0)
            .shadow(color: color.opacity(0.8), radius: 3, x: 0, y: 0)
    }
}

extension View {
    func retroNeonStyle(color: Color = Color(red: 0.4, green: 0.9, blue: 0.3)) -> some View {
        self.modifier(RetroNeonTextModifier(color: color))
    }
}

// Fondo de Aluminio Cepillado
struct ChasisMetalBackground: View {
    var body: some View {
        ZStack {
            // Base 1: Gradiente de chasis metálico más oscuro y denso
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.53, blue: 0.50), // Gris metálico medio
                    Color(red: 0.68, green: 0.65, blue: 0.62), // Brillo central sutil
                    Color(red: 0.48, green: 0.46, blue: 0.43), // Sombra de chasis
                    Color(red: 0.60, green: 0.57, blue: 0.54)  // Base inferior
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Base 2: Vinñeta y reflejo especular para dar profundidad física
            LinearGradient(
                colors: [
                    .white.opacity(0.15), // Destello superior sutil
                    .clear,
                    .black.opacity(0.35)  // Sombra de fondo oscura
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Base 3: Sombra radial sutil en los bordes para resaltar los botones
            RadialGradient(
                colors: [.clear, .black.opacity(0.25)],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
}

struct RetroScreenFrame: ViewModifier {
    var outerCornerRadius: CGFloat = 12
    var innerCornerRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .cornerRadius(innerCornerRadius)
            .padding(12) // Grosor del marco / bisel de plástico/metal
            .background(
                // 1. BASE DEL MARCO (Plástico/Metal extruido con sombras)
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.23, blue: 0.21), // Sombra superior del marco
                        Color(red: 0.45, green: 0.42, blue: 0.39), // Brillo central
                        Color(red: 0.15, green: 0.14, blue: 0.13)  // Sombra inferior profunda
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(outerCornerRadius)
            // 2. BISEL EXTERIOR (Borde biselado para dar volumen 3D)
            .overlay(
                RoundedRectangle(cornerRadius: outerCornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6), // Reflejo de luz en la esquina superior izquierda
                                .black.opacity(0.8)  // Sombra de hundimiento en la esquina inferior derecha
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            // 3. CANALETA INTERIOR (Efecto de hendidura donde encaja el cristal)
            .overlay(
                RoundedRectangle(cornerRadius: innerCornerRadius)
                    .stroke(Color.black.opacity(0.85), lineWidth: 3)
                    .padding(10)
            )
            .shadow(color: .black.opacity(0.6), radius: 6, x: 2, y: 4)
    }
}

extension View {
    func retroScreenFrame(outerRadius: CGFloat = 12, innerRadius: CGFloat = 8) -> some View {
        self.modifier(RetroScreenFrame(outerCornerRadius: outerRadius, innerCornerRadius: innerRadius))
    }
}
