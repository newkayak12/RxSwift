import UIKit
import RxSwift

/*:
 # catch(_:)
 */


let bag = DisposeBag()

enum MyError: Error {
    case error
}

let subject = PublishSubject<Int>()
let recovery = PublishSubject<Int>()

subject
    .subscribe { print($0) }
    .disposed(by: bag)


