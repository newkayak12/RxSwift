import UIKit
import RxSwift

/*:
 # concat
 */

let bag = DisposeBag()
let fruits = Observable.from(["🍏", "🍎", "🥝", "🍑", "🍋", "🍉"])
let animals = Observable.from(["🐶", "🐱", "🐹", "🐼", "🐯", "🐵"])


//두 개의 observable을 연결 할 때 사용
//typeMethod, instanceMethod로 구성됨

Observable.concat([fruits, animals])
    .subscribe{ print($0) }.disposed(by: bag)
//순서대로 연결한 새로운 Observable을 반환
//연결된 observable이 모든 요소를 방출하면 completed

fruits.concat(animals).subscribe{ print($0) }.disposed(by: bag)
//error가 전달되면 바로 종료


animals.concat(fruits).subscribe{ print($0) }.disposed(by: bag)
// 이전 observable(animal) 이 completed 되어야 다음 Observable(fruits)이 방출됨






