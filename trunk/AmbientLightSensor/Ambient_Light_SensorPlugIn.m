//
//  Ambient_Light_SensorPlugIn.m
//  Ambient Light Sensor
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

#import "Ambient_Light_SensorPlugIn.h"
#import <mach/mach.h>

#import <CoreFoundation/CoreFoundation.h>

#define	kQCPlugIn_Name				@"Ambient Light Sensor"
#define	kQCPlugIn_Description		@"This patch returns the current state of the ambient light sensors.\nIt will return values between 0.0 (dark) and 1.0 (lit)."
#define	kQCPlugIn_Copyright         @"Copyright 2007 Google Inc. All Rights Reserved."

enum {
    kGetSensorReadingID   = 0,  // getSensorReading(int *, int *)
    kGetLEDBrightnessID   = 1,  // getLEDBrightness(int, int *)
    kSetLEDBrightnessID   = 2,  // setLEDBrightness(int, int, int *)
    kSetLEDFadeID         = 3,  // setLEDFade(int, int, int, int *)
};

@implementation com_google_Ambient_Light_SensorPlugIn

@dynamic outputRight, outputLeft;

+ (NSDictionary*) attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
            kQCPlugIn_Name, QCPlugInAttributeNameKey, 
            kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, 
            kQCPlugIn_Copyright, QCPlugInAttributeCopyrightKey, 
            nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key {
  if([key isEqualToString:@"outputLeft"]) {
      return [NSDictionary dictionaryWithObjectsAndKeys:
              @"Left", QCPortAttributeNameKey,
              nil];
  }
	if([key isEqualToString:@"outputRight"]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Right", QCPortAttributeNameKey,
                nil];
  }
	return nil;
}

+ (QCPlugInExecutionMode) executionMode {
  return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeIdle;
}

@end

@implementation com_google_Ambient_Light_SensorPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    kern_return_t kr = KERN_FAILURE;
        
    // Look up a registered IOService object whose class is AppleLMUController
    io_service_t serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                             IOServiceMatching("AppleLMUController"));
    if (!serviceObject) {
        serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                             IOServiceMatching("IOI2CDeviceLMU"));
    }
    if (serviceObject) {
        kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &dataPort);
        IOObjectRelease(serviceObject);
    }
    return kr == KERN_SUCCESS;
}

- (void) enableExecution:(id<QCPlugInContext>)context {
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
    uint32_t   scalarOutputCount = 2;
    uint64_t values[2];
    
    kern_return_t kr = IOConnectCallMethod(dataPort, kGetSensorReadingID, nil, 0, nil, 0, values, &scalarOutputCount, nil, 0);
    
    if (kr == KERN_SUCCESS) {
        self.outputLeft = MIN(values[0] / 1600.0, 1.0);
        self.outputRight = MIN(values[1] / 1600.0, 1.0);
        
    }
	return kr == KERN_SUCCESS;
}

- (void) disableExecution:(id<QCPlugInContext>)context {
}

- (void) stopExecution:(id<QCPlugInContext>)context {
	if (dataPort) {
        IOServiceClose(dataPort);
        dataPort = IO_OBJECT_NULL;
    }
}

@end
