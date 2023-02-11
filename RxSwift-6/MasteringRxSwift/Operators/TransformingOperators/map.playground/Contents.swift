
import UIKit
import RxSwift

/*:
 # map
 */

let disposeBag = DisposeBag()
let skills = ["Swift", "SwiftUI", "RxSwift"]

Observable.from(skills)
//    .map{ "Hello, \($0)"}
    .map{ $0.count }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)


