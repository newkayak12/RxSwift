import UIKit
import RxSwift

/*:
 # multicast
 */

let bag = DisposeBag()
let subject = PublishSubject<Int>()

let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)

source
    .subscribe { print("🔵", $0) }
    .disposed(by: bag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }
    .disposed(by: bag)




















