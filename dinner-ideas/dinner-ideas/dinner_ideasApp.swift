//
//  dinner_ideasApp.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 28/01/2025.
//

import SwiftUI

@main
struct dinner_ideasApp: App {
    
    @StateObject private var store = DinnerItemStore()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Recipes", systemImage: "fork.knife.circle", role: .search) {
                    DinnerItemsView(dinnerItems: $store.savedItems) {
                        Task {
                            do {
                                try await store.save(items: store.savedItems)
                            } catch {
                                print("error saving items")
                            }
                        }
                    }
                }
                
                Tab("Generate", systemImage: "wand.and.stars") {
                    GenerateView(dinnerItems: store.savedItems) {
                        Task {
                            do {
                                try await store.save(items: store.savedItems)
                            } catch {
                                print("error saving generated items")
                            }
                        }
                    }
                }
                
                Tab("History", systemImage: "clock.arrow.circlepath") {
                    HistoryView()
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .task {
                do {
                    try await store.load()
                } catch {
                    print("error loading store!")
                }
            }
        }
    }
}

// Placeholder for History View - to be implemented
struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                
                Text("History Coming Soon")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Your meal generation history will appear here")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

    
