
import UIKit
import RxSwift

/*:
 # buffer
 */

/**
 특정 주기동안 Obs가 방출하는 값을 수집하고 하나의 배열로 리턴
 */

let disposeBag = DisposeBag()

Observable<Int>.interval(.milliseconds(1000), scheduler: MainScheduler.instance)
    .buffer(timeSpan: .milliseconds(2000), count: 3, scheduler: MainScheduler.instance)
    .take(5)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)











