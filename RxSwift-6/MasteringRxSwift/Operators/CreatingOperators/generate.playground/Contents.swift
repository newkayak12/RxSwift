
import UIKit
import RxSwift

/*:
 # generate
 */

let disposeBag = DisposeBag()
let red = "🔴"
let blue = "🔵"



Observable.generate(initialState: 0, condition: { $0 <= 10}, iterate: { $0 + 2 } ).subscribe {print($0)}.disposed(by: disposeBag)
Observable.generate(initialState: 0, condition: { $0 >= -10}, iterate: { $0 - 2 } ).subscribe {print($0)}.disposed(by: disposeBag)

Observable.generate(initialState: red, condition: { $0.count < 15 }, iterate: { $0.count.isMultiple(of: 2) ? $0 + red : $0 + blue }).subscribe{print($0)}.disposed(by: disposeBag)


