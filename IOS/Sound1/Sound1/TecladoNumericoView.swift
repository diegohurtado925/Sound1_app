//
//  NumPad.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI

struct TecladoNumericoView: View {
    @Binding var bpm: Double
    @State private var compas: Int = 4
    @State private var pulso: Int = 1
    @State private var bpmDigitado: String = "120"
    
    let botones = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["×2", "0", "÷2"]
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            // --- PANTALLAS SUPERIORES (COMPAS Y PULSO) ---
            HStack(spacing: 25) {
                VStack(spacing: 4) {
                    Text("COMPAS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                    
                    ZStack {
                        Color(red: 0.05, green: 0.1, blue: 0.05)
                        Text("\(compas)")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.2))
                    }
                    .frame(width: 55, height: 50)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 2))
                }
                
                VStack(spacing: 4) {
                    Text("PULSO")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                    
                    ZStack {
                        Color(red: 0.05, green: 0.1, blue: 0.05)
                        Text("\(pulso)")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.2))
                    }
                    .frame(width: 55, height: 50)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 2))
                }
            }
            .padding(.top, 10)
            

            
            // --- REJILLA DE BOTONES DE HARDWARE ---
            VStack(spacing: 10) {
                ForEach(botones, id: \.self) { fila in
                    HStack(spacing: 12) {
                        ForEach(fila, id: \.self) { boton in
                            Button(action: {
                                procesarEntrada(boton)
                            }) {
                                Text(boton)
                                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black.opacity(0.8))
                                    .frame(width: 65, height: 60)
                                    .background(colorParaBoton(boton))
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 2)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Text("MULTIPLY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                Spacer()
                Text("DIVIDE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 15)
            .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .frame(width: 260, height: 440)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.94, green: 0.92, blue: 0.88))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 2, y: 4)
        )
        .overlay(
            ZStack {
                Tornillo().offset(x: -115, y: -205)
                Tornillo().offset(x: 115, y: -205)
                Tornillo().offset(x: -115, y: 205)
                Tornillo().offset(x: 115, y: 205)
            }
        )
    }
    
    private func procesarEntrada(_ valor: String) {
        if valor == "×2" {
            bpm = min(bpm * 2, 300)
            bpmDigitado = String(Int(bpm))
        } else if valor == "÷2" {
            bpm = max(bpm / 2, 40)
            bpmDigitado = String(Int(bpm))
        } else {
            if bpmDigitado.count >= 3 {
                bpmDigitado = ""
            }
            bpmDigitado += valor
            if let nuevoBPM = Double(bpmDigitado), nuevoBPM > 0 {
                bpm = nuevoBPM
            }
        }
    }
    
    private func colorParaBoton(_ texto: String) -> Color {
        if texto == "×2" {
            return Color(red: 0.62, green: 0.78, blue: 0.68)
        } else if texto == "÷2" {
            return Color(red: 0.75, green: 0.45, blue: 0.48)
        } else {
            return Color(red: 0.84, green: 0.82, blue: 0.78)
        }
    }
}

#Preview {
    TecladoNumericoView(bpm: .constant(120.0))
        .background(Color.gray)
}
