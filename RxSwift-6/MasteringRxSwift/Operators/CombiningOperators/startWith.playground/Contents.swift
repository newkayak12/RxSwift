

import UIKit
import RxSwift

/*:
 # startWith
 */

let bag = DisposeBag()
let numbers = [1, 2, 3, 4, 5]

//Obs가 방출하기 전에 기본/시작값을 지정할 때 사용
//당연히 두 개 이상 연달아 사용 가능

Observable.from(numbers).startWith(-1).startWith(-2).startWith(-4, -9, -22)
    .subscribe{ print($0) }.disposed(by: bag)
// -4 -9 -22 -2 -1 1 2 3 4 5
// last in first out

//추가한 역순으로 시작

