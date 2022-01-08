//
//  AutocompleteResultsVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import Combine
import MapKit
import UIKit

protocol AutocompleteResultsVCDelegate: AnyObject {
    func didSelectSearchResult(result: NavigationViewModel)
    func changeSearchBarText(newText: String)
}

class AutocompleteResultsVC: UIViewController {
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
        label.numberOfLines = 0
        return label
    }()
    
    var searchViewModel: SearchViewModel!
    var cancellables = [AnyCancellable]()
    var autocompleteResults = [MKLocalSearchCompletion]()
    weak var delegate: AutocompleteResultsVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
        cell.backgroundColor = .primaryBackground
        
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
        let autocompleteResult = autocompleteResults[indexPath.row]
        
        if autocompleteResult.isSearchNearby {
            searchViewModel.searchNearby(query: autocompleteResult.title, changeRegion: true)
            delegate.changeSearchBarText(newText: autocompleteResult.title)
            dismiss(animated: true)
        } else {
            searchViewModel.fetchDestination(forSearchCompletion: autocompleteResult) { [weak self] result in
                guard case .success(let destination) = result, let self = self else { return }
                let navigationVM = NavigationViewModel(destination: destination)
                self.delegate.didSelectSearchResult(result: navigationVM)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MKLocalSearchCompletion {
    var isSearchNearby: Bool {
        subtitle == "Search Nearby"
    }
}
