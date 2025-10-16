//
//  NewDinnerItemSheet.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 13/02/2025.
//

import SwiftUI
import FoundationModels

public struct NewDinnerItemSheet: View {
    @State private var newDinnerItem: DinnerItem = DinnerItem.emptyDinnerItem
    @State private var itemImage: UIImage?
    @State private var generator = DinnerItemGenerator()
    @State private var isGenerating = false
    @State private var showRegenerateConfirmation = false
    @State private var generatedRecipe: DinnerItemGeneration.PartiallyGenerated?
    
    @Binding var items: [DinnerItem]
    @Binding var isPresentingSheet: Bool
    
    private var isValidItem: Bool {
        !effectiveName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !effectiveDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var hasGeneratedContent: Bool {
        generator.generatedItem != nil
    }
    
    // Use generated content if available, otherwise fallback to manual input
    private var effectiveName: String {
        generator.generatedItem?.name ?? newDinnerItem.name
    }
    
    private var effectiveDescription: String {
        generator.generatedItem?.description ?? newDinnerItem.description
    }
    
    private var effectivePrepTime: Int {
        generator.generatedItem?.prepTime ?? newDinnerItem.prepTime
    }
    
    private var effectiveCookTime: Int {
        generator.generatedItem?.cookTime ?? newDinnerItem.cookTime
    }
    
    private var effectiveSteps: [DinnerItemStep] {
        if let generatedSteps = generator.generatedItem?.steps {
            return generatedSteps.map { step in
                DinnerItemStep(
                    stepTitle: step.stepTitle ?? "",
                    stepDescription: step.stepDescription ?? ""
                )
            }
        }
        return newDinnerItem.steps
    }
    
    private var effectiveTags: [FoodTag] {
        generator.generatedItem?.tags ?? newDinnerItem.tags
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if hasGeneratedContent {
                    GeneratedRecipeView(
                        name: effectiveName,
                        description: effectiveDescription,
                        prepTime: effectivePrepTime,
                        cookTime: effectiveCookTime,
                        steps: effectiveSteps,
                        tags: effectiveTags,
                        itemImage: $itemImage
                    )
                } else {
                    DetailEditView(
                        item: $newDinnerItem, 
                        itemImage: $itemImage,
                        isGenerating: isGenerating,
                        generatedData: generator.generatedItem
                    )
                }
            }
            .navigationTitle(isGenerating ? "Generating Recipe..." : "New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresentingSheet = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    HStack(spacing: 12) {
                        if !isGenerating {
                            Button(action: {
                                if hasGeneratedContent {
                                    showRegenerateConfirmation = true
                                } else {
                                    generateRecipe()
                                }
                            }) {
                                Image(systemName: hasGeneratedContent ? "arrow.clockwise" : "sparkles")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                            }
                        } else {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Generating...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Button(action: {
                            var finalItem: DinnerItem
                            if let convertedItem = generator.convertToFinalItem() {
                                finalItem = convertedItem
                            } else {
                                finalItem = createFinalItem()
                            }
                            finalItem.image = FileHelper.saveImage(image: itemImage)
                            items.append(finalItem)
                            isPresentingSheet = false
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .disabled(!isValidItem || isGenerating)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            generator.prewarmModel()
        }
        .alert("Start Over?", isPresented: $showRegenerateConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Generate New Recipe", role: .destructive) {
                clearAndGenerate()
            }
        } message: {
            Text("This will clear the current recipe and generate a new one.")
        }
    }
    
    private func generateRecipe() {
        isGenerating = true
        generator.reset()
        
        Task {
            await generator.generateRecipe()
            await MainActor.run {
                isGenerating = false
            }
        }
    }
    
    private func clearAndGenerate() {
        newDinnerItem = DinnerItem.emptyDinnerItem
        itemImage = nil
        generateRecipe()
    }
    
    private func createFinalItem() -> DinnerItem {
        // Convert generated steps to proper DinnerItemStep instances with UUIDs
        let finalSteps = effectiveSteps.map { step in
            DinnerItemStep(stepTitle: step.stepTitle, stepDescription: step.stepDescription)
        }
        
        return DinnerItem(
            createdBy: 1,
            lastModifiedBy: 1,
            createdDate: Date(),
            lastModifiedDate: Date(),
            id: UUID(),
            name: effectiveName,
            description: effectiveDescription,
            prepTime: effectivePrepTime,
            cookTime: effectiveCookTime,
            steps: finalSteps,
            tags: effectiveTags,
            image: ""
        )
    }
}

struct GeneratedRecipeView: View {
    let name: String
    let description: String
    let prepTime: Int
    let cookTime: Int
    let steps: [DinnerItemStep]
    let tags: [FoodTag]
    @Binding var itemImage: UIImage?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Image section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Photo", icon: "photo")
                    
                    DinnerItemImageView(
                        canEdit: true,
                        imageGenerationConcept: .constant(name),
                        selectedImage: $itemImage
                    )
                }
                
                // Basic information
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Basic Information", icon: "info.circle")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Recipe Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Text(name)
                                .font(.body)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Text(description)
                                .font(.body)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                
                // Timing section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Timing", icon: "clock")
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Prep Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Text("\(prepTime) min")
                                .font(.body)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Cook Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Text("\(cookTime) min")
                                .font(.body)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
                        }
                    }
                    
                    // Total time display
                    let totalTime = prepTime + cookTime
                    if totalTime > 0 {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.secondary)
                            Text("Total: \(DinnerItem.formatTimeToHoursAndMinutes(time: totalTime))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(.quaternary.opacity(0.2), in: .rect(cornerRadius: 12, style: .continuous))
                    }
                }
                
                // Tags section
                if !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Tags", icon: "tag")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    FoodTagView(tag: tag)
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                        .padding(16)
                        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
                    }
                }
                
                // Steps section
                if !steps.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Instructions", icon: "list.number")
                        
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            GeneratedStepCard(stepNumber: index + 1, step: step)
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

struct GeneratedStepCard: View {
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
        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NewDinnerItemSheet(items: .constant(DinnerItem.sampleItems), isPresentingSheet: .constant(true))
}
