import UIKit
import RxSwift

/*:
 # sample
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}

/**
 dataObservable.sample(triggerObservable)
 withLatestFrom과 정반대
 
 trigger가 next이면 data에서 이벤트 방출
 그러나, 동일한 next를 방출하지 않는다는 차이점이 있다.
 */


let trigger = PublishSubject<Void>()
let data = PublishSubject<String>()

data.sample(trigger)
    .subscribe{ print($0) }
    .disposed(by: bag)

trigger.onNext(()) //data가 방출되지 않아서 구독자에 방출되지 않음

data.onNext("HALO!")
trigger.onNext(())
trigger.onNext(()) //이전 데이터를 중복 방출하지 않음

data.onCompleted() // sample은 completed를 onNext시 그대로 전달
//trigger.onNext(())

//data.onError(MyError.error) //트리거에서 next 없이도 에러 전달

trigger.onError(MyError.error) //바로 에러 전달

