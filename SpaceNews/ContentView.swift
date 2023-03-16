//
//  ContentView.swift
//  SpaceNews
//
//  Created by Christopher Yoon on 3/16/23.
//

/*
 API used from
 https://api.spaceflightnewsapi.net/documentation#/Article/get_v3_articles
 */

import SwiftUI

let spaceNewsURLString = "https://api.spaceflightnewsapi.net/v3/articles"
struct SpaceData : Codable, Identifiable {
    var id: Int
    var title: String
    var url: String
    var imageUrl: String
    var newsSite: String
    var summary: String
    var publishedAt: String
}
let testArticle = SpaceData(id: 0, title: "Test News", url: "https://www.space.com/venus-active-volcano-nasa-magellan-mission", imageUrl: "https://cdn.mos.cms.futurecdn.net/YWpKWSwaC3d3ZwaxaFHBqV-1920-80.jpeg.webp", newsSite: "Space.com", summary: "Maat Mons is displayed in this computer generated three-dimensional perspective of the surface of Venus. The viewpoint is located 393 miles (634 kilometers) north of Maat Mons at an elevation of 2 miles (3 km) above the terrain. Lava flows extend for hundreds of kilometers across the fractured plains shown in the foreground, to the base of Maat Mons.  (Image credit: NASA/JPL-Caltech)", publishedAt: "Science & Astronomy") // Test Article

struct ListRowView: View {
    let data: SpaceData
    var body: some View {
        VStack {
            Text("\(data.title)")
                .font(.title3)
            AsyncImage(url: URL(string: data.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()

            } placeholder: {
                ProgressView()
            }
            Link(destination: URL(string: data.url)!) {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }.buttonStyle(.plain)
    }
}
struct DetailView: View {
    var body: some View {
        Text("HI")
    }
}

@MainActor
class ArticleList: ObservableObject {
    @Published var articles : [SpaceData] = []
    
    func getOnlineData() async  {
        guard let url = URL(string: spaceNewsURLString) else {
            print("error making URL from \(spaceNewsURLString)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode([SpaceData].self, from: data) {
                articles = decodedResponse
            }
        } catch {
            print(error)
        }
    }
    
    
    // Test Function
    func getData() {
        articles = [testArticle,testArticle]
    }
}

struct ContentView: View {
    @StateObject var vm = ArticleList()
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.articles) { article in
                    NavigationLink {
                        DetailView()
                    } label: {
                        ListRowView(data: article)
                    }

                    
                }
            }
            .task {
                await vm.getOnlineData()
            }
            .refreshable {
                await vm.getOnlineData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
