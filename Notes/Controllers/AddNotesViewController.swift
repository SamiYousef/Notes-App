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

    private lazy var categoryContainer: UIView = {
        let categoryContainer = UIView()
        categoryContainer.isHidden = note == nil
        categoryContainer.translatesAutoresizingMaskIntoConstraints = false
        return categoryContainer
    }()

    private lazy var categoryTitle: UILabel = {
        let categoryTitle = UILabel()
        categoryTitle.text = "Category"
        categoryTitle.textColor = .lightGray
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        return categoryTitle
    }()

    private lazy var categoryName: UILabel = {
        let categoryName = UILabel()
        categoryName.textColor = .darkGray
        categoryName.text = "No Category"
        categoryName.translatesAutoresizingMaskIntoConstraints = false
        return categoryName
    }()

    private lazy var editCategoryButton: UIButton = {
        let editCategoryButton = UIButton(type: .system)
        editCategoryButton.setTitle("Edit", for: .normal)
        editCategoryButton.addTarget(self, action: #selector(editCatitegoryButtonTaped(_:)), for: .touchDown)
        editCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        return editCategoryButton
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
        setUpNotificationHandlling()
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
        view.addSubview(categoryContainer)

        categoryContainer.addSubview(categoryTitle)
        categoryContainer.addSubview(categoryName)
        categoryContainer.addSubview(editCategoryButton)

        view.addSubview(contentsTextView)
        view.addSubview(saveButton)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            titleTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16)
            ])

        NSLayoutConstraint.activate([
            categoryContainer.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            categoryContainer.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            categoryContainer.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            categoryContainer.heightAnchor.constraint(equalToConstant: 70)
            ])

        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            categoryTitle.trailingAnchor.constraint(equalTo: editCategoryButton.leadingAnchor),
            categoryTitle.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 8)
            ])

        NSLayoutConstraint.activate([
            categoryName.leadingAnchor.constraint(equalTo: categoryTitle.leadingAnchor),
            categoryName.trailingAnchor.constraint(equalTo: categoryTitle.trailingAnchor),
            categoryName.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 8)
            ])

        NSLayoutConstraint.activate([
            editCategoryButton.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),
            editCategoryButton.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 16),
            editCategoryButton.widthAnchor.constraint(equalToConstant: 80)
            ])

        NSLayoutConstraint.activate([
            contentsTextView.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            contentsTextView.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),
            contentsTextView.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 16),
            contentsTextView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.5)
            ])

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: contentsTextView.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: contentsTextView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }

    private func setUpNotificationHandlling() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(valueDidChange(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: note?.managedObjectContext)
    }

    @objc private func valueDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        if (updates.filter{ $0 == note}).count > 0 {
            categoryName.text = note?.category?.name ?? "No category"
        }
    }

    @objc private func editCatitegoryButtonTaped(_ sender: UIButton) {
        let categoriesController = CategoriesViewController()
        categoriesController.note = note
        self.navigationController?.pushViewController(categoriesController, animated: true)
    }

    private func setUpViewData() {
        guard let note = note else { return }
        titleTextField.text = note.title
        contentsTextView.text = note.contents
        categoryName.text = note.category?.name
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

