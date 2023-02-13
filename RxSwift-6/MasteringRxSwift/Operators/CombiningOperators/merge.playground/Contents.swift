import UIKit
import RxSwift

/*:
 # merge
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}

let oddNumbers = BehaviorSubject(value: 1)
let evenNumbers = BehaviorSubject(value: 2)
let negativeNumbers = BehaviorSubject(value: -1)

//concat과 혼동할 수 있지만, 다른 동작을 갖는다.
//두 개 이상의 obs를 병합하고 모든 obs에서 방출하는 요소들을 방출하는 obs를 생성
//merge 수는 제한이 없음. 만약 제한해야 한다면 merge(maxConcurrent: )에 파라미터로 수를 보내면 된다.
let source = Observable.of(oddNumbers, evenNumbers, negativeNumbers)
source
    .merge(maxConcurrent: 2)
    .subscribe { print($0) }
    .disposed(by: bag)

oddNumbers.onNext(3)
evenNumbers.onNext(4)

evenNumbers.onNext(6)
oddNumbers.onNext(5)
/**
 next(1)
 next(2)
 next(3)
 next(4)
 next(6)
 next(5)

 대체 언제 종료되는가?
 */
//oddNumbers.onCompleted()
//이래도 evenNumbers는 이벤트를 받을 수 있다.
////oddNumbers.onError(MyError.error)
//#2 error라면? -> 그 즉시 구독자에 에러를 전달

////evenNumbers.onNext(8)
//next(8)
///evenNumbers.onCompleted()
//이렇게 다 종료해야 merge 역시 completed

//#3
negativeNumbers.onNext(-11)
//이러면 queue에 저장해 놓는다. 다른 Observable이 completed가 되면 병합 대상으로 올린다. 
