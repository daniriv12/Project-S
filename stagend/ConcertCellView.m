//
//  ConcertCellView.m
//  Stagend
//
//  Created by koa on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConcertCellView.h"


@implementation ConcertCellView

@synthesize logo, title, place;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
	
		self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
		
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 70.0, 70.0)];
		[self addSubview:logo];

		title = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 4.0, 205.0, 42.0)];
		title.font = [UIFont boldSystemFontOfSize:17];
		title.backgroundColor = [UIColor clearColor];
		title.numberOfLines = 0;
		title.lineBreakMode = UILineBreakModeTailTruncation;
		
		[self addSubview:title];
    
		
        place = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 50.0, 205.0, 20.0)];
		place.font = [UIFont systemFontOfSize:13];
		place.backgroundColor = [UIColor clearColor];
		place.numberOfLines = 1;
		place.lineBreakMode = UILineBreakModeTailTruncation;
        
		[self addSubview:place];
		
    }
    return self;
}


- (void)clearContents {

    self.title.frame = CGRectMake(85.0, 4.0, 205.0, 42.0);
	
}

- (void)resizeLabelToFitText {
    
    [self.title sizeToFit];
    
    if (self.title.frame.size.height > 42.0) {
        self.title.frame = CGRectMake(85.0, 4.0, 205.0, 42.0);
        [self.title setNeedsDisplay];
    }    
    
}

@end
