//
//  RoyalIndicator.m
//  Royal Open Source
//
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
 

#import "RoyalIndicator.h"
#import <QuartzCore/QuartzCore.h>


@interface RoyalIndicator ()

#if __has_feature(objc_arc)
@property (nonatomic, strong) UIView *originalView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;
#else
@property (nonatomic, retain) UIView *originalView;
@property (nonatomic, retain) UIView *borderView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *activityLabel;
#endif
@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation RoyalIndicator

@synthesize originalView, borderView, activityIndicator, activityLabel, labelWidth, showNetworkActivityIndicator;

static RoyalIndicator *royalIndicator = nil;

/*
 currentRoyalIndicator
 
 Returns the currently displayed activity view, or nil if there isn't one.
 
 .
*/

+ (RoyalIndicator *)currentRoyalIndicator;
{
    return royalIndicator;
}

/*
 royalIndicatorForView:
 
 Creates and adds an activity view centered within the specified view, using the label "Loading...".  Returns the activity view, already added as a subview of the specified view.
 
 .
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by BPT 2013-08 to remove the "new" prefix again.
*/

+ (RoyalIndicator *)royalIndicatorForView:(UIView *)addToView;
{
    return [self royalIndicatorForView:addToView withLabel:NSLocalizedString(@"Loading...", @"Default RoyalActivtyView label text") width:0];
}

/*
 royalIndicatorForView:withLabel:
 
 Creates and adds an activity view centered within the specified view, using the specified label.  Returns the activity view, already added as a subview of the specified view.
 
 .
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by BPT 2013-08 to remove the "new" prefix again.
*/

+ (RoyalIndicator *)royalIndicatorForView:(UIView *)addToView withLabel:(NSString *)labelText;
{
    return [self royalIndicatorForView:addToView withLabel:labelText width:0];
}

/*
 royalIndicatorForView:withLabel:width:
 
 Creates and adds an activity view centered within the specified view, using the specified label and a fixed label width.  The fixed width is useful if you want to change the label text while the view is visible.  Returns the activity view, already added as a subview of the specified view.
 
 .
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by BPT 2013-08 to remove the "new" prefix again, and move the singleton stuff to here.
*/

+ (RoyalIndicator *)royalIndicatorForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;
{
    // Immediately remove any existing activity view:
    if (royalIndicator)
        [self removeView];
    
    // Remember the new view (so this is a singleton):
    royalIndicator = [[self alloc] initForView:addToView withLabel:labelText width:aLabelWidth];
    
    return royalIndicator;
}

/*
 initForView:withLabel:width:
 
 Designated initializer.  Configures the activity view using the specified label text and width, and adds as a subview of the specified view.
 
 .
 Changed by BPT 2013-08 to move the singleton stuff to the calling class method, where it should be.
*/

- (RoyalIndicator *)initForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;
{
	if (!(self = [super initWithFrame:CGRectZero]))
		return nil;
	
    // Allow subclasses to change the view to which to add the activity view (e.g. to cover the keyboard):
    self.originalView = addToView;
    addToView = [self viewForView:addToView];
    
    // Configure this view (the background) and its subviews:
    [self setupBackground];
    
    self.labelWidth = aLabelWidth;
    self.borderView = [self makeBorderView];
    [self.borderView setBackgroundColor:[UIColor clearColor]];
    self.activityIndicator = [self makeActivityIndicator];
    self.activityLabel = [self makeActivityLabelWithText:labelText];
    self.activityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    // Assemble the subviews:
	[addToView addSubview:self];
    [self addSubview:self.borderView];
    
    UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(-10, -10, 100, 100)];
    imgview.image = [UIImage animatedImageNamed:@"loading-" duration:1.0f];
    [imgview setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.borderView addSubview:imgview];
//    [self.borderView addSubview:self.activityIndicator];
//    [self.borderView addSubview:self.activityLabel];
    
	// Animate the view in, if appropriate:
	[self animateShow];
    
	return self;
}

- (void)dealloc;
{
#if __has_feature(objc_arc)
    if ([RoyalIndicator isEqual:self])
        royalIndicator = nil;
#else
    [self setBorderView:nil];
    [self setActivityIndicator:nil];
    [self setActivityLabel:nil];
    [self setOriginalView:nil];
    [super dealloc];
#endif
}

/*
 removeView
 
 Immediately removes and releases the view without any animation.
 
 .
 Changed by DJS 2009-09 to disable the network activity indicator if it was shown by this view.
*/

