//
//  WizEditNoteBase.h
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
@interface WizEditNoteBase : UIViewController<AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    WizDocument* docEdit;
    float currentTime;
    NSMutableArray* attachmentsArray;
}
@property (nonatomic, retain)  WizDocument* docEdit;
@property (nonatomic, retain)  NSMutableArray* attachmentsArray;
@property (readonly) float currentTime;
- (void) audioStartRecode;
- (void) audioStopRecord;
- (BOOL) takePhoto;
- (BOOL) selectePhotos;
- (void) attachmentAddDone;
- (float) updateTime;
- (void) stopAutoSaveDocument;
- (void) autoSaveDocument;
@end
