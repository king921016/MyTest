
//  ViewController.m
//  ArcGIS test
//
//  Created by 潇 on 16/8/3.
//  Copyright © 2016年 潇. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+DrawShip.h"
#import "ShipInfo.h"
#import "DrawMapLayers.h"
#import "Utils.h"
#import "LayerInfo.h"


#define kBaseMap @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
#define kDynamicMapServiceURL @"http://221.234.38.231:8003/arcgis/rest/services/cjmsa0128/MapServer"
//http://192.168.0.140:8003/ArcGIS/rest/services/cjmsa0128/MapServer

//  @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
//  @"http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"


@interface ViewController ()<AGSMapViewTouchDelegate,AGSMapViewLayerDelegate,AGSCalloutDelegate,AGSMapViewCalloutDelegate,AGSLayerDelegate>


@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *dingweiBtn;

@property (nonatomic, strong) AGSDynamicMapServiceLayer *dynamicLayer;

@property (nonatomic, weak) AGSGraphicsLayer *graphicsLayer;//图像图层
@property (nonatomic, weak) AGSGraphicsLayer *shipnameLayer;//船名图层

@property (nonatomic, weak) AGSGraphic *selectedGraphic;

@end


DrawMapLayers *maplayers;
//LocalLayerInfo *locallayers;
//定义船舶列表的全局变量
NSMutableDictionary *dictShip = nil;
NSMutableDictionary *dictMmsi = nil;
AGSPoint* dropPoint = nil;
//定义船舶刷新的定时器
NSTimer *shipTimer;
//定义画船是否完成判断
BOOL isDrawShip = NO;
//定义默认经纬度
double lon=114.28362;
double lat=30.561663;
//放大范围
double diff = 0.05;
//是否跟踪船舶
BOOL isTrackShip = NO;
//船舶在线状态
BOOL isOnline = NO;

//TTS开关
BOOL isTTS = NO;
AVSpeechSynthesizer *av;
ShipInfo *warmingShip = nil;

//选中船舶mmsi
NSString* selectMmsi=@"";

CGFloat topY = -100;//-100

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化变量
    [self setSHipValue];
    //启动定时器
    shipTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:shipTimer forMode:NSDefaultRunLoopMode];
    
    //设置代理
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;
    self.mapView.callout.delegate = self;
//    self.mapView.calloutDelegate = self;
    
   
    NSLog(@"btn==%f,%f",self.dingweiBtn.frame.origin.x,self.dingweiBtn.frame.origin.y);
    NSLog(@"mapview ===%f,%f",self.mapView.frame.origin.x,self.mapView.frame.origin.y);
    
    //创建我们的地图图层
    NSString *strURL = kDynamicMapServiceURL;
    NSURL *urlDynamic = [NSURL URLWithString:strURL];
    self.dynamicLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:urlDynamic];
    [self.mapView addMapLayer:self.dynamicLayer withName:@"Dynamic Layer"];

    //加载离线地图-->暂时没完成
    
    
    //初始化图层
    maplayers = [[DrawMapLayers alloc] init];
    [maplayers initload:self.mapView];
    [maplayers startThread];
    
    //创建画船动态图层  图形图层
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
    self.mapView.minScale = 320000;
    self.mapView.maxScale = 4000;
    NSLog(@"%@",self.graphicsLayer);
    NSLog(@"---%f",self.mapView.mapScale);
    
    //创建画船名图层
    self.shipnameLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.shipnameLayer withName:@"shipname Layer"];
    self.shipnameLayer.minScale = 7500;
    
    self.graphicsLayer.delegate = self;
    //设置图层最大与最小显示级别
    self.graphicsLayer.minScale = 160000;
    
    
    av = [[AVSpeechSynthesizer alloc] init];
 

    
    
    //默认定位到长江二桥
//    AGSPoint* point  = [AGSPoint pointWithX:lon y:lat spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
//    //scale值越小,地图显示越大
//    [self.mapView zoomToScale:30000 withCenterPoint:point animated:YES];
    
 
    
}

