//
//  MotionSensorPlugIn.h
//  MotionSensor
//
//  Created by Dave MacLachlan on 6/14/07.
//  Copyright (c) 2007 Google Inc. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface com_google_MotionSensorPlugIn : QCPlugIn
{
	double outputX, outputY, outputZ;
	int hardware;
}

@property double outputZ;
@property double outputY;
@property double outputX;
@end
