import UIKit
import RxSwift

/*:
 # timer
 */

let bag = DisposeBag()

//첫 번째 요소의 전달 시간
Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
    .disposed(by: bag)


//두 번 째 파라미터(period)가 반복 주기가 된다.
let obs = Observable<Int>.timer(.seconds(1), period: .milliseconds(500), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }

DispatchQueue.main.asyncAfter(deadline: .now() + 5){
    obs.dispose()
}

