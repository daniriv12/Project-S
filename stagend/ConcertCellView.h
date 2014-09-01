//
//  ConcertCellView.h
//  Stagend
//
//  Created by koa on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ConcertCellView : UIView

@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *place;

- (void)clearContents;
- (void)resizeLabelToFitText;

@end
