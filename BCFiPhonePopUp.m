//
//  BCFiPhonePopUp.m
//  Mariette
//
//  Created by Boris Yo on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BCFIPhonePopUp.h"
#import "LocationListViewController.h"
#import "MainViewController.h"

#define kSideFramePixelWith 3
#define kTopFramePixelWith 34
#define kShrinkHeight 0



@implementation BCFIPhonePopUp

@synthesize  delegate                = _delegate;
@synthesize  placeHolderView         = _placeHolderView;
@synthesize  containerViewController = _containerViewController;
@synthesize  savedTouches            = _savedTouches;
@synthesize  superViewController     = _superViewController;
@synthesize  topBarTitle             = _topBarTitle;
@synthesize gap                      = _gap;
@synthesize popUpStartMoving         = _popUpStartMoving;
@synthesize clearParentViews         = _clearParentViews;

-(void) dealloc {
    [_placeHolderView release];
    [_containerViewController release];
    [_savedTouches release];
    [_superViewController release];
    [_topBarTitle release];
    //[_delegate release];
    [super dealloc];
}
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}*/

+ (BCFIPhonePopUp *)showViewController:(UIViewController*)vc asPopUpInViewController:(UIViewController*)addedTo fromCoordinates:(CGPoint)point clearingParentViews:(BOOL)clearPV{
    BCFIPhonePopUp *popUp = [[BCFIPhonePopUp alloc] initWithView:vc fromPoint:point showAddedTo:addedTo clearingParentViews:(BOOL)clearPV];
    return [popUp autorelease];
}

