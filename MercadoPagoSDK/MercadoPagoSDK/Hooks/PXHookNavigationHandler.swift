//
//  PXHookNavigationHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers
public class PXHookNavigationHandler: NSObject {

    private var checkout: MercadoPagoCheckout?
    private var targetHook: PXHookStep?

    internal init(withCheckout: MercadoPagoCheckout, targetHook: PXHookStep) {
        self.checkout = withCheckout
        self.targetHook = targetHook
    }

    open func next() {
        checkout?.executeNextStep()
    }

    open func back() {
        checkout?.executePreviousStep()
    }

    open func showLoading() {
        checkout?.viewModel.pxNavigationHandler.presentLoading()
    }

    open func hideLoading() {
        checkout?.viewModel.pxNavigationHandler.dismissLoading()
    }
}
