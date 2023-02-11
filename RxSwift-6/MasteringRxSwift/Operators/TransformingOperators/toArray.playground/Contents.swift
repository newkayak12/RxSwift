
import UIKit
import RxSwift

/*:
 # toArray
 */

let disposeBag = DisposeBag()
let nums = [1,2,3,4,5,6,7,8,9,10]

let subject = PublishSubject<Int>()

subject
    .toArray()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

subject.onNext(1)
subject.onNext(2)
subject.onCompleted()
//toArray는 completed전까지 방출한 요소를 모아서 배열로 방출한다. 
