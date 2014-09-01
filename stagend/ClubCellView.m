//
//  ClubCellView.m
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClubCellView.h"

@implementation ClubCellView

@synthesize logo, name, city;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
		
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 70.0, 70.0)];
		[self addSubview:logo];
        
		name = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 4.0, 205.0, 42.0)];
		name.font = [UIFont boldSystemFontOfSize:17];
		name.backgroundColor = [UIColor clearColor];
		name.numberOfLines = 0;
		name.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:name];
        
		
        city = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 50.0, 205.0, 20.0)];
		city.font = [UIFont systemFontOfSize:13];
		city.backgroundColor = [UIColor clearColor];
        city.numberOfLines = 1;
		city.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:city];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)clearContents {
    
    self.name.frame = CGRectMake(85.0, 4.0, 205.0, 42.0);
	
}

- (void)resizeLabelToFitText {
    
    [self.name sizeToFit];
    
    if (self.name.frame.size.height > 42.0) {
        self.name.frame = CGRectMake(85.0, 4.0, 205.0, 42.0);
        [self.name setNeedsDisplay];
    }    
    
}
@end
