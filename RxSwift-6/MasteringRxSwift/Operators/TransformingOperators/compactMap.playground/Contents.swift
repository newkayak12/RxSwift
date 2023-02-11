import UIKit
import RxSwift

/*:
 # compactMap
 */

let disposeBag = DisposeBag()

let subject = PublishSubject<String?>()

subject
//    .filter{ $0 != nil }
//    .map { $0! }
    .compactMap{ $0 }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

Observable<Int>.interval(.milliseconds(300), scheduler: MainScheduler.instance)
    .take(10)
    .map { _ in Bool.random() ? "⭐️" : nil }
    .subscribe(onNext: { subject.onNext($0) })
    .disposed(by: disposeBag)

/**
    compactMap은 변환을 한다. nil이면 무시, nil이 아니면 언래핑 해서 반환
 */