- (id) initWithView:(UIViewController*)containerView fromPoint:(CGPoint)point showAddedTo:(UIViewController*)addedTo clearingParentViews:(BOOL)clearPV{
    self.clearParentViews = clearPV;
    CGRect fullScreen = CGRectMake(0, 0,
                                   addedTo.view.bounds.size.width,
                                   addedTo.view.bounds.size.height);  // toolbar = -40 points
        
    self = [super initWithFrame:fullScreen];
    if (self) {
        [self setPopUpStartMoving:NO];
        //first of all we remove any previus popupWindow that could exist
        if (self.clearParentViews) 
        {
            for (UIView *view in [addedTo.view subviews]) {
                if ([view isKindOfClass:[self class]]) {
                    [view removeFromSuperview];}
            }   
        }
        
        
        // set the delegate property (it must have one) of the view used to show popUp to itself. means 
        // on the call showViewController ...    vc.delegate = addedTo. If for any reason you want to change this delegate, assign a new delegate after the
        // showViewController declaration 
        if ([containerView respondsToSelector:@selector(peoplePickerDelegate)]) {
            [containerView performSelector:@selector(setPeoplePickerDelegate:) withObject:addedTo];
        }else if ([containerView respondsToSelector:@selector(delegate)]) {
            [containerView performSelector:@selector(setDelegate:) withObject:addedTo];
        }

        [self setContainerViewController:containerView]; // copy the added viewController
        
        UIImage      *frameLayer      = [UIImage imageNamed:@"popUpFrame"]; // (215, 288)
        UIImage      *arrowImage      = [UIImage imageNamed:@"popUpArrow"]; // 
        UIImageView  *arrowImageView  = [[UIImageView alloc] initWithImage:arrowImage ];
        [arrowImageView setUserInteractionEnabled:NO];
        [arrowImageView setTag:5];

        CGFloat arrowIconHeight  = arrowImage.size.height;
        CGFloat arrowIconWidth   = arrowImage.size.width;
        CGFloat frameLayerWidth  = frameLayer.size.width;
        CGFloat frameLayerHeight = frameLayer.size.height;
        
        //this will hold the corrected value for x,y because point indicate the left bottom corner.
        CGPoint translatedOrigin = CGPointMake(0, 0);        
        
        //calculate the position of the x point for placeHolderView
        CGFloat gapForAxis_X=0;
        // arrow in the left corner
        float ExpressionA = point.x + frameLayerWidth/2;
        float ExpressionB = frameLayerWidth*2;

        int iphoneLimit = 259;
        int ipadLimit   = 460;
        
        int safeMargin = [MainViewController deviceTypeName] == iPhone ? iphoneLimit : ipadLimit;
        
        /*if ([MainViewController deviceTypeName]==iPhone) 
        {*/
            
    
        if ( (( ExpressionA) <= (ExpressionB)) && (ExpressionA) < (150) ){ 
            gapForAxis_X = point.x;                                         // arrow in the left
        }else  
        if ( ((ExpressionA) <= (ExpressionB)) &&  ((ExpressionA) <=  (safeMargin)) ){ 
            gapForAxis_X = point.x - ((frameLayerWidth/2)-arrowIconWidth); // arrow in the middle
        }else 
        if ( ((ExpressionA) <= (ExpressionB)) &&  ((ExpressionA) >=  (safeMargin)) ){ 
            gapForAxis_X = point.x - (frameLayerWidth-arrowIconWidth);     // arrow in the right
        }else
            if ( ((ExpressionA) >= (ExpressionB)) &&  ((ExpressionA) >=  (safeMargin)) ){ 
                gapForAxis_X = point.x - (frameLayerWidth-arrowIconWidth);     // arrow in the right
            }
       // }
        //set the arrow for bottom touch
        [arrowImageView setFrame:CGRectMake(point.x-2, point.y-arrowIconHeight,  // 2 is because arrow witdth here is a litle wide
                                            arrowIconWidth, arrowIconHeight)];
        
        translatedOrigin.x = gapForAxis_X;
        translatedOrigin.y = point.y-(frameLayerHeight+arrowIconHeight);
        
        //this is the 2 view in hirerchary this contain the rest forward
        _placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(translatedOrigin.x , translatedOrigin.y+kShrinkHeight,
                                                  frameLayerWidth+kSideFramePixelWith*2, frameLayerHeight-kShrinkHeight)];
        [_placeHolderView setClipsToBounds:YES];
        [_placeHolderView setContentMode:UIViewContentModeScaleToFill];
        [_placeHolderView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_placeHolderView setAutoresizesSubviews:YES];
        [_placeHolderView setTag:2];
        [_placeHolderView setBackgroundColor:[UIColor clearColor]];

        
        //this is the 3 view imageview that contain the frame image frameLayer
        UIImageView *placeHolderFrame = [[UIImageView alloc] init];
        UIEdgeInsets inset = UIEdgeInsetsMake(40, 10, 10, 10);
        [placeHolderFrame setImage:[frameLayer resizableImageWithCapInsets:inset]];
        [placeHolderFrame setClipsToBounds:YES];
        [placeHolderFrame setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [placeHolderFrame setContentMode:UIViewContentModeScaleToFill];
        [placeHolderFrame setAlpha:1];
        [placeHolderFrame setTag:3];
        [placeHolderFrame setFrame:CGRectMake(0, 0, frameLayerWidth, frameLayerHeight-kShrinkHeight)];

        //this is the 4 view, here adjust the frame of the containerViewController to fit the finalContainer
        self.containerViewController.view.frame = CGRectMake(0, 0, frameLayerWidth-kSideFramePixelWith*2,
                                                                   frameLayerHeight-arrowIconHeight);
        [self.containerViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.containerViewController.view setClipsToBounds:YES];
        [self.containerViewController.view setAutoresizesSubviews:YES];
        [self.containerViewController.view setBackgroundColor:[UIColor whiteColor]];
        
        //this is the 5 and the topmost view where the tableview is inserted
        UIView *finalContainer = [[UIView alloc] initWithFrame:CGRectMake(kSideFramePixelWith, kTopFramePixelWith,
                                                                          frameLayerWidth-kSideFramePixelWith*2,
                                                                          (frameLayerHeight-arrowIconHeight)-kSideFramePixelWith)];
        [finalContainer setBackgroundColor:[UIColor clearColor]];
        [finalContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [finalContainer setContentMode:UIViewContentModeScaleToFill];
        [finalContainer setAutoresizesSubviews:YES];
        [finalContainer setClipsToBounds:YES];
        [finalContainer addSubview:self.containerViewController.view];

        //final assembly
        [_placeHolderView addSubview:finalContainer], [finalContainer release];
        [_placeHolderView addSubview:placeHolderFrame], [placeHolderFrame release];
        [self addSubview:arrowImageView], [arrowImageView release];
        [self addSubview: _placeHolderView];
        
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setContentMode:UIViewContentModeScaleToFill];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self setAutoresizesSubviews:NO];
        [self setAlpha:0.0];
        [addedTo.view addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{[self setAlpha:1.0];}];
         
        [self setSuperViewController:addedTo];
        if ([addedTo.view.gestureRecognizers count]!=0) 
        {
            _savedTouches = _savedTouches==nil ? [[NSArray alloc] initWithArray:[addedTo.view gestureRecognizers]] : _savedTouches;
            [self cleanAllGestureRecognizerFromVC:self.superViewController];
        }
       /* [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];*/
    }

    return self;
}

