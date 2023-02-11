import UIKit
import RxSwift

/*:
 # distinctUntilChanged
 */

struct Person {
    let name: String
    let age: Int
}

let disposeBag = DisposeBag()
let numbers = [1, 1, 3, 2, 2, 3, 1, 5, 5, 7, 7, 7]
let tuples = [(1, "하나"), (1, "일"), (1, "one")]
let persons = [
    Person(name: "Sam", age: 12),
    Person(name: "Paul", age: 12),
    Person(name: "Tim", age: 56)
]

Observable.from(numbers)
    .distinctUntilChanged() //순서대로 비교하고 이전 이벤트와 같다면 방출하지 않는다.
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
//단순히 동일한 이벤트가 연속적으로 방출되는지만 막는다.
//같은지는 $0 == $1와 같이 비교한다.
//만약 비교를 커스텀하고 싶다면 클로저나 keyPath를 받는다.

Observable.from(numbers)
    .distinctUntilChanged { !$0.isMultiple(of: 2) && !$1.isMultiple(of: 2) }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(tuples)
    .distinctUntilChanged { $0.0 }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(tuples)
    .distinctUntilChanged { $0.1 }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)


Observable.from(persons)
    .distinctUntilChanged(at: \.age)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
