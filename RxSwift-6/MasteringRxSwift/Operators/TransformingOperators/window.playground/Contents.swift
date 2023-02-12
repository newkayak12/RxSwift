
import UIKit
import RxSwift

/*:
 # window
 */

let disposeBag = DisposeBag()
//buffer같이 작은 단위 Observable로 분해한다.
//window는 수집된 항목(Observable)을 반환하는 Observable을 반환한다.

Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .window(timeSpan: .seconds(5), count: 3, scheduler: MainScheduler.instance)
    .subscribe{
        print($0)
        if let observable = $0.element {
            observable.subscribe{print("  Inner  :", $0)}
        }
    }
    .disposed(by: disposeBag)