- (void)setSHipValue {

    //初始化船舶字典
    dictShip = [NSMutableDictionary dictionaryWithCapacity:10];
    dictMmsi = [NSMutableDictionary dictionaryWithCapacity:10];
    
    //定义画船是否完成判断
    isDrawShip = NO;
    //是否跟踪船舶
    isTrackShip = NO;
    //船舶在线状态
    isOnline = NO;
    //TTS开关
    isTTS = NO;
    //选中船舶 mmsi
    selectMmsi = @"";
}


-(void)setMapViewHeight{
    
//    CGRect vframe = CGRectMake(0, topY, u_phonewidth, u_phoneheight + 260);
//    self.mapView.frame = vframe;
//    [self.view sendSubviewToBack:self.mapView];
    
//    CGRect vframe = CGRectMake(0, topY, u_phonewidth, u_phoneheight + 260);
//    self.mapView.frame = vframe;
//    [self.view sendSubviewToBack:self.mapView];
}


//单击地图会调用此方法
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics {
    
    
}



#pragma mark AGSMapViewLayerDelegate
- (void)mapViewDidLoad:(AGSMapView *)mapView {

//    [self.mapView.locationDisplay startDataSource];//开启位置显示
    //定义地图拖动消息,频繁响应可能会影响效率
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) name:@"AGSMapViewDidEndPanningNotification" object:nil];
    
    //地图上加载船舶
    [self.graphicsLayer removeAllGraphics];//清除图形绘制图层
    
    //用户是否绑定船舶
    if (![u_mymmsi isEqualToString:@""])
    {
        AGSPoint *point = [self GetPointShip:u_mymmsi];
        if (!point.x == 0 && !point.y == 0)
        {
            isTrackShip = YES;
            [self DrawShip:u_mymmsi Lookmmsi:@"" Diff:[NSString stringWithFormat:@"%f", diff]];
        }
        else
        {
            isTrackShip = NO;
            AGSPoint *point = [AGSPoint pointWithX:lon y:lat spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
            [self.mapView zoomToScale:20000 withCenterPoint:point animated:YES];
            [self DrawShip:@"" Lon:[NSString stringWithFormat:@"%f", lon] Lat:[NSString stringWithFormat:@"%f", lat] Diff:[NSString stringWithFormat:@"%f", diff]];
        }
    }else {
        //默认定位到长江二桥
        AGSPoint *point = [AGSPoint pointWithX:lon y:lat spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
        
        [self.mapView zoomToScale:30000 withCenterPoint:point animated:YES];
        [self DrawShip:@"" Lon:[NSString stringWithFormat:@"%f", lon] Lat:[NSString stringWithFormat:@"%f", lat] Diff:[NSString stringWithFormat:@"%f", diff]];
        //设置 but 图片为初始样式
    }
//    [self setMapViewHeight];
}





//响应地图拖动消息
- (void)respondToEnvChange: (NSNotification*) notification{

//    CGPoint point1 =[self.mapView center];
    
    AGSPoint *point = [self.mapView mapAnchor];
    lon = point.x;
    lat = point.y;
    [self dropDrawShip:point];
    
}

//超出拖动范围重新画船
-(void) dropDrawShip:(AGSPoint*) point
{
    if (dropPoint == nil) {
        dropPoint = point;
    }
    
    if (fabs(dropPoint.x - point.x) > 0.05 || fabs(dropPoint.y-point.y)>0.05) {
        dropPoint = point;
        if (![u_searchMmsi isEqualToString:@""]) {
            [self DrawShip:u_mymmsi Lookmmsi:u_searchMmsi Diff:[NSString stringWithFormat:@"%f", diff]];
        }else {
            [self DrawShip:u_mymmsi Lon:[NSString stringWithFormat:@"%f", lon] Lat:[NSString stringWithFormat:@"%f", lat] Diff:[NSString stringWithFormat:@"%f", diff]];
        }
    }
}


//地图点击事件
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    if (![features valueForKey:@"Graphics Layer"]) {
        [self UnTrackShip];
    }
}

//取消跟踪和查询
- (void)UnTrackShip {

    selectMmsi = @"";
    if (isTrackShip || ![u_searchMmsi isEqualToString:@""]) {
        isTrackShip = NO;
        u_searchMmsi = @"";
        [self showAllTextDialog:@"已解除绑定船舶或查询船舶跟踪!"];
    }
}

