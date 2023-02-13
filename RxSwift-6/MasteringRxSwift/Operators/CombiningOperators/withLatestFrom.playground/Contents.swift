import UIKit
import RxSwift

/*:
 # withLatestFrom
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}
/**
 triggerObservable.withLatestFrom(dataObservable)
 트리거가 next를 방출하면 dataObservable 가장 최근의 Next를 구독자에게 전달
 
 
 */
let trigger = PublishSubject<Void>()
let data = PublishSubject<String>()

trigger.withLatestFrom(data)
    .subscribe{ print($0) }
    .disposed(by: bag)

data.onNext("Hello")
data.onNext("RxSwift")

trigger.onNext(())
trigger.onNext(())
//trigger가 next 될 때마다 data의 최신 next를 구독자에 전달

//data.onCompleted() // 트리거가 completed여야 구독자에 completed를 전달
//data.onError(MyError.error) //에러면 구독자에 바로 전달
trigger.onNext(())
trigger.onCompleted()




