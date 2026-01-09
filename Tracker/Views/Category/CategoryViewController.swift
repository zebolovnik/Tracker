//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 05.01.2026.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private let categoryViewModel: CategoryViewModel
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .ypBackground
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var placeholderImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Error"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(categoryViewModel: CategoryViewModel) {
        self.categoryViewModel = categoryViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        view.addSubview(addButton)
        
        updatePlaceholderVisibility()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 232),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func bindViewModel() {
        categoryViewModel.onCategoriesUpdated = { [weak self] _ in
            self?.tableView.reloadData()
            self?.updatePlaceholderVisibility()
        }
    }
    
    private func updatePlaceholderVisibility() {
        let hasCategories = !categoryViewModel.getCategories().isEmpty
        tableView.isHidden = !hasCategories
        placeholderImage.isHidden = hasCategories
        placeholderLabel.isHidden = hasCategories
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let vc = NewCategoryViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryViewModel.getCategories().count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let title = categoryViewModel.getCategories()[indexPath.row]
        let isSelected = categoryViewModel.isCategorySelected(title)
        
        cell.configure(with: title, isSelected: isSelected)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categoryViewModel.getCategories()[indexPath.row]
        
        categoryViewModel.selectCategory(category)
        delegate?.didSelectCategory(category)
        
        tableView.reloadData()
        dismiss(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        let category = categoryViewModel.getCategories()[indexPath.row]
        
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self else { return }

            let oldTitle = self.categoryViewModel.getCategories()[indexPath.row]

            let vc = NewCategoryViewController()
            vc.initialTitle = oldTitle

            vc.onSave = { [weak self] newTitle in
                self?.categoryViewModel.updateCategory(
                    oldTitle: oldTitle,
                    newTitle: newTitle
                )
            }

            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }
        
        let deleteAction = UIAction(
            title: "Удалить",
            attributes: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            
            let alert = UIAlertController(
                title: "Эта категория точно не нужна?",
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let confirm = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                self.categoryViewModel.deleteCategory(category)
            }
            
            let cancel = UIAlertAction(title: "Отменить", style: .cancel)
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            UIMenu(
                title: "",
                options: .displayInline,
                children: [editAction, deleteAction]
            )
        }
    }
}

// MARK: - NewCategoryDelegate

extension CategoryViewController: NewCategoryDelegate {
    func addNewCategory(newCategory: String) {
        categoryViewModel.addCategory(newCategory)
    }
}
