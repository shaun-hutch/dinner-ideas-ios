//
//  GenerateView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 06/03/2025.
//

import SwiftUI

struct GenerateView: View {
    var dinnerItems: [DinnerItem]
    
    @State private var generated: Bool = false
    @State private var generatedItems: [DinnerItem] = []
    @State private var loading: Bool = false
    @State private var generatedDate: Date?
    @State private var numberOfMeals: Int = 3
    
    let saveAction: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !generated {
                    // Setup view
                    VStack(spacing: 32) {
                        Spacer()
                        
                        // Hero section
                        VStack(spacing: 16) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 64))
                                .foregroundStyle(.blue)
                                .symbolEffect(.bounce, value: loading)
                            
                            Text("Generate Meal Plan")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Create a random selection of meals from your recipe collection")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Configuration section
                        VStack(spacing: 20) {
                            HStack {
                                Text("Number of meals:")
                                    .font(.headline)
                                Spacer()
                                
                                Picker("Number of meals", selection: $numberOfMeals) {
                                    ForEach(1...min(7, dinnerItems.count), id: \.self) { number in
                                        Text("\(number)")
                                            .tag(number)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            .padding(20)
                            .background(.regularMaterial, in: .rect(cornerRadius: 16, style: .continuous))
                            
                            // Stats card
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "Total Recipes",
                                    value: "\(dinnerItems.count)",
                                    icon: "fork.knife.circle"
                                )
                                
                                StatCard(
                                    title: "Available",
                                    value: "\(min(numberOfMeals, dinnerItems.count))",
                                    icon: "checkmark.circle"
                                )
                            }
                        }
                        
                        Spacer()
                        
                        // Generate button
                        Button(action: {
                            generateDinnerItems()
                        }) {
                            HStack(spacing: 12) {
                                if loading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                        .font(.title3)
                                }
                                
                                Text(loading ? "Generating..." : "Generate Meals")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(dinnerItems.isEmpty ? .gray : .blue, in: .rect(cornerRadius: 16, style: .continuous))
                            .foregroundStyle(.white)
                        }
                        .disabled(dinnerItems.isEmpty || loading)
                        .sensoryFeedback(.impact, trigger: loading)
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Results view
                    VStack(spacing: 0) {
                        // Header with date and regenerate option
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Generated Plan")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if let date = generatedDate {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button("Regenerate") {
                                generateDinnerItems()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.regularMaterial)
                        
                        // Generated items list
                        List(generatedItems, id: \.id) { item in
                            NavigationLink(destination: DetailView(item: .constant(item))) {
                                DinnerItemCardView(item: item)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                
                if dinnerItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No recipes available")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("Add some recipes first to generate meal plans")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
            }
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if generated {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("New Plan") {
                            withAnimation(.bouncy) {
                                generated = false
                                generatedItems = []
                                generatedDate = nil
                            }
                        }
                        .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    private func generateDinnerItems() {
        loading = true
        
        // Add a small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let count = min(numberOfMeals, dinnerItems.count)
            generatedItems = Array(dinnerItems.shuffled().prefix(count))
            generatedDate = Date()
            
            withAnimation(.bouncy) {
                loading = false
                generated = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    GenerateView(dinnerItems: DinnerItem.sampleItems, saveAction: {})
}


