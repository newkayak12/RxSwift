import UIKit
import RxSwift

/*:
 # take
 */

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


Observable.from(numbers).take(5).subscribe{ print($0) }.disposed(by: disposeBag)
//에러가 발생하면 에러 이벤트도 전달
