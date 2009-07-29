//
//  iSightCaptureAppDelegate.h
//  iSightCapture
//
//  Created by Jeff Rock on 7/7/09.
//  Copyright 2009 Mobelux. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>

@interface iSightCaptureAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	IBOutlet QTCaptureView *theCaptureView;
	IBOutlet NSButton *startStopCaptureButton;
	
	QTCaptureSession *captureSession;
    QTCaptureMovieFileOutput *captureMovieFileOutput;
    QTCaptureDeviceInput *captureVideoDeviceInput;
    QTCaptureDeviceInput *captureAudioDeviceInput;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)startStopCapture:(id)sender;

@end
