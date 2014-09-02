//
//  DRActivityItemProvider.m
//  stagend
//
//  Created by Daniel Rivera on 01/09/14.
//
//

#import "DRActivityItemProvider.h"



@implementation DRActivityItemProvider

- (id)initWithDefaultText:(NSString*)text;
{
    self = [super initWithPlaceholderItem: (NSString*) text];
   
    self.text = text;
   

    
    if ( self )
    {
      
       
        self.text = text;
    }
    return self;
}

- (id)item
{
    
    if (self.activityType == UIActivityTypePostToTwitter )
    {
        return self.text;
   
    }
    
    if (self.activityType == UIActivityTypeMail)
    {
        return NSLocalizedString(@"Sharing concert", @"");
    }
    
    if(self.activityType == UIActivityTypeMessage)
    {
        return NSLocalizedString(@"Sharing concert", @"");
    }
    
  
    
    // else we didn't actually provide a string just return the placeholder
    return nil;
}

@end

@implementation DRActivityItemProvider2

- (id)initWithDefaultText:(NSString*)text;
{
    self = [super initWithPlaceholderItem: (NSString*) text];
    
    self.text = text;
    
    
    
    if ( self )
    {
        
        
        self.text = text;
    }
    return self;
}

- (id)item
{
    
    if (self.activityType == UIActivityTypePostToTwitter )
    {
        return self.text;
        
    }
    
    if (self.activityType == UIActivityTypeMail)
    {
        return NSLocalizedString(@"Sharing artist", @"");
    }
    
    if(self.activityType == UIActivityTypeMessage)
    {
        return NSLocalizedString(@"Sharing artist", @"");
    }
    
    
    
    // else we didn't actually provide a string just return the placeholder
    return nil;
}



@end


@implementation DRActivityImageProvider

- (id)initWithDefaultImage: (UIImage*) image;
{
    //  self = [super initWithPlaceholderItem: (NSString*) url];
    self = [super initWithPlaceholderItem: (NSURL*) image];
    

    self.image = image;
    
    
    if ( self )
    {
        self.image = image;
        
    }
    return self;
}

- (id)item
{
    
    if (self.activityType == UIActivityTypePostToTwitter )
    {

        return self.image;
    }
    
    
    // else we didn't actually provide a string just return the placeholder
    return nil;
}
@end


@implementation DRActivityURLProvider

- (id)initWithDefaultURL: (NSURL*) url;
{
    //  self = [super initWithPlaceholderItem: (NSString*) url];
    self = [super initWithPlaceholderItem: (NSURL*) url];
    
    
    self.url = url;;
    
    
    if ( self )
    {
        self.url = url;;
        
    }
    return self;
}

- (id)item
{
    
    if (self.activityType == UIActivityTypePostToTwitter )
    {
        
        return nil;
    }
    
    
    
    return self.url;
}
@end