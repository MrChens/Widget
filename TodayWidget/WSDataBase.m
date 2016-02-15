//
//  WSDataBase.m
//  WangsuTraffic
//
//  Created by apple on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSDataBase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
//#import "TrafficCell.h"

@implementation WSDataBase
@synthesize dbPath;

-(id)init
{
    self = [super init];
	if (self) 
    {
		//获取Document文件夹下的数据库文件，没有则创建  
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; 
        dbPath = [docPath stringByAppendingPathComponent:@"WSDatabase.db"];
        NSLog(@"today2 : %@", dbPath);
	}
    
	return self;
}

#pragma mark table

-(void)createDB
{
    FMDatabase *database  = [FMDatabase databaseWithPath:self.dbPath];
    
    //获取数据库并打开
    if (![database open])
    {
        NSLog(@"Open database failed");
        return;
    }
    
    //创建表（FMDB中只有update和query操作，除了查询其他都是update操作）
    [database executeUpdate:@"create table wsTraffic (trafficId integer primary key autoincrement, trafficDate text,trafficCount double, trafficWifiCount double)"];
    
    [database executeUpdate:@"create table wsTrafficLocation (trafficLocationId integer primary key autoincrement, trafficlongitude double, trafficlatitude double, trafficDate text,trafficLocationCount double)"];
    
    [database executeUpdate:@"create table wsWifiTrafficLocation (trafficLocationId integer primary key autoincrement, trafficlongitude double, trafficlatitude double, trafficDate text, trafficLocationWifiCount double)"];
    
	[database executeUpdate:@"create table WSAppInfo (AppDisplayName text,AppIcon blob,AppBundleIdentifier varchar DEFAULT NULL,AppId integer PRIMARY KEY)"];
	
	[database executeUpdate:@"create table WSAppTrafficInfo (srcPort integer DEFAULT 0,appPid integer DEFAULT 0,appTotalBytes double DEFAULT 0.0,appPriKey integer PRIMARY KEY,appBundleIdentifier varchar DEFAULT NULL,appNetworkStatus integer DEFAULT 0,dateTime varchar)"];
	
	[database executeUpdate:@"CREATE TABLE WSSpeedTestResult (priKey integer PRIMARY KEY,speedBefore double DEFAULT 0.0,speedAfter double DEFAULT 0.0,speedUpPercent float DEFAULT 0.0,speedTestDate varchar)"];
    [database close];
}

-(BOOL)checkTableExist
{
    FMDatabase *database = [FMDatabase databaseWithPath:self.dbPath];
    if (![database open])
    {
        return NO;
    }
    int resultId = 0;
    BOOL status = NO;
    FMResultSet *resultSet = [database executeQuery:@"select count(*) from sqlite_master where type = \"table\" and name = \"WSAppInfo\""];
    while ([resultSet next])
    {
        resultId = [resultSet intForColumnIndex:0];
    }
    if (resultId != 0)
    {
		FMResultSet *appResultSet = [database executeQuery:@"select count(*) from sqlite_master where type = \"table\" and name = \"WSAppTrafficInfo\""];
		while ([appResultSet next])
		{
			resultId = [appResultSet intForColumnIndex:0];
			if (resultId != 0)
			{
				FMResultSet *speedResultSet = [database executeQuery:@"select count(*) from sqlite_master where type = \"table\" and name = \"WSSpeedTestResult\""];
				while ([speedResultSet next])
				{
					resultId = [speedResultSet intForColumnIndex:0];
					if (resultId != 0)
					{
						status = YES;
					}
				}
			}
		}
    }
	[database close];
    return status;
}

- (void)updateTrafficCountWithDate:(NSString *)date andCount:(double)count
{
	FMDatabase *database  = [FMDatabase databaseWithPath:self.dbPath];
    
    //获取数据库并打开
    if (![database open])
    {
        NSLog(@"Open database failed");
        return;
    }
	[database executeUpdate:@"delete from wsTrafficLocation where trafficDate = ?", date];
	NSString *updateString = [NSString stringWithFormat:@"update wsTraffic set trafficCount = %f where trafficDate = %@", count, date];
    [database executeUpdate:updateString];
	[database close];
}

-(void)deleteSheetdayTrafficWithDate:(NSString *)date
{
    FMDatabase *database  = [FMDatabase databaseWithPath:self.dbPath];
    
    //获取数据库并打开
    if (![database open])
    {
        NSLog(@"Open database failed");
        return;
    }
    
    [database executeUpdate:@"delete from wsTrafficLocation where trafficDate = ?", date];
    [database executeUpdate:@"delete from wsWifiTrafficLocation where trafficDate = ?", date];
    [database executeUpdate:@"delete from wsTraffic where trafficDate = ?", date];
    [database close];
}

#pragma mark SpeedTestResult
- (BOOL)insertSpeedTestResultWithSpeedBefore:(double)beforeSpeed
							   andSpeedAfter:(double)afterSpeed
								  andPercent:(float)percent
									 andDate:(NSString *)speedTestDate
{
	FMDatabase *database = [FMDatabase databaseWithPath:self.dbPath];
	if (![database open])
    {
        return NO;
    }
	
	NSString *insertStatementsNS = [NSString stringWithFormat:
									@"insert into WSSpeedTestResult (speedBefore, speedAfter, speedUpPercent,speedTestDate) values(%f, %f, %f, \"%@\")",
									beforeSpeed, afterSpeed, percent, speedTestDate];
    BOOL status = [database executeUpdate:insertStatementsNS];
	[database close];
	return status;
	return status;
}

- (float)queryAveragePercentFromDate:(NSString *)beginDate
							  toDate:(NSString *)endDate
{
	FMDatabase *database = [FMDatabase databaseWithPath:self.dbPath];
	if (![database open])
    {
        return 0.0;
    }
	float percent = 0.0;
	NSString *queryString = [NSString stringWithFormat:@"select Avg(speedUpPercent) from WSSpeedTestResult where speedTestDate between \"%@\" and \"%@\"", beginDate, endDate];
	FMResultSet *resultSet = [database executeQuery:queryString];
	while ([resultSet next])
	{
		percent = [resultSet doubleForColumnIndex:0];
	}
	[database close];
	return percent;

}

#pragma mark AppInfo
//删除应用信息
- (BOOL)deleteFromAppBytesInfoFromDate:(NSString *)beginDate
								toDate:(NSString *)endDate
{
	FMDatabase *database = [FMDatabase databaseWithPath:self.dbPath];
	if (![database open])
    {
        return NO;
    }
	NSString *deleteString = [NSString stringWithFormat:@"delete from WSAppTrafficInfo where dateTime between \"%@\" and \"%@\"", beginDate, endDate];
	BOOL status = [database executeUpdate:deleteString];
	[database close];
	return status;
}



@end
