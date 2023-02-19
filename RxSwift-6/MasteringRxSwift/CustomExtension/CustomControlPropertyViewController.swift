
import UIKit
import RxSwift
import RxCocoa

class CustomControlPropertyViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    @IBOutlet weak var whiteSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        whiteSlider.rx.value
//            .map { UIColor(white: CGFloat($0), alpha: 1.0) }
//            .bind(to: view.rx.backgroundColor)
//            .disposed(by: bag)
//
//        resetButton.rx.tap
//            .map { Float(0.5) }
//            .bind(to: whiteSlider.rx.value)
//            .disposed(by: bag)
//
//        resetButton.rx.tap
//            .map { UIColor(white: 0.5, alpha: 1.0) }
//            .bind(to: view.rx.backgroundColor)
//            .disposed(by: bag)
//
//
        //쓰기만 -> Binder
        //읽기 쓰기 -> ControlProperty
        
        whiteSlider.rx.color.bind(to: view.rx.backgroundColor).disposed(by: bag)
        resetButton.rx.tap
            .map { _ in UIColor(white:0.5, alpha: 1.0) }
            .bind(to: whiteSlider.rx.color.asObserver(), view.rx.backgroundColor.asObserver()) //2개 이상 옵저버를 전달할 수 있다.
            .disposed(by: bag)
    }
}

extension Reactive where Base: UISlider {
    var color: ControlProperty<UIColor?> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { (slider) in
            UIColor(white: CGFloat(slider.value), alpha: 1.0)
        }, setter: { slider, color in
            var white = CGFloat(1)
            color?.getWhite(&white, alpha: nil)
            slider.value = Float(white)
        })
    }
}
