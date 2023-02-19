
import UIKit
import RxSwift
import RxCocoa

class CustomBinderViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var colorPicker: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        colorPicker.rx.selectedSegmentIndex
//            .map { index -> UIColor in
//                switch index {
//                case 0:
//                    return UIColor.red
//                case 1:
//                    return UIColor.green
//                case 2:
//                    return UIColor.blue
//                default:
//                    return UIColor.black
//                }
//            }
//            .subscribe(onNext: { [weak self] color in
//                self?.valueLabel.textColor = color
//            })
//            .disposed(by: bag)
//
//        colorPicker.rx.selectedSegmentIndex
//            .map { index -> String? in
//                switch index {
//                case 0:
//                    return "Red"
//                case 1:
//                    return "Green"
//                case 2:
//                    return "Blue"
//                default:
//                    return "Unknown"
//                }
//            }
//            .bind(to: valueLabel.rx.text)
//            .disposed(by: bag)
        colorPicker.rx.selectedSegmentIndex.bind(to: valueLabel.rx.segmentedValue).disposed(by: bag)
    }
}

extension Reactive where Base: UILabel {
    var segmentedValue: Binder<Int> {
        return Binder(self.base) { label, index in
            switch (index){
                case 0:
                    label.text = "Red"
                    label.textColor = UIColor.red
                case 1:
                    label.text = "Green"
                    label.textColor = UIColor.green
                case 2:
                    label.text = "Blue"
                    label.textColor = UIColor.blue
                default:
                    label.text = "Unknown"
                    label.textColor = UIColor.black
            }
            
        }
    }
}
