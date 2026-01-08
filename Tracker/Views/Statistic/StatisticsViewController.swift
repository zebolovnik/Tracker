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
    private var finishedTrackersCount: Int = 0
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
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
        label.text = "Трекеров завершено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var errorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ErrorStat") // ТВОЁ название
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
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
        view.backgroundColor = .ypWhite
        setupUI()
        setupConstraints()
        statisticsService.delegate = self
        loadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
        view.addSubview(cardView)
        
        cardView.addSubview(countLabel)
        cardView.addSubview(descriptionLabel)
        
        setupGradientBorder()
        updateUI()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorImage.widthAnchor.constraint(equalToConstant: 80),
            errorImage.heightAnchor.constraint(equalToConstant: 80),
            
            errorLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupGradientBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 90)
        
        gradientLayer.colors = [
            UIColor.colorSelected1.cgColor,
            UIColor.colorSelected9.cgColor,
            UIColor.colorSelected3.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: gradientLayer.bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        cardView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func loadStatistics() {
        finishedTrackersCount = statisticsService.getFinishedTrackersCount()
        countLabel.text = "\(finishedTrackersCount)"
        updateUI()
    }
    
    private func updateUI() {
        let hasStatistics = finishedTrackersCount > 0
        
        cardView.isHidden = !hasStatistics
        errorImage.isHidden = hasStatistics
        errorLabel.isHidden = hasStatistics
    }
}

// MARK: - StatisticsServiceDelegate
extension StatisticsViewController: StatisticsServiceDelegate {
    func statisticsDidUpdate() {
        loadStatistics()
    }
}
