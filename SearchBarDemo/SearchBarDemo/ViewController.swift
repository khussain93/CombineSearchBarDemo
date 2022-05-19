//
//  ViewController.swift
//  SearchBarDemo
//
//  Created by Khateeb H. on 5/16/22.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(
                for: UITextField.textDidChangeNotification,
                object: self)
            .map(\.object)
            .map { $0 as! UITextField }
            .map(\.text)
            .eraseToAnyPublisher()
    }
}

struct Person: Hashable {
    let name: String
}

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
        
    var cancellables = Set<AnyCancellable>()
    var allPeople:[Person] = [Person(name: "John Michael"), Person(name: "Kenvin Jones"), Person(name: "Strong Michael")]
    var peopleFiltered = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupPipelines()
    }

    func setupPipelines() {
        let searchStream = searchBar.searchTextField.textPublisher
            .prepend(searchBar.text!)
            .eraseToAnyPublisher()

        let sparsedSearchStream = searchStream
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        sparsedSearchStream
            .sink(
                receiveValue: {[unowned self] searchText in
                    self.doSearching(by: searchText ?? "")
            })
            .store(in: &cancellables)
    }
    
    private func doSearching(by searchTerm: String) {
        self.peopleFiltered = self.allPeople.filter{$0.name.lowercased().contains(searchTerm.lowercased())}
            self.tableView.reloadData()
    }
}

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "TextCell")
        cell.textLabel?.text = peopleFiltered[indexPath.row].name
        return cell
    }
    
    
}
