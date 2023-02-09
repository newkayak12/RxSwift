
import UIKit
import RxSwift

/*:
 # repeatElement
 */

let disposeBag = DisposeBag()
let element = "❤️"

Observable.repeatElement(element).take(7).subscribe{print($0)}.disposed(by: disposeBag)
