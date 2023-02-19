
import UIKit
import RxSwift
import RxCocoa

class CustomControlEventViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.borderStyle = .none
        inputField.layer.borderWidth = 3
        inputField.layer.borderColor = UIColor.gray.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: inputField.frame.height))
        inputField.leftView = paddingView
        inputField.leftViewMode = .always
        
//        inputField.rx.text
//            .map { $0?.count ?? 0 }
//            .map { "\($0)" }
//            .bind(to: countLabel.rx.text)
//            .disposed(by: bag)
        
        inputField.rx.editiingChanged
            .map{ [weak self] in
                self?.inputField.text?.count
            }.bind(to: countLabel.rx.textCount)
            .disposed(by: bag)
        
        
        doneButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.inputField.resignFirstResponder()
            })
            .disposed(by: bag)
        
//        inputField.delegate = self
        
        inputField.rx.editingDidBegin
            .map{ UIColor.red }
            .bind(to: inputField.rx.borderColor)
            .disposed(by: bag)
        
        inputField.rx.editingDidEnd
            .map{ UIColor.gray}
            .bind(to: inputField.rx.borderColor)
            .disposed(by: bag)
    }
}

//extension CustomControlEventViewController: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.layer.borderColor = UIColor.red.cgColor
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.layer.borderColor = UIColor.gray.cgColor
//    }
//}


extension Reactive where Base: UITextField {
    var editiingChanged: ControlEvent<Void> {
        return controlEvent(.editingChanged)
    }
    
    var editingDidBegin: ControlEvent<Void> {
        return controlEvent(.editingDidBegin)
    }
    var editingDidEnd: ControlEvent<Void> {
        return controlEvent(.editingDidEnd)
    }

    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { textfield, color in
            textfield.layer.borderColor = color?.cgColor
        }
    }
}

extension Reactive where Base: UILabel {
    var textCount: Binder<Int?> {
        return Binder(self.base) { textfield, count in
            textfield.text = "\(count ?? 0)"
        }
    }
}
