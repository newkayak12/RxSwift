import UIKit
import RxSwift

/*:
 # delay
 */

let bag = DisposeBag()

func currentTimeString() -> String {
   let f = DateFormatter()
   f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
   return f.string(from: Date())
}
//next이벤트가 구독자로 전달되는 시점을 지정한 시간만큼 지연시킨다.
//에러 이벤트는 즉시 전달
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .debug()
    .delay(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
    .disposed(by: bag)
//구독 시점을 연기 시키는 것이 아니라 구독자에게 전달하는 시점을 딜레이 한다. 




