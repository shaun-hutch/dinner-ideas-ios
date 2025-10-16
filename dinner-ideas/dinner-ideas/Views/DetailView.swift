//
//  DetailView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 01/02/2025.
//

import SwiftUI

struct DetailView: View {
    @Binding var item: DinnerItem
    
    @State var itemImage: UIImage?
    @State var tempImage: UIImage?
    
    @State private var editingItem = DinnerItem.emptyDinnerItem
    @State private var isPresentingEditView = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Hero Image Section
                Group {
                    if let image = itemImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(.tertiary)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                    Text("No Image")
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)
                
                // Content sections
                VStack(spacing: 20) {
                    // Title and basic info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if !item.description.isEmpty {
                            Text(item.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                    .background(.regularMaterial, in: .rect(cornerRadius: 16, style: .continuous))
                    
                    // Time information
                    HStack(spacing: 16) {
                        TimeInfoCard(
                            title: "Prep Time",
                            time: DinnerItem.formatTimeToHoursAndMinutes(time: item.prepTime),
                            icon: "clock"
                        )
                        
                        TimeInfoCard(
                            title: "Cook Time", 
                            time: DinnerItem.formatTimeToHoursAndMinutes(time: item.cookTime),
                            icon: "flame"
                        )
                        
                        TimeInfoCard(
                            title: "Total Time",
                            time: DinnerItem.formatTimeToHoursAndMinutes(time: item.totalTime),
                            icon: "timer"
                        )
                    }
                    
                    // Tags section
                    if !item.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundStyle(.secondary)
                                Text("Tags")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                                ForEach(item.tags, id: \.self.id) { tag in
                                    FoodTagView(tag: tag)
                                }
                            }
                        }
                        .padding(20)
                        .background(.regularMaterial, in: .rect(cornerRadius: 16, style: .continuous))
                    }
                    
                    // Steps section
                    if !item.steps.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "list.number")
                                    .foregroundStyle(.secondary)
                                Text("Instructions")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            ForEach(Array(item.steps.enumerated()), id: \.offset) { index, step in
                                StepCard(stepNumber: index + 1, step: step)
                            }
                        }
                        .padding(20)
                        .background(.regularMaterial, in: .rect(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isPresentingEditView = true
                    editingItem = item
                    tempImage = itemImage
                }
                .fontWeight(.medium)
            }
        }
        .onAppear {
            itemImage = FileHelper.loadImage(fileName: item.image ?? "")
            tempImage = itemImage
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                DetailEditView(item: $editingItem, itemImage: $tempImage)
                    .navigationTitle("Edit Recipe")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                                tempImage = itemImage
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                isPresentingEditView = false
                                item = editingItem
                                
                                itemImage = tempImage
                                item.image = FileHelper.saveImage(image: tempImage)
                            }
                            .fontWeight(.semibold)
                        }
                    }
            }
        }
    }
}

struct TimeInfoCard: View {
    let title: String
    let time: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(time)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
    }
}

struct StepCard: View {
    let stepNumber: Int
    let step: DinnerItemStep
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(stepNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.blue, in: .circle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.stepTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(step.stepDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.quaternary.opacity(0.3), in: .rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    DetailView(item: .constant(DinnerItem.sampleItems[0]))
}
