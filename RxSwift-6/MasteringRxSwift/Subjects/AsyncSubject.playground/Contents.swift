
import UIKit
import RxSwift

/*:
 # AsyncSubject
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}

//publish, behavior -> 이벤트 전달시 즉시 구독자에 전달
//AsyncSubject는 completed가 전달되면 completed 직전의 onNext만 전달

let subject = AsyncSubject<Int>()

subject.subscribe{ print($0) }.disposed(by: bag)

subject.onNext(1)
subject.onNext(2)
subject.onNext(3)

//subject.onCompleted()
//마지막 onNext + onCompleted

subject.onError(MyError.error)
//onError 만




