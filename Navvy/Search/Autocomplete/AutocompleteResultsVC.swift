//
//  AutocompleteResultsVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import UIKit
import Combine
import MapKit

class AutocompleteResultsVC: UIViewController {
    var searchViewModel: SearchViewModel!
    var results = [MKLocalSearchCompletion]()
    var cancellables = [AnyCancellable]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AutocompleteTableViewCell.self, forCellReuseIdentifier: AutocompleteTableViewCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        searchViewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { results in
                self.results = results
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension AutocompleteResultsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteTableViewCell.reuseId) as? AutocompleteTableViewCell else {
            return UITableViewCell()
        }
        
        let result = results[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: result.isSearchNearby ? "magnifyingglass.circle.fill" : "mappin.circle.fill")
        content.text = result.title
        content.secondaryText = result.subtitle
        cell.contentConfiguration = content
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}

extension AutocompleteResultsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        
        if result.isSearchNearby {
            searchViewModel.searchNearby(query: result.title, changeRegion: true)
            dismiss(animated: true)
        } else {
            // Show navigation screen
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MKLocalSearchCompletion {
    var isSearchNearby: Bool {
        subtitle == "Search Nearby"
    }
}
