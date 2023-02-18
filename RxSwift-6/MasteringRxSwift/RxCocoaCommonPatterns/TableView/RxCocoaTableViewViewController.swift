
import UIKit
import RxSwift
import RxCocoa


class RxCocoaTableViewViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    let priceFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.currency
        f.locale = Locale(identifier: "Ko_kr")
        
        return f
    }()
    
    let bag = DisposeBag()
    
    let nameObservable = Observable.of(appleProducts.map{ $0.name })
    let productObservable = Observable.of(appleProducts)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //#1 StandardCell
//        nameObservable.bind(to: listTableView.rx.items) { tableView, row, element in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "standardCell")!
//            cell.textLabel?.text = element
//            return cell
//        }
//
//        .disposed(by: bag)
        
        //#2
//        nameObservable.bind(to: listTableView.rx.items(cellIdentifier: "standardCell")) {
//            row, element, cell in
//            cell.textLabel?.text = element
//
//        }.disposed(by: bag)
        
        
        //#3
        productObservable.bind(to: listTableView.rx.items(cellIdentifier: "productCell", cellType: ProductTableViewCell.self)){
            [ weak self ] row, element, cell in
            cell.categoryLabel.text = element.category
            cell.productNameLabel.text = element.name
            cell.summaryLabel.text = element.summary
            cell.priceLabel.text = self?.priceFormatter.string(from: element.price as NSNumber)
        }.disposed(by: bag)
        
//        listTableView.rx.modelSelected(Product.self)
//            .subscribe(onNext: {product in
//                print(product.name)
//            }).disposed(by: bag)
//
//                      +
//
//        listTableView.rx.itemSelected
//            .subscribe(onNext: { [weak self] IndexPath in
//                self?.listTableView.deselectRow(at: IndexPath, animated: true)
//            }).disposed(by: bag)
//
//                      =
        
        Observable.zip(listTableView.rx.modelSelected(Product.self), listTableView.rx.itemSelected)
            .bind{ [weak self] (product, indexPath) in
                self?.listTableView.deselectRow(at: indexPath, animated: true)
                print(product.name)
            }
            .disposed(by: bag)
        
        
//        listTableView.delegate = self//cocoaTouch 방식으로 구현하면 Rxcocoa 방식이 동작하지 않는다.
        listTableView.rx.setDelegate(self).disposed(by: bag) //이렇게 하면 둘 다 돈다.
        
        
    }
}


extension RxCocoaTableViewViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
    }
}


