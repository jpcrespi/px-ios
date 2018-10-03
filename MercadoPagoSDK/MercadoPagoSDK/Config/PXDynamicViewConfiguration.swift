//
//  PXDynamicViewConfiguration.swift
//  FXBlurView
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/10/18.
//

import Foundation

@objc public enum PXDynamicViewPosition: Int {
    case top
    case bottom
}

public class PXDynamicViewsConfiguration: NSObject {
    var creators: [PXDynamicViewPosition:PXDynamicViewCreator] = [:]

    @discardableResult
    public func addDynamicViewCreator(position: PXDynamicViewPosition, creator: PXDynamicViewCreator) -> PXDynamicViewsConfiguration {
        creators[position] = creator
        return self
    }
}

@objc public protocol PXDynamicViewCreator: NSObjectProtocol {
    @objc func getDynamicView(store: PXCheckoutStore) -> UIView?
}











@objc public enum PXDynamicViewControllerPosition: Int {
    case RyC
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
