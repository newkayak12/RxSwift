import UIKit
import RxSwift

/*:
 # flatMap
 */

let disposeBag = DisposeBag()

let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable.from([redCircle, greenCircle, blueCircle])
    .flatMap { circle -> Observable<String> in
        switch circle {
            case redCircle:
                return Observable.repeatElement(redHeart).take(5)
            case greenCircle:
                return Observable.repeatElement(greenHeart).take(5)
            case blueCircle:
                return Observable.repeatElement(blueHeart).take(5)
            default:
                return Observable.just("")
        }
    }.subscribe{ print($0) }
    .disposed(by: disposeBag)

//InnerObservable을 지연없이 방출하기 때문에 순서가 제멋대로 (Interleaving이라고 한다. -> ConcatMap과 비교된다.)