//MBProgewssHUD提示
- (void)showAllTextDialog:(NSString *)str {
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    
    [self.view addSubview:HUD];
    HUD.label.text = str;
    HUD.mode = MBProgressHUDModeText;
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
}


//判断要查询的船舶是否是船舶字典中
-(BOOL) IsSearchShip:(NSString*) shipName{
    NSObject *object = [dictShip objectForKey:shipName];
    if (object != nil) {
        return YES;
    }else {
        return NO;
    }
}

//通过九位码取得船舶经纬度
-(AGSPoint*) GetPointShip:(NSString*) mmsi{

    ShipInfo *shipinfo = [[ShipInfo alloc] GetShipInfoByMmsi:mmsi];
    
    AGSPoint *point = [AGSPoint pointWithX:[shipinfo.lon doubleValue] y:[shipinfo.lat doubleValue] spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
    
    return point;
}

//画选择船舶
- (void)DrawSelectShip:(NSString *)selmmsi Angle:(NSString *)angle MyPoint:(AGSPoint *)mapPoint Start:(AGSGraphic *)start {
    
    //构建点要素的渲染样式
    AGSPictureMarkerSymbol *myMarkerSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"ic_sship.png"];
    CGSize temp = myMarkerSymbol.size;
    temp.height = 24;
    temp.width = 24;
    myMarkerSymbol.size = temp;
    myMarkerSymbol.angle = [angle doubleValue];
    
    //创建点要素
    AGSGraphic *agsGraphic = [AGSGraphic graphicWithGeometry:mapPoint symbol:myMarkerSymbol attributes:[start allAttributes]];
    
    [self.graphicsLayer addGraphic:agsGraphic];
    [self.graphicsLayer removeGraphic:self.selectedGraphic];
    self.selectedGraphic = (AGSGraphic *)agsGraphic;

}

#pragma mark AGSLayerCalloutDelegate
- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint {
    
    if ([feature hasAttributeForKey:@"九位码"]) {
        selectMmsi = (NSString *)[feature attributeForKey:@"九位码"];
        NSString *angle = [feature attributeForKey:@"方向"];
        AGSGraphic *start = (AGSGraphic *)feature;
        
        [self DrawSelectShip:selectMmsi Angle:angle MyPoint:mapPoint Start:start];
        
        if (![u_searchMmsi isEqualToString:@""] || [u_mymmsi isEqualToString:@""])
        {
            [self DrawShip:u_mymmsi Lookmmsi:u_searchMmsi Diff:[NSString stringWithFormat:@"%f", diff]];
        }
        else
        {
            [self DrawShip:@"" Lon:[NSString stringWithFormat:@"%f",lon] Lat:[NSString stringWithFormat:@"%f", lat] Diff:[NSString stringWithFormat:@"%f", diff]];
        }
        //segue 跳转
        return NO;
    }
    else
    {
        return NO;
    }
}

//如果有错误,找到并提示给用户
-(void)findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didFailWithError:(NSError *)error{

}

#pragma mark AGSCalloutDelegate
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    
    self.selectedGraphic = (AGSGraphic *)callout.representedObject;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//查询画船
-(void) DrawShip :(NSString *) mmsi Lookmmsi:(NSString*) lookmmsi Diff:(NSString *)diff{
    isDrawShip = NO;
    
    //子线程中处理地图上画船
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时操作,取二桥附近10公里的船舶数据
        NSString *serverData = [[ShipInfo alloc] GetServerShipStrDw:mmsi Lookmmsi:lookmmsi Diff:diff Flag:@"1"];
        
        NSMutableArray *arrayShip = [[ShipInfo alloc] GetShipInfoList:serverData];
        
        if (arrayShip.count < 1) {
            arrayShip = [[ShipInfo alloc] GetShipInfoList:serverData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *zhmmsi = mmsi;
            
            if (![u_searchMmsi isEqualToString:@""]) {
                zhmmsi = lookmmsi;
            }
            
            if (![u_mymmsi isEqualToString:@""] || ![u_searchMmsi isEqualToString:@""]) {
                [self ToMmsi:zhmmsi];
                selectMmsi = u_searchMmsi;
            }
            
            //判断查询船舶是否有 gps 数据
            if (lookmmsi.length > 0) {
                bool isexitllogps = false;
                for (int i = 0; i < arrayShip.count; i++) {
                    ShipInfo *shipinfo = arrayShip[i];
                    if ([shipinfo.mmsi isEqualToString:lookmmsi]) {
                        isexitllogps = true;
                        break;
                    }
                }
                if (!isexitllogps) {
                    [self showAllTextDialog:@"您查询的船舶无数据"];
                    u_searchMmsi = @"";
                }
            }
            [self DrawShip:arrayShip];
        });
    });
    
}

