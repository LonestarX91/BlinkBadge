include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BlinkBadge
BlinkBadge_FILES = Tweak.xm
BlinkBadge_EXTRA_FRAMEWORKS += Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
after-uninstall::
	uninstall.exec "killall -9 SpringBoard"
	
SUBPROJECTS += blinkbadgepreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
