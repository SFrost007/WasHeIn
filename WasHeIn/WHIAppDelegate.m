//
//  WHIAppDelegate.m
//  WasHeIn
//
//  Created by Simon Frost on 05/12/2013.
//  Copyright (c) 2013 Orangeninja. All rights reserved.
//

#import "WHIAppDelegate.h"
#import "WHIViewController.h"


@interface WHIAppDelegate ()
@property (strong, nonatomic) WHIViewController *viewController;
@end

@implementation WHIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[WHIViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [self.viewController fixIOS7StatusBar];
}

@end
