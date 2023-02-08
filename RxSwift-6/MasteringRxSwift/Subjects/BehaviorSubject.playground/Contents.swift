import UIKit
import RxSwift

/*:
 # BehaviorSubject
 */

/**
 PublishSubject와 유사한 방식으로 동작
 차이점은 생성하는 방식에 있다.
 또 구독할 때 차이가 있다.
 */
let disposeBag = DisposeBag()

enum MyError: Error {
   case error
}

let p = PublishSubject<Int>() // 빈 생성자
p.subscribe{ print("publicshSubject >>", $0) }.disposed(by: disposeBag)
//subject로 이벤트 전달 전까지 구독자로 이벤트 전달 X

let b = BehaviorSubject<Int>(value: 0) //기본 값을 전달한다.
b.subscribe { print("behaviorSubject >>", $0)}.disposed(by: disposeBag)
//내부에 Next가 BehaviorSubject를 생성하자 마자 바로 생성

b.onNext(1)

// 이전 이벤트를 저장하고 있다가 새로 구독한 녀석에게 던진다. 단 새로운 이벤트가 발생하면 이전 이벤트를 교체한다.
b.subscribe { print("behaviorSubject >>", $0)}.disposed(by: disposeBag)

//b.onCompleted()
b.onError(MyError.error)

//completed가 전달되면 이전 이벤트라도 무시함
b.subscribe { print("behaviorSubject >>", $0)}.disposed(by: disposeBag)



