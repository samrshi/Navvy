//
//  FavoritesVC.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import Combine
import UIKit

class FavoritesVC: UIViewController {
    var cancellables: [AnyCancellable] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DestinationTableViewCell.self, forCellReuseIdentifier: DestinationTableViewCell.reuseId)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl(frame: .zero)

        refreshControl.addAction(UIAction { [weak self] _ in
            self?.getFavorites()
        }, for: .valueChanged)

        return refreshControl
    }()

    var favorites: [NavigationViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        FavoritesDataStore.shared.$destinations
            .map { $0.map(NavigationViewModel.init) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                self?.favorites = favorites
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

//        getFavorites()
    }

    func getFavorites() {
        favorites = FavoritesDataStore.shared.getAll()
            .map(NavigationViewModel.init)

        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

extension FavoritesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DestinationTableViewCell.reuseId,
                                                 for: indexPath) as! DestinationTableViewCell
        cell.setUp(navigationVM: favorites[indexPath.row])
        return cell
    }
}

extension FavoritesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startNavigation(navigationVM: favorites[indexPath.row])

        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
}

extension FavoritesVC: DestinationConfirmationVCDelegate {
    func didDismissDestinationConfirmation() {}
}
