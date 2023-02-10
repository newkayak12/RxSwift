import UIKit
import RxSwift

/*:
 # take(until:)
 */

let disposeBag = DisposeBag()


var subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()
/** take(until: ObservableType)*/
subject.take(until: trigger)
//trigger가 onNext를 전달하면
    .subscribe{ print($0) }.disposed(by: disposeBag)

subject.onNext(1)
subject.onNext(2)
//원본 이벤트를 더 이상 전달하지 않는다. ==> completed가 된다.
trigger.onNext(0)
subject.onNext(3)

/** take(until: (Int) -> Bool, behavior: TakeBehavior)*/
//predicate가 true가 되면 complete
subject.take(until: { $0 > 5 }, behavior:.exclusive)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

subject.onNext(1)
subject.onNext(2)
subject.onNext(4)
subject.onNext(6) //completed
subject.onNext(2)








