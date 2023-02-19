
import UIKit
import RxSwift
import RxCocoa

class RxCocoaNotificationCenterViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggleButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if self.textView.isFirstResponder {
                    self.textView.resignFirstResponder()
                } else {
                    self.textView.becomeFirstResponder()
                }
            })
            .disposed(by: bag)
        
        let willShowObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
            .map{ ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0}
        
        let willHideObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map{ noti -> CGFloat in 0}
        
        Observable.merge(willShowObservable, willHideObservable)
            .map{ [unowned self] height -> UIEdgeInsets in
                var inset = self.textView.contentInset
                inset.bottom = height
                return inset
            }
            .subscribe(onNext: { [weak self] inset in
                UIView.animate(withDuration: 0.3) {
                    self?.textView.contentInset = inset
                }
            }).disposed(by: bag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
}
