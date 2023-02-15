import UIKit
import RxSwift

/*:
 # multicast
 */



//Unicast와 같다. 여러 구독자가 하나의 Observable을 구독하는 방법 ==> 1. Multicast
/**
 Subject가 Observable을 구독하고 그 subject를 구독하는 방식 (ConnectableObservable<Subject, Element> 형태)
 
 ConnectableObservable은 subscribe를 해도 시퀀스가 실행되지 않음
 connect()를 해야, 시퀀스 실행
 
 --> 모든 구독자 구독 후 Subject 실행
 */


let bag = DisposeBag()
let subject = PublishSubject<Int>()

let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)

    .multicast(subject) //이러면 source에는 ConnectablerObsevable이 저장

source
    .subscribe { print("🔵", $0) }
    .disposed(by: bag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }
    .disposed(by: bag)

source.connect() //이러면 Observable 방출 시작
    .disposed(by: bag)//.connect() -> Disposable을 리턴
/**
 🔴는 2부터 출력, 원래는 3초 뒤 0부터 실행됐음
 */



















