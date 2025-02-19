#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

%group VideoAndAudioModePatches
// Remove popup reminder 
%hook YTMPlayerHeaderViewController
- (bool)shouldDisplayHintForAudioVideoSwitch {
	return 0;
}
%end

%hook YTIPlayerResponse
- (id)ytm_audioOnlyUpsell {
    return nil;
}

- (BOOL)ytm_isAudioOnlyPlayable {
    return YES;
}

- (BOOL)isAudioOnlyAvailabilityBlocked {
    return NO;
}

- (void)setIsAudioOnlyAvailabilityBlocked:(BOOL)blocked{
    %orig(NO);
}

- (void)setYtm_isAudioOnlyPlayable:(BOOL)playable{
    %orig(YES);
}
%end

%hook YTMAudioVideoModeController
- (BOOL)isAudioOnlyBlocked {
    return NO;
}

- (void)setIsAudioOnlyBlocked:(BOOL)blocked {
    %orig(NO);
}

- (void)setSwitchAvailability:(long long)arg1 {
    %orig(1);
}
%end

%hook YTMQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}

/*
- (BOOL)noVideoModeEnabled {
    return YES;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(YES);
}
*/
%end

%hook YTDefaultQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}
%end

%hook YTMSettings
- (BOOL)allowAudioOnlyManualQualitySelection {
    return YES;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer
- (BOOL)audioOnlyPlayability {
    return YES;
}

- (int)audioOnlyAvailability {
    return 1;
}

- (void)setAudioOnlyPlayability:(BOOL)playability {
    %orig(YES);
}

- (id)infoRenderer {
    return nil;
}

- (BOOL)hasInfoRenderer {
    return NO;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer_AudioOnlyPlayabilityInfoSupportedRenderers
- (id)upsellDialogRenderer {
    return nil;
}

- (void)setUpsellDialogRenderer:(id)renderer {
    return;
}
%end

%hook YTQueueItem
- (BOOL)supportsAudioVideoSwitching {
    return YES;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioOnlyButtonVisible {
    return YES;
}
%end
%end

%group audioVideoSelection
%hook YTMQueueConfig
- (bool)noVideoModeEnabledForMusic {
	return 1;
}

- (bool)noVideoModeEnabledForPodcasts {
	return 1;
}
%end

%hook YTQueueController
- (bool)noVideoModeEnabled:(id)arg1 {
	return 1;
}
%end
%end

%group AVSwitchForAds
// %hook YTDefaultQueueConfig
// - (bool)noVideoModeEnabledForMusic {
// 	return 1;
// }

// - (bool)noVideoModeEnabledForPodcasts {
// 	return 1;
// }
// %end

// %hook YTUserDefaults
// - (BOOL)noVideoModeEnabled {
//     return YES;
// }

// - (void)setNoVideoModeEnabled:(BOOL)enabled {
//     %orig(YES);
// }
// %end

// %hook YTIAudioConfig
// - (BOOL)hasPlayAudioOnly {
//     return YES;
// }

// - (BOOL)playAudioOnly {
//     return YES;
// }
// %end

// %hook YTMSettings
// - (BOOL)initialFormatAudioOnly {
//     return YES;
// }

// - (BOOL)noVideoModeEnabled{
//     return YES;
// }

// - (void)setNoVideoModeEnabled:(BOOL)enabled {
//     %orig(YES);
// }
// %end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL audioVideoMode = ([[NSUserDefaults standardUserDefaults] objectForKey:@"AudioVideoMode"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"AudioVideoMode"] : YES;
    BOOL noAds = ([[NSUserDefaults standardUserDefaults] objectForKey:@"noAds_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"noAds_enabled"] : YES;

    if (isEnabled) {
        %init(VideoAndAudioModePatches);
        if (audioVideoMode) {
            %init(audioVideoSelection);
        } if (noAds) {
            %init(AVSwitchForAds);
        }
    }
}