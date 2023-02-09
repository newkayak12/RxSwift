import UIKit
import RxSwift

/*:
 # ReplaySubject
 */

let disposeBag = DisposeBag()

enum MyError: Error {
   case error
}

//2개 이상의 이벤트를 저장하고 새로운 구독자로 전달하고 싶다면 사용하면 된다.
//이전과 다르게 crate로 만든다.
let rs = ReplaySubject<Int>.create(bufferSize: 3)
(1...10).forEach { rs.onNext($0) }
rs.subscribe{ print("observer 1 >> ", $0)}.disposed(by: disposeBag)

rs.subscribe{ print("observer 2 >> ", $0)}.disposed(by: disposeBag)

rs.onNext(11)

rs.subscribe{ print("observer 3 >> ", $0)}.disposed(by: disposeBag)

//rs.onCompleted()
rs.onError(MyError.error)

rs.subscribe{ print("observer 4 >> ", $0)}.disposed(by: disposeBag)
//버퍼에 있던 것들 소모하고 completed
