//
//  NewDinnerItemSheet.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 13/02/2025.
//

import SwiftUI

public struct NewDinnerItemSheet: View {
    @State private var newDinnerItem: DinnerItem = DinnerItem.emptyDinnerItem
    @State private var itemImage: UIImage?
    @Binding var items: [DinnerItem]
    @Binding var isPresentingSheet: Bool
    
    private var isValidItem: Bool {
        !newDinnerItem.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !newDinnerItem.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public var body: some View {
        NavigationStack {
            DetailEditView(item: $newDinnerItem, itemImage: $itemImage)
                .navigationTitle("New Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            newDinnerItem.image = FileHelper.saveImage(image: itemImage)
                            items.append(newDinnerItem)
                            isPresentingSheet = false
                        }
                        .fontWeight(.semibold)
                        .disabled(!isValidItem)
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NewDinnerItemSheet(items: .constant(DinnerItem.sampleItems), isPresentingSheet: .constant(true))
}
