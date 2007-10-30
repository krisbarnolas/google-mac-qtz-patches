//
//  Ambient_Light_SensorPlugIn.h
//  Ambient Light Sensor
//
//  Created by Dave MacLachlan on 6/15/07.
//  Copyright (c) 2007 Google Inc. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <IOKit/IOKitLib.h>

@interface com_google_Ambient_Light_SensorPlugIn : QCPlugIn {
    double outputLeft;
    double outputRight;
    io_connect_t dataPort;
}

@property double outputRight;
@property double outputLeft;

@end
