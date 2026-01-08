//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 03.01.2026.
//

import UIKit

final class TrackerHeaderView: UICollectionReusableView {
    
    static let switchHeaderIdentifier = String(describing: TrackerHeaderView.self)
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addConstraints()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
