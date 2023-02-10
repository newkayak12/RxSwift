

import UIKit
import RxSwift

/*:
 # skip(duration:scheduler:)
 */


let disposeBag = DisposeBag()

let o = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

o.take(10)
    .skip(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
//Observable이 방출하는 이벤트를 3초 간 무시
//2부터 방출하는 이유?? -> 시간 오차가 발생 ms 단위의 오차가 발생 








