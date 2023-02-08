import UIKit
import RxSwift

/*:
 # Operators
 */

let bag = DisposeBag()

Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9])
    .take(5) //요소 중 파라미터 수만큼 방출하는 새로운 Observable생성
    .filter{$0.isMultiple(of: 2)}
    .subscribe { print($0) }
    .disposed(by: bag)

/**
 Observable을 리턴하기 때문에 체이닝으로 이어갈 수 있다.
 */












