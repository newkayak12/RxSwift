

import UIKit
import RxSwift

/*:
 # range
 */

let disposeBag = DisposeBag()

//정수를 지정된 수만큼 방출
Observable.range(start: 1, count: 10).subscribe { print($0) }.disposed(by: disposeBag)
/**
 시작값에서 1씩 증가하는 시퀀스가 생성
 만약 스탭을 바꾸거나 감소하는 연산을 하고 싶다면 generate를 써야한다.
 */


