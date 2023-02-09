
import UIKit
import RxSwift

/*:
 # just
 */

let disposeBag = DisposeBag()
let element = "😀"

//하나만
Observable.just(element).subscribe { event in print(event) }.disposed(by: disposeBag)
Observable.just([1,2,3]).subscribe { event in print(event) }.disposed(by: disposeBag)
//받은 Element를 그대로 방출
