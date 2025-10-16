//
//  DinnerItemCardView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 30/01/2025.
//

import SwiftUI

struct DinnerItemCardView: View {
    let item: DinnerItem
    
    @State var image: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Image section with gradient overlay
            ZStack(alignment: .topTrailing) {
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(.tertiary)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                .frame(height: 180)
                .mask(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 16,
                        style: .continuous
                    )
                )
                .overlay(alignment: .topTrailing) {
                    // Time badge
                    Text("\(item.totalTime) min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: .capsule)
                        .padding(12)
                }
                .overlay(alignment: .bottomLeading) {
                    // Gradient overlay for text readability
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.3), .black.opacity(0.6)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .mask(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 16,
                            style: .continuous
                        )
                    )
                }
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // Tags section
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(item.tags, id: \.self) { tag in
                                FoodTagView(tag: tag)
                            }
                        }
                        .padding(.horizontal, 1) // Prevent clipping
                    }
                }
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(topLeadingRadius: 0, bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 0))
        }
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            image = FileHelper.loadImage(fileName: item.image ?? "")
        }
        .onChange(of: item.image) { _, newImage in
            image = FileHelper.loadImage(fileName: newImage ?? "")
        }
    }
}

#Preview {
    DinnerItemCardView(item: DinnerItem.sampleItems[0])
}
