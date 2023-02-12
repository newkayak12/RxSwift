import UIKit
import RxSwift

/*:
 # groupBy
 */
//

let disposeBag = DisposeBag()
let words = ["Apple", "Banana", "Orange", "Book", "City", "Axe"]

Observable.from(words)
//    .groupBy { $0.count }
//    .subscribe{ print($0) }
//    .subscribe(onNext: {groupedObservable in
//        print("== \(groupedObservable.key)")
//        groupedObservable.subscribe{ print("  \($0)") }
//    })
    .groupBy{ $0.first ?? Character(" ") }
    .flatMap{ $0.toArray() }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)



Observable.range(start: 1, count: 10)
    .groupBy{ $0.isMultiple(of: 2) }
    .flatMap{ $0.toArray() }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)



