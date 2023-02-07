import UIKit
import RxSwift


let disposeBag = DisposeBag()
//Observable.just("Hello, RxSwift").subscribe{print($0)}.disposed(by: disposeBag)

//var a = 1;
//var b = 2;
//a + b
//
//a = 12


let a = BehaviorSubject(value: 1)
let b = BehaviorSubject(value: 2)

Observable.combineLatest(a,b) {$0 + $1}.subscribe(onNext: {print($0)}).disposed(by: disposeBag)


a.onNext(12)













