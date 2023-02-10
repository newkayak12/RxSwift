import UIKit
import RxSwift

/*:
 # take(while:)
 */

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


Observable.from(numbers).take(while: {!$0.isMultiple(of: 2)}, behavior: .exclusive)
//조건을 충족하는 이벤트만 방출
//behavior -> exclusive, inclusive
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

//단 predicate가 false가 되면 중지(.exclusive)


Observable.from(numbers).take(while: {!$0.isMultiple(of: 2)}, behavior: .inclusive)
//조건을 충족하는 이벤트만 방출
//behavior -> exclusive, inclusive
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

//단 predicate가 false가 되면 중지(.inclusive ==> 마지막 값 포함)

