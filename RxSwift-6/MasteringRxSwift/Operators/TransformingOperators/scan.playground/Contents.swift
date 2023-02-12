
import UIKit
import RxSwift

/*:
 # scan
 */
/**
 기본 값으로 연산을 시작 -> 원본 Obs가 방출하는 값으로 연산을 시작하고 결과를 방출
-> Reduce랑 비슷해보임 (중간 단계도 구독자에 보낸다는 점이 다른 것 같음)
 */
let disposeBag = DisposeBag()


Observable.range(start: 1, count: 10)
//    .scan(0, accumulator: { $0 + $1})
    .scan(0, accumulator: + )
    .subscribe{ print($0) }
    .disposed(by: disposeBag)


