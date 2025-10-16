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
    
    @State private var prepTime: String = ""
    @State private var cookTime: String = ""
    @State private var stepTitle: String = ""
    @State private var stepDescription: String = ""
    @State private var showPicker: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, description, prepTime, cookTime, stepTitle, stepDescription
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Image section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Photo", icon: "photo")
                    
                    DinnerItemImageView(
                        canEdit: true,
                        imageGenerationConcept: $item.name,
                        selectedImage: $itemImage
                    )
                }
                
                // Basic information
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Basic Information", icon: "info.circle")
                    
                    VStack(spacing: 12) {
                        CustomTextField(
                            title: "Recipe Name",
                            text: $item.name,
                            placeholder: "Enter recipe name",
                            focused: $focusedField,
                            field: .name
                        )
                        
                        CustomTextEditor(
                            title: "Description",
                            text: $item.description,
                            placeholder: "Describe your recipe...",
                            focused: $focusedField,
                            field: .description
                        )
                    }
                }
                
                // Timing section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Timing", icon: "clock")
                    
                    HStack(spacing: 12) {
                        CustomTextField(
                            title: "Prep Time",
                            text: $prepTime,
                            placeholder: "0",
                            suffix: "min",
                            keyboardType: .numberPad,
                            focused: $focusedField,
                            field: .prepTime
                        )
                        .onChange(of: prepTime) { _, newValue in
                            item.prepTime = Int(newValue) ?? 0
                        }
                        
                        CustomTextField(
                            title: "Cook Time",
                            text: $cookTime,
                            placeholder: "0",
                            suffix: "min",
                            keyboardType: .numberPad,
                            focused: $focusedField,
                            field: .cookTime
                        )
                        .onChange(of: cookTime) { _, newValue in
                            item.cookTime = Int(newValue) ?? 0
                        }
                    }
                    
                    // Total time display
                    if item.totalTime > 0 {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.secondary)
                            Text("Total: \(DinnerItem.formatTimeToHoursAndMinutes(time: item.totalTime))")
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
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Tags", icon: "tag")
                    
                    Button(action: { showPicker = true }) {
                        HStack {
                            if item.tags.isEmpty {
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
                                        ForEach(item.tags, id: \.self) { tag in
                                            FoodTagView(tag: tag)
                                        }
                                        
                                        Image(systemName: "plus")
                                            .foregroundStyle(.blue)
                                            .padding(.leading, 4)
                                    }
                                    .padding(.horizontal, 1)
                                }
                            }
                        }
                        .padding(16)
                        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                
                // Steps section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Instructions", icon: "list.number")
                    
                    // Existing steps
                    ForEach(Array(item.steps.enumerated()), id: \.element.id) { index, step in
                        EditableStepCard(
                            stepNumber: index + 1,
                            step: step,
                            onDelete: { deleteStep(at: index) }
                        )
                    }
                    
                    // Add new step section
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
            .padding(20)
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
