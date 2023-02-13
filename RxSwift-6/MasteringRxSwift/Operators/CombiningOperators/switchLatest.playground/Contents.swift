import UIKit
import RxSwift

/*:
 # switchLatest
 */

let bag = DisposeBag()

enum MyError: Error {
   case error
}
/**
 가장 최근 이벤트를 방출한 Observable이 방출하는 이벤트를 구독자에 전달
 어떤 Observable이 가장 최근인지 파악하는 것이 중요
 */

let a = PublishSubject<String>()
let b = PublishSubject<String>()


let source = PublishSubject<Observable<String>>()
source
    .switchLatest() // 파라미터 없음
    .subscribe { print($0) }
    .disposed(by: bag)

a.onNext("1")
b.onNext("B")

source.onNext(a) //여기까지 소스에서 방출하는 것이 없기에 아무것도 방출되지 않는다. onNext(a)로 하면 a가 감시 대상이 된다.

a.onNext("2")
b.onNext("B") //여기는 구독하지 않았기에 전달되지 않는다.

source.onNext(b) //b가 감시 대상이된다. a에 대한 구독은 종료한다.
b.onNext("b")


//a.onCompleted()//구독자로 전달되지 않는다.
//b.onCompleted()//구독자로 전달되지 않는다.

a.onError(MyError.error) //구독해제 했기에 전달되지 않는다.
b.onError(MyError.error) //전달한다.

source.onCompleted() // 소스에 completed 해야 전달

