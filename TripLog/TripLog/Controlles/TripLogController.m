//
//  TripLogController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripLogController.h"
#import "TripLogWebServiceController.h"
#import "TripLogCoreDataController.h"
#import "AppDelegate.h"
#import "LocationDetailsViewController.h"

#define HAS_SAVED_USER_DATA_KEY @"hasUserDataKey"
#define USER_ID_KEY @"userId"
#define SESSION_KEY @"sessionKey"

@interface TripLogController ()

@end

@implementation TripLogController

static TripLogController* tripController;
static NSOperationQueue *sharedQueue;

+(id)sharedInstance{
    @synchronized(self){
        if (!tripController) {
            tripController = [[TripLogController alloc] init];
        }
    }
    
    return tripController;
}

-(instancetype)init{
    if(tripController){
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    }
    else{
        self = [super init];
        if(self){
            tripController = self;
        }
    }
    
    return tripController;
}

-(void)fetchTrips{
    TripLogWebServiceController* webController = [TripLogWebServiceController sharedInstance];
    
    [webController sendGetRequestForTripsWithCompletionHandler:^(NSDictionary *result) {
        NSArray* trips = [result objectForKey:@"results"];
        TripLogCoreDataController* coreDataController = [TripLogCoreDataController sharedInstance];
        [coreDataController addTripsFromArray:trips];
    }];
}

-(void)saveTrip:(NSDictionary*)tripProperties{
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    [dataController addTrip:tripProperties];
    
    if ([[TripLogController sharedInstance] autoSubmitTripToServer]) {
#warning set push request to Parse
        // TODO:
    }
}

-(bool)tryLogWithSavedUserData{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![userDefaults boolForKey:IS_AUTO_LOGIN_ENABLED_KEY]) {
        return NO;
    }
    
    BOOL hasSavedUserData = [userDefaults boolForKey:HAS_SAVED_USER_DATA_KEY];
    if(!hasSavedUserData){
        return NO;
    }
    
    NSString* userId = [userDefaults objectForKey:USER_ID_KEY];
    NSString* sessionToken = [userDefaults objectForKey:SESSION_KEY];
    
    [self logTheUserwithUserId:userId andSessionToken:sessionToken andSaveUserData:NO];
    
    return YES;
}

-(void)logTheUserwithUserId:(NSString *)userId andSessionToken:(NSString *)sessionToken andSaveUserData:(BOOL)shouldSave{
    TripLogCoreDataController* dataController = [TripLogCoreDataController sharedInstance];
    User* loggedUser = [dataController userWithUserId:userId initInContenxt:dataController.mainManagedObjectContext];
    TripLogController* tripController = [TripLogController sharedInstance];
    tripController.loggedUser = loggedUser;
    tripController.currentSessionToken = sessionToken;
    
    if(shouldSave){
        [self saveUserDataInUserDefaultsWithUserId:userId andSessionToken:sessionToken];
    }
    
    [self presentTripTabBarViewController];
}

-(void)saveUserDataInUserDefaultsWithUserId:(NSString*)userId andSessionToken:(NSString*)sessionToken{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:HAS_SAVED_USER_DATA_KEY];
    [userDefaults setObject:userId forKey:USER_ID_KEY];
    [userDefaults setObject:sessionToken forKey:SESSION_KEY];
    
    [userDefaults synchronize];
}

-(void)presentTripTabBarViewController{
    if ([NSThread isMainThread]) {
        [self fetchTrips];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController* controller = [storyboard instantiateViewControllerWithIdentifier:@"TripTabViewController"];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = controller;
        [appDelegate.window makeKeyAndVisible];
        // [appDelegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
    } else {
        //Or call the same method on main thread
        [self performSelectorOnMainThread:@selector(presentTripTabBarViewController)
                               withObject:nil waitUntilDone:NO];
    }
}

-(void)onEnterRegion{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController* tabController = [storyboard instantiateViewControllerWithIdentifier:@"TripTabViewController"];
    LocationDetailsViewController* locationDetailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"locationDetailsVC"];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:locationDetailsViewController];
    locationDetailsViewController.atTripLocation = YES;
    NSMutableArray* viewControllers = [NSMutableArray arrayWithObject:navController];
    [viewControllers addObjectsFromArray:[tabController viewControllers]];
    tabController.viewControllers = viewControllers;
    
    navController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"At trip location!"
                                                                           image:[UIImage imageNamed:@"alltrips.png"]
                                                                             tag:5];
    [navController.tabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateNormal];
    [navController.tabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateSelected];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = tabController;
    [appDelegate.window makeKeyAndVisible];
}

@end
