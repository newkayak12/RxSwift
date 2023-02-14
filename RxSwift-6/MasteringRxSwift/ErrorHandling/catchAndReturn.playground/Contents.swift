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
    .subscribe { print($0) }
    .disposed(by: bag)

subject.onError(MyError.error)
