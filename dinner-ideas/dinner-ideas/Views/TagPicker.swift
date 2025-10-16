//
//  TagPicker.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 02/02/2025.
//

import SwiftUI

struct TagPicker: View {
    @Binding var selectedTags: [FoodTag]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Tags")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Select tags that describe your recipe")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    
                    // Selected tags count
                    if !selectedTags.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("\(selectedTags.count) tag\(selectedTags.count == 1 ? "" : "s") selected")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.green.opacity(0.1), in: .rect(cornerRadius: 12, style: .continuous))
                    }
                    
                    // Tags grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(FoodTag.allCases, id: \.self.id) { tag in
                            TagSelectionCard(
                                tag: tag,
                                isSelected: selectedTags.contains(tag)
                            ) {
                                toggleTag(tag)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func toggleTag(_ tag: FoodTag) {
        withAnimation(.bouncy) {
            if let index = selectedTags.firstIndex(of: tag) {
                selectedTags.remove(at: index)
            } else {
                selectedTags.append(tag)
            }
        }
    }
}

struct TagSelectionCard: View {
    let tag: FoodTag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Tag icon representation
                Circle()
                    .fill(tag.color.opacity(isSelected ? 1.0 : 0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        } else {
                            Circle()
                                .strokeBorder(tag.color.opacity(0.4), lineWidth: 2)
                        }
                    }
                
                Text(tag.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                AnyShapeStyle(isSelected ? AnyShapeStyle(tag.color.opacity(0.1)) : AnyShapeStyle(.regularMaterial)),
                in: .rect(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? AnyShapeStyle(tag.color.opacity(0.3)) : AnyShapeStyle(.quaternary),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    TagPicker(selectedTags: .constant([FoodTag.Cheap, FoodTag.Vegeterian]))
}
