

import UIKit
import RxSwift

/*:
 # Infallible
 */

enum MyError: Error {
    case unknown
}

let observable = Observable<String>.create { observer in
    observer.onNext("Hello")
    observer.onNext("Observable")
    
    //observer.onError(MyError.unknown)
    
    observer.onCompleted()
    
    return Disposables.create()
}

//Error는 방출하지 않음
let inallible = Infallible<String>.create { observer in
//    observable.onNext()
    
    observer(.next("Hello"))
    observer(.completed)
    
    return Disposables.create()
}








