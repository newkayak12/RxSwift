/**
 에러 전달 X
 MainThread에서 기본적으로 실행(스케쥴러 변경이 없는 한)
 Driver는 sideEffect를 공유한다.
 일반 Observable에서 share를 호출하고 subscribe를 한 것과 같다. (시퀀스 공유)
 가장 최근의 이벤트 하나를 버퍼해놓는다.
 */
import UIKit
import RxSwift
import RxCocoa

enum ValidationError: Error {
    case notANumber
}

class DriverViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let result = inputField.rx.text
//            .flatMapLatest {
//                validateText($0)
//                    .observe(on: MainScheduler.instance) //background에서 돌 수도2
//                    .catchAndReturn(false)
//            }
//            .share()
        let result = inputField.rx.text.asDriver()
            .flatMapLatest{
                validateText($0)
                    .asDriver(onErrorJustReturn: false)
            }
        
        result
            .map { $0 ? "Ok" : "Error" }
//            .bind(to: resultLabel.rx.text) //driver를 사용하면 dribe로 대체
            .drive(resultLabel.rx.text)
            .disposed(by: bag)
        
        result
            .map { $0 ? UIColor.blue : UIColor.red }
//            .bind(to: resultLabel.rx.backgroundColor)
            .drive(resultLabel.rx.backgroundColor)
            .disposed(by: bag)
        
        result
//            .bind(to: sendButton.rx.isEnabled)
            .drive(sendButton.rx.isEnabled)
            .disposed(by: bag)
        
    }
}


func validateText(_ value: String?) -> Observable<Bool> {
    return Observable<Bool>.create { observer in
        print("== \(value ?? "") Sequence Start ==")
        
        defer {
            print("== \(value ?? "") Sequence End ==")
        }
        
        guard let str = value, let _ = Double(str) else {
            observer.onError(ValidationError.notANumber)
            return Disposables.create()
        }
        
        observer.onNext(true)
        observer.onCompleted()
        
        return Disposables.create()
    }
}
