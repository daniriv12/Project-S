//
//  DRActivityItemProvider.h
//  stagend
//
//  Created by Daniel Rivera on 01/09/14.
//
//

#import <Foundation/Foundation.h>
#import "DRWhatsapp.h"

@interface DRActivityItemProvider : UIActivityItemProvider

- (id)initWithDefaultText:(NSString*) text;



@property (nonatomic, strong) NSString* text;

@end


@interface DRActivityItemProvider2 : UIActivityItemProvider

- (id)initWithDefaultText:(NSString*) text;

@property (nonatomic, strong) NSString* text;

@end



@interface DRActivityImageProvider : UIActivityItemProvider

- (id)initWithDefaultImage:(UIImage*) image;


@property (nonatomic, strong) UIImage * image;

@end


@interface DRActivityURLProvider : UIActivityItemProvider

- (id)initWithDefaultURL:(NSURL*) url;


@property (nonatomic, strong) NSURL * url;



@end
