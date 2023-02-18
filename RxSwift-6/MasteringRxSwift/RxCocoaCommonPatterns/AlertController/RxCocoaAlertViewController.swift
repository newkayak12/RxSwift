import UIKit
import RxSwift
import RxCocoa

class RxCocoaAlertViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var oneActionAlertButton: UIButton!
    
    @IBOutlet weak var twoActionsAlertButton: UIButton!
    
    @IBOutlet weak var actionSheetButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneActionAlertButton.rx.tap
            .flatMap { [unowned self] in self.info(title: "CurrentColor", message: self.colorView.backgroundColor?.rgbHexString)}
            .subscribe(onNext: { [unowned self] actionType in
                switch actionType {
                    case .ok:
                        print(self.colorView.backgroundColor?.rgbHexString ?? "")
                        break;
                    default:
                        break;
                }
            }).disposed(by: bag)
        
        twoActionsAlertButton.rx.tap
            .flatMap { [unowned self] in self.alert(title: "Reset Color", message: "Reset to black color?")}
            .subscribe(onNext: { [unowned self] ActionType in
                switch ActionType {
                    case .ok:
                        self.colorView.backgroundColor = UIColor.black
                        break;
                    default:
                        break;
                }
            }).disposed(by: bag)
        
        
        actionSheetButton.rx.tap
            .flatMap { [unowned self] in
                self.colorActionSheet(colors: MaterialBlue.allColors, title: "Change Color", message: "choose one")
            }
            .subscribe(onNext: { [unowned self] color in
                self.colorView.backgroundColor = color
            })
            .disposed(by: bag)
        
    }
}

enum ActionType {
    case ok
    case cancel
}

extension UIViewController {
    func info(title: String, message: String? = nil) -> Observable<ActionType> {
        return Observable.create { [weak self] observable in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                observable.onNext(.ok)
                observable.onCompleted()
            }
            alert.addAction(okAction)
            
            self?.present(alert,animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true)
            }
        }
    }
    
    
    func alert(title: String, message: String? = nil) -> Observable<ActionType> {
        return Observable.create { [weak self] observable in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                observable.onNext(.ok)
                observable.onCompleted()
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel) { _ in
                observable.onNext(.cancel)
                observable.onCompleted()
                
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            
            self?.present(alert,animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true)
            }
        }
    }
    
    func colorActionSheet(colors: [UIColor], title: String, message: String? = nil) -> Observable<UIColor> {
        return Observable.create{ [weak self] observable in
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            for color in colors {
                let colorAction = UIAlertAction(title: color.rgbHexString, style: .default) {
                    _ in
                    
                    observable.onNext(color)
                    observable.onCompleted()
                }
                
                actionSheet.addAction(colorAction)
            }
            
            let cancalAction = UIAlertAction(title: "CANCEL", style: .cancel) {
                _ in
                observable.onCompleted()
            }
            
            actionSheet.addAction(cancalAction)
            self?.present(actionSheet, animated: true, completion: nil)
            
            return Disposables.create {
                actionSheet.dismiss(animated: true)
            }
        }
    }
}
