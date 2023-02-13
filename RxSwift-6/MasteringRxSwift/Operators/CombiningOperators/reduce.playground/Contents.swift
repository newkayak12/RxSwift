import UIKit
import RxSwift

/*:
 # reduce
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}

let o = Observable.range(start: 1, count: 5)

print("== scan") //중간 결과가 필요한 경우에 사용
o.scan(0, accumulator: +)
   .subscribe { print($0) }
   .disposed(by: bag)

print("== reduce") //결과만 필요한 경우 사용
o.reduce(0, accumulator: +)
    .subscribe { print($0) }
    .disposed(by: bag)


//reduce는 결과만 방출하고 onCompleted가 된다.



