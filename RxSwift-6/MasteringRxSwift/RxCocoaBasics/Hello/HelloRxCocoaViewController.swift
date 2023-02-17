import UIKit
import RxSwift
import RxCocoa


class HelloRxCocoaViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var tapButton: UIButton!
    //oulet으로 연결
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapButton.rx.tap
            .map{ "Hello, RxCocoa"}
//            .subscribe(onNext: {[weak self] str in
//                self?.valueLabel.text = str
//            })
//        이것 보다 더 좋은 것?
            .bind(to: valueLabel.rx.text)
            .disposed(by: bag)
        
    }
}
