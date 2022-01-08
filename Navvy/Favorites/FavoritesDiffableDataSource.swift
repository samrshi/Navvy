//
//  FavoritesDiffableDataSource.swift
//  Navvy
//
//  Created by Samuel Shi on 1/7/22.
//

import UIKit

class FavoritesDiffableDataSource: UITableViewDiffableDataSource<FavoritesDiffableDataSource.Section, Destination> {
    enum Section { case favorites }
    
    var favorites: [NavigationViewModel] = []
    
    var shouldAnimateDifferences: (() -> Bool)!
    var showEmptyView: (() -> Void)!
    var hideEmptyView: (() -> Void)!
    
    override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, Destination>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
        defaultRowAnimation = .left
    }
    
    func update(destinations: [Destination]) {
        favorites = destinations.map(NavigationViewModel.init)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Destination>()
        snapshot.appendSections([.favorites])
        snapshot.appendItems(destinations)
        apply(snapshot, animatingDifferences: shouldAnimateDifferences())
    }
    
    override func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Destination>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        
        if snapshot.itemIdentifiers.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let destination = itemIdentifier(for: indexPath) else { return }
        FavoritesDataStore.shared.remove(destination: destination)
    }
}
