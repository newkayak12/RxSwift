import UIKit
import RxSwift

/*:
 # combineLatest
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}

let greetings = PublishSubject<String>()
let languages = PublishSubject<String>()


/**
 ----1----2--------------------------3-----4-----------------5-----|→
    
                                +
 
 ------A-----B--------------C---D----------------------------------|→
 
 
                                =
 
 -------1A--2A--2B-----------2C--2D----3D----4D---------------5D---|→
 */



Observable.combineLatest(greetings, languages) { lhs, rhs -> String in
    return "\(lhs) \(rhs)"
}
.subscribe{ print($0) }
.disposed(by: bag)

//combineLatest 결과를 방출하는 Observable을 방출


greetings.onNext("Hi, ")
//여기서 language에 이벤트가 없어서 구독자에게 방출 X -> 바로 받고 싶다면 BehaviorSubject || startWith 연산자로 넘기면 바로 받을 수도 있겠다
languages.onNext("Swift")
languages.onNext("RxSwift")

greetings.onNext("Hello!, ")

//greetings.onCompleted()
greetings.onError(MyError.error)  //소스 중 하나라도 error -> 구독자에게 Error
greetings.onNext("ByeBye! ")
languages.onNext("js")


// 둘 다(combine 대상 모두) completed가 되면 구독자에게 completed가 전달됨
languages.onCompleted()