-(void)updateTitle:(NSString*)text{
    UIView *popUpView = [self viewWithTag:3];
    //scan in subviews of popUp Frame any previus UILabel and remove it.
    for (UIView *view in [popUpView subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, popUpView.bounds.size.width-20, 20)];
    [textLabel setTextColor:[UIColor whiteColor]];
    [textLabel setText:text];
    [textLabel setTextAlignment:UITextAlignmentCenter];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [popUpView addSubview:textLabel];
    [textLabel release];
}

-(void)reduceHeightBy:(CGFloat)points{
     CGFloat x = self.placeHolderView.frame.origin.x;
     CGFloat y = self.placeHolderView.frame.origin.y;
     CGFloat H = self.placeHolderView.frame.size.height;
     CGFloat W = self.placeHolderView.frame.size.width;
     //[_placeHolderView setBounds:CGRectMake(x, y-n, W, H-n)];
    [_placeHolderView setFrame:CGRectMake(x, y+points, W, H-points)];
    [self setNeedsLayout];
}

-(void)increaseWidthBy:(CGFloat)points{
    CGFloat x = self.placeHolderView.frame.origin.x;
    CGFloat y = self.placeHolderView.frame.origin.y;
    CGFloat H = self.placeHolderView.frame.size.height;
    CGFloat W = self.placeHolderView.frame.size.width;
    [_placeHolderView setFrame:CGRectMake(x-points, y, W+points, H)];
    [self setNeedsLayout];
}

- (void)movePopUp:(CGPoint)newCoordinates{
    CGFloat x = self.placeHolderView.frame.origin.x;
    CGFloat y = self.placeHolderView.frame.origin.y;
    CGFloat H = self.placeHolderView.frame.size.height;
    CGFloat W = self.placeHolderView.frame.size.width;
    
    //if is first touch, calculate the diference between origin.x and the x touched
    //and add permanentely when draggin
   if (!self.popUpStartMoving) { 
       [self setGap:CGPointMake(newCoordinates.x - x, newCoordinates.y - y)];
       [self setPopUpStartMoving:YES];
   }
    //set the limits of the draggable area
    CGFloat maxDragOnY = self.frame.size.height-70;
    if ( (newCoordinates.y-self.gap.y >=0 ) && (newCoordinates.y-self.gap.y <= maxDragOnY ) ) {
        [_placeHolderView setFrame:CGRectMake(newCoordinates.x - self.gap.x ,
                                              newCoordinates.y - self.gap.y , W, H)];
    }   
    if (![[self viewWithTag:5] isHidden]) {
        [[self viewWithTag:5] removeFromSuperview];
    }
}

-(void)cleanAllGestureRecognizerFromVC:(UIViewController*)vc{
    for (UIGestureRecognizer *viewGestures in self.savedTouches) {
        [self.superViewController.view removeGestureRecognizer:viewGestures];
    }
}

-(void)restoreAllGestureRecognizerFromVC:(UIViewController*)vc{
    [self.superViewController.view setGestureRecognizers:self.savedTouches];
    [self setSavedTouches:nil];  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch phase]==UITouchPhaseMoved) {
        [[self viewWithTag:7] removeFromSuperview];
    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint move = [touch locationInView:self];
    if (touch.view.tag==2) [self movePopUp:move];
    //NSLog(@"Coordinates X: %f  Y: %f", move.x, move.y);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == self) {
        [self restoreAllGestureRecognizerFromVC:self.superViewController];
        [self setPlaceHolderView:nil];
        [self setSuperViewController:nil];
        [self setContainerViewController:nil];
        //[self setSavedTouches:nil];
        [self removeFromSuperview];
        //[super dealloc];
        [self.delegate popUpWillClose:YES];
    }
    [self setPopUpStartMoving:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
