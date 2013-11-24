//
//  BCFiPhonePopUp.h
//  Mariette
//
//  Created by Boris Yo on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BCFiPhonePopUpDelegate;

@interface BCFIPhonePopUp : UIView{

}

@property (assign) id <BCFiPhonePopUpDelegate> delegate;
@property (retain) UIView *placeHolderView;
@property (retain) UIViewController *containerViewController;
@property (retain) NSArray *savedTouches;
@property (retain) UIViewController *superViewController;
@property (copy)   NSString *topBarTitle;
@property BOOL popUpStartMoving;
@property BOOL clearParentViews;
@property (readwrite) CGPoint gap;

+ (BCFIPhonePopUp *)showViewController:(UIViewController*)vc asPopUpInViewController:(UIViewController*)addedTo fromCoordinates:(CGPoint)point clearingParentViews:(BOOL)clearPV;
-(id) initWithView:(UIViewController*)containerView fromPoint:(CGPoint)point showAddedTo:(UIViewController*)addedTo clearingParentViews:(BOOL)clearPV;
-(void)cleanAllGestureRecognizerFromVC:(UIViewController*)vc;
-(void)restoreAllGestureRecognizerFromVC:(UIViewController*)vc;
-(void)reduceHeightBy:(CGFloat)points;
-(void)increaseWidthBy:(CGFloat)points;
-(void)movePopUp:(CGPoint)newCoordinates;
-(void)updateTitle:(NSString*)text;
@end


@protocol BCFiPhonePopUpDelegate <NSObject>

@optional

- (void)popUpWillClose:(BOOL)value;

@end