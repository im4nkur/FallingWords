//
//  SceneDelegate.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Game", bundle: nil)
        guard let rootVC = storyboard.instantiateViewController(identifier: String(describing: GameViewController.self)) as? GameViewController else {
            return
        }
        // Initialised this viewmodel here just to show that it should be injected as a dependency to viewcontroller.
        // This could have been a part of Router or Coordinator that takes care of assembling the app flow.
        let repo = WordsLocalRepo() // Can be switch with Network or any other Repo.
        let viewModel = GameViewModel(repo: repo)
        rootVC.viewModel = viewModel
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }

}

