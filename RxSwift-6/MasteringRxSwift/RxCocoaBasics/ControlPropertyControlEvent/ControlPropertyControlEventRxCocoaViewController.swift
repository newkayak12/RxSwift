/**
 trait UI에 특화된 Observable
 ControlProperty
 ControlEvent
 Driver
 Signal
 모든 작업은 MainScheduler에서 진행된다. trait는 error를 전파하지 않는다.
 trait는 새로운 시퀀스가 실행되지 않는다.
 trait를 구독하면 공유 구독이 된다.
 
 
 
 
 
        Observable  ->  ControlProperty -----> share(replay: 1) ------> subscriber
        controlEvent (next, completed ✓ error ❌ ) -----> share() ----> subscriber
 
 */
import UIKit
import RxSwift
import RxCocoa

class ControlPropertyControlEventRxCocoaViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var redComponentLabel: UILabel!
    @IBOutlet weak var greenComponentLabel: UILabel!
    @IBOutlet weak var blueComponentLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    
    private func updateComponentLabel() {
        redComponentLabel.text = "\(Int(redSlider.value))"
        greenComponentLabel.text = "\(Int(greenSlider.value))"
        blueComponentLabel.text = "\(Int(blueSlider.value))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redSlider.rx.value
            .map{ "\(Int($0))"}
            .bind(to: redComponentLabel.rx.text)
            .disposed(by: bag)
        greenSlider.rx.value
            .map{ "\(Int($0))"}
            .bind(to: greenComponentLabel.rx.text)
            .disposed(by: bag)
        blueSlider.rx.value
            .map{ "\(Int($0))"}
            .bind(to: blueComponentLabel.rx.text)
            .disposed(by: bag)
        
        let observer = Observable.combineLatest([redSlider.rx.value, greenSlider.rx.value, blueSlider.rx.value])
        //The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions
        // 타입 추론이 어렵다는 것이 결론, 따라서 위 아래처럼 쪼개면 된다고 한다. 
        observer.map { UIColor(red: CGFloat($0[0]) / 255, green: CGFloat($0[1]) / 255, blue: CGFloat($0[2]) / 255, alpha: 1.0) }
                .bind(to: colorView.rx.backgroundColor).disposed(by:bag)


        resetButton.rx.tap
            .subscribe(onNext: { [ weak self ] in
                self?.colorView.backgroundColor = UIColor.black
                self?.redSlider.value = 0
                self?.greenSlider.value = 0
                self?.blueSlider.value = 0
                
                self?.updateComponentLabel()
            }).disposed(by: bag)
    }
}
