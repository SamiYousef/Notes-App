//
//  ViewController.swift
//  Notes
//
//  Created by Sami Youssef on 9/14/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataManager.managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    lazy var notesTableView: UITableView = {
        let notesTableView = UITableView()
        notesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
        return notesTableView
    }()

    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = "You don't have any notes yet"
        messageLabel.textColor = .lightGray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()

    lazy var addBarButtonItem: UIBarButtonItem = {
        let addBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                         action: #selector(addBarItemTapped(_:)))
        return addBarItem
    }()

    private var hasNotes: Bool {
        guard let notes = self.fetchedResultsController.fetchedObjects else { return false }
        return notes.count > 0
    }

    let coreDataManager = CoreDataManager(modelName: "Notes")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"
        navigationItem.setRightBarButton(addBarButtonItem, animated: true)

        setupView()
        fetchNotes()
        updateView()
    }

    @objc private func addBarItemTapped(_ sender: UIButton) {
        self.presentAddNoteController(with: nil)
    }

    private func updateView() {
        notesTableView.isHidden = !hasNotes
        messageLabel.isHidden = hasNotes
    }

    private func setupView() {
        view.addSubview(messageLabel)
        view.addSubview(notesTableView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            notesTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            notesTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 16),
            notesTableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            notesTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 16)
            ])
    }

    private func fetchNotes() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Unable to fetch Notes")
            print("\(error) \n \(error.localizedDescription)")
        }
    }

    private func presentAddNoteController(with note: Note?) {
        let addNoteController = AddNotesViewController()
        addNoteController.managedObjectContext = self.coreDataManager.managedObjectContext
        addNoteController.note = note
        navigationController?.pushViewController(addNoteController, animated: false)
    }
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        presentAddNoteController(with: note)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let note = fetchedResultsController.object(at: indexPath)
        coreDataManager.managedObjectContext.delete(note)
    }
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notesTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notesTableView.endUpdates()
        updateView()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                notesTableView.insertRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath,
                let cell = notesTableView.cellForRow(at: indexPath) {
                configure(cell, at: indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                notesTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath {
                notesTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                notesTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }

    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.description
    }
}

