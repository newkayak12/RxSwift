import UIKit
import RxSwift

/*:
 # publish
 */

let bag = DisposeBag()
let subject = PublishSubject<Int>()
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)//.multicast(subject)
    .publish() //publishSubject를 생성하고 multicast로 전달하는 동작이 통합됨
    
source
    .subscribe { print("🔵", $0) }
    .disposed(by: bag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }
    .disposed(by: bag)

source.connect()












