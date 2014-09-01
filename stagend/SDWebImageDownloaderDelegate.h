/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"

@class SDWebImageDownloader2;

@protocol SDWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownloaderDidFinish:(SDWebImageDownloader2 *)downloader;
- (void)imageDownloader:(SDWebImageDownloader2 *)downloader didFinishWithImage:(UIImage *)image;
- (void)imageDownloader:(SDWebImageDownloader2 *)downloader didFailWithError:(NSError *)error;

@end
