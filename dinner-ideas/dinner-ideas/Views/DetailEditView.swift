//
//  DetailEditView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 01/02/2025.
//

import SwiftUI

struct DetailEditView: View {
    @Binding var item: DinnerItem
    @Binding var itemImage: UIImage?
    var isGenerating: Bool = false
    var generatedData: DinnerItemGeneration.PartiallyGenerated? = nil
    
    @State private var prepTime: String = ""
    @State private var cookTime: String = ""
    @State private var stepTitle: String = ""
    @State private var stepDescription: String = ""
    @State private var showPicker: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, description, prepTime, cookTime, stepTitle, stepDescription
    }
    
    // Helper computed properties for live data
    private var displayName: String {
        if let generated = generatedData?.name, !generated.isEmpty {
            return generated
        }
        return item.name
    }
    
    private var displayDescription: String {
        if let generated = generatedData?.description, !generated.isEmpty {
            return generated
        }
        return item.description
    }
    
    private var displayPrepTime: Int {
        generatedData?.prepTime ?? item.prepTime
    }
    
    private var displayCookTime: Int {
        generatedData?.cookTime ?? item.cookTime
    }
    
    private var displaySteps: [DinnerItemStep] {
        if let generatedSteps = generatedData?.steps, !generatedSteps.isEmpty {
            return generatedSteps.map { step in
                DinnerItemStep(
                    stepTitle: step.stepTitle ?? "",
                    stepDescription: step.stepDescription ?? ""
                )
            }
        }
        return item.steps
    }
    
    private var displayTags: [FoodTag] {
        if let generatedTags = generatedData?.tags, !generatedTags.isEmpty {
            return generatedTags
        }
        return item.tags
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            scrollContent
                .onChange(of: generatedData?.name, initial: false) { _, newValue in
                    if newValue != nil {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("basic-info-section", anchor: .top)
                        }
                    }
                }
                .onChange(of: generatedData?.prepTime, initial: false) { _, newValue in
                    if newValue != nil {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("timing-section", anchor: .top)
                        }
                    }
                }
                .onChange(of: generatedData?.tags, initial: false) { _, newValue in
                    if newValue != nil {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("tags-section", anchor: .top)
                        }
                    }
                }
                .onChange(of: generatedData?.steps?.count, initial: false) { _, newValue in
                    if newValue != nil {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("steps-section", anchor: .top)
                        }
                    }
                }
        }
        .onAppear {
            prepTime = String(item.prepTime)
            cookTime = String(item.cookTime)
        }
        .sheet(isPresented: $showPicker) {
            TagPicker(selectedTags: $item.tags)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: {
                    focusedField = nil
                }) {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                }
            }
        }
    }
    
    @ViewBuilder
    private var scrollContent: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                photoSection
                basicInfoSection
                timingSection
                tagsSection
                stepsSection
            }
            .padding(20)
        }
    }
    
    // MARK: - View Sections
    
    @ViewBuilder
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Photo", icon: "photo")
            
            DinnerItemImageView(
                canEdit: true,
                imageGenerationConcept: .constant(displayName),
                selectedImage: $itemImage
            )
        }
        .id("photo-section")
    }
    
    @ViewBuilder
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Basic Information", icon: "info.circle")
            
            VStack(spacing: 12) {
                GenerativeTextField(
                    title: "Recipe Name",
                    displayText: displayName,
                    actualText: $item.name,
                    placeholder: "Enter recipe name",
                    focused: $focusedField,
                    field: .name,
                    isGenerating: isGenerating,
                    hasGeneratedContent: generatedData?.name != nil
                )
                
                GenerativeTextEditor(
                    title: "Description",
                    displayText: displayDescription,
                    actualText: $item.description,
                    placeholder: "Describe your recipe...",
                    focused: $focusedField,
                    field: .description,
                    isGenerating: isGenerating,
                    hasGeneratedContent: generatedData?.description != nil
                )
            }
        }
        .id("basic-info-section")
    }
    
    @ViewBuilder
    private var timingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Timing", icon: "clock")
            
            HStack(spacing: 12) {
                prepTimeField
                cookTimeField
            }
            
            totalTimeDisplay
        }
        .id("timing-section")
    }
    
    @ViewBuilder
    private var prepTimeField: some View {
        GenerativeTextField(
            title: "Prep Time",
            displayText: displayPrepTime > 0 ? String(displayPrepTime) : "",
            actualText: $prepTime,
            placeholder: "0",
            suffix: "min",
            keyboardType: .numberPad,
            focused: $focusedField,
            field: .prepTime,
            isGenerating: isGenerating,
            hasGeneratedContent: generatedData?.prepTime != nil
        )
        .onChange(of: prepTime) { _, newValue in
            item.prepTime = Int(newValue) ?? 0
        }
    }
    
    @ViewBuilder
    private var cookTimeField: some View {
        GenerativeTextField(
            title: "Cook Time",
            displayText: displayCookTime > 0 ? String(displayCookTime) : "",
            actualText: $cookTime,
            placeholder: "0",
            suffix: "min",
            keyboardType: .numberPad,
            focused: $focusedField,
            field: .cookTime,
            isGenerating: isGenerating,
            hasGeneratedContent: generatedData?.cookTime != nil
        )
        .onChange(of: cookTime) { _, newValue in
            item.cookTime = Int(newValue) ?? 0
        }
    }
    
    @ViewBuilder
    private var totalTimeDisplay: some View {
        let totalTime = displayPrepTime + displayCookTime
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
            .opacity(isGenerating && generatedData?.prepTime == nil && generatedData?.cookTime == nil ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isGenerating)
        }
    }
    
    @ViewBuilder
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Tags", icon: "tag")
            
            Button(action: { 
                if !isGenerating { 
                    showPicker = true 
                }
            }) {
                tagsContent
            }
            .buttonStyle(.plain)
            .disabled(isGenerating)
        }
        .id("tags-section")
    }
    
    @ViewBuilder
    private var tagsContent: some View {
        HStack {
            if displayTags.isEmpty && !isGenerating {
                HStack {
                    Image(systemName: "plus")
                        .foregroundStyle(.blue)
                    Text("Add tags")
                        .foregroundStyle(.blue)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(displayTags, id: \.self) { tag in
                            FoodTagView(tag: tag)
                                .scaleEffect(isGenerating && generatedData?.tags == nil ? 0.95 : 1.0)
                                .opacity(isGenerating && generatedData?.tags == nil ? 0.6 : 1.0)
                        }
                        
                        tagsSuffix
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
        .animation(.easeInOut(duration: 0.3), value: displayTags)
        .animation(.easeInOut(duration: 0.3), value: isGenerating)
    }
    
    @ViewBuilder
    private var tagsSuffix: some View {
        if !isGenerating {
            Image(systemName: "plus")
                .foregroundStyle(.blue)
                .padding(.leading, 4)
        } else if generatedData?.tags == nil {
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Generating tags...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
        }
    }
    
    @ViewBuilder
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Instructions", icon: "list.number")
            
            stepsContent
            stepsGenerationIndicator
            addStepSection
        }
        .id("steps-section")
    }
    
    @ViewBuilder
    private var stepsContent: some View {
        ForEach(Array(displaySteps.enumerated()), id: \.element.id) { index, step in
            GenerativeStepCard(
                stepNumber: index + 1,
                step: step,
                isGenerated: generatedData?.steps != nil,
                isGenerating: isGenerating && generatedData?.steps == nil,
                onDelete: generatedData == nil ? { deleteStep(at: index) } : nil
            )
        }
    }
    
    @ViewBuilder
    private var stepsGenerationIndicator: some View {
        if isGenerating && generatedData?.steps == nil {
            HStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(0.8)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Generating cooking instructions...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("AI is creating step-by-step instructions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
            .background(.blue.opacity(0.1), in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.blue.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private var addStepSection: some View {
        if !isGenerating && generatedData == nil {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add Step")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    CustomTextField(
                        title: "Step Title",
                        text: $stepTitle,
                        placeholder: "e.g., Prepare ingredients",
                        focused: $focusedField,
                        field: .stepTitle
                    )
                    
                    CustomTextEditor(
                        title: "Instructions",
                        text: $stepDescription,
                        placeholder: "Describe what to do in this step...",
                        focused: $focusedField,
                        field: .stepDescription,
                        height: 80
                    )
                    
                    Button(action: addStep) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.medium)
                            Text("Add Step")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(isStepValid ? .blue : .gray, in: .rect(cornerRadius: 8, style: .continuous))
                        .foregroundStyle(.white)
                    }
                    .disabled(!isStepValid)
                }
                .padding(20)
                .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var isStepValid: Bool {
        !stepTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !stepDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addStep() {
        let step = DinnerItemStep(
            stepTitle: stepTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            stepDescription: stepDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        withAnimation(.bouncy) {
            item.steps.append(step)
            stepTitle = ""
            stepDescription = ""
            focusedField = .stepTitle
        }
    }
    
    private func deleteStep(at index: Int) {
        _ = withAnimation(.bouncy) {
            item.steps.remove(at: index)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var suffix: String? = nil
    var keyboardType: UIKeyboardType = .default
    @FocusState.Binding var focused: DetailEditView.Field?
    let field: DetailEditView.Field
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack {
                TextField(placeholder, text: $text)
                    .focused($focused, equals: field)
                    .keyboardType(keyboardType)
                
                if let suffix = suffix {
                    Text(suffix)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
        }
    }
}

struct CustomTextEditor: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @FocusState.Binding var focused: DetailEditView.Field?
    let field: DetailEditView.Field
    var height: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .focused($focused, equals: field)
                    .frame(height: height)
                    .scrollContentBackground(.hidden)
                
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            .padding(12)
            .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
        }
    }
}

struct EditableStepCard: View {
    let stepNumber: Int
    let step: DinnerItemStep
    let onDelete: () -> Void
    
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
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    DetailEditView(item: .constant(DinnerItem.sampleItems[0]), itemImage: .constant(nil))
}

// MARK: - Generative UI Components

struct GenerativeTextField: View {
    let title: String
    let displayText: String
    @Binding var actualText: String
    let placeholder: String
    var suffix: String? = nil
    var keyboardType: UIKeyboardType = .default
    @FocusState.Binding var focused: DetailEditView.Field?
    let field: DetailEditView.Field
    let isGenerating: Bool
    let hasGeneratedContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if isGenerating && !hasGeneratedContent {
                    Spacer()
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Generating...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            HStack {
                if hasGeneratedContent {
                    Text(displayText)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    TextField(placeholder, text: $actualText)
                        .focused($focused, equals: field)
                        .keyboardType(keyboardType)
                        .disabled(isGenerating)
                }
                
                if let suffix = suffix {
                    Text(suffix)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(hasGeneratedContent ? .blue.opacity(0.3) : .clear, lineWidth: 1.5)
            )
            .scaleEffect(isGenerating && !hasGeneratedContent ? 0.98 : 1.0)
            .opacity(isGenerating && !hasGeneratedContent ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: hasGeneratedContent)
            .animation(.easeInOut(duration: 0.3), value: isGenerating)
        }
    }
}

struct GenerativeTextEditor: View {
    let title: String
    let displayText: String
    @Binding var actualText: String
    let placeholder: String
    @FocusState.Binding var focused: DetailEditView.Field?
    let field: DetailEditView.Field
    var height: CGFloat = 100
    let isGenerating: Bool
    let hasGeneratedContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if isGenerating && !hasGeneratedContent {
                    Spacer()
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Generating...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            ZStack(alignment: .topLeading) {
                if hasGeneratedContent {
                    ScrollView {
                        Text(displayText)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    .frame(height: height)
                } else {
                    TextEditor(text: $actualText)
                        .focused($focused, equals: field)
                        .frame(height: height)
                        .scrollContentBackground(.hidden)
                        .disabled(isGenerating)
                    
                    if actualText.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
            }
            .padding(12)
            .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(hasGeneratedContent ? .blue.opacity(0.3) : .clear, lineWidth: 1.5)
            )
            .scaleEffect(isGenerating && !hasGeneratedContent ? 0.98 : 1.0)
            .opacity(isGenerating && !hasGeneratedContent ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: hasGeneratedContent)
            .animation(.easeInOut(duration: 0.3), value: isGenerating)
        }
    }
}

struct GenerativeStepCard: View {
    let stepNumber: Int
    let step: DinnerItemStep
    let isGenerated: Bool
    let isGenerating: Bool
    let onDelete: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(stepNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(isGenerated ? .green : .blue, in: .circle)
                .scaleEffect(isGenerating ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isGenerating)
            
            VStack(alignment: .leading, spacing: 4) {
                if isGenerated {
                    Text(step.stepTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(step.stepDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(step.stepTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(step.stepDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .opacity(isGenerating ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isGenerating)
            
            Spacer()
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .font(.title3)
                }
            } else if isGenerated {
                Image(systemName: "sparkles")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isGenerated ? .green.opacity(0.3) : .clear, lineWidth: 1.5)
        )
        .scaleEffect(isGenerated ? 1.02 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isGenerated)
    }
}
