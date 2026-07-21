//
//  SongModel.swift
//  Sound1
//
//  Created by Diego Benjamin Hurtado Ramos on 7/20/26.
//

import Foundation

struct SongModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    let durationFormatted: String
}
