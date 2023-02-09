
import UIKit
import RxSwift

/*:
 # create
 */

let disposeBag = DisposeBag()

enum MyError: Error {
   case error
}


//Observable이 동작하는 방식을 직접 정의하고 싶다면

let obs = Observable<String>.create{ (observer) -> Disposable in
    guard let url = URL(string: "https://www.apple.com") else {
        observer.onError(MyError.error)
        return Disposables.create()
    }
    
    guard let html = try? String(contentsOf: url, encoding: .utf8) else {
        observer.onError(MyError.error)
        return Disposables.create()
    }
    
    observer.onNext(html)
    observer.onCompleted()
    
    observer.onNext("After completed")
    return Disposables.create()
}


obs.subscribe{ print($0) }.disposed(by: disposeBag)
