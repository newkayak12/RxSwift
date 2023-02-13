import UIKit
import RxSwift

/*:
 # zip
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}
//combineLatest와 비교하면 쉽게 이해할 수 있다.
/**
 ---------1--------2-------------------3-----4---------5--|→
 
                            +
 
 -------------A-------B-----------C-D---------------------|→
 
                            =
 
 -------------1A-------2B--------------3C------4D---------|→
 
 각 인덱스에 맞춰서 짝을 이룬다. 요소를 중복해서 사용하지 않는다.(CombineLatest와 다른 점)
 결합할 짝이 없으면 구독자에 전달되지 않는다. (Indexed Sequencing)
 */
let numbers = PublishSubject<Int>()
let strings = PublishSubject<String>()


Observable.zip(strings, numbers) { "\($0) - \($1)" }.subscribe{ print($0) }.disposed(by: bag)
strings.onNext("A")
strings.onNext("B")

numbers.onNext(1)
//strings.onCompleted()
strings.onError(MyError.error)
numbers.onCompleted()
//항상 방출된 순서대로 짝을 이룬다.
//소스 중 하나라도 에러가 나면 구독자에 에러를 전파






