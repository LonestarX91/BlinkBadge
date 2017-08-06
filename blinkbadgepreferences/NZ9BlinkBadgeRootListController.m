#include "NZ9BlinkBadgeRootListController.h"

@implementation NZ9BlinkBadgeRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

+ (NSString *)hb_shareText {
	return @"I'm using #BlinkBadge by @NeinZedd9 to animate my notification badges!";
}

static int count = 0;

- (void)updateAnimation {
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]; // Dismisses keyboard
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("NZ9BlinkBadgeNotification"), NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	if(count >= 2) {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enjoying my tweak, \nBlinkBadge?"
																									message:@"Please consider donating so I can continue to develop tweaks like this! \n\nAlso, be sure to check out my other tweaks!\n-NeinZedd9 <3"
																									preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
																									style:UIAlertActionStyleDefault
																									handler:^(UIAlertAction * action) {}];
		[alert addAction:dismissAction];
		[self presentViewController:alert animated:YES completion:nil];
		count = 0;
	}
	else {
		count++;
	}
}

@end
