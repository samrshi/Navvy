//
//  FavoritesVC.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import Combine
import UIKit

class FavoritesVC: UIViewController {
    enum Section { case favorites }

    var cancellables: [AnyCancellable] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DestinationTableViewCell.self, forCellReuseIdentifier: DestinationTableViewCell.reuseId)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        return tableView
    }()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl(frame: .zero)

        refreshControl.addAction(UIAction { [weak self] _ in
            self?.refresh()
        }, for: .valueChanged)

        return refreshControl
    }()

    var dataSource: FavoritesDiffableDataSource!

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

        dataSource = FavoritesDiffableDataSource(tableView: tableView, cellProvider: tableViewCellProvider)
        dataSource.shouldAnimateDifferences = shouldAnimateDataSourceChanges
        
        FavoritesDataStore.shared.$destinations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] destinations in
                self?.dataSource.update(destinations: destinations)
            }
            .store(in: &cancellables)
    }

    func refresh() {
        dataSource.update(destinations: FavoritesDataStore.shared.getAll())
        refreshControl.endRefreshing()
    }
}

extension FavoritesVC {
    func tableViewCellProvider(tableView: UITableView, indexPath: IndexPath, model: Destination) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DestinationTableViewCell.reuseId, for: indexPath) as! DestinationTableViewCell

        let destination = dataSource.itemIdentifier(for: indexPath)
        guard let navigationVM = dataSource.favorites.first(where: { $0.destination == destination }) else { return nil }

        cell.setUp(navigationVM: navigationVM, showCustomSeparator: false)
        return cell
    }
    
    func shouldAnimateDataSourceChanges() -> Bool {
        return view.window != nil
    }
}

extension FavoritesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startNavigation(navigationVM: dataSource.favorites[indexPath.row])

        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension FavoritesVC: DestinationConfirmationVCDelegate {
    func didDismissDestinationConfirmation() {}
}
