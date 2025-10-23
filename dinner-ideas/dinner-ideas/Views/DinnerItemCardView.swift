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
            imageSection
            contentSection
        }
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            loadImage()
        }
        .onChange(of: item.image) { _, newImage in
            image = FileHelper.loadImage(fileName: newImage ?? "")
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            imageDisplay
                .overlay(alignment: .topTrailing) {
                    timeBadge
                }
                .overlay(alignment: .bottomLeading) {
                    gradientOverlay
                }
        }
    }
    
    @ViewBuilder
    private var imageDisplay: some View {
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
    }
    
    @ViewBuilder
    private var timeBadge: some View {
        Text("\(item.totalTime) min")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: .capsule)
            .padding(12)
    }
    
    @ViewBuilder
    private var gradientOverlay: some View {
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
    
    @ViewBuilder
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleView
            
            if !item.description.isEmpty {
                descriptionView
            }
            
            if !item.tags.isEmpty {
                tagsView
            }
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(topLeadingRadius: 0, bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 0))
    }
    
    @ViewBuilder
    private var titleView: some View {
        HStack {
            Text(item.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        Text(item.description)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
    }
    
    @ViewBuilder
    private var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(item.tags, id: \.self) { tag in
                    FoodTagView(tag: tag)
                }
            }
            .padding(.horizontal, 1) // Prevent clipping
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadImage() {
        image = FileHelper.loadImage(fileName: item.image ?? "")
    }
}

#Preview {
    DinnerItemCardView(item: DinnerItem.sampleItems[0])
}
