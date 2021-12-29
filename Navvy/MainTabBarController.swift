//
//  ViewController.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import UIKit

class MainTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: .main)
        
        let searchVC = LocationSearchVC()
        let favoritesVC = UIViewController()
        let profileVC = UIViewController()
        
        var controllers: [UIViewController] = [searchVC, favoritesVC, profileVC]
        controllers = controllers.map { UINavigationController(rootViewController: $0) }
        
        searchVC.title = "Search"
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")

        favoritesVC.title = "Favorites"
        favoritesVC.tabBarItem.image = UIImage(systemName: "heart")
        favoritesVC.tabBarItem.selectedImage = UIImage(systemName: "heart.fill")

        profileVC.title = "Profile"
        profileVC.tabBarItem.image = UIImage(systemName: "person")
        profileVC.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .primaryBackground
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
        viewControllers = controllers
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
