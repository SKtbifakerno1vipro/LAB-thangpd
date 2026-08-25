//
//  AppIcon.swift
//  PartyUI
//
//  Created by lunginspector on 6/13/26.
//

import SwiftUI

public struct AppIcon: View {
    var image: Image
    
    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        image
            .resizable()
            .frame(width: 55, height: 55)
            .background(PlaceholderAppIcon())
            .overlay(AppIconBorder())
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PlaceholderAppIcon: View {
    var body: some View {
        Image(systemName: "questionmark.square")
            .foregroundStyle(.secondary)
            .frame(width: 55, height: 55)
            .background(Color(.systemGray5))
    }
}

struct AppIconBorder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.secondary.opacity(0.2), lineWidth: 1.5)
    }
}
