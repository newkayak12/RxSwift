

import UIKit
import RxSwift

/*:
 # from
 */

let disposeBag = DisposeBag()
let fruits = ["🍏", "🍎", "🍋", "🍓", "🍇"]

//그냥 배열
//배열의 요소를 하나씩 방출하려면?

Observable.from(fruits).subscribe { print($0) }.disposed(by: disposeBag)