- (void)ToMmsi:(NSString *)mmsi {
    //获取要查询船舶的经纬度
    AGSPoint *point = [self GetPointShip:mmsi];
    
    if (point.x == 0 && point.y == 0) {
        return;
    }else {
        //地图居中显示
        [self.mapView zoomToScale:20000 withCenterPoint:point animated:YES];
        lon = point.x;
        lat = point.y;
    }
    
}

//经纬度画船
- (void)DrawShip:(NSString *)mmsi Lon:(NSString *)lon Lat:(NSString *)lat Diff:(NSString *)diff {

    isDrawShip = NO;
    
    //多线程处理在地图上画船
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //耗时的操作,取二桥附近10公里船舶的数据
        NSString *serverData = [[ShipInfo alloc]GetServerShipInfoStr:mmsi Lon:lon Lat:lat Diff:diff];
        NSMutableArray *arrayShip = [[ShipInfo alloc]GetShipInfoList:serverData];
        if (arrayShip.count < 1) {
            arrayShip = [[ShipInfo alloc]GetShipInfoList:serverData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self DrawShip:arrayShip];
        });
    });
}


//地图上画船操作
- (void)DrawShip:(NSMutableArray *)arrayship {

    //数据取到后执行的操作
    AGSPictureMarkerSymbol *myMarkerSymbol = nil;
    NSMutableDictionary *attributes = nil;
    AGSGraphic *agsGraphic = nil;
    AGSTextSymbol *txtSymbol = nil;
    AGSPoint *mapPoint = nil;
    ShipInfo *shipinfo = nil;
    
    //船舶图片
    NSString *shipPng = @"ic_cship.png";
    
    //循环在地图上画船
    if (arrayship.count > 0) {
        [self.graphicsLayer removeAllGraphics];
        [self.shipnameLayer removeAllGraphics];
        
        for (int i = 0; i < arrayship.count; i++) {
            shipinfo = (id)arrayship[i];
            mapPoint = [AGSPoint pointWithX:[shipinfo.lon doubleValue] y:[shipinfo.lat doubleValue] spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *shipDate = [dateFormat dateFromString:shipinfo.systime];
            NSTimeInterval time = [shipDate timeIntervalSinceNow];
            
            if (fabs(time) > 600) {
                shipPng = @"ic_hship.png";
            }else {
            
                if (![u_mymmsi isEqualToString:@""]) {
                    if ([shipinfo.mmsi isEqualToString:u_mymmsi]) {
                        shipPng = @"ic_mship.png";
                        
                        if ([dictShip count] < 1) {
                            //将船舶信息放入船舶字典中
                            [dictShip setObject:shipinfo forKey:@"one"];
                            [dictShip setObject:shipinfo forKey:@"two"];
                        }else {
                            ShipInfo *shipinfoTwo = [dictShip objectForKey:@"two"];
                            [dictShip removeAllObjects];
                            [dictShip setObject:shipinfoTwo forKey:@"one"];
                            [dictShip setObject:shipinfo forKey:@"two"];
                        }
                    }else {
                        if ([shipinfo.mmsi isEqualToString:selectMmsi]) {
                            shipPng = @"ic_sship.png";
                        }else {
                            shipPng = @"ic_cship.png";
                        }
                    }
                } else{
                    if ([shipinfo.mmsi isEqualToString:selectMmsi]) {
                        shipPng = @"ic_sship.png";
                    } else{
                        shipPng = @"ic_cship.png";
                    }
                }
            }
            
            myMarkerSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:shipPng];
            CGSize temp = myMarkerSymbol.size;
            temp.height = 24;
            temp.width =24;
            myMarkerSymbol.size = temp;
            myMarkerSymbol.angle = [shipinfo.head doubleValue];
            attributes = [NSMutableDictionary dictionary];
            
            [attributes setObject:shipinfo.zwcm forKey:@"船舶名称"];
            [attributes setObject:shipinfo.mmsi forKey:@"九位码"];
            [attributes setObject:shipinfo.speed forKey:@"船舶速度(公里/小时)"];
            [attributes setObject:shipinfo.cbcd forKey:@"船舶长度(米)"];
            [attributes setObject:shipinfo.cbxk forKey:@"船舶宽度(米)"];
            [attributes setObject:shipinfo.lc forKey:@"船舶位置"];
            [attributes setObject:shipinfo.systime forKey:@"更新时间"];
            [attributes setObject:shipinfo.head forKey:@"方向"];
            
            agsGraphic = [AGSGraphic graphicWithGeometry:mapPoint symbol:myMarkerSymbol attributes:attributes];
            
            txtSymbol = [[AGSTextSymbol alloc]initWithText:shipinfo.zwcm color:[UIColor blackColor]];
            txtSymbol.fontFamily = @"Heiti SC";//黑体
            CGPoint temp1 = txtSymbol.offset;
            temp1.x = -2;
            temp1.y = -20;
            txtSymbol.offset = temp1;
            
            AGSGraphic *agsGraphicTxt = [AGSGraphic graphicWithGeometry:mapPoint symbol:txtSymbol attributes:nil];
            [agsGraphicTxt geometry];
            
            //添加图形到图形层
            [self.graphicsLayer addGraphic:agsGraphic];
            [self.shipnameLayer addGraphic:agsGraphicTxt];
            
            [dictMmsi setObject:shipinfo forKey:shipinfo.mmsi];
        }
       
        if (![u_mymmsi isEqualToString:@""]) {
            ShipInfo *myShipinfo = [dictMmsi objectForKey:u_searchMmsi];
            NSDateFormatter *myDateFormat = [[NSDateFormatter alloc]init];
            [myDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *myShipDate = [myDateFormat dateFromString:myShipinfo.systime];
            NSTimeInterval myTime = [myShipDate timeIntervalSinceNow];
            
            if (fabs(myTime) > 600) {
                isOnline = NO;
                //设置导航 btn
            }else {
                isOnline = YES;
                //设置导航 btn
            }
        }
        isDrawShip = YES;
    }
}


//定时器调用
- (void)timerFired:(NSTimer *)timer {
    
    if (isDrawShip) {
        if (![u_searchMmsi isEqualToString:@""])
        {
            [self DrawShip:@"" Lookmmsi:u_searchMmsi Diff:[NSString stringWithFormat:@"%f",diff]];
        }else
        {
            if (![u_mymmsi isEqualToString:@""])
            {
                if (isOnline)
                {
                    //设置导航按钮的图片
                    
                }else
                {
                    //设置导航按钮的图片
                    
                }
            }
            if (!isTrackShip)
            {
                [self DrawShip:u_mymmsi Lon:[NSString stringWithFormat:@"%f", lon] Lat:[NSString stringWithFormat:@"%f", lat] Diff:[NSString stringWithFormat:@"%f", diff]];
            }else
            {
                [self DrawShip:u_mymmsi Lookmmsi:@"" Diff:[NSString stringWithFormat:@"%f", diff]];
            }
        }
    }
}

//区域定位方法
- (void)ToPoint:(double)dlon Dlat:(double)dlat {

    AGSPoint *point = [AGSPoint pointWithX:dlon y:dlat spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
    
    [self.mapView zoomToScale:100000 withCenterPoint:point animated:YES];
}

//segue 传值



- (void)speedStop {
    bool stopspeed = [av stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    if (stopspeed) {
        [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    }
}
- (void)speedText:(NSString *)ttsString {
    [self speedStop];
    AVSpeechUtterance *text = [[AVSpeechUtterance alloc]initWithString:ttsString];
    AVSpeechSynthesisVoice *voiceTpye = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    text.rate = 0.25;
    text.voice = voiceTpye;
    text.pitchMultiplier = 1.25;
    [av speakUtterance:text];
}

@end
