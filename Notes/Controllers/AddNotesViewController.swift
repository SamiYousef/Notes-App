//
//  AddNotesViewController.swift
//  Notes
//
//  Created by Sami Youssef on 9/15/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import UIKit
import CoreData

class AddNotesViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?

    lazy var titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.placeholder = "Note Title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        return titleTextField
    }()

    lazy var contentsTextView: UITextView = {
        let contentsTextView = UITextView()
        contentsTextView.layer.cornerRadius = 5
        contentsTextView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        contentsTextView.layer.borderWidth = 1
        contentsTextView.translatesAutoresizingMaskIntoConstraints = false
        return contentsTextView
    }()

    lazy var saveButton: UIButton = {
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveNoteTaped(_:)), for: .touchUpInside)
        saveButton.backgroundColor = .yellow
        saveButton.isHidden = note != nil
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()

    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setUpViewData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let note = note else { return }
        if let title = titleTextField.text, !title.isEmpty {
            note.title = title
        }
        note.contents = contentsTextView.text
        note.updatedAt = Date()
    }

    private func initView() {
        view.addSubview(titleTextField)
        view.addSubview(contentsTextView)
        view.addSubview(saveButton)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            titleTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16)
            ])

        NSLayoutConstraint.activate([
            contentsTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            contentsTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            contentsTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentsTextView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.5)
            ])

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: contentsTextView.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: contentsTextView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }

    private func setUpViewData() {
        guard let note = note else { return }
        titleTextField.text = note.title
        contentsTextView.text = note.contents
    }

    @objc private func saveNoteTaped(_ sender: UIButton) {
        addNote()
    }

    private func addNote() {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(with: "Title Messsing", and: "Your note does't have a title")
            return
        }

        let note = Note(context: managedObjectContext)
        note.title = title
        note.contents = contentsTextView.text
        note.createdAt = Date()
        note.updatedAt = Date()

        navigationController?.popViewController(animated: true)
    }

}
