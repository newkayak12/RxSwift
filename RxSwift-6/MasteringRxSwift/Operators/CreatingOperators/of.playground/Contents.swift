
import UIKit
import RxSwift

/*:
 # of
 */

let disposeBag = DisposeBag()
let apple = "๐"
let orange = "๐"
let kiwi = "๐ฅ"

//ํ๋ ์ด์
//๋ ๋ง์ Element๋ฅผ ๋ฐ์ผ๋ ค๋ฉด..
Observable.of(apple, orange, kiwi).subscribe { element in print(element) }.disposed(by: disposeBag)

Observable.of([1,2], [3,4], [5,6]).subscribe { element in print(element) }.disposed(by: disposeBag)






