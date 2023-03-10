
import UIKit
import RxSwift

//: [Previous](@previous)

/*:
 # flatMapFirst #2
 */

let disposeBag = DisposeBag()

let redCircle = "π΄"
let greenCircle = "π’"
let blueCircle = "π΅"

let redHeart = "β€οΈ"
let greenHeart = "π"
let blueHeart = "π"

let sourceObservable = PublishSubject<String>()
//νλμ μ£ΌκΈ° μμμ κ°μ₯ λ¨Όμ  λ°©μΆλ κ²μ λ°©μΆ
sourceObservable
    .flatMapFirst { circle -> Observable<String> in
        print(circle)
        switch circle {
        case redCircle:
            return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                .map { _ in redHeart}
                .take(10)
        case greenCircle:
            return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                .map { _ in greenHeart}
                .take(10)
        case blueCircle:
            return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                .map { _ in blueHeart}
                .take(10)
        default:
            return Observable.just("")
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

sourceObservable.onNext(redCircle)

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    sourceObservable.onNext(greenCircle)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    sourceObservable.onNext(blueCircle)
}


