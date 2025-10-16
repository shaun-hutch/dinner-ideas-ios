//
//  DinnerItemsView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 28/01/2025.
//

import SwiftUI

struct DinnerItemsView: View {
    @Binding var dinnerItems: [DinnerItem]
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isPresentingNewDinnerItemView = false
    @State private var showAlert: Bool = false
    @State private var deleting: Bool = false
    @State private var itemToDelete: DinnerItem? = nil
    @State private var searchText = ""
    
    let saveAction: () -> Void
    
    var filteredItems: [DinnerItem] {
        if searchText.isEmpty {
            return dinnerItems
        } else {
            return dinnerItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredItems.isEmpty && !dinnerItems.isEmpty {
                    // No search results
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No recipes found")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Try searching with different keywords")
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                } else if dinnerItems.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        
                        Text("No recipes yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Add your first recipe to get started")
                            .foregroundStyle(.secondary)
                        
                        Button("Add Recipe") {
                            isPresentingNewDinnerItemView = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(40)
                } else {
                    List {
                        ForEach(filteredItems, id: \.id) { item in
                            // Create a binding to the underlying dinnerItems element by id
                            if let index = dinnerItems.firstIndex(where: { $0.id == item.id }) {
                                let binding = $dinnerItems[index]
                                NavigationLink(destination: DetailView(item: binding)) {
                                    DinnerItemCardView(item: item)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash") {
                                        promptDeleteItem(item: item)
                                    }
                                    .tint(.red)
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Edit", systemImage: "pencil") {
                                        // TODO: Quick edit action
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isPresentingNewDinnerItemView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
            }
            .alert("Delete Recipe", isPresented: $showAlert) {
                Button("Delete", role: .destructive) {
                    if let itemToDelete = itemToDelete {
                        deleteItem(item: itemToDelete)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete \(itemToDelete?.name ?? "this recipe")?")
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $isPresentingNewDinnerItemView) {
            NewDinnerItemSheet(items: $dinnerItems, isPresentingSheet: $isPresentingNewDinnerItemView)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive {
                print("app not in foreground")
                saveAction()
            }
        }
    }
    
    private func promptDeleteItem(item: DinnerItem) {
        if !deleting {
            itemToDelete = item
            showAlert = true
        }
    }
        
    private func deleteItem(item: DinnerItem) {
        if let index = dinnerItems.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.bouncy) {
                _ = dinnerItems.remove(at: index)
            }
            saveAction() // Save after deletion
        }
    }
}

#Preview {
    DinnerItemsView(dinnerItems: .constant(DinnerItem.sampleItems), saveAction: {})
}
