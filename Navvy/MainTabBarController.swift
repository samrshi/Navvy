//
//  ViewController.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import UIKit

class MainTabBarController: UITabBarController {
    lazy var searchVC: LocationSearchVC = {
        let searchVC = LocationSearchVC()
        searchVC.title = "Search"
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        return searchVC
    }()

    lazy var favoritesVC: FavoritesVC = {
        let favoritesVC = FavoritesVC()
        favoritesVC.title = "Favorites"
        favoritesVC.tabBarItem.image = UIImage(systemName: "heart")
        favoritesVC.tabBarItem.selectedImage = UIImage(systemName: "heart.fill")
        return favoritesVC
    }()

    lazy var settingsVC: SettingsVC = {
        let settingsVC = SettingsVC()
        settingsVC.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(systemName: "gearshape")
        settingsVC.tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
        return settingsVC
    }()

    init() {
        super.init(nibName: nil, bundle: .main)
        delegate = self

        var controllers: [UIViewController] = [searchVC, favoritesVC, settingsVC]
        controllers = controllers.map { UINavigationController(rootViewController: $0) }

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .primaryBackground
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance

        viewControllers = controllers
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let completion: () -> Void = { [weak self] in
            self?.searchVC.setUp()
        }
        if !UserDefaults.standard.bool(forKey: "hasShownOnboarding") {
            showRequestLocationPermissions(requestType: .firstTime, completion: completion)
        } else if LocationManager.shared.locationPermissionsAreDenied {
            showRequestLocationPermissions(requestType: .currentlyDenied, completion: completion)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedViewController = viewControllers?[safe: selectedIndex] else { return true }
        guard selectedViewController == viewController else { return true }

        if selectedIndex == 0 {
            searchVC.clearSearchResults()
        } else if selectedIndex == 1 {
            favoritesVC.refresh()
        }

        return true
    }
}
