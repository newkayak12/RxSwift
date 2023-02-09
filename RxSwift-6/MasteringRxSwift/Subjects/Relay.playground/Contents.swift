import UIKit
import RxSwift
import RxCocoa

/*:
 # Relay
 */

let bag = DisposeBag()

/**
 PublicshRelay
 BehaviorReplay
 ReplayRelay
 
 Relay는 onNext 밖에 없다. 즉, 종료되지 않는다. 구독자가 dispose되지 않는 경우가 아니라면.
 */

print("\npublish relay")
let prelay = PublishRelay<Int>()
prelay.subscribe { print("1: \($0)") }.disposed(by: bag)
prelay.accept(1)

print("\nbehavior relay")
let brelay = BehaviorRelay(value: 1)
brelay.accept(2)
brelay.subscribe { print("2: \($0)")}.disposed(by: bag)

brelay.accept(3)
print(brelay.value) //읽기 전용
//brelay.value = 4 //error

print("\nreplay relay")
let rrelay = ReplayRelay<Int>.create(bufferSize: 3)
(1...10).forEach { rrelay.accept($0) }

rrelay.subscribe{ print("3: \($0)")}




