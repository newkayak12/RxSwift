
import UIKit
import RxSwift

/*:
 # Observables
 */

/**
Observable  ->      Event        ->        Observer
            <-     subscribe     <-
 
 //////////////////////////////////////////////////////
            ->   Next(Emission)  ->
            -> Error/Completed(Notification) ->

 */


//#1 Create 연산자로 Observable 동작을 직접
let o1 = Observable<Int>.create { (observable) -> Disposable in
    observable.on(.next(0))
    observable.onNext(1)
    
    observable.onCompleted() //종료
    return Disposables.create()
}

//#1-1
o1.subscribe {
    print("--start--")
    print($0)
    if let elem = $0.element {
        print(elem)
    }
    print("--end--")
}

print("-----------------------")

//#1-2
o1.subscribe ( onNext: {elem in
    print(elem)
})



//#2 create가 아닌 다른 연산자.
Observable.from([0, 1])












