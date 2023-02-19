
import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import MapKit
/**
 CLLocationManager
 위치 정보 필요 시점에 코드를 구현 -> RxSwift 방식으로 확장 불가
 
 => DelegateProxy : 해당 Delegate가 호출되는 시점에 next() 넘김
 CLLocationManager -> DelegateProxy -> Subscriber
 */
class DelegateProxyViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.rx.didUpdateLocations.subscribe(onNext: {locations in print(locations)}).disposed(by: bag)
        locationManager.rx.didUpdateLocations.map{ $0[0] }.bind(to: mapView.rx.center).disposed(by: bag)
    }
}
extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate //해당 delegate로 지정하면 된다.
}

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    weak private(set) var locationManager: CLLocationManager?
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {
            RxCLLocationManagerDelegateProxy(locationManager: $0)
        }
    }
}


extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in return parameters[1] as! [CLLocation]}
    }
}

extension Reactive where Base: MKMapView {
    public var center: Binder<CLLocation> {
        return Binder(self.base) { mapView, location in
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            self.base.setRegion(region, animated: true)
        }
    }
}
