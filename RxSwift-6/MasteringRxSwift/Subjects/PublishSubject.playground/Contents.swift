
import UIKit
import RxSwift

/*:
 # PublishSubject
 */
//subject로 전달되는 이벤트를 Observer에게 전달하는 subject


let disposeBag = DisposeBag()

enum MyError: Error {
   case error
}


let subject = PublishSubject<String>()
subject.onNext("HELLO")
let o1 = subject.subscribe { print(">>1", $0) }
o1.disposed(by: disposeBag)
//이전의 "HELLO"는 이미 소모됨 PublishSubject는 구독 이후의 동작을 처리
subject.onNext("RxSwift")

let o2 = subject.subscribe{ print(">>2", $0) }
o2.disposed(by: disposeBag)
subject.onNext("SUBJECT")


//subject.onCompleted()
//completed 이후에는 next전달 X 바로 completed

//에러를 보내면?
subject.onError(MyError.error)
//completed와 같음
let o3 = subject.subscribe{
    print(">>3", $0)
}


//구독 이전의 이벤트는 사라지는 것이 PublishSubject의 특징 
