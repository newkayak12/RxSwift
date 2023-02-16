import UIKit
import RxSwift

/*:
 # catch(_:)
 */

/**
 Rx으로 네트워크 Observable을 구독한 UI가 있다고 해보자
 1. 에러 이벤트가 전달되면 새로운 Observable전달 (catch사용 -> next, completed은 그대로 error는 새로운 Observable)
 2. 에러가 발생하면 Observable을 다시 구독하고 재시도한다.
 
 
 catch에서 Observable을 리턴하거나 Default Value를 사용한다.
 */
let bag = DisposeBag()

enum MyError: Error {
    case error
}

let subject = PublishSubject<Int>()
let recovery = PublishSubject<Int>()

subject
    .catch{ _ in recovery}
    .subscribe { print($0) }
    .disposed(by: bag)

subject.onError(MyError.error)
subject.onNext(123)//당연히 더 이상 전달되지 않는다. - catch를 붙이고 -> 에러가 전달되지 않는다.
subject.onNext(44) //더 이상 값을 전달하지 못한다.

recovery.onNext(22) //recovery의 이벤트가 전달된다.
recovery.onCompleted()//recovery의 구독 종료

