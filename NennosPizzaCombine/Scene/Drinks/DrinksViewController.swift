//
//  DrinksViewController.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 13..
//

import Combine
import UIKit

class DrinksViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private var datasource = [ItemCellViewModel]()
    private var subscriptions = Set<AnyCancellable>()

    var viewModel: DrinksViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        bindViewModel()
    }

    private func bindViewModel() {
        guard let viewModel = viewModel else { return }

        viewModel.tableData
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.handleCompletion(completion: completion)
            }, receiveValue: { [weak self] tableData in
                guard let self = self else { return }
                self.datasource = tableData
                self.tableView.reloadData()
            }).store(in: &subscriptions)
    }

    private func handleCompletion(completion: Subscribers.Completion<PizzaServiceError>) {
        switch completion {
        case let .failure(error):
            showError(error: error)
        case .finished:
            return
        }
    }

    private func showError(error: PizzaServiceError) {
        let message = error.localizedDescription
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension DrinksViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell else { return UITableViewCell() }
        cell.config(with: datasource[indexPath.row])
        return cell
    }
}

extension DrinksViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        44
    }
}
