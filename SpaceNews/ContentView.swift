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
import SDWebImageSwiftUI

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


@MainActor
class ArticleList: ObservableObject {
    @Published var articles : [SpaceData] = []
    @Published var pageNumber = 0 // Starts at 0, display as 1 on view.
    @Published var articlesPerPage = 10 // Default 10
    
    
    func getURLstring() -> String {
        let urlBase = "https://api.spaceflightnewsapi.net/v3/articles?"
        
        func getArticlesPerPageString(count: Int) -> String {
            "_limit=\(count)"
        }
        func getPageOffsetString(page: Int) -> String {
            "_start=\(articlesPerPage * pageNumber)"
        }
        let urlString = urlBase + getArticlesPerPageString(count: articlesPerPage) + "&" + getPageOffsetString(page: pageNumber)
        print("getURLString gets: \(urlString)")
        return urlString
    }
    
    func getOnlineData() async  {
        guard let url = URL(string: getURLstring()) else {
            print("error making URL from \(spaceNewsURLString)")
            print("getURLstring() returns : \(getURLstring())")
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

struct ListRowView: View {
    let data: SpaceData
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(data.title)")
                .font(.title3)
            Text("Story from: \(data.newsSite)")
                .font(.subheadline)
            Text("\(data.publishedAt)")
                .font(.footnote)
//            AsyncImage(url: URL(string: data.imageUrl)) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 200, height: 200)
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//            } placeholder: {
//                ProgressView()
//            }
//            
            WebImage(url: URL(string: data.imageUrl))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }.buttonStyle(.plain)
    }
}
struct DetailView: View {
    let data: SpaceData
    var body: some View {
        ScrollView {
            Text(data.title)
                .font(.title)
            Text(data.publishedAt)
            WebImage(url: URL(string: data.imageUrl))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFit()
//            AsyncImage(url: URL(string: data.imageUrl)) { image in
//                image
//                    .resizable()
//                    .scaledToFit()
//                
//            } placeholder: {
//                ProgressView()
//            }
            Text(data.summary)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Text("Visit \(data.newsSite) for more")
                    Link(destination: URL(string: data.url)!) {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}


struct ContentView: View {
    @ObservedObject var vm = ArticleList()
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.articles) { article in
                    NavigationLink {
                        DetailView(data: article)
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
            .navigationTitle("Space News")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
