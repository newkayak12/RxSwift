import UIKit

class CocoaTouchViewViewController: UIViewController {

    @IBOutlet weak var targetView: UIView!
    
    @IBAction func showView(_ sender: Any) {
        targetView.isHidden = false
    }
    
    @IBAction func hideView(_ sender: Any) {
        targetView.isHidden = true
    }
    
    @IBAction func setAlphaToZero(_ sender: Any) {
        targetView.alpha = 0.0
    }
    
    @IBAction func setAlphaToZeroPointFive(_ sender: Any) {
        targetView.alpha = 0.5
    }
    
    @IBAction func setAlphaToOne(_ sender: Any) {
        targetView.alpha = 1.0
    }
    
    @IBAction func setBackgroundColorToRed(_ sender: Any) {
        targetView.backgroundColor = .systemRed
    }
    
    @IBAction func setBackgroundColorToGreen(_ sender: Any) {
        targetView.backgroundColor = .systemGreen
    }
    
    @IBAction func setBackgroundColorToBlue(_ sender: Any) {
        targetView.backgroundColor = .systemBlue
    }
    
    @IBAction func enableUserInteraction(_ sender: Any) {
        targetView.isUserInteractionEnabled = true
    }
    
    @IBAction func disableUserInteraction(_ sender: Any) {
        targetView.isUserInteractionEnabled = false
    }
}
