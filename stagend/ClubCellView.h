//
//  ClubCellView.h
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubCellView : UIView

@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *city;

- (void)clearContents;
- (void)resizeLabelToFitText;

@end
