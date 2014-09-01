//
//  JSONDownloader.h
//  stagend
//
//  Created by koa on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONDownloader;

@protocol JSONDownloaderDelegate <NSObject>

@required

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data;
- (void)handleConnectionError:(JSONDownloader *)jsonDownloader;

@end


@interface JSONDownloader : NSObject {
	
}

@property (unsafe_unretained) id<JSONDownloaderDelegate> delegate;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) NSURLConnection *itemsConnection;
@property (nonatomic, assign) int typeJSON;

- (void) handleError: (NSError *)error;
- (void) get:(NSString *)url;

@end