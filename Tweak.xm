NSUserDefaults *settings;
NSMutableArray *badges = [NSMutableArray array];
BOOL createdTimer = NO;
NSTimer *timer;
double animationDuration = 0.7;

@interface SBIconBadgeView : UIView
- (void)nz9_blinkbadge_fadeInBadge;
- (void)nz9_blinkbadge_fadeOutBadge;
- (void)nz9_blinkbadge_animate;
@end

static void nz9_prefChanged() {
  if (settings) {
    [settings release];
  }
  settings = [[NSUserDefaults  alloc] initWithSuiteName:@"com.neinzedd9.BlinkBadge"];
  [settings registerDefaults:@{
      @"animationDuration": @"0.7",
  }];
	animationDuration = [[settings objectForKey:@"animationDuration"] doubleValue];
	if(createdTimer) {
		[timer invalidate];
		timer = [NSTimer scheduledTimerWithTimeInterval: (animationDuration * 2)
																						 target: [NSBlockOperation blockOperationWithBlock:^{
																							 for(SBIconBadgeView *badge in badges) {
																						 		[badge nz9_blinkbadge_fadeInBadge];
																						 	}
																								if([badges count] == 0) {
																									[timer invalidate];
																									createdTimer = NO;
																								}}]
																					 selector: @selector(main)
																					 userInfo: nil
																					  repeats: YES];
	}
}

%hook SBIconBadgeView

- (id)init {
	%orig;
	[badges addObject: self];
	if(!createdTimer) {
		timer = [NSTimer scheduledTimerWithTimeInterval: (animationDuration * 2)
																						 target: [NSBlockOperation blockOperationWithBlock:^{
																							 for(SBIconBadgeView *badge in badges) {
																						 		[badge nz9_blinkbadge_fadeInBadge];
																						 	}
																								if([badges count] == 0) {
																									[timer invalidate];
																									createdTimer = NO;
																								}}]
																					 selector: @selector(main)
																					 userInfo: nil
																					  repeats: YES];
		createdTimer = YES;
	}
	return self;
}

%new - (void)nz9_blinkbadge_fadeInBadge {
	[UIView animateWithDuration: animationDuration
					delay: 0.0
					options: nil
					animations: ^{
						self.alpha = 1.0;
					}
					completion: ^(BOOL finished){
		if(finished) {
			[self nz9_blinkbadge_fadeOutBadge];
		}
	}];
}

%new - (void)nz9_blinkbadge_fadeOutBadge {
	[UIView animateWithDuration: animationDuration
					delay: 0.0
					options: nil
					animations: ^{
						self.alpha = 0.0;
					}
					completion: nil
	];
}

%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)nz9_prefChanged, CFSTR("NZ9BlinkBadgeNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	%init;
	nz9_prefChanged();
}
