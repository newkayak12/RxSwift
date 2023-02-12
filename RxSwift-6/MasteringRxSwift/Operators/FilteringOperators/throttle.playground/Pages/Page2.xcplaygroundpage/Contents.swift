//: [Previous](@previous)




import Foundation
import RxSwift


/*:
 # throttle
 ## latest parameter
 */

let disposeBag = DisposeBag()

func currentTimeString() -> String {
   let f = DateFormatter()
   f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
   return f.string(from: Date())
}

//
//Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
//   .debug()
//   .take(10)
//   .throttle(.milliseconds(2500), latest: true, scheduler: MainScheduler.instance)
//   .subscribe { print(currentTimeString(), $0) }
//   .disposed(by: disposeBag)


Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
   .debug()
   .take(10)
   .throttle(.milliseconds(2500), latest: false, scheduler: MainScheduler.instance)
   .subscribe { print(currentTimeString(), $0) }
   .disposed(by: disposeBag)
