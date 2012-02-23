//
//  WizDownloadObject.m
//  Wiz
//
//  Created by dong zhao on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizDownloadObject.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizSync.h"
#import "AttachmentsView.h"
#import "WizDocumentsByLocation.h"
#import "WizSyncByTag.h"
#import "WizSyncByLocation.h"
#import "WizSyncByKey.h"
NSString* SyncMethod_DownloadProcessPartBeginWithGuid = @"DownloadProcessPartBegin";
NSString* SyncMethod_DownloadProcessPartEndWithGuid   = @"DownloadProcessPartEnd";

@implementation WizDownloadObject
@synthesize objGuid;
@synthesize objType;
@synthesize busy;
@synthesize currentPos;
@synthesize isLogin;
@synthesize owner;
-(void) dealloc {
    self.objType = nil;
    self.objGuid = nil;
    self.isLogin = NO;
    self.owner = nil;
    [super dealloc];
}

-(void) onError: (id)retObject
{
    if (self.owner != nil && [self.owner isKindOfClass:[WizSync class]]) {
        WizSync* sync = (WizSync*)self.owner;
        [sync onError:retObject];
    }
    
    else if (self.owner != nil && [self.owner isKindOfClass:[AttachmentsView class]])
    {
        AttachmentsView* attachts = (AttachmentsView*)self.owner;
        [attachts.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        attachts.waitAlertView = nil;
        [super onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizDocumentsByLocation class]])
    {
        WizDocumentsByLocation* syncByLoaction = (WizDocumentsByLocation*)self.owner;
        [syncByLoaction onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizSyncByTag class]])
    {
        WizSyncByTag* sync = (WizSyncByTag*)self.owner;
        [sync onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizSyncByLocation class]])
    {
        WizSyncByLocation* sync = (WizSyncByLocation*)self.owner;
        [sync onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizSyncByKey class]])
    {
        WizSyncByKey* sync = (WizSyncByKey*)self.owner;
        [sync onError:retObject];
    }
    else
    {
        [super onError:retObject];
    }
    self.owner = nil;

	busy = NO;
}
-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];
    [self callDownloadObject:self.objGuid startPos:0 objType:self.objType];
}

- (void) downloadOver
{
    if (isLogin) {
        self.busy = NO;
    }
    else
    {
        [self callClientLogout];
    }
   
}
-(NSMutableDictionary*) onDownloadObject:(id)retObject
{
	
    NSDictionary* dic = [super  onDownloadObject:retObject];
    
    NSNumber* fileSize = [dic valueForKey:@"obj_size"];
    NSNumber* currentSize=[dic valueForKey:@"current_size"];
    NSNumber* succeed = [dic valueForKey:@"is_succeed"];
    
    if(!succeed) {
        [self callDownloadObject:objGuid startPos:self.currentPos objType:objType];
        [self postSyncDoloadObject:[fileSize intValue] current:[currentSize intValue] objectGUID:self.objGuid objectType:self.objType];
  
    }
    else
    {
        //发送下载进度
        
        {
            [self postSyncDoloadObject:[fileSize intValue] current:[currentSize intValue] objectGUID:self.objGuid objectType:self.objType];
        }
        if([fileSize intValue] > [currentSize intValue]) {
            self.currentPos = [currentSize intValue];
            [self callDownloadObject:self.objGuid startPos:self.currentPos objType:self.objType];
        } else {
            [self downloadOver];
        }
    }
          return [NSMutableArray array];
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
     self.owner = nil;
	self.busy = NO;
}


- (BOOL) downloadObject
{
	
    //删除以前可能会留下的临时文件
    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:self.objGuid];
    [WizGlobals ensurePathExists:objectPath];
    NSString* fileNamePath = [objectPath stringByAppendingPathComponent:@"temp.zip"];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileNamePath])
       [WizGlobals deleteFile:fileNamePath];
    self.currentPos = 0;
    if (self.isLogin) {
        return [self callDownloadObject:objGuid startPos:self.currentPos objType:objType];
    } else
    {
        return [self callClientLogin];
    }
}
- (NSString*) padNotificationName:(NSString*)prefix
{
    NSString* string = [super notificationName:prefix];
    NSString* ret = [NSString stringWithFormat:@"%@%@",self,string];
    return ret;
}
@end

@implementation WizDownloadDocument

- (void) downloadOver
{
    [super downloadOver];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSLog(@"%@ will severchanged",self.objGuid);
    [index setDocumentServerChanged:self.objGuid changed:NO];
    NSDictionary* ret = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentDownloadObjectGUID,  @"document_guid",  nil];
    
    NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:SyncMethod_DownloadObject, @"method",ret,@"ret",[NSNumber numberWithBool:YES], @"succeeded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix] object: nil userInfo: userInfo];
	[userInfo release];
    [ret release];
}
- (BOOL) downloadDocument:(NSString *)documentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.objType = @"document";
    self.objGuid = documentGUID;
    self.currentPos = 0;
    self.isLogin = NO;
    return [self downloadObject];
}
- (BOOL) downloadWithoutLogin:(NSURL *)apiUrl kbguid:(NSString *)kbGuid token:(NSString*)token_ documentGUID:(NSString *)documentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.apiURL = apiUrl;
    self.kbguid  =kbGuid;
    self.token = token_;
    self.objType = @"document";
    self.objGuid = documentGUID;
    self.currentPos = 0;
    self.isLogin = YES;
    return [self downloadObject];
}
@end
@implementation WizDownloadAttachment
- (void) downloadOver
{
    [super downloadOver];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [index setAttachmentServerChanged:self.objGuid changed:NO];
    NSDictionary* ret = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentDownloadObjectGUID,  @"document_guid",  nil];
    
    NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:SyncMethod_DownloadObject, @"method",ret,@"ret",[NSNumber numberWithBool:YES], @"succeeded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix] object: nil userInfo: userInfo];
	[userInfo release];
    [ret release];
}

- (BOOL) downloadAttachment:(NSString *)attachmentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.objType = @"attachment";
    self.objGuid = attachmentGUID;
    self.currentPos = 0;
    self.isLogin = NO;
    return [self downloadObject];
}
- (BOOL) downloadWithoutLogin:(NSURL *)apiUrl kbguid:(NSString *)kbGuid token:(NSString*)token_ downloadAttachment:(NSString *)attachmentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.apiURL = apiUrl;
    self.kbguid  =kbGuid;
    self.token = token_;
    self.objType = @"attachment";
    self.objGuid = attachmentGUID;
    self.currentPos = 0;
    self.isLogin = YES;
    return [self downloadObject];
}
@end