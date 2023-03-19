//
//  SpaceNewsApp.swift
//  SpaceNews
//
//  Created by Christopher Yoon on 3/16/23.
//

import SwiftUI

@main
struct SpaceNewsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(vm: ArticleList())
        }
    }
}
