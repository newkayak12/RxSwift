import UIKit
import RxSwift


/*:
 # replay, replayAll
 */

let bag = DisposeBag()
//let subject = PublishSubject<Int>()
let subject = ReplaySubject<Int>.create(bufferSize: 5) //소실되는 이벤트를 Replay로 저장
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)//.multicast(subject)
    .replay(5)//혹은 이렇게 replay연산자 혹은 replayAll로 버퍼 지정 없이 사용할 수 있다.

source
    .subscribe { print("🔵", $0) }
    .disposed(by: bag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }
    .disposed(by: bag)

source.connect()
//두 번째 구독자는 모든 이벤트를 받을 수 없다.
/**
 만약 두 번째 구독자에게 모두 전달하고 싶다면???
 ReplaySubject로 버퍼링할 수 있다.
 */
















