//
//  PlaceCellView.m
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceCellView.h"

@implementation PlaceCellView

@synthesize name, state;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
        
		name = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 2.0, 200.0, 40.0)];
		name.font = [UIFont boldSystemFontOfSize:17];
		name.backgroundColor = [UIColor clearColor];
		name.numberOfLines = 0;
		name.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:name];
        
		
        state = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 200.0, 40.0)];
		state.font = [UIFont systemFontOfSize:15];
		state.backgroundColor = [UIColor clearColor];
		state.numberOfLines = 0;
		state.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:state];
        
    }
    return self;
}

@end
