//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 07.01.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let statisticsService = StatisticsService.shared
    
    private var finishedTrackersCount: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "statistics.completed".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ErrorStat"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "statistics.empty".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        statisticsService.delegate = self
        loadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationItem.title = "statistics.title".localized
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(cardView)
        
        cardView.addSubview(countLabel)
        cardView.addSubview(descriptionLabel)
        
        setupGradientBorder()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Stub
            stubImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Card
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12)
        ])
    }
    
    // MARK: - Gradient
    
    private func setupGradientBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width - 32,
            height: 90
        )
        
        gradientLayer.colors = [
            UIColor.colorSelected1.cgColor,
            UIColor.colorSelected9.cgColor,
            UIColor.colorSelected3.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(
            roundedRect: gradientLayer.bounds,
            cornerRadius: 16
        ).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        cardView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Data
    
    private func loadStatistics() {
        finishedTrackersCount = statisticsService.getFinishedTrackersCount()
    }
    
    private func updateUI() {
        countLabel.text = "\(finishedTrackersCount)"
        
        let hasData = finishedTrackersCount > 0
        cardView.isHidden = !hasData
        stubImageView.isHidden = hasData
        stubLabel.isHidden = hasData
    }
}

// MARK: - StatisticsServiceDelegate
extension StatisticsViewController: StatisticsServiceDelegate {
    func statisticsDidUpdate() {
        loadStatistics()
    }
}
