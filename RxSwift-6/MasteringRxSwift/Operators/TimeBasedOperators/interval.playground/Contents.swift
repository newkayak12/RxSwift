import UIKit
import RxSwift

/*:
 # interval
 */


let i = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
let subscription1 = i.subscribe{ print("1 >>> \($0)") }

//Observable 내부에 타이머가 있는데 생성 시점은 subscribe 때이다. 따라서 subscriber 수 만큼 타이머가 생긴다.
DispatchQueue.main.asyncAfter(deadline: .now() + 5){
    subscription1.dispose()
}

var subscription2: Disposable?
DispatchQueue.main.asyncAfter(deadline: .now() + 2){
    subscription2 = i.subscribe{ print("2 >>> \($0)")}
}

DispatchQueue.main.asyncAfter(deadline: .now() + 7){
    subscription2?.dispose()
}




