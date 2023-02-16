import UIKit
import RxSwift

/*:
 # catchAndReturn
 */

let bag = DisposeBag()

enum MyError: Error {
    case error
}

let subject = PublishSubject<Int>()

subject
    .catchAndReturn(4)
    .subscribe { print($0) }
    .disposed(by: bag)

subject.onError(MyError.error) //catchAndReturn의 파라미터 값 전달
