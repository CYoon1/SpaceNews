//
//  MainView.swift
//  SpaceNews
//
//  Created by Christopher Yoon on 3/18/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var vm : ArticleList
    var body: some View {
        TabView {
            ContentView(vm: vm)
                .tabItem {
                    Label("List", systemImage: "list.dash")
                }
            GridView(vm: vm)
                .tabItem {
                    Label("Grid", systemImage: "square.grid.2x2")
                }
        }
        .navigationTitle("Space News")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        vm.pageNumber -= 1
                        // Load Page
                        Task {
                            await vm.getOnlineData()
                        }
                    } label: {
                        Label("Previous", systemImage: "chevron.backward")
                    }
                    .disabled(vm.pageNumber <= 0) // Disable to prevent negative pages
                    Spacer()
                    Text("Page \(vm.pageNumber + 1)")
                        .monospaced()
                    Spacer()
                    Button {
                        vm.pageNumber += 1
                        // Load Page
                        Task {
                            await vm.getOnlineData()
                        }
                    } label : {
                        Label("Next", systemImage: "chevron.forward")
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainView(vm: ArticleList())
        }
    }
}
