//
//  ViewController.swift
//  RxDataSourcesSample
//
//  Created by sana on 2018/10/19.
//  Copyright © 2018年 takagisou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ViewModel!
    var disposeBag = DisposeBag()
    var dataSources: RxTableViewSectionedAnimatedDataSource<SectionModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addAction(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Add", bundle: nil).instantiateInitialViewController() else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
    }    
 
    private func configureTableView() {
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    private func bindRx() {
        self.disposeBag = DisposeBag()
        self.viewModel = ViewModel()
        
        let animationConfiguration = AnimationConfiguration(insertAnimation: .fade,
                                                            reloadAnimation: .fade,
                                                            deleteAnimation: .fade)
        
        dataSources = RxTableViewSectionedAnimatedDataSource<SectionModel>
            .init(animationConfiguration: animationConfiguration,
                  decideViewTransition: { (dataSources, tableView, changeSet) -> ViewTransition in
                    //
                    return .animated
            }, configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
                
                if indexPath.row == 0 {
                    print("[indexPath:0], \(item), count:\(item.itemCount)")
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
                if let cell = cell as? TableViewCell {
                    cell.configure(viewModel: item.viewModel)

                }
                return cell
            }, titleForHeaderInSection: { (dataSource, section) -> String? in
                return nil
            }, titleForFooterInSection: { (dataSource, section) -> String? in
                return nil
            }, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
                return false
            }, canMoveRowAtIndexPath: { (dataSource, indexPath) -> Bool in
                return false
            }, sectionIndexTitles: { (dataSource) -> [String]? in
                return nil
            }, sectionForSectionIndexTitle: { (dataSource, title, index) -> Int in
                return index
            })
        
        viewModel.items
            .debug()
            .bind(to: tableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { (at: $0, animated: false) }
            .subscribe(onNext: tableView.deselectRow)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SectionItem.self)
            .subscribe(onNext: { [weak self] item in
                self?.viewModel.tapped(cellViewModel: item.viewModel)
            }).disposed(by: disposeBag)
        
    }
}

