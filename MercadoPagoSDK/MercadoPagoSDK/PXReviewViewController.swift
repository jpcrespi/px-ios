//
//  PXReviewViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

class PXReviewViewController: PXComponentContainerViewController {
    
    // MARK: Tracking
    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_REVIEW_AND_CONFIRM } }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_REVIEW_AND_CONFIRM } }
    
    // MARK: Definitions
    var footerView : UIView!
    var floatingButtonView : UIView!
    var termsConditionView: PXTermsAndConditionView!
    var itemViews: [UIView]!
    fileprivate var viewModel: PXReviewViewModel!

    var callbackConfirm: ((PaymentData) -> Void)
    var callbackExit: (() -> Void)
    
    // MARK: Lifecycle - Publics
    init(viewModel: PXReviewViewModel, callbackConfirm: @escaping ((PaymentData) -> Void), callbackExit: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.callbackConfirm = callbackConfirm
        self.callbackExit = callbackExit
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        setupUI()
    }
    
    func update(viewModel: PXReviewViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: UI Methods
extension PXReviewViewController {
    
    fileprivate func setupUI() {
        scrollView.backgroundColor = .white
        setNavBarBackgroundColor(color: .white)
        renderViews()
    }
    
    fileprivate func renderViews() {
        // TODO: Decidir que hacer con esto
        //if contentView.contentView.subviews.isEmpty {

        self.contentView.prepareforRender()

        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        for constraint in contentView.constraints {
            constraint.isActive = false
        }
        // Add title view.
        let titleView = getTitleComponentView()
        contentView.addSubview(titleView)
        PXLayout.pinTop(view: titleView, to: contentView, withMargin: 0).isActive = true
        PXLayout.centerHorizontally(view: titleView).isActive = true
        PXLayout.matchWidth(ofView: titleView).isActive = true

        // Add summary view.
        let summaryView = getSummaryComponentView()
        contentView.addSubview(summaryView)
        PXLayout.put(view: summaryView, onBottomOf: titleView, withMargin: 0).isActive = true
        PXLayout.centerHorizontally(view: summaryView).isActive = true
        PXLayout.matchWidth(ofView: summaryView).isActive = true

        // Add item views
        itemViews = buildItemComponentsViews()
        for itemView in itemViews {
            contentView.addSubviewToButtom(itemView)
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.matchWidth(ofView: itemView).isActive = true
            itemView.addSeparatorLineToBottom(height: 1)
        }

        // Add payment method view.
        let paymentMethodView = getPaymentMethodComponentView()
        contentView.addSubview(paymentMethodView)
        PXLayout.matchWidth(ofView: paymentMethodView).isActive = true
        PXLayout.put(view: paymentMethodView, onBottomOf: summaryView, withMargin: 0).isActive = true
        PXLayout.centerHorizontally(view: paymentMethodView).isActive = true

        // TODO Phantom view, delete when finish the screen 🚫
        let panthomView = UIView()
        panthomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(panthomView)
        panthomView.backgroundColor = .white
        PXLayout.matchWidth(ofView: panthomView).isActive = true
        PXLayout.put(view: panthomView, onBottomOf: paymentMethodView, withMargin: 0).isActive = true
        PXLayout.centerHorizontally(view: panthomView).isActive = true
        PXLayout.setHeight(owner: panthomView, height: 600).isActive = true

        //Add Footer
        footerView = getFooterView()
        contentView.addSubview(footerView)
        PXLayout.matchWidth(ofView: footerView).isActive = true
        PXLayout.put(view: footerView, onBottomOf: panthomView, withMargin: 0).isActive = true
        PXLayout.centerHorizontally(view: footerView, to: contentView).isActive = true
        self.view.layoutIfNeeded()
        PXLayout.setHeight(owner: footerView, height: footerView.frame.height).isActive = true

        // Add terms and conditions.
        if viewModel.shouldShowTermsAndCondition() {
            termsConditionView = getTermsAndConditionView()
            contentView.addSubview(termsConditionView)
            PXLayout.matchWidth(ofView: termsConditionView).isActive = true
            PXLayout.centerHorizontally(view: termsConditionView).isActive = true
            PXLayout.put(view: termsConditionView, onBottomOf: paymentMethodView, withMargin: 0).isActive = true
            termsConditionView.delegate = self
        }

        // Add floating button
        floatingButtonView = getFloatingButtonView()
        view.addSubview(floatingButtonView)
        PXLayout.setHeight(owner: floatingButtonView, height: viewModel.getFloatingConfirmViewHeight()).isActive = true
        PXLayout.matchWidth(ofView: floatingButtonView).isActive = true
        PXLayout.pinBottom(view: floatingButtonView, to: view, withMargin: 0).isActive = true

        // Add elastic header.
        addElasticHeader(headerBackgroundColor: summaryView.backgroundColor, navigationCustomTitle: PXReviewTitleComponentProps.DEFAULT_TITLE.localized)

        self.view.layoutIfNeeded()
        PXLayout.pinLastSubviewToBottom(view: self.contentView)?.isActive = true
        refreshContentViewSize()
        //        }

    }
    
    fileprivate func refreshContentViewSize() {
        var height : CGFloat = 0
        for view in contentView.subviews {
            height = height + view.frame.height
        }
        scrollView.contentSize = CGSize(width: PXLayout.getScreenWidth(), height: height)
    }

}
// MARK: Component Builders
extension PXReviewViewController {
    fileprivate func buildItemComponentsViews() -> [UIView] {
        var itemViews = [UIView]()
        let itemComponents = viewModel.buildItemComponents()
        for items in itemComponents {
            itemViews.append(items.render())
        }
        return itemViews
    }

    fileprivate func isConfirmButtonVisible() -> Bool {
        guard let floatingButton = self.floatingButtonView, let fixedButton = self.footerView else {
            return false
        }
        let floatingButtonCoordinates = floatingButton.convert(CGPoint.zero, from: self.view.window)
        let fixedButtonCoordinates = fixedButton.convert(CGPoint.zero, from: self.view.window)
        return fixedButtonCoordinates.y >= floatingButtonCoordinates.y
    }

    fileprivate func getPaymentMethodComponentView() -> UIView {
        let action = PXComponentAction(label: "Action label") {
            print("Action called")
        }
        let paymentMethodComponent = viewModel.buildPaymentMethodComponent(withAction:action)
        let paymentMethodView = paymentMethodComponent.render()
        return paymentMethodView
    }
    
    fileprivate func getSummaryComponentView() -> UIView {
        let summaryComponent = viewModel.buildSummaryComponent(width: PXLayout.getScreenWidth())
        let summaryView = summaryComponent.render()
        return summaryView
    }
    
    fileprivate func getTitleComponentView() -> UIView {
        let titleComponent = viewModel.buildTitleComponent()
        return titleComponent.render()
    }

    fileprivate func getFloatingButtonView() -> PXContainedActionButtonView {
        let component = PXContainedActionButtonComponent(props: PXContainedActionButtonProps(title: "Confirmar".localized, action: {
            [weak self] in
            guard let strongSelf = self else {
                    return
            }
           strongSelf.confirmPayment()
        }))
        let containedButtonView = PXContainedActionButtonRenderer().render(component)
        return containedButtonView
    }
    
    fileprivate func getFooterView() -> UIView {
        let payAction = PXComponentAction(label: "Confirmar".localized) {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.confirmPayment()
        }
        let cancelAction = PXComponentAction(label: "Cancelar".localized) {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.cancelPayment()
        }
        let footerProps = PXFooterProps(buttonAction: payAction, linkAction: cancelAction)
        let footerComponent = PXFooterComponent(props: footerProps)
        return footerComponent.render()
    }
    
    fileprivate func getTermsAndConditionView() -> PXTermsAndConditionView {
        let termsAndConditionView = PXTermsAndConditionView()
        return termsAndConditionView
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if !isConfirmButtonVisible() {
            self.floatingButtonView.alpha = 1
        } else {
            self.floatingButtonView.alpha = 0
        }
    }
}

//MARK: Actions.
extension PXReviewViewController: PXTermsAndConditionViewDelegate {
    
    fileprivate func confirmPayment() {
        self.hideNavBar()
        self.hideBackButton()
        self.callbackConfirm(self.viewModel.paymentData)
    }
    
    fileprivate func cancelPayment() {
        self.callbackExit()
    }
    
    func shouldOpenTermsCondition(_ title: String, screenName: String, url: URL) {
        let webVC = WebViewController(url: url, screenName: screenName, navigationBarTitle: title)
        webVC.title = title
        self.navigationController?.pushViewController(webVC, animated: true)
    }

}
