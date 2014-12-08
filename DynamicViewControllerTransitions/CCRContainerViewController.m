//
//  ViewController.m
//  DynamicViewControllerTransitions
//
//  Created by admin on 03/11/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import "CCRContainerViewController.h"
#import "CCRReplaceableViewController.h"

@interface CCRContainerViewController ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicBehavior;

@property (nonatomic, weak) CCRReplaceableViewController *topReplacebleViewController;
@property (nonatomic, weak) CCRReplaceableViewController *bottomReplacebleViewController;

@end

@implementation CCRContainerViewController

// Lazily instanciate the behaviors
- (UICollisionBehavior *)collisionBehavior
{
    if (!_collisionBehavior) {
        _collisionBehavior = [[UICollisionBehavior alloc] init];
        [_collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-1.2 * CGRectGetMaxY(self.view.bounds), 0.0, 0.0, 0.0)];
        
        // Detect when the replaceble controller's view is completely off screen
        __block CCRContainerViewController *weakSelf = self;
        _collisionBehavior.action = ^{
            if (weakSelf.topReplacebleViewController.view.center.y < -CGRectGetMaxY(weakSelf.topReplacebleViewController.view.bounds) / 2) {
                [weakSelf.collisionBehavior removeItem:weakSelf.topReplacebleViewController.view];
                [weakSelf.animator removeBehavior:weakSelf.collisionBehavior];
                [weakSelf.animator removeBehavior:weakSelf.attachmentBehavior];
                
                // Remove the pushed controller from the view controller's hierarchy
                [weakSelf.topReplacebleViewController willMoveToParentViewController:nil];
                [weakSelf.topReplacebleViewController.view removeFromSuperview];
                [weakSelf.topReplacebleViewController removeFromParentViewController];
                
                // Remove the attachment behavior
                [weakSelf.animator removeBehavior:weakSelf.attachmentBehavior];
                weakSelf.attachmentBehavior = nil;
                
                // The controller underneath is now on top
                weakSelf.topReplacebleViewController = weakSelf.bottomReplacebleViewController;
                NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                weakSelf.topReplacebleViewController.controllerPositionTitle.attributedText = [[NSAttributedString alloc] initWithString:@"Top view controller" attributes:attributes];

            }
        };
    }
    
    return _collisionBehavior;
}

- (UIGravityBehavior *)gravityBehavior
{
    if (!_gravityBehavior) {
        _gravityBehavior = [[UIGravityBehavior alloc] init];
        _gravityBehavior.magnitude = 5.0;
        [self.animator addBehavior:_gravityBehavior];
        
    }
    
    return _gravityBehavior;
}

- (UIDynamicItemBehavior *)dynamicBehavior
{
    if (!_dynamicBehavior) {
        _dynamicBehavior = [[UIDynamicItemBehavior alloc] init];
        [self.animator addBehavior:_dynamicBehavior];
    }
    
    return _dynamicBehavior;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScreenEdgePanGestureRecognizer *bottomEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgeGestureRecognizer:)];
    bottomEdgeGestureRecognizer.edges = UIRectEdgeBottom;
    //bottomEdgeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:bottomEdgeGestureRecognizer];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Add the initial view controller
    [self insertReplacebleViewController];
}

- (void)insertReplacebleViewController
{
    // Create a replaceable controller and add it to the hierarchy
    CCRReplaceableViewController *replacebleViewController = [[CCRReplaceableViewController alloc] init];
    [self addChildViewController:replacebleViewController];
    replacebleViewController.view.frame = self.view.bounds;
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    if (!self.topReplacebleViewController) {
        replacebleViewController.controllerPositionTitle.attributedText = [[NSAttributedString alloc] initWithString:@"Top view controller" attributes:attributes];
        // First replaceable view controller, inserted at launch at the top of the hierarchy
        [self.view addSubview:replacebleViewController.view];
        self.topReplacebleViewController = replacebleViewController;
    } else {
        replacebleViewController.controllerPositionTitle.attributedText = [[NSAttributedString alloc] initWithString:@"Bottom view controller" attributes:attributes];
        // Next replaceable view controllers are inserted under the top controller
        [self.view insertSubview:replacebleViewController.view belowSubview:self.topReplacebleViewController.view];
        self.bottomReplacebleViewController = replacebleViewController;
    }
    
    // Alternate the replaceable controller's background color
    if (self.topReplacebleViewController.view.backgroundColor == [UIColor orangeColor]) {
        replacebleViewController.view.backgroundColor = [UIColor blueColor];
    } else {
        replacebleViewController.view.backgroundColor = [UIColor orangeColor];
    }
    
    [replacebleViewController didMoveToParentViewController:self];
}

- (void)handleEdgeGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPoint = [gestureRecognizer locationInView:self.view];
    // The anchor point X position is constant to prevent the pushed controller to move horizontally
    anchorPoint.x = CGRectGetMidX(self.view.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        [self insertReplacebleViewController];
        
        // Add the attachement behavior to the top controller
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.topReplacebleViewController.view
                                                                             attachedToAnchor:anchorPoint];
        [self.animator addBehavior:self.attachmentBehavior];
        
        [self.animator addBehavior:self.collisionBehavior];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // Move the top controller in sync with the pan gesture
        self.attachmentBehavior.anchorPoint = anchorPoint;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [self.animator removeBehavior:self.attachmentBehavior];
        
        // Add the top controller's view to the different behaviors to take over when the pan gesture is finished
        [self.gravityBehavior addItem:self.topReplacebleViewController.view];
        [self.collisionBehavior addItem:self.topReplacebleViewController.view];
        [self.dynamicBehavior addItem:self.topReplacebleViewController.view];
        
        // The top controller falls back down if it isn't pushed past one third of the screen height
        if (anchorPoint.y > 2 * CGRectGetMaxY(self.view.bounds) / 3) {
            
            self.gravityBehavior.gravityDirection = CGVectorMake(0.0, 1.0);
            [self.bottomReplacebleViewController removeFromParentViewController];
            
        } else {
            self.gravityBehavior.gravityDirection = CGVectorMake(0.0, -1.0);
            self.dynamicBehavior.elasticity = 0.0;

            // Keep the top controller speed when the attachment behavior is removed
            CGPoint instantVelocity = [gestureRecognizer velocityInView:self.view];
            instantVelocity.x = 0.0;
            [self.dynamicBehavior addLinearVelocity:instantVelocity forItem:self.topReplacebleViewController.view];
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    // This enables the top and bottom edge gesture custom gesture recognizers
    // Otherwise, the top edge pan gesture slides down the Notification Center and the bottom pan gesture slides up the Control Center
    return YES;
}

- (BOOL)shouldAutorotate
{
    // This sample only works in portait orientation 
    return NO;
}
@end
