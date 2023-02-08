

import UIKit
import RxSwift

let subscription1 = Observable.from([1,2,3])
.subscribe(onNext: {elem in
    print("NEXT", elem)
}, onError: { error in
    print("ERROR", error)
}, onCompleted: {
    print("COMPLETED")
}, onDisposed: {
    //파라미터로 클로저를 전달하면 Observable과 관련된 리소스를 정리
    print("DISPOSED")
})
subscription1.dispose() //이것보다 DisposeBag이 권장사항
//
var bag = DisposeBag()

Observable.from([1,2,3]).subscribe{
    print($0)
}.disposed(by: bag)
//Observable이 completed, error가 되면 리소스가 해제됨
//두 번쨰 코드는 왜 DISPOSED가 호출되지 않았나? -> Observable과는 연관이 없음
//메모리 해제와 관련됨


/**
 disposeBag에 담고 disposeBag이 해제되는 시점에 모아둔 것을 해제
 */
bag = DisposeBag() // 이렇게하면 리소스가 해제됨 nil을 할당해도 좋다.




let subscription2 = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
.subscribe(onNext: {elem in
    print("NEXT", elem)
}, onError: { error in
    print("ERROR", error)
}, onCompleted: {
    print("COMPLETED")
}, onDisposed: {
    //파라미터로 클로저를 전달하면 Observable과 관련된 리소스를 정리
    print("DISPOSED")
})
// interval로 무한정 방출한다.

DispatchQueue.main.asyncAfter(deadline: .now() + 3){
    subscription2.dispose()
}
