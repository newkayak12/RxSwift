import UIKit
import RxSwift

/*:
 # refCount
 */
/**
 ConnectableObservableType 프로토콜에 구현됨
 Observable을 리턴한다.
 
 RefCount는 내부에 Connectable을 유지하면서 새로운 구독자가 생기면 자동으로 connect를 실행,
 구독자가 구독을 중지하고 더 이상 다른 구독자가 없으면 시퀀스를 종료
 새로운 구독자가 붙으면 connect를 실행, 새로운 시퀀스 실행
 */

let bag = DisposeBag()
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).debug().publish()
    //.replay(4)
    .refCount() //refCountObservable을 리턴 (내부에서 connect)

let observer1 = source
    .subscribe { print("🔵", $0) }

//source.connect()

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    observer1.dispose()
}

//DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//    let observer3 = source.subscribe{ print("🟣", $0) }
//    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//        observer3.dispose()
//    }
//}


DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
    let observer2 = source.subscribe { print("🔴", $0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        observer2.dispose()
    }
}












