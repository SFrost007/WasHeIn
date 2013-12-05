//
//  WHIAppDelegate.m
//  WasHeIn
//
//  Created by Simon Frost on 05/12/2013.
//  Copyright (c) 2013 Orangeninja. All rights reserved.
//

#import "WHIAppDelegate.h"
#import "WHIViewController.h"

@implementation WHIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[WHIViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
