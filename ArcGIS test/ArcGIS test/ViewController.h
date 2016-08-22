//
//  ViewController.h
//  ArcGIS test
//
//  Created by 潇 on 16/8/3.
//  Copyright © 2016年 潇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "MBProgressHUD.h"

@interface ViewController : UIViewController
{
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) AGSCalloutTemplate *cityCalloutTemplate;
@property (nonatomic, strong) AGSCalloutTemplate *riverCalloutTemplate;
@property (nonatomic, strong) NSMutableArray* recentSearches;
@property(nonatomic,strong) NSTimer *paintingTimer;

//查询画船
-(void) DrawShip :(NSString *) mmsi Lookmmsi:(NSString*) lookmmsi Diff:(NSString *)diff;

//经纬度画船
-(void) DrawShip :(NSString *)mmsi Lon:(NSString *)lon Lat:(NSString *)lat Diff:(NSString *)diff;

//地图画船操作
-(void) DrawShip:(NSMutableArray *) arrayship;

//判断要查询的船舶是否是船舶字典中
-(BOOL) IsSearchShip:(NSString*) shipName;

//通过九位码取得船舶经纬度
-(AGSPoint*) GetPointShip:(NSString*) mmsi;

//响应地图拖动消息
- (void)respondToEnvChange: (NSNotification*) notification;

//区域定位方法
-(void)ToPoint:(double) dlon Dlat:(double)dlat;

@end

