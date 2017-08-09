NSUserDefaults *settings;
NSMutableArray *badges = [NSMutableArray array];
BOOL createdTimer = NO;
NSTimer *timer;
double animationDuration = 0.7;
int animationType = 1;

@interface SBIconBadgeView : UIView
- (void)nz9_blinkbadge_blinkAnimation;
- (void)nz9_blinkbadge_bounceAnimation;
- (void)nz9_blinkbadge_wiggleAnimation;
- (void)nz9_blinkbadge_animate;
@end

static void nz9_createTimer() {
  timer = [NSTimer scheduledTimerWithTimeInterval: (animationDuration * 2)
                                           target: [NSBlockOperation blockOperationWithBlock:^{
                                             for(SBIconBadgeView *badge in badges) {
                                              [badge nz9_blinkbadge_animate];
                                            }
                                              if([badges count] == 0) {
                                                [timer invalidate];
                                                createdTimer = NO;
                                              }}]
                                         selector: @selector(main)
                                         userInfo: nil
                                          repeats: YES];
}

static void nz9_prefChanged() {
  if (settings) {
    [settings release];
  }
  settings = [[NSUserDefaults  alloc] initWithSuiteName:@"com.neinzedd9.BlinkBadge"];
  [settings registerDefaults:@{
      @"animationDuration": @"0.7",
      @"animationType": @"blink",
  }];
	animationDuration = [[settings objectForKey:@"animationDuration"] doubleValue];
  if([[settings objectForKey:@"animationType"] isEqualToString:@"bounce"]) {
    animationType = 0;
  }
  else if([[settings objectForKey:@"animationType"] isEqualToString:@"blink"]) {
    animationType = 1;
  }
  else if([[settings objectForKey:@"animationType"] isEqualToString:@"wiggle"]) {
    animationType = 2;
  }
	if(createdTimer) {
		[timer invalidate];
    nz9_createTimer();
	}
}

%hook SBIconBadgeView

- (id)init {
	%orig;
	[badges addObject: self];
	if(!createdTimer) {
		nz9_createTimer();
		createdTimer = YES;
	}
	return self;
}

%new - (void)nz9_blinkbadge_blinkAnimation {
	[UIView animateWithDuration: animationDuration
					delay: 0.0
					options: nil
					animations: ^{
						self.alpha = 1.0;
					}
					completion: ^(BOOL finished){
		if(finished) {
      [UIView animateWithDuration: animationDuration
    					delay: 0.0
    					options: nil
    					animations: ^{
    						self.alpha = 0.0;
    					}
    					completion: nil
    	];
		}
	}];
}

%new - (void)nz9_blinkbadge_bounceAnimation {
  CGPoint originalCenter = self.center;
  [UIView animateWithDuration: animationDuration / 2
          delay: 0
          usingSpringWithDamping: 0.0
          initialSpringVelocity: 0
          options: UIViewAnimationOptionCurveEaseOut
          animations: ^{
            self.center = CGPointMake(self.center.x, self.center.y - 15);
          }
          completion: ^(BOOL finished) {
            if (finished) {
              [UIView animateWithDuration: animationDuration * 2
                      delay: 0
                      usingSpringWithDamping: 0.2
                      initialSpringVelocity: 0
                      options: UIViewAnimationOptionCurveEaseOut
                      animations: ^{
                        self.center = originalCenter;
                      }
                      completion: ^(BOOL finished) {
                        self.center = originalCenter; // called when animation is cancelled and finished
                      }];
            } else {
              self.center = originalCenter; // called when animation is canceclled
            }
          }];
}

%new - (void)nz9_blinkbadge_wiggleAnimation {
  self.transform = CGAffineTransformIdentity;
  [UIView animateWithDuration: animationDuration
          delay:0.0
          usingSpringWithDamping:0.0
          initialSpringVelocity:0.0
          options:UIViewAnimationOptionCurveEaseInOut
          animations: ^{
            self.transform = CGAffineTransformRotate(self.transform, 0.174533);
          }
          completion: ^(BOOL finished) {
            if (finished) {
              [UIView animateWithDuration: animationDuration
                      delay:0.0
                      usingSpringWithDamping:0.0
                      initialSpringVelocity:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                      animations: ^{
                        self.transform = CGAffineTransformIdentity;
                        self.transform = CGAffineTransformRotate(self.transform, -0.174533);
                      }
                      completion: nil];
            }
          }];
}

%new - (void)nz9_blinkbadge_animate {
  if(animationType == 0) {
    // bounce
    [self nz9_blinkbadge_bounceAnimation];
  }
  else if(animationType == 1) {
    // blink
    [self nz9_blinkbadge_blinkAnimation];
  }
  else if(animationType == 2) {
    // wiggle
    [self nz9_blinkbadge_wiggleAnimation];
  }
}

%end

%hook SBApplication

- (void)willActivate {
  %orig;
  if(createdTimer) {
    [timer invalidate];
    createdTimer = NO;
  }
  for(SBIconBadgeView *badge in badges) {
   [badge.layer removeAllAnimations];
 }
}

- (void)willDeactivateForEventsOnly:(BOOL)arg1 {
  %orig;
  if(!createdTimer) {
		nz9_createTimer();
		createdTimer = YES;
	}
}

%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)nz9_prefChanged, CFSTR("NZ9BlinkBadgeNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	%init;
	nz9_prefChanged();
}
