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

    private var notesDidChange = false
    private var notes: [Note]? {
        didSet {
            updateView()
        }
    }

    private var hasNotes: Bool {
        guard let notes = notes else { return false }
        return notes.count > 0
    }

    let coreDataManager = CoreDataManager(modelName: "Notes")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"
        navigationItem.setRightBarButton(addBarButtonItem, animated: true)

        setupView()
        fetchNotes()
        setupNotificationHandling()
    }

    @objc private func addBarItemTapped(_ sender: UIButton) {
        self.presentAddNoteController(with: nil)
    }

    private func updateView() {
        notesTableView.isEditing = !hasNotes
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

    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextdidChange(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: coreDataManager.managedObjectContext)
    }

    @objc private func managedObjectContextdidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            for insert in inserts {
                if let note = insert as? Note {
                    notes?.append(note)
                    notesDidChange = true
                }
            }
        }
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for update in updates {
                if let _ = update as? Note {
                    notesDidChange = true
                }
            }
        }
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for delete in deletes {
                if let note = delete as? Note {
                    if let index = notes?.index(of: note) {
                        notes?.remove(at: index)
                        notesDidChange = true
                    }
                }
            }
        }

        if notesDidChange {
            notes?.sort(by: { $0.updatedAtAsDate > $1.updatedAtAsDate })
            notesTableView.reloadData()
            updateView()
        }
    }

    private func fetchNotes() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]
        coreDataManager.managedObjectContext.performAndWait {
            do {
                let notes = try fetchRequest.execute()
                self.notes = notes
                self.notesTableView.reloadData()
            } catch {
                print("Unable to fetch Notes")
                print("\(error) \n \(error.localizedDescription)")
            }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let note = notes?[indexPath.row] else {
            fatalError("Unexpected index path")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.description
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = notes?[indexPath.row] else {
            fatalError("Select unexbected row")
        }
        presentAddNoteController(with: note)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let note = notes?[indexPath.row] else {
            fatalError("Unexpected indexPath")
        }
        coreDataManager.managedObjectContext.delete(note)
    }
}

