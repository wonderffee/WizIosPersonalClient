//
//  DocumentViewCtrollerBase.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizDocument;
@class WizDownloadDocument;


@interface DocumentViewCtrollerBase : UIViewController <UIWebViewDelegate, UISearchBarDelegate>
{
    UIWebView* web;
    WizDocument* doc;
    NSString* accountUserID;
    UISlider* webFontSizeSlider;
    UIBarItem* attachmentBarItem;
    UIBarItem* infoBarItem;
    UIBarItem* editBarItem;
    UIBarItem* searchItem;
    
    UISearchBar* searchDocumentBar;
    
    UIAlertView* conNotDownloadAlert;
    
    UIActivityIndicatorView* downloadActivity;
    
    WizDownloadDocument* download;
    
    BOOL isEdit;
    
}
@property (nonatomic, retain) IBOutlet UIWebView* web;
@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, retain) NSString* accountUserID;
@property (nonatomic, retain)  IBOutlet UIBarItem* attachmentBarItem;
@property (nonatomic, retain)  IBOutlet UIBarItem* infoBarItem;
@property (nonatomic, retain)  IBOutlet UIBarItem* editBarItem;
@property (nonatomic, retain)  IBOutlet UIBarItem* searchItem;
@property (nonatomic, retain)  UISearchBar* searchDocumentBar;
@property (nonatomic, retain)  UIAlertView* conNotDownloadAlert;
@property (retain) WizDownloadDocument* download;
@property (nonatomic, retain)  UIActivityIndicatorView* downloadActivity;
@property (assign) BOOL isEdit;
- (void) downloadDocumentDone;
-(IBAction)editDocument:(id)sender;
-(IBAction)viewAttachments:(id)sender;
-(IBAction)viewDocumentInfo:(id)sender;
-(IBAction)searchDocument:(id)sender;
@end
