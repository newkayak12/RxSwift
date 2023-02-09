
import UIKit
import RxSwift

/*:
 # elementAt
 */

let disposeBag = DisposeBag()
let fruits = ["🍏", "🍎", "🍋", "🍓", "🍇"]

Observable.from(fruits).element(at: 1)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
