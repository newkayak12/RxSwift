
import UIKit
import RxSwift

/*:
 # ignoreElements
 */

let disposeBag = DisposeBag()
let fruits = ["🍏", "🍎", "🍋", "🍓", "🍇"]



Observable.from(fruits).ignoreElements()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
