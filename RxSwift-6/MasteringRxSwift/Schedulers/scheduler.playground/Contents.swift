import UIKit
import RxSwift

/*:
 # Scheduler
 */

let bag = DisposeBag()
/**
 swift는 쓰레드 처리를 위해서 GCD를 사용한다.
 RxSwift는 Scheduler를 사용한다.
 
 스케쥴러는 특정 코드가 실행되는 컨텍스트를 추상화된 것이다.
 그렇기에 스케쥴러 == 쓰레드 1:1 매칭 되지 않는다.
 하나의 쓰레드 안에 여러 스케쥴러
 두 개의 쓰레드에 하나의 스케쥴러가 얽혀있기도 하다.
 
 스케쥴러는 여러 가지가 있다. 스케쥴러 방식에 따라  SerialScheduler / concurrentScheduler가 있다.
 
 Serial (CurrentThreadScheduler / MainScheduler / SerialDispatchQueueScheduler)
 Concurrent(ConcurrentDispatchQueueScheduler / OperationQueueScheduler )
 
 이 외에도 TestScheduler/ CustomScheduler가 있다.
 
 
 */

let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9) //Observable의 정의
    .subscribe(on:MainScheduler.instance)
    .filter { num -> Bool in
        print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> filter")
        return num.isMultiple(of: 2)
    }
    .observe(on: backgroundScheduler) //이렇게 하면 이후 체이닝은 다 백그라운드로 동작한다.
    .map { num -> Int in
//        DispatchQueue.global().async {
//            print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> map")
//            return num * 2
//        }
// 이러면 map을 백그라운드가 아닌 연산을 백그라운드로 실행시킨다.
// RX에서 스케쥴러 지정은 observeOn, subscribeOn으로 한다.
        print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> map")
        return num * 2
    }
    .observe(on: MainScheduler.instance)
    
//    .subscribe(on:MainScheduler.instance) //이래도 여전히 백그라운드 subscribe의 스케쥴러를 정하는 것이 아니다. Observable 생성 시 어떤 스케쥴러를 사용할 지 정하는 것 + observe(on:)과 달리 호출 시점에 구애받지 않는다.
    .subscribe {//Observable이 생성되는 시점은 구독이 되는 시점이다.
        print(Thread.isMainThread ? "Main Thread" : "Background Thread >> subscribe", $0)
    } .disposed(by: bag)
/**
 Scheduler를 따로 정하지 않았다. -> CurrentScheduler이다.
 */
/**
 subscribe(on:)은 Observable이 시작하는 스케쥴러를
 observe(on:)은 이어지는 연산자가 시작되는 스케쥴러를 정한다.
 */
