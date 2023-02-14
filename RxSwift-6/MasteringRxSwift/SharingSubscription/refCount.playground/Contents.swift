import UIKit
import RxSwift

/*:
 # refCount
 */

let bag = DisposeBag()
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).debug().publish()

let observer1 = source
    .subscribe { print("🔵", $0) }

source.connect()

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    observer1.dispose()
}

DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
    let observer2 = source.subscribe { print("🔴", $0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        observer2.dispose()
    }
}












