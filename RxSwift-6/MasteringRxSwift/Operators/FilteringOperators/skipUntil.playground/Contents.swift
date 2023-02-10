
import UIKit
import RxSwift

/*:
 # skip(until:)
 */

let disposeBag = DisposeBag()
//until의 Observable이 trigger로 작동된다.
//Observable.just(1).skip(until: <#T##ObservableType#>)

let subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()
subject.skip(until: trigger).subscribe{ print($0) }.disposed(by: disposeBag)

subject.onNext(1)
print("NXT")
trigger.onNext(0)
subject.onNext(2)

//trigger가 방출된 이후 이벤트만 방출
