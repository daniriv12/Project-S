//
//  DRFacebookHolder.m
//  stagend
//
//  Created by Daniel Rivera on 05/09/14.
//
//

#import "DRFacebookHolder.h"

@implementation DRFacebookHolder

- (NSString *)activityType {
    return nil;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"facebook2"];
}

- (NSString *)activityTitle
{
    return @"Facebook";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Attention: "
                                                      message:@"To share on facebook you must make sure you are logged in in your device's settings."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

@end
