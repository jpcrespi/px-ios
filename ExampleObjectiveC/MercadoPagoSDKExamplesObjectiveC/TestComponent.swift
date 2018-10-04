//
//  TestComponent.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 19/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDKV4

class ClosureSleeve {
    let closure: () -> Void

    init (_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func add (for controlEvents: UIControlEvents, _ closure: @escaping () -> Void) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

@objc public class TestComponent: NSObject, PXDynamicViewControllerCreator, PXDynamicViewCreator {
    public func getDynamicView(store: PXCheckoutStore) -> UIView? {
        if let pmName = store.getPaymentData().getPaymentMethod()?.name {
            return getView(text: "Dynamic Custom View - PM:\(pmName)", color: .white)
        }
        return nil
    }

    public func getDynamicViewController(store: PXCheckoutStore) -> UIViewController? {
        let vc = UIViewController()
        vc.view.backgroundColor = .blue
        NSLayoutConstraint(item: vc.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        NSLayoutConstraint(item: vc.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss", for: .normal)
        button.add(for: .touchUpInside) {
            vc.dismiss(animated: true, completion: nil)
        }

        vc.view.addSubview(button)

        NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: vc.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: vc.view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0).isActive = true

        return vc
    }

    public func getView(text: String = "Custom Component", color: UIColor = UIColor.white) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let view = UIView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        let label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = label.font.withSize(20)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .black
        view.addSubview(label)

        NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0).isActive = true

        return view
    }
}

// MARK: Mock configurations (Ex-preferences).
extension TestComponent {
    static public func getPaymentResultConfiguration() -> PXPaymentResultConfiguration {
        let testComponent = TestComponent()
        let paymentConfig = PXPaymentResultConfiguration(topView: testComponent.getView(), bottomView: testComponent.getView())
        return paymentConfig
    }

    static public func getReviewConfirmConfiguration() -> PXReviewConfirmConfiguration {
        let testComponent = TestComponent()
        let config = PXReviewConfirmConfiguration(itemsEnabled: true, topView: testComponent.getView(), bottomView: testComponent.getView())
        return config
    }

    static public func getDynamicViewsConfiguration() -> PXDynamicViewsConfiguration {
        let testComponent = TestComponent()
        let configuration = PXDynamicViewsConfiguration()
        configuration.addDynamicViewCreator(position: .TOP_PAYMENT_METHOD_REVIEW_AND_CONFIRM, creator: testComponent).addDynamicViewCreator(position: .BOTTOM_PAYMENT_METHOD_REVIEW_AND_CONFIRM, creator: testComponent)
        return configuration
    }

    static public func getDynamicViewControllersConfiguration() -> PXDynamicViewControllersConfiguration {
        let testComponent = TestComponent()
        let configuration = PXDynamicViewControllersConfiguration()
        configuration.addDynamicViewControllerCreator(position: .DID_ENTER_REVIEW_AND_CONFIRM, creator: testComponent)
        return configuration
    }
}
