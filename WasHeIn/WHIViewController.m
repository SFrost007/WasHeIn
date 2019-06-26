//
//  WHIViewController.m
//  WasHeIn
//
//  Created by Simon Frost on 05/12/2013.
//  Copyright (c) 2013 Simon Frost. All rights reserved.
//

#import "WHIViewController.h"

@interface WHIViewController ()
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIImageView *splash;
@end

@interface WHIBrowserActionSheet : UIActionSheet
@property (strong, nonatomic) NSArray *urlList;
@end
@implementation WHIBrowserActionSheet
@end



@implementation WHIViewController

- (void) loadView
{
    // Create the container view
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Set up the splash image
    NSString *splashImage = nil;
    if ([[UIScreen mainScreen] bounds].size.height == 667) {
        splashImage = @"Default-667h@2x.png";
    } else if ([[UIScreen mainScreen] bounds].size.height == 568) {
        splashImage = @"Default-568h@2x.png";
    } else {
        splashImage = @"Default.png";
    }
    self.splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashImage]];
    self.splash.frame = self.view.frame;
    [self.view addSubview:self.splash];

    // Create the web view
    self.webView = [[UIWebView alloc] init];
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    self.webView.hidden = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"www/index" ofType:@"htm"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.webView];

    [self fixIOS7StatusBar];
}

// Set the correct size for the webview based on the OS version
- (void) fixIOS7StatusBar
{
    CGRect targetFrame;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        targetFrame = [[UIScreen mainScreen] applicationFrame];
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        if (statusBarHeight == 40) {
            targetFrame.origin.y -= statusBarHeight/2;
            targetFrame.size.height += statusBarHeight/2;
        }
    } else {
        targetFrame = self.view.frame;
    }

    self.webView.frame = targetFrame;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleBlackOpaque;
}

static NSString * encodeByAddingPercentEscapes(NSString *input) {
    NSString *encodedValue =
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                        kCFAllocatorDefault,
                                                        (CFStringRef)input,
                                                        NULL,
                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                        kCFStringEncodingUTF8));
    return encodedValue;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    webView.hidden = NO;
}

- (BOOL) webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    
    NSMutableArray *openableApps = [NSMutableArray array];
    NSMutableArray *openableURLs = [NSMutableArray array];
    
    if ([url.scheme hasPrefix:@"http"]) {
        // External link, open in another app
        
        // Always have Safari available
        [openableApps addObject:@"Safari"];
        [openableURLs addObject:url];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://m.imdb.com" withString:@"imdb://"];
            [openableApps addObject:@"IMDB"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
          
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                // IMDB will hijack opening in Safari
                [openableApps removeObject:@"Safari"];
                [openableURLs removeObject:url];
            }
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"atomic://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"atomic://http://"];
            [openableApps addObject:@"Atomic"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome-x-callback://"]]) {
            // Special handling for Chrome's back button
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            NSURL *callbackURL = [NSURL URLWithString:@"washein://"];
            
            NSString *chromeURLString = [NSString stringWithFormat:
                                         @"googlechrome-x-callback://x-callback-url/open/?x-source=%@&x-success=%@&url=%@",
                                         encodeByAddingPercentEscapes(appName),
                                         encodeByAddingPercentEscapes([callbackURL absoluteString]),
                                         encodeByAddingPercentEscapes([url absoluteString])];
            [openableApps addObject:@"Chrome"];
            [openableURLs addObject:[NSURL URLWithString:chromeURLString]];
        } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"googlechrome://"];
            [openableApps addObject:@"Chrome"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"dolphin://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"dolphin://http://"];
            [openableApps addObject:@"Dolphin"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"dualbrowser://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"dualbrowser://"];
            [openableApps addObject:@"DualBrowser"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"icabmobile://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"icabmobile://"];
            [openableApps addObject:@"iCab Mobile"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ohttp://"]]) {
            NSString *newURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"ohttp://"];
            [openableApps addObject:@"Opera"];
            [openableURLs addObject:[NSURL URLWithString:newURL]];
        }
        
        if (openableApps.count == 1) {
            // Only have Safari
            [[UIApplication sharedApplication] openURL:url];
        } else {
            // Show an actionsheet to choose
            WHIBrowserActionSheet *actionSheet = [[WHIBrowserActionSheet alloc] initWithTitle:@"Open in.."
                                                                                     delegate:self
                                                                            cancelButtonTitle:nil
                                                                       destructiveButtonTitle:nil
                                                                            otherButtonTitles:nil];
            actionSheet.urlList = openableURLs;
            
            for (NSString *browser in openableApps) {
                [actionSheet addButtonWithTitle:browser];
            }
            
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = openableApps.count;
            
            [actionSheet showInView:self.view];
        }
        return NO;
    }
    return YES;
}

- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WHIBrowserActionSheet *browserSheet = (WHIBrowserActionSheet*)actionSheet;
    if (browserSheet.urlList.count > buttonIndex) {
        [[UIApplication sharedApplication] openURL:[browserSheet.urlList objectAtIndex:buttonIndex]];
    }
}

@end
