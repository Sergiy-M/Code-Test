import Combine
import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate {
    private var cancellable: AnyCancellable? = nil
    private var model: Model = Model()
    private var filteredRecords: [Record] = []
    private var savedSelectedRow = -1
    private let config = Config.sharedConfig
    
    lazy var searchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        self.title = config.title
        
        cancellable = createSessionPublisher().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { error in
            // Handle error if needed (out of scope)
        }, receiveValue: { [weak self] in
            if let json = try? JSONSerialization.jsonObject(with: $0) {
                self?.model = Model.extractViewModel(json)
                self?.filterRecords(searchText: nil)
            }
        })
    }
    
    @objc private func selectFirstRowIfNeeded() {
        guard savedSelectedRow < 0 else { return }
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        guard tableView.numberOfRows(inSection: 0) > 0 else { return }
        
        let indexPath = IndexPath(row: 0, section: 0)
        savedSelectedRow = 0
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    private func checkIfLastCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == filteredRecords.count - 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let record = filteredRecords[indexPath.row]
        configure(cell, with: record)
        return cell
    }
    
    private func configure(_ cell: UITableViewCell, with record: Record) {
        var configuration = cell.defaultContentConfiguration()
        configuration.text = record.getFirstName()
        cell.contentConfiguration = configuration
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        selectFirstRowIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        savedSelectedRow = indexPath.row
        return indexPath
    }

    func filterRecords(searchText: String?) {
        if let searchString = searchText, !searchString.isEmpty {
            let lowercasedSearchString = searchString.lowercased()
            filteredRecords = model.records.filter{ $0.getFirstName().lowercased().contains(lowercasedSearchString) }
        } else {
            filteredRecords = model.records
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        filterRecords(searchText: textSearched)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailsViewController = segue.destination as? DetailsViewController else {
            return
        }
        if savedSelectedRow >= 0 {
            detailsViewController.record = filteredRecords[savedSelectedRow]
        }
        
    }

    // MARK: - API call

    func createSessionPublisher() -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: config.apiUrl) else { fatalError("Invalid URL: \(config.apiUrl)") }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .eraseToAnyPublisher()
    }
}
