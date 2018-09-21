//
//  CategoriesViewController.swift
//  Notes
//
//  Created by Sami Youssef on 9/20/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {

    var note: Note?
    private var context: NSManagedObjectContext {
        guard let context = note?.managedObjectContext else {
            fatalError("no context")
        }
        return context
    }
    private lazy var fetchedResultscontroller: NSFetchedResultsController<Category> = {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Category.name), ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    lazy var addBarButtonItem: UIBarButtonItem = {
        let addBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                         action: #selector(addCategoryTapped(_:)))
        return addBarItem
    }()

    private lazy var categoriesTableView: UITableView = {
        let categoriesTableView = UITableView()
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        return categoriesTableView
    }()

    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = "You don't have any Categories yet"
        messageLabel.textColor = .lightGray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()

    private var hasNotes: Bool {
        guard let categories = fetchedResultscontroller.fetchedObjects else { return false }
        return categories.count > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categories"
        navigationItem.setRightBarButton(addBarButtonItem, animated: true)

        setUpView()
        fetchCategories()
        updateView()
    }

    private func setUpView() {
        view.addSubview(categoriesTableView)
        view.addSubview(messageLabel)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

        NSLayoutConstraint.activate([
            categoriesTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 16),
            categoriesTableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            categoriesTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 16)
            ])
    }

    private func fetchCategories() {
        do {
            try fetchedResultscontroller.performFetch()
        } catch {
            print("unable to fetch categories")
            print("\(error) \n \(error.localizedDescription)")
        }
    }

    private func updateView() {
        categoriesTableView.isHidden = !hasNotes
        messageLabel.isHidden = hasNotes
    }

    @objc private func addCategoryTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter category name please"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0] else { return }
            if let categoryName = textField.text?.trim(), !categoryName.isEmpty {
                self.saveCategory(with: categoryName)
            }
        }))
        self.present(alert, animated: true)
    }

    private func saveCategory(with name: String) {
        let category = Category(context: context)
        category.name = name
    }

    private func editCategory(_ category: Category) {
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter category name please"
            textField.text = category.name
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0] else { return }
            if let categoryName = textField.text?.trim(), !categoryName.isEmpty {
                category.name = categoryName
            }
        }))
        self.present(alert, animated: true)
    }

}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultscontroller.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultscontroller.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        note?.category = fetchedResultscontroller.object(at: indexPath)
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let category = fetchedResultscontroller.object(at: indexPath)
        editCategory(category)
    }
}

extension CategoriesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categoriesTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categoriesTableView.endUpdates()
        updateView()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                categoriesTableView.insertRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath,
                let cell = categoriesTableView.cellForRow(at: indexPath) {
                configure(cell, at: indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                categoriesTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath {
                categoriesTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                categoriesTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }

    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let category = fetchedResultscontroller.object(at: indexPath)
        cell.accessoryType = .detailDisclosureButton
        cell.textLabel?.textColor = (note?.category == category) ? .bitterSweet : .black
        cell.textLabel?.text = category.name
    }
}
