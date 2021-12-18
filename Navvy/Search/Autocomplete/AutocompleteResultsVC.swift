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
    var autocompleteResults = [MKLocalSearchCompletion]()
    var cancellables = [AnyCancellable]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AutocompleteTableViewCell.self, forCellReuseIdentifier: AutocompleteTableViewCell.reuseId)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var statusLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(statusLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 10)
        ])
        
        searchViewModel.$autocompleteResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.autocompleteResults = results
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        searchViewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.statusLabel.text = status.displayString
                self.statusLabel.isHidden = status == .hasResults
            }
            .store(in: &cancellables)
    }
}

extension AutocompleteResultsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteTableViewCell.reuseId) as? AutocompleteTableViewCell else {
            return UITableViewCell()
        }
        
        let result = autocompleteResults[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: result.isSearchNearby ? "magnifyingglass.circle.fill" : "mappin.circle.fill")
        content.text = result.title
        content.secondaryText = result.subtitle
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.backgroundColor = .systemBackground
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteResults.count
    }
}

extension AutocompleteResultsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autcompleteResult = autocompleteResults[indexPath.row]
        
        if autcompleteResult.isSearchNearby {
            searchViewModel.searchNearby(query: autcompleteResult.title, changeRegion: true)
            dismiss(animated: true)
        } else {
            searchViewModel.fetchAndSelectMapItem(forCompletion: autcompleteResult)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MKLocalSearchCompletion {
    var isSearchNearby: Bool {
        subtitle == "Search Nearby"
    }
}
