
import UIKit
import RxSwift

/*:
 # takeLast
 */

let disposeBag = DisposeBag()
let subject = PublishSubject<Int>()

subject.takeLast(2)
//원본 Observable이 방출하는 next이벤트를 count 만큼 마지막에서 방출 (끝에서)
    .subscribe{ print($0) }.disposed(by: disposeBag)
// 마지막에서 ~개를 방출하는 식이라 자연스럽게 방출이 지연된다.
(1 ... 10).forEach{ subject.onNext($0) }
//이렇게 해도 방출은 안된다 지연상태다.
subject.onNext(11)
//이러면 10, 11을 담고 기다린다.

//subject.onCompleted()
//completed가 되는 순간 마지막 이벤트를 방출한다.


enum MyError: Error {
    case error
}
subject.onError(MyError.error)
//에러는 이전 버퍼를 무시하고 에러만 보낸다.
