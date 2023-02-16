import UIKit
import RxSwift

/*:
 # retry
 */

/**
 에러가 발생하면 기존 구독을 해제하고 새로운 구독을 한다.
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
//    .retry() //Observable이 정상적으로 완료될 때까지 재시도
    .retry(2) // 첫 시도도 retry에 포함된다.
    .subscribe { print($0) }
    .disposed(by: bag)

//재시도 횟수 내에 성공하면 종료한다.
//재시도 사이 sleep은 따로 지정할 수 없다.



