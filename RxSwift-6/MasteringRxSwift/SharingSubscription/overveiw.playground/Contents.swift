import UIKit
import RxSwift

/*:
 # Sharing Subscriptions
 */

let bag = DisposeBag()

let source = Observable<String>.create { observer in
    let url = URL(string: "https://kxcoding-study.azurewebsites.net/api/string")!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data, let html = String(data: data, encoding: .utf8) {
            observer.onNext(html)
        }
        
        observer.onCompleted()
    }
    task.resume()
    
    return Disposables.create {
        task.cancel()
    }
}
.debug()
.share() //이러면 결과를 공유 -> Observable에서 구독한 결과는 한 번만 실행됨

source.subscribe().disposed(by: bag) //시퀀스 시작,
source.subscribe().disposed(by: bag) // 새로운 구독자가 있으면 공유할 구독이 있어서 새로운 시퀀스 시작되지 않음
source.subscribe().disposed(by: bag)
//3번 실행됨
//이걸 막으려면 모든 구독자가 결과를 공유할 수 있으면 좋음








