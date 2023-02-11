import UIKit
import RxSwift

/*:
 # flatMapLatest
 */

let disposeBag = DisposeBag()

let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

let sourceObservable = PublishSubject<String>()
let trigger = PublishSubject<Void>()
//원본 -> InnerObservable을 만들어서 방출하는데 새로운 InnerObservable이 생기면 기존 이벤트 방출은 멈추고 최근 이벤트를 방출한다.
sourceObservable
//    .flatMap { circle -> Observable<String> in
    .flatMapLatest { circle -> Observable<String> in
        switch circle {
            case redCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                    .map { _ in redHeart}
                    .take(until: trigger)
            case greenCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                    .map { _ in greenHeart}
                    .take(until: trigger)
            case blueCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                    .map { _ in blueHeart}
                    .take(until: trigger)
            default:
                return Observable.just("")
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

sourceObservable.onNext(redCircle)

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    sourceObservable.onNext(greenCircle)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    sourceObservable.onNext(blueCircle)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    sourceObservable.onNext(redCircle)
} // -> 핵심은 InnerObservable을 재사용하는 식으로 만들어지는 것이 아니다. 항상 기존의 것을 제거한다. 

DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    trigger.onNext(())
}

//새로운 InnerObs 가 생성되면 기존 InnerObs가 삭제
