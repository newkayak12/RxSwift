import UIKit
import RxSwift

/*:
 # timeout
 */


let bag = DisposeBag()

let subject = PublishSubject<Int>()



//timeout 내에 next를 전달하지 않으면 RxError.timeout으로 에러를 전파
//subject.timeout(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe{ print($0) }
//    .disposed(by: bag)
//
//Observable<Int>.timer(.seconds(1), period: .seconds(1),scheduler: MainScheduler.instance)
//    .subscribe(onNext: { subject.onNext($0) })
//    .disposed(by: bag)

//other에는 Observable을 전달하며, subject에서 타임아웃이 발생하면 Observable이 other로 변경된다. 
subject.timeout(.seconds(3), other: Observable.just(0), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
.disposed(by: bag)

Observable<Int>.timer(.seconds(2 /*5*/), period: .seconds(5 /*2*/),scheduler: MainScheduler.instance)
    .subscribe(onNext: { subject.onNext($0) })
    .disposed(by: bag)
