//
//  PXDynamicViewsConfiguration.swift
//  Pods
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/10/18.
//

import Foundation

@objc public enum PXDynamicViewPosition: Int {
    case TOP_PAYMENT_METHOD_REVIEW_AND_CONFIRM
    case BOTTOM_PAYMENT_METHOD_REVIEW_AND_CONFIRM
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