+ (void)removeView;
{
    if (!royalIndicator)
        return;
    
    if (royalIndicator.showNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [royalIndicator removeFromSuperview];
    
    // Remove the global reference:
    royalIndicator = nil;
}

/*
 viewForView:
 
 Returns the view to which to add the activity view.  By default returns the same view.  Subclasses may override this to change the view.
 
 .
*/

- (UIView *)viewForView:(UIView *)view;
{
    return view;
}

/*
 enclosingFrame
 
 Returns the frame to use for the activity view.  Defaults to the superview's bounds.  Subclasses may override this to use something different, if desired.
 
 .
*/

- (CGRect)enclosingFrame;
{
    return self.superview.bounds;
}

/*
 setupBackground
 
 Configure the background of the activity view.
 
 .
*/

- (void)setupBackground;
{
	self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

/*
 makeBorderView
 
 Returns a new view to contain the activity indicator and label.  By default this view is transparent.  Subclasses may override this method, optionally calling super, to use a different or customized view.
 
 .
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UIView *)makeBorderView;
{
#if __has_feature(objc_arc)
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
#else
    UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
#endif
    view.opaque = NO;
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    return view;
}

/*
 makeActivityIndicator
 
 Returns a new activity indicator view.  Subclasses may override this method, optionally calling super, to use a different or customized view.
 
 .
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
#if __has_feature(objc_arc)
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
#else
    UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
#endif
    [indicator startAnimating];
    
    return indicator;
}

/*
 makeActivityLabelWithText:
 
 Returns a new activity label.  Subclasses may override this method, optionally calling super, to use a different or customized view.
 
 .
 Changed by BPT 2013-11 to simplify and make it easier to override.
 Changed by chrisledet 2013-01 to use NSTextAlignmentLeft instead of the deprecated UITextAlignmentLeft.
*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
#if __has_feature(objc_arc)
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
#else
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
#endif
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
    //label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.text = labelText;
    
    return label;
}

/*
 layoutSubviews
 
 Positions and sizes the various views that make up the activity view, including after rotation.
 
 .
*/

- (void)layoutSubviews;
{
    self.frame = [self enclosingFrame];
    
    // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
    if (!CGAffineTransformIsIdentity(self.borderView.transform))
        return;
    
    CGSize textSize = [self.activityLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f]];
    
    // Use the fixed width if one is specified:
    if (self.labelWidth > 10)
        textSize.width = self.labelWidth;
    
    self.activityLabel.frame = CGRectMake(self.activityLabel.frame.origin.x, self.activityLabel.frame.origin.y, textSize.width, textSize.height);
    
    // Calculate the size and position for the border view: with the indicator to the left of the label, and centered in the receiver:
	CGRect borderFrame = CGRectZero;
    borderFrame.size.width = self.activityIndicator.frame.size.width + textSize.width + 25.0;
    borderFrame.size.height = self.activityIndicator.frame.size.height + 10.0;
    borderFrame.origin.x = floor(0.5 * (self.frame.size.width - borderFrame.size.width));
    borderFrame.origin.y = floor(0.5 * (self.frame.size.height - borderFrame.size.height - 20.0));
    self.borderView.frame = borderFrame;
	
    // Calculate the position of the indicator: vertically centered and at the left of the border view:
    CGRect indicatorFrame = self.activityIndicator.frame;
	indicatorFrame.origin.x = 10.0;
	indicatorFrame.origin.y = 0.5 * (borderFrame.size.height - indicatorFrame.size.height);
    self.activityIndicator.frame = indicatorFrame;
    
    // Calculate the position of the label: vertically centered and at the right of the border view:
	CGRect labelFrame = self.activityLabel.frame;
    labelFrame.origin.x = borderFrame.size.width - labelFrame.size.width - 10.0;
	labelFrame.origin.y = floor(0.5 * (borderFrame.size.height - labelFrame.size.height));
    self.activityLabel.frame = labelFrame;
}

/*
 animateShow
 
 Animates the view into visibility.  Does nothing for the simple activity view.
 
 .
*/

- (void)animateShow;
{
    // Does nothing by default
}

/*
 animateRemove
 
 Animates the view out of visibiltiy.  Does nothng for the simple activity view.
 
 .
*/

- (void)animateRemove;
{
    // Does nothing by default
}

/*
 setShowNetworkActivityIndicator:
 
 Sets whether or not to show the network activity indicator in the status bar.  Set to YES if the activity is network-related.  This can be toggled on and off as desired while the activity view is visible (e.g. have it on while fetching data, then disable it while parsing it).  By default it is not shown.
 
 Written by BPT-09.
*/

- (void)setShowNetworkActivityIndicator:(BOOL)show;
{
    showNetworkActivityIndicator = show;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation RoyalWhiteroyalIndicator

/*
 makeActivityIndicator
 
 Returns a new activity indicator view.  This subclass uses a white activity indicator instead of gray.
 
 Written by BPT-10.
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
#if __has_feature(objc_arc)
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
#else
    UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
#endif
    [indicator startAnimating];
    
    return indicator;
}

/*
 makeActivityLabelWithText:
 
 Returns a new activity label.  This subclass uses white text instead of black.
 
 Written by BPT-10.
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
    UILabel *label = [super makeActivityLabelWithText:labelText];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    
    return label;
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation RoyalIndicatorWindow

/*
 viewForView:
 
 Returns the view to which to add the activity view.  For the bezel style, if there is a keyboard displayed, the view is changed to the keyboard's superview.
 
 .
*/

- (UIView *)viewForView:(UIView *)view;
{
    UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    
    if (keyboardView)
        view = keyboardView.superview;
    
    return view;
}

/*
 enclosingFrame
 
 Returns the frame to use for the activity view.  For the bezel style, if there is a keyboard displayed, the frame is changed to cover the keyboard too.
 
 .
*/

- (CGRect)enclosingFrame;
{
    CGRect frame = [super enclosingFrame];
    
    if (self.superview != self.originalView)
        frame = [self.originalView convertRect:self.originalView.bounds toView:self.superview];
    
    return frame;
}

/*
 setupBackground
 
 Configure the background of the activity view.
 
 .
*/

- (void)setupBackground;
{
    [super setupBackground];
    
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
}

/*
 makeBorderView
 
 Returns a new view to contain the activity indicator and label.  The bezel style has a semi-transparent rounded rectangle.
 
 .
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UIView *)makeBorderView;
{
    UIView *view = [super makeBorderView];
    
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    view.layer.cornerRadius = 10.0;
    
    return view;
}

/*
 makeActivityIndicator
 
 Returns a new activity indicator view.  The bezel style uses a large white indicator.
 
 .
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
#if __has_feature(objc_arc)
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
#else
    UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
#endif
    
    [indicator startAnimating];
    
    return indicator;
}

/*
 makeActivityLabelWithText:
 
 Returns a new activity label.  The bezel style uses centered white text.
 
 .
 Changed by Suleman Sidat 2011-07 to support a multi-line label.
 Changed by BPT 2013-11 to simplify and make it easier to override.
 Changed by chrisledet 2013-01 to use NSTextAlignmentCenter and NSLineBreakByWordWrapping instead of the deprecated UITextAlignmentCenter and UILineBreakModeWordWrap.
*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
#if __has_feature(objc_arc)
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
#else
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
#endif
    label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = labelText;
    
    return label;
}

/*
 layoutSubviews
 
 Positions and sizes the various views that make up the activity view, including after rotation.
 
 .
 Changed by Suleman Sidat 2011-07 to support a multi-line label.
*/

- (void)layoutSubviews;
{
    // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
    if (!CGAffineTransformIsIdentity(self.borderView.transform))
        return;
    
    self.frame = [self enclosingFrame];
    
    CGSize maxSize = CGSizeMake(260, 400);
    CGSize textSize = [self.activityLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] constrainedToSize:maxSize lineBreakMode:self.activityLabel.lineBreakMode];
    
    // Use the fixed width if one is specified:
    if (self.labelWidth > 10)
        textSize.width = self.labelWidth;
    
    // Require that the label be at least as wide as the indicator, since that width is used for the border view:
    if (textSize.width < self.activityIndicator.frame.size.width)
        textSize.width = self.activityIndicator.frame.size.width + 10.0;
    
    // If there's no label text, don't need to allow height for it:
    if (self.activityLabel.text.length == 0)
        textSize.height = 0.0;
    
    self.activityLabel.frame = CGRectMake(self.activityLabel.frame.origin.x, self.activityLabel.frame.origin.y, textSize.width, textSize.height);
    
    // Calculate the size and position for the border view: with the indicator vertically above the label, and centered in the receiver:
	CGRect borderFrame = CGRectZero;
    borderFrame.size.width = textSize.width + 30.0;
    borderFrame.size.height = self.activityIndicator.frame.size.height + textSize.height + 40.0;
    borderFrame.origin.x = floor(0.5 * (self.frame.size.width - borderFrame.size.width));
    borderFrame.origin.y = floor(0.5 * (self.frame.size.height - borderFrame.size.height));
    self.borderView.frame = borderFrame;
	
    // Calculate the position of the indicator: horizontally centered and near the top of the border view:
    CGRect indicatorFrame = self.activityIndicator.frame;
	indicatorFrame.origin.x = 0.5 * (borderFrame.size.width - indicatorFrame.size.width);
	indicatorFrame.origin.y = 20.0;
    self.activityIndicator.frame = indicatorFrame;
    
    // Calculate the position of the label: horizontally centered and near the bottom of the border view:
	CGRect labelFrame = self.activityLabel.frame;
    labelFrame.origin.x = floor(0.5 * (borderFrame.size.width - labelFrame.size.width));
	labelFrame.origin.y = borderFrame.size.height - labelFrame.size.height - 10.0;
    self.activityLabel.frame = labelFrame;
}

/*
 animateShow
 
 Animates the view into visibility.  For the bezel style, fades in the background and zooms the bezel down from a large size.
 
 .
*/

- (void)animateShow;
{
    self.alpha = 0.0;
    self.borderView.transform = CGAffineTransformMakeScale(3.0, 3.0);
    
	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:5.0];            // Uncomment to see the animation in slow motion
	
    self.borderView.transform = CGAffineTransformIdentity;
    self.alpha = 1.0;
    
	[UIView commitAnimations];
}

