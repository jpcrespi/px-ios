//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "ExampleUtils.h"
//#import "FirstHookViewController.h"
//#import "SecondHookViewController.h"
//#import "ThirdHookViewController.h"

#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"
#import "PaymentMethodPluginConfigViewController.h"
#import "PaymentPluginViewController.h"
#import "MLMyMPPXTrackListener.h"

@import MercadoPagoSDKV4;

@implementation MainExamplesViewController

- (IBAction)checkoutFlow:(id)sender {

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;

    self.pref = nil;

    [self setCheckoutPref_CreditCardNotExcluded];

    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-c6d9b1f9-71ff-4e05-9327-3c62468a23ee" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];

//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd" preferenceId:@"243966003-0812580b-6082-4104-9bce-1a4c48a5bc44"];

    [PXTracker setListener:self];

    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-1094487241196549-081708-4bc39f94fd147e7ce839c230c93261cb__LA_LC__-145698489"];

    // AdvancedConfig
    PXAdvancedConfiguration* advancedConfig = [[PXAdvancedConfiguration alloc] init];

    // Add theme to advanced config.
    // MeliTheme *meliTheme = [[MeliTheme alloc] init];
    MPTheme *mpTheme = [[MPTheme alloc] init];
    [advancedConfig setTheme:mpTheme];

    // Add ReviewConfirm configuration to advanced config.
    [advancedConfig setReviewConfirmConfiguration: [self getReviewScreenConfiguration]];

    // Add PaymentResult configuration to advanced config.
    [advancedConfig setPaymentResultConfiguration: [self getPaymentResultConfiguration]];

    // Disable bank deals
    [advancedConfig setBankDealsEnabled:NO];

    // Add dynamic view controllers
    [advancedConfig setDynamicViewControllersConfiguration: [TestComponent getDynamicViewControllersConfiguration]];

    // Add dynamic views
    [advancedConfig setDynamicViewsConfiguration: [TestComponent getDynamicViewsConfiguration]];

    // Set advanced comnfig
    [self.checkoutBuilder setAdvancedConfigurationWithConfig:advancedConfig];

    // Set language
    [self.checkoutBuilder setLanguage:@"es"];
  
    MercadoPagoCheckout *mpCheckout = [[MercadoPagoCheckout alloc] initWithBuilder:self.checkoutBuilder];

    //[mpCheckout startWithLazyInitProtocol:self];
    [mpCheckout startWithLazyInitProtocol:self];
}

// ReviewConfirm
-(PXReviewConfirmConfiguration *)getReviewScreenConfiguration {
    PXReviewConfirmConfiguration *config = [TestComponent getReviewConfirmConfiguration];
    return config;
}

// PaymentResult
-(PXPaymentResultConfiguration *)getPaymentResultConfiguration {
    PXPaymentResultConfiguration *config = [TestComponent getPaymentResultConfiguration];
    return config;
}

// Procesadora
-(PXPaymentConfiguration *)getPaymentConfiguration {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];
    PaymentPluginViewController *paymentProcessorPlugin = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];
    self.paymentConfig = [[PXPaymentConfiguration alloc] initWithPaymentProcessor:paymentProcessorPlugin];
    [self addPaymentMethodPluginToPaymentConfig];
    [self addDiscount];
    [self addCharges];
    return self.paymentConfig;
}

-(void)addPaymentMethodPluginToPaymentConfig {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];

    PXPaymentMethodPlugin * bitcoinPaymentMethodPlugin = [[PXPaymentMethodPlugin alloc] initWithPaymentMethodPluginId:@"account_money" name:@"Bitcoin" image:[UIImage imageNamed:@"bitcoin_payment"] description:@"Estas usando dinero invertido"];

    [self.paymentConfig addPaymentMethodPluginWithPlugin:bitcoinPaymentMethodPlugin];
}

-(void)addDiscount {
    PXDiscount* discount = [[PXDiscount alloc] initWithId:@"34295216" name:@"nada" percentOff:20 amountOff:0 couponAmount:7 currencyId:@"ARG"];
    PXCampaign* campaign = [[PXCampaign alloc] initWithId:30959 code:@"sad" name:@"Campaña" maxCouponAmount:7];
    PXDiscountConfiguration * configDiscount = [[PXDiscountConfiguration alloc] initWithDiscount:discount campaign:campaign];

    [self.paymentConfig setDiscountConfigurationWithConfig:configDiscount];
}

-(void)addCharges {
    NSMutableArray* chargesArray = [[NSMutableArray alloc] init];
    PXPaymentTypeChargeRule* chargeCredit = [[PXPaymentTypeChargeRule alloc] initWithPaymentMethdodId:@"payment_method_plugin" amountCharge:10.5];
    PXPaymentTypeChargeRule* chargeDebit = [[PXPaymentTypeChargeRule alloc] initWithPaymentMethdodId:@"debit_card" amountCharge:8];
    [chargesArray addObject:chargeCredit];
    [chargesArray addObject:chargeDebit];
    [self.paymentConfig addChargeRulesWithCharges:chargesArray];
}

-(void)setCheckoutPref_CreditCardNotExcluded {
    PXItem *item = [[PXItem alloc] initWithTitle:@"title" quantity:2 unitPrice:90.0];
    PXItem *item2 = [[PXItem alloc] initWithTitle:@"title" quantity:2 unitPrice:2.0];

    NSArray *items = [NSArray arrayWithObjects:item, item2, nil];

    self.pref = [[PXCheckoutPreference alloc] initWithSiteId:@"MLA" payerEmail:@"sara@gmail.com" items:items];
    [self.pref addExcludedPaymentType:@"ticket"];
}

-(IBAction)startCardManager:(id)sender  {}

- (void)didFinishWithCheckout:(MercadoPagoCheckout * _Nonnull)checkout {
    [checkout startWithNavigationController:self.navigationController lifeCycleProtocol:self];
}

-(void)failureWithCheckout:(MercadoPagoCheckout * _Nonnull)checkout {
    NSLog(@"PXLog - LazyInit - failureWithCheckout");
}

-(void (^ _Nullable)(void))cancelCheckout {
    //return nil;
    NSLog(@"PXLog - cancelCheckout outside Called");
    return ^ {
        NSLog(@"PXLog - cancelCheckout Called");
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-( void (^)(PXGenericPayment*)) finishCheckout {
    //return nil;x
    NSLog(@"PXLog - finishCheckoutWithPayment outside Called ");
    return ^ (PXGenericPayment* payment) {
        NSLog(@"PXLog - finishCheckoutWithPayment Called");
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
}


-(void (^)(void))changePaymentMethodTapped {
    return nil;
    NSLog(@"PXLog - changePaymentMethodTapped outside Called");
    return ^ {
        NSLog(@"PXLog - changePaymentMethodTapped Called");
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void)trackEventWithScreenName:(NSString * _Nullable)screenName action:(NSString * _Null_unspecified)action result:(NSString * _Nullable)result extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track event
}

- (void)trackScreenWithScreenName:(NSString * _Nonnull)screenName extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track screen
}

@end
