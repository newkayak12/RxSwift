

import UIKit
import RxSwift

/*:
 # from
 */

let disposeBag = DisposeBag()
let fruits = ["π", "π", "π", "π", "π"]

//κ·Έλ₯ λ°°μ΄
//λ°°μ΄μ μμλ₯Ό νλμ© λ°©μΆνλ €λ©΄?

Observable.from(fruits).subscribe { print($0) }.disposed(by: disposeBag)







