import UIKit
import RxSwift

/*:
 # single
 */

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
//원본에서 첫 번째만 방출하거나 조건에 부합하는 첫 번쨰만 방출
Observable.just(1)
    .single()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(numbers)
    .single() //error(Sequence contains more than one element.)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
//하나 이상을 방출하려고 하면 에러

Observable.from(numbers)
    .single{ $0 == 3}
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

let subject = PublishSubject<Int>()
subject.single()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

subject.onNext(100) //하나 보냈다고 바로 completed를 리턴하지 않는다. 즉, 대기한다.
Thread.sleep(forTimeInterval: 1)
subject.onNext(200) //구독자에게 하나 만을 방출하는 것을 보장한다.


