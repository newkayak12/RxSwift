/**
 Binding
 데이터 생성자 : Observable
 데이터 소비자 : UI Component
 Uni-direction
 
 binder는 데이터 바인딩에서 사용하는 Observer(소비자)
 에러 이벤트를 받지 않는다. -> 크래시 혹은 에러 메시지를 뿜는다.
 Binding이 성공하면 UI를 업데이트한다. -> MainThread에서 시작 (MainThread에서 실행되는 것이 보장 된다.)
 */

import UIKit
import RxSwift
import RxCocoa

class BindingRxCocoaViewController: UIViewController {
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var valueField: UITextField!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueLabel.text = ""
        valueField.becomeFirstResponder()
        
        
        //ControlProperty
//        valueField.rx.text
////            .observe(on: MainScheduler.instance) //#2 메인쓰레드 방법 2
//            .subscribe(onNext: { [weak self] str in
//                print("ISMAIN? \(Thread.isMainThread)")
//
////                DispatchQueue.main.async { //#1 메인쓰레드 방법 1
////                    self?.valueLabel.text = str
////                }
//
//                self?.valueLabel.text = str
//            }).disposed(by: disposeBag)
        
        
        valueField.rx.text.bind(to: valueLabel.rx.text).disposed(by: disposeBag)
        //이러면 알아서 MainThread에서 바인딩한다. (스케쥴러를 따로 지정하지 않는다면)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        valueField.resignFirstResponder()
    }
}
