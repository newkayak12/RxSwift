

import UIKit
import RxSwift

/*:
 # empty
 */

let disposeBag = DisposeBag()

//어떠한 요소도 방출하지 않는다.
//Copmleted 를 생성하는 Observable 을 만든다.

Observable<Void>.empty()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)


//옵저버가 아무런 동작 없이 종료해야할 경우 사용
