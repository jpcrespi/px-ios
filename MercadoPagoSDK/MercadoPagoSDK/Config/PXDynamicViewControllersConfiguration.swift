//
//  PXDynamicViewControllersConfiguration.swift
//  Pods
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/10/18.
//

import Foundation

@objc public enum PXDynamicViewControllerPosition: Int {
    case DID_ENTER_REVIEW_AND_CONFIRM
}

public class PXDynamicViewControllersConfiguration: NSObject {
    var creators: [PXDynamicViewControllerPosition:PXDynamicViewControllerCreator] = [:]

    @discardableResult
    public func addDynamicViewControllerCreator(position: PXDynamicViewControllerPosition, creator: PXDynamicViewControllerCreator) -> PXDynamicViewControllersConfiguration {
        creators[position] = creator
        return self
    }
}

@objc public protocol PXDynamicViewControllerCreator: NSObjectProtocol {
    @objc func getDynamicViewController(store: PXCheckoutStore) -> UIViewController?
    //    @objc func shouldShowViewController(store: PXCheckoutStore) -> Bool
    //    @objc optional func didReceive(hookStore: PXCheckoutStore)
    @objc optional func navigationHandlerForHook(navigationHandler: PXHookNavigationHandler)
}
