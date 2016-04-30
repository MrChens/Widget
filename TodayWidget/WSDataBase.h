//
//  WSDataBase.h
//  WangsuTraffic
//
//  Created by apple on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


//流量最小值显示
#define kMinmumTrafficCount (0.005)

@interface WSDataBase : NSObject
{
    
}
@property (nonatomic, copy) NSString *dbPath;

-(void)createDB;



@end
