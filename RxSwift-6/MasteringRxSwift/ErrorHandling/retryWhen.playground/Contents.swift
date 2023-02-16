import UIKit
import RxSwift

/*:
 # retry(when:)
 */


let bag = DisposeBag()

enum MyError: Error {
    case error
}

var attempts = 1

let source = Observable<Int>.create { observer in
    let currentAttempts = attempts
    print("START #\(currentAttempts)")
    
    if attempts < 3 {
        observer.onError(MyError.error)
        attempts += 1
    }
    
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    
    return Disposables.create {
        print("END #\(currentAttempts)")
    }
}

let trigger = PublishSubject<Void>()

source
    .retry{ _ in trigger}
    .subscribe { print($0) }
    .disposed(by: bag)

//트리거가 next를 방출할 때까지 기다린다.
trigger.onNext(())
trigger.onNext(())
trigger.onNext(())
