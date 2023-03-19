//
//  GridView.swift
//  SpaceNews
//
//  Created by Christopher Yoon on 3/18/23.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct GridView: View {
    @ObservedObject var vm : ArticleList

    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(vm.articles) { article in
                    NavigationLink {
                        ArticlePhotoView(article: article)
                    } label: {
                        GridCellView(article: article)
                            .frame(height: 150)
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
        .padding(.horizontal, 4)
    }
    
}

struct GridCellView: View {
    let article : SpaceData
    var body: some View {
        GeometryReader { geo in
            WebImage(url: URL(string: article.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}


struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GridView(vm: ArticleList())
        }
    }
}

struct ArticlePhotoView: View {
    let article: SpaceData
    var body: some View {
        GeometryReader { geo in
            WebImage(url: URL(string: article.imageUrl))
                .resizable()
                .scaledToFit()
                .clipShape(Rectangle())
                .modifier(ImageModifier(contentSize: CGSize(width: geo.size.width, height: geo.size.height)))
        }
    }
}
