//
//  MotionSensorPlugIn.m
//  MotionSensor
//
//  Created by Dave MacLachlan on 6/15/07.
//  Copyright (c) 2007 Google Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "MotionSensorPlugIn.h"
#import "unimotion.h"

#define	kQCPlugIn_Name				@"Motion Sensor"
#define	kQCPlugIn_Description		@"This patch returns the current state of the motion sensor.\nIt will return values between -1.0 and 1.0.\nThanks to the UniMotion Library."
#define	kQCPlugIn_Copyright         @"Copyright 2007 Google Inc. All Rights Reserved."


@implementation com_google_MotionSensorPlugIn

@dynamic outputZ, outputY, outputX;

+ (NSDictionary*) attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
            kQCPlugIn_Name, QCPlugInAttributeNameKey, 
            kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, 
            kQCPlugIn_Copyright, QCPlugInAttributeCopyrightKey, 
            nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key {
	if([key isEqualToString:@"outputX"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
            @"X Value", QCPortAttributeNameKey,
            nil];
	if([key isEqualToString:@"outputY"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Y Value", QCPortAttributeNameKey,
            nil];
	if([key isEqualToString:@"outputZ"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Z Value", QCPortAttributeNameKey,
           nil];
	return nil;
}

+ (QCPlugInExecutionMode) executionMode {	
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode {	
	return kQCPlugInTimeModeIdle;
}

@end

@implementation com_google_MotionSensorPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context {
	hardware = detect_sms();
    return hardware != unknown;
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	BOOL isGood = NO;
	if (hardware != unknown) {
        double x, y, z;
		isGood = read_sms_real(hardware, &x, &y, &z) != 0;
        if (!isGood) {
            int tempX, tempY, tempZ;
            isGood = read_sms_raw(hardware, &tempX, &tempY, &tempZ) != 0;
            x = tempX / 280.0;
            y = tempY / 280.0;
            z = tempZ / 280.0;
            if (x > 1.0) x = 1.0;
            if (y > 1.0) y = 1.0;
            if (z > 1.0) z = 1.0;
        }
        if (isGood) {
            self.outputX = x;
            self.outputY = y;
            self.outputZ = z;
        } else {
            self.outputX = self.outputY = self.outputZ = 0.0;
        }
	}
	return isGood;
}
    
@end
