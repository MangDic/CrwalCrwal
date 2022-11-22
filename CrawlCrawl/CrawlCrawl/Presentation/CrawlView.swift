//
//  CrawlView.swift
//  CrawlCrawl
//
//  Created by 이명직 on 2022/11/17.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class CrawlView: UIView {
    // MARK: Properties
    let disposeBag = DisposeBag()
    let searchRelay = PublishRelay<String>()
    let dataRelay = BehaviorRelay<[ImageData]>(value: [])
    
    var downloadCompletedCount = 0
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Dependency Injection
    func setupDI(dataRelay: BehaviorRelay<[ImageData]>) {
        dataRelay.bind(to: self.dataRelay).disposed(by: disposeBag)
    }
    
    // MARK: Binding
    private func bind() {
        searchBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                guard let text = self.inputField.text else { return }
                self.downloadCompletedCount = 0
                self.searchRelay.accept(text)
                DispatchQueue.main.async {
                    self.endEditing(true)
                    self.searchBtn.isEnabled = false
                    self.searchBtn.backgroundColor = R.Color.Crwal.disabled
                }
            }).disposed(by: disposeBag)
        
        allDownloadBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.downLoadAll()
            }).disposed(by: disposeBag)
        
        dataRelay.asDriver(onErrorJustReturn: [])
            .asDriver()
            .drive(tableView.rx.items) { table, row, item in
                guard let cell = table.dequeueReusableCell(withIdentifier: ImageDataCell.id) as? ImageDataCell else { return UITableViewCell() }
                cell.configure(data: item)
                cell.selectionStyle = .none
                return cell
            }.disposed(by: disposeBag)
        
        /// 데이터가 갱신되면 각 버튼의 상태와 스크롤 포지션을 업데이트 합니다.
        dataRelay.subscribe(onNext: { [weak self] data in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.allDownloadBtn.setTitle(R.String.Crwal.download_description(data.count), for: .normal)
                
                self.allDownloadBtn.backgroundColor = data.count == 0 ? R.Color.Crwal.disabled : R.Color.Crwal.normal
                self.allDownloadBtn.isEnabled = data.count != 0
                self.searchBtn.isEnabled = true
                self.searchBtn.backgroundColor = R.Color.Crwal.normal
                
                self.tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: true)
            }
        }).disposed(by: disposeBag)
        
        /// 셀을 클릭하면 해당 이미지를 다운로드 합니다.
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            let item = self.dataRelay.value[indexPath.row]
            if item.isDownLoad { return }
            
            self.downLoadImage(urlStr: item.url, indexPath: indexPath) { response in
                if response {
                    self.downLoadComplete(item: item, indexPath: indexPath)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    // MARK: Method
    /// 디바이스에 선택한 이미지를 저장합니다.
    private func downLoadImage(urlStr: String, indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .default).async {
            do {
                guard let url = URL(string: urlStr) else { return }
                guard let image = UIImage(data: try Data(contentsOf: url)) else {
                    return
                }
                
                guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
                    return
                }
                
                var filePath = URL(fileURLWithPath: path)
                filePath.appendPathComponent((urlStr as NSString).lastPathComponent)
                
                
                FileManager().createFile(atPath: filePath.path,
                                         contents: image.pngData(),
                                         attributes: nil)
                self.downloadCompletedCount += 1
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                completion(true)
            }
            catch {
                print("이미지 저장 실패")
                return
            }
        }
    }
    
    private func downLoadAll() {
        var row = 0
        allDownloadBtn.isEnabled = false
        for item in dataRelay.value {
            let indexPath = IndexPath(row: row, section: 0)
            if !item.isDownLoad {
                self.downLoadImage(urlStr: item.url, indexPath: indexPath, completion: { [weak self] respone in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        if self.downloadCompletedCount != self.dataRelay.value.count {
                            let percent = Int(round((Double(self.downloadCompletedCount)/Double(self.dataRelay.value.count))*100))
                            self.reloadRow(indexPath: indexPath)
                            self.allDownloadBtn.setTitle(R.String.Crwal.downloading_description(percent), for: .disabled)
                            
                        }
                        else {
                            self.allDownloadBtn.setTitle(R.String.Crwal.complete_download, for: .disabled)
                            self.downLoadComplete(item: item, indexPath: indexPath)
                        }
                    }
                })
            }
            row += 1
        }
    }
    
    private func downLoadComplete(item: ImageData, indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.showToast(title: item.title)

            self.reloadRow(indexPath: indexPath)
            
            let difCount = self.dataRelay.value.count - self.downloadCompletedCount
            if difCount == 0 {
                self.allDownloadBtn.backgroundColor = R.Color.Crwal.disabled
                self.allDownloadBtn.setTitle(R.String.Crwal.complete_download, for: .disabled)
            }
            else {
                self.allDownloadBtn.backgroundColor = R.Color.Crwal.normal
                self.allDownloadBtn.setTitle(R.String.Crwal.download_description(difCount), for: .normal)
            }
        }
    }
    
    /// 다운로드가 끝나면 해당 셀을 업데이트 합니다.(다운로드 완료 레이어)
    private func reloadRow(indexPath: IndexPath) {
        self.dataRelay.value[indexPath.row].isDownLoad = true
        UIView.performWithoutAnimation {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    /// 다운로드 후 토스트를 보여줍니다.
    private func showToast(title: String) {
        DispatchQueue.main.async {
            self.toastTitle.text = R.String.Crwal.complete_download
            self.toastView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                self.toastView.alpha = 1
            },completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.toastView.alpha = 0
                }, completion: { _ in
                    self.toastView.isHidden = true
                })
            })
        }
    }
    
    // MARK: View
    lazy var contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    lazy var searchStack = UIStackView().then {
        $0.spacing = 10
    }
    
    lazy var inputBackgroundView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = R.Color.Crwal.normal_layer.cgColor
        $0.layer.borderWidth = 1
    }
    
    lazy var inputField = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.placeholder = R.String.Crwal.search_placeholder
    }
    
    lazy var searchBtn = UIButton().then {
        $0.setTitle(R.String.Crwal.search_description, for: .normal)
        $0.setTitle(R.String.Crwal.searching_description, for: .disabled)
        $0.backgroundColor = R.Color.Crwal.normal
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.sizeToFit()
    }
    
    lazy var allDownloadBtn = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.titleLabel?.textColor = R.Color.Crwal.white_title
        $0.isEnabled = false
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .disabled)
        $0.setTitle(R.String.Crwal.download_description(0), for: .disabled)
        $0.backgroundColor = R.Color.Crwal.disabled
        $0.layer.cornerRadius = 8
    }
    
    lazy var tableView = UITableView().then {
        $0.rowHeight = UITableView.automaticDimension
        $0.register(ImageDataCell.self, forCellReuseIdentifier: ImageDataCell.id)
        $0.separatorStyle = .none
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
    }
    
    lazy var toastView = UIView().then {
        $0.backgroundColor = R.Color.Crwal.toast_background
        $0.layer.cornerRadius = 8
        $0.isHidden = true
        $0.alpha = 0
        $0.isUserInteractionEnabled = false
    }
    
    lazy var toastTitle = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = R.Color.Crwal.white_title
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private func setupLayout() {
        addSubview(contentStack)
        addSubview(toastView)
        
        contentStack.addArrangedSubview(searchStack)
        contentStack.addArrangedSubview(allDownloadBtn)
        contentStack.addArrangedSubview(tableView)
        
        searchStack.addArrangedSubview(inputBackgroundView)
        searchStack.addArrangedSubview(searchBtn)
        
        inputBackgroundView.addSubview(inputField)
        
        toastView.addSubview(toastTitle)
        
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        inputField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        searchBtn.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 60, height: 30))
        }
        
        toastView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        toastTitle.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
}