/*
 animateRemove
 
 Animates the view out, deferring the removal until the animation is complete.  For the bezel style, fades out the background and zooms the bezel down to half size.
 
 .
 Changed by DJS 2009-09 to disable the network activity indicator if it was shown by this view.
*/

- (void)animateRemove;
{
    if (self.showNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.borderView.transform = CGAffineTransformIdentity;
    
	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:5.0];            // Uncomment to see the animation in slow motion
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
	
    self.borderView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.alpha = 0.0;
    
	[UIView commitAnimations];
}

- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [[self class] removeView];
}

/*
 removeViewAnimated:
 
 Animates the view out from the superview and releases it, or simply removes and releases it immediately if not animating.
 
 .
*/

+ (void)removeViewAnimated:(BOOL)animated;
{
    if (!royalIndicator)
        return;
    
    if (animated)
        [royalIndicator animateRemove];
    else
        [[self class] removeView];
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation RoyalIndicatorKeyboard

/*
 royalIndicator
 
 Creates and adds a keyboard-style activity view, using the label "Loading...".  Returns the activity view, already covering the keyboard, or nil if the keyboard isn't currently displayed.
 
 .
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by BPT 2013-08 to remove the "new" prefix again.
*/

+ (RoyalIndicatorKeyboard *)royalIndicator;
{
    return [self royalIndicatorWithLabel:NSLocalizedString(@"Loading...", @"Default RoyalActivtyView label text")];
}

/*
 royalIndicatorWithLabel:
 
 Creates and adds a keyboard-style activity view, using the specified label.  Returns the activity view, already covering the keyboard, or nil if the keyboard isn't currently displayed.
 
 .
 Changed by DJS 2010-06 to add "new" prefix to the method name to make it clearer that this returns a retained object.
 Changed by BPT 2013-08 to remove the "new" prefix again.
*/

+ (RoyalIndicatorKeyboard *)royalIndicatorWithLabel:(NSString *)labelText;
{
    UIView *keyboardView = [[UIApplication sharedApplication] keyboardView];
    
    if (!keyboardView)
        return nil;
    else
        return (RoyalIndicatorKeyboard *)[self royalIndicatorForView:keyboardView withLabel:labelText];
}

/*
 viewForView:
 
 Returns the view to which to add the activity view.  For the keyboard style, returns the same view (which will already be the keyboard).
 
 .
*/

- (UIView *)viewForView:(UIView *)view;
{
    return view;
}

/*
 animateShow
 
 Animates the view into visibility.  For the keyboard style, simply fades in.
 
 .
*/

- (void)animateShow;
{
    self.alpha = 0.0;
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	
    self.alpha = 1.0;
    
	[UIView commitAnimations];
}

/*
 animateRemove
 
 Animates the view out, deferring the removal until the animation is complete.  For the keyboard style, simply fades out.
 
 .
*/

- (void)animateRemove;
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
	
    self.alpha = 0.0;
    
	[UIView commitAnimations];
}

/*
 setupBackground
 
 Configure the background of the activity view.
 
 .
*/

- (void)setupBackground;
{
    [super setupBackground];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
}

/*
 makeBorderView
 
 Returns a new view to contain the activity indicator and label.  The keyboard style has a transparent border.
 
 .
 Changed by BPT 2013-11 to simplify and make it easier to override.
*/

- (UIView *)makeBorderView;
{
    UIView *view = [super makeBorderView];
    
    view.backgroundColor = nil;
    
    return view;
}

@end


// ----------------------------------------------------------------------------------------
// MARK: -
// ----------------------------------------------------------------------------------------


@implementation UIApplication (KeyboardView)

//  keyboardView
//
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

- (UIView *)keyboardView;
{
	NSArray *windows = [self windows];
	for (UIWindow *window in [windows reverseObjectEnumerator])
	{
		for (UIView *view in [window subviews])
		{
            // UIPeripheralHostView is used from iOS 4.0, UIKeyboard was used in previous versions:
			if (!strcmp(object_getClassName(view), "UIPeripheralHostView") || !strcmp(object_getClassName(view), "UIKeyboard"))
			{
				return view;
			}
		}
	}
	
	return nil;
}


@end

