//
//  APActivity.m
//  stagend
//
//  Created by Daniel Rivera on 01/09/14.
//
//

#import "APActivity.h"

@implementation APActivityProvider
- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return @"This is a #twitter post!";
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
        return @"This is a facebook post!";
    if ( [activityType isEqualToString:UIActivityTypeMessage] )
        return @"SMS message text";
    if ( [activityType isEqualToString:UIActivityTypeMail] )
        return @"Email text here!";
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end