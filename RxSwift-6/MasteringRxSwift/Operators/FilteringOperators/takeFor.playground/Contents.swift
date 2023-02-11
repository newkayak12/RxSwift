import UIKit
import RxSwift

/*:
 # take(for:scheduler:)
 */


let disposeBag = DisposeBag()

let o = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

o.take(for: .seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// take(for:) 여기에 준 시간 만큼 방출하고 끝낸다.
