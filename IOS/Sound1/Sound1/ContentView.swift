//
//  ContentView.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI

struct ContentView: View {
    // Estado para saber qué sección está seleccionada
    @State private var seccionSeleccionada: String? = "Inicio"
    
    var body: some View {
        NavigationSplitView {
            // 1. BARRA LATERAL (Sidebar)
            List(selection: $seccionSeleccionada) {
                NavigationLink(value: "Inicio") {
                    Label("Inicio", systemImage: "house")
                }
                NavigationLink(value: "Mi Panel") {
                    Label("Mi Panel", systemImage: "square.grid.2x2")
                }
                NavigationLink(value: "Ajustes") {
                    Label("Ajustes", systemImage: "gearshape")
                }
            }
            .navigationTitle("Menú")
            
        } detail: {
            // 2. VISTA DE DETALLE (Contenido principal)
            if let seccion = seccionSeleccionada {
                VistaDetalle(nombreSeccion: seccion)
            } else {
                Text("Selecciona una opción del menú")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Una vista secundaria para mostrar el contenido según la sección
struct VistaDetalle: View {
    let nombreSeccion: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: nombreSeccion == "Inicio" ? "sparkles" : (nombreSeccion == "Mi Panel" ? "chart.bar" : "wrench.and.screwdriver"))
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Estás en: \(nombreSeccion)")
                .font(.largeTitle)
                .bold()
            
            Text("¡Tu lienzo de iPad está listo para desarrollo!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle(nombreSeccion)
    }
}

// Vista previa para el Canvas de Xcode
#Preview {
    ContentView()
}
