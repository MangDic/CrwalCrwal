//
//  ImageDataCell.swift
//  CrawlCrawl
//
//  Created by 이명직 on 2022/11/21.
//
import UIKit

class ImageDataCell: UITableViewCell {
    // MARK: Properties
    static let id = "ImageDataCell"
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Data Configuration
    func configure(data: ImageData) {
        titleLabel.text = data.title
        guard let url = URL(string: data.url) else {
            return
        }
        
        thumbNail.snp.updateConstraints {
            $0.size.equalTo(data.size)
        }
        
        self.thumbNail.kf.setImage(with: url)
        
        containerView.layer.borderColor = data.isDownLoad ?  R.Color.Crwal.download_complete_layer.cgColor : R.Color.Crwal.normal_layer.cgColor
    }
    
    // MARK: View
    lazy var containerView = UIView()

    lazy var stack = UIStackView().then {
        $0.spacing = 10
        $0.axis = .vertical
    }
    
    lazy var thumbNail = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = R.Color.Crwal.cell_title
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    lazy var bottomMarginView = UIView()
    
    private func setupLayout() {
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 3
        containerView.layer.borderColor = R.Color.Crwal.normal_layer.cgColor
        
        contentView.addSubview(containerView)
        contentView.addSubview(bottomMarginView)
        
        containerView.addSubview(stack)

        stack.addArrangedSubview(thumbNail)
        stack.addArrangedSubview(titleLabel)
        
        containerView.snp.makeConstraints {
            $0.top.left.trailing.equalToSuperview()
        }
        
        stack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
        
        thumbNail.snp.makeConstraints {
            $0.size.equalTo(50)
        }
        
        bottomMarginView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(containerView.snp.bottom)
            $0.height.equalTo(10)
        }
    }
}

