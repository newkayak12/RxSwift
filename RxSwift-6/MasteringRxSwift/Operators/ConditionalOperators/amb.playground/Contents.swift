
import UIKit
import RxSwift

/*:
 # amb
 */


let bag = DisposeBag()

enum MyError: Error {
   case error
}

/**
 ---------20----40-------60-----------|→
 
 ------1--2-----3---------------------|→
 
 ----------0------0--------0--------0-|→
 
 [amb]
 ------1--2-----3---------------------|→
 
 amb는 가장 먼저 방출한 Observable을 구독한다.
 > 여러 서버로 요청을 전달하고 가장 빠른 응답을 사용하는 로직을 만들 수 있다.
 */

let a = PublishSubject<String>()
let b = PublishSubject<String>()
let c = PublishSubject<String>()


a.amb(b)
    .subscribe{ print($0) }
    .disposed(by: bag)

a.onNext("A")
b.onNext("B")  //이러면 A subject를 구독
b.onCompleted() //어떠한 B의 이벤트 모두 무시
a.onCompleted()

//
//Observable.amb([a,b,c])
//    .subscribe{ print($0) }
//    .disposed(by: bag)
//
//
//a.onNext("A")
//b.onNext("B")
//c.onNext("C")



