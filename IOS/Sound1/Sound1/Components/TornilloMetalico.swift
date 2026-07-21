//
//  TornilloMetalico.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import SwiftUI

struct TornilloMetalico: View {
    var body: some View {
        Circle()
            .fill(
                LinearGradient(colors: [.white, .gray, Color(white: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: 14, height: 14)
            .shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 9, height: 2)
                    .rotationEffect(.degrees(45))
            )
    }
}
