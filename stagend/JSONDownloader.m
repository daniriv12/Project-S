//
//  JSONDownloader.m
//  stagend
//
//  Created by koa on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONDownloader.h"
#include "SBJson.h"

@implementation JSONDownloader

@synthesize delegate, itemsConnection, data, typeJSON;


- (void) get:(NSString *)url {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	self.itemsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data {
    [self.data appendData:_data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Connection error", @"") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.itemsConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.itemsConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *responseString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    
    NSDictionary *_data = [responseString JSONValue];
    
    self.data = nil;
    
    if (delegate != nil && [delegate conformsToProtocol:@protocol(JSONDownloaderDelegate)]) {
        if ([delegate respondsToSelector:@selector(downloadDidFinish:data:)]) {
            [delegate performSelector:@selector(downloadDidFinish:data:) withObject:self withObject:_data];
        }
    }
    
}

- (void)handleError:(NSError *)error {
	NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", @"") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    // Call the delegate
    if (delegate != nil && [delegate conformsToProtocol:@protocol(JSONDownloaderDelegate)]) {
		if ([delegate respondsToSelector:@selector(handleConnectionError:)]) {
			[delegate performSelector:@selector(handleConnectionError:) withObject:self];
		}
    }
}

@end
