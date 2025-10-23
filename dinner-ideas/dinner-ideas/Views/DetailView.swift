//
//  DetailView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 01/02/2025.
//

import SwiftUI

struct DetailView: View {
    @Binding var item: DinnerItem
    let saveAction: () -> Void
    
    @State var itemImage: UIImage?
    @State var tempImage: UIImage?
    
    @State private var editingItem = DinnerItem.emptyDinnerItem
    @State private var isPresentingEditView = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                heroImageSection
                contentSections
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                editButton
            }
        }
        .onAppear {
            loadImage()
        }
        .sheet(isPresented: $isPresentingEditView) {
            editSheet
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var heroImageSection: some View {
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
    }
    
    @ViewBuilder
    private var contentSections: some View {
        VStack(spacing: 20) {
            basicInfoSection
            timeInfoSection
            
            if !item.tags.isEmpty {
                tagsSection
            }
            
            if !item.steps.isEmpty {
                stepsSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var basicInfoSection: some View {
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
    }
    
    @ViewBuilder
    private var timeInfoSection: some View {
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
    }
    
    @ViewBuilder
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundStyle(.secondary)
                Text("Tags")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                ForEach(item.tags, id: \.self.id) { tag in
                    FoodTagView(tag: tag)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: .rect(cornerRadius: 16, style: .continuous))
    }
    
    @ViewBuilder
    private var stepsSection: some View {
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
    
    @ViewBuilder
    private var editButton: some View {
        Button("Edit") {
            isPresentingEditView = true
            editingItem = item
            tempImage = itemImage
        }
        .fontWeight(.medium)
    }
    
    @ViewBuilder
    private var editSheet: some View {
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
                            saveChanges()
                        }
                        .fontWeight(.semibold)
                    }
                }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadImage() {
        itemImage = FileHelper.loadImage(fileName: item.image ?? "")
        tempImage = itemImage
    }
    
    private func saveChanges() {
        isPresentingEditView = false
        item = editingItem
        
        itemImage = tempImage
        item.image = FileHelper.saveImage(image: tempImage)
        
        // Save the changes to disk
        saveAction()
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
    DetailView(item: .constant(DinnerItem.sampleItems[0]), saveAction: {})
}
