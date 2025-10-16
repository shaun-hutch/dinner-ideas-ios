//
//  FoodTagView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 30/01/2025.
//

import SwiftUI

public struct FoodTagView: View {
    let tag: FoodTag
    
    public var body: some View {
        Text(tag.name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tag.color.opacity(0.2), in: .capsule)
            .overlay {
                Capsule()
                    .strokeBorder(tag.color.opacity(0.4), lineWidth: 0.5)
            }
            .foregroundStyle(tag.color)
    }
}


#Preview {
    FoodTagView(tag: FoodTag.FamilyFriendly)
        .frame(width: 200, height: 50)
        .background(Color.gray.opacity(0.5))
        .colorScheme(.dark)
    
    FoodTagView(tag: FoodTag.Cheap)
        .frame(width: 200, height: 50)
        .background(Color.gray.opacity(0.5))
        .colorScheme(.light)
}
