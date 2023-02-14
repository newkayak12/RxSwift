import UIKit
import RxSwift

/*:
 # retry
 */

let bag = DisposeBag()

enum MyError: Error {
    case error
}

var attempts = 1

let source = Observable<Int>.create { observer in
    let currentAttempts = attempts
    print("#\(currentAttempts) START")
    
    if attempts < 3 {
        observer.onError(MyError.error)
        attempts += 1
    }
    
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    
    return Disposables.create {
        print("#\(currentAttempts) END")
    }
}

source
    .subscribe { print($0) }
    .disposed(by: bag)





