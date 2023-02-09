
import UIKit
import RxSwift

/*:
 # of
 */

let disposeBag = DisposeBag()
let apple = "🍏"
let orange = "🍊"
let kiwi = "🥝"

//하나 이상
//더 많은 Element를 받으려면..
Observable.of(apple, orange, kiwi).subscribe { element in print(element) }.disposed(by: disposeBag)

Observable.of([1,2], [3,4], [5,6]).subscribe { element in print(element) }.disposed(by: disposeBag)






