//
//  iSightCaptureAppDelegate.m
//  iSightCapture
//
//  Created by Jeff Rock on 7/7/09.
//  Copyright 2009 Mobelux. All rights reserved.
//

#import "iSightCaptureAppDelegate.h"

@implementation iSightCaptureAppDelegate

@synthesize window;

- (id)init {
	[super init];
	return self;
}

- (void)awakeFromNib {
	// Create session
	captureSession = [[QTCaptureSession alloc] init];
	
	//Connect inputs and outputs to the session
    BOOL success = NO;
    NSError *error;
	
	// Find the iSight
	QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	success = [videoDevice open:&error];
	
	// If there's no iSight then look for a muxed device (like a firewire DV cam
    if (!success) {
        videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
        success = [videoDevice open:&error];
	}
	
	// If there's no devices, then you're fucked!
	if (!success) {
	   videoDevice = nil;
	   NSLog(@"No video device connected to this Mac.");
	}
	if (videoDevice) {
		// Add the video input to the session
		captureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
        success = [captureSession addInput:captureVideoDeviceInput error:&error];
        if (!success) {
            NSLog(@"No video device connected to this Mac.");
        }
 
		// If this is an iSight (not muxed) add an audio input from the default audio input on the system
        if (![videoDevice hasMediaType:QTMediaTypeSound] && ![videoDevice hasMediaType:QTMediaTypeMuxed]) {
 
            QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
            success = [audioDevice open:&error];
 
            if (!success) {
                audioDevice = nil;
                NSLog(@"No microphone connected to this Mac. Video will be recorded without audio.");
            }
 
            if (audioDevice) {
                captureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
 
                success = [captureSession addInput:captureAudioDeviceInput error:&error];
                if (!success) {
                     NSLog(@"Something went wrong with audio input. Video will be recorded without audio.");
                }
            }
        }
 
		// Create the movie file output and add it to the session
        captureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
        success = [captureSession addOutput:captureMovieFileOutput error:&error];
        if (!success) {
            NSLog(@"File output couldn't be added to the session.");
        }
		
		// Enumerate through each connection and set the compression
		NSEnumerator *connectionEnumerator = [[captureMovieFileOutput connections] objectEnumerator];
		QTCaptureConnection *connection;

		while ((connection = [connectionEnumerator nextObject])) {
			NSString *mediaType = [connection mediaType];
			QTCompressionOptions *compressionOptions = nil;

			// Set compression based on input type (audio vs. video)
			if ([mediaType isEqualToString:QTMediaTypeVideo]) {
				// H.264
				compressionOptions = [QTCompressionOptions
									   compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeH264Video"];
			} else if ([mediaType isEqualToString:QTMediaTypeSound]) {
				// AAC Audio
				compressionOptions = [QTCompressionOptions
									   compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
			}

			// Set the compression options the current connection
			[captureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
		}
		
		
		// Set the QTCaptureView for the session
        [theCaptureView setCaptureSession:captureSession];
		
		// Start the session
        [captureSession startRunning];
    }
	
}

- (IBAction)startStopCapture:(id)sender {
	if ([startStopCaptureButton state] == NSOnState) {
		// Record video to desktop
		NSString *folder = @"~/Desktop";
		folder = [folder stringByExpandingTildeInPath];
		
		NSString *filename = @"video.mp4";
		NSString *videoFile =  [folder stringByAppendingPathComponent:filename];
			
		NSLog(@"Started recording");
		[captureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:videoFile]];
	} else if ([startStopCaptureButton state] == NSOffState) {
		// Close file output
		[captureMovieFileOutput recordToOutputFileURL:nil];
		NSLog(@"Stopped recording");
	}

}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSLog(@"Shutting down iSight connections");
	[captureSession stopRunning];
	[[captureAudioDeviceInput device] close];
	[[captureVideoDeviceInput device] close];
	NSLog(@"iSight connections closed");
	
	return NSTerminateNow;
}

@end
