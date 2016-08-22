//
//  DrawMapLayers.m
//  ArcGIS test
//
//  Created by 潇 on 16/8/5.
//  Copyright © 2016年 潇. All rights reserved.
//

#import "DrawMapLayers.h"
#import "ViewController.h"
#import "LayerInfo.h"
#import "ShipInfo.h"

@interface DrawMapLayers ()

@end

NSMutableArray* layerarray;
AGSGraphicsLayer* maplayer;
AGSGraphicsLayer* mapnamelayer;
AGSMapView* mainmapView;
NSTimer *layertimer;
bool isdrawlayer = false;
bool isexit = false;
bool ispause = false;
bool isload = false;
AGSPoint* maplayerpoint = nil;
NSThread *loadlayerThread = nil;

@implementation DrawMapLayers
- (void)DrawPolygonLayer{
    
}
//初始化
- (void)initload:(AGSMapView *)mView {

    mainmapView = mView;
    layerarray = [NSMutableArray arrayWithCapacity:0];
    //要素图层的初始化与加载
    maplayer = [AGSGraphicsLayer graphicsLayer];
    [mainmapView addMapLayer:maplayer withName:@"Map Layer"];
    
    maplayer.minScale = 80000;
    mapnamelayer = [AGSGraphicsLayer graphicsLayer];
    mapnamelayer.minScale = 40000;
    [mainmapView addMapLayer:mapnamelayer withName:@"MapName Layer"];
    
    layertimer = nil;
    isdrawlayer = false;
    isexit = false;
    ispause = false;
    isload = false;
    maplayerpoint = nil;
    
}

//隐藏图层
//- (void)hideLayer {
//    if (maplayer != nil) {
//        if (maplayer.isVisible) {
//            [maplayer setVisible:NO];
//        }
//    }
//}

//显示图层
- (void)showLayer {

    if (maplayer != nil) {
        if (!maplayer.isVisible) {
            [maplayer setVisible:YES];
        }
    }
}
//隐藏名字图层
- (void)hideNameLayer {
    if (mapnamelayer != nil) {
        if (mapnamelayer.isVisible) {
            [mapnamelayer setVisible:NO];
        }
    }
}
//展示名字图层
- (void)showNameLayer {

    if (mapnamelayer != nil) {
        if (!mapnamelayer.isVisible) {
            [mapnamelayer setVisible:YES];
        }
    }
}

- (void)onClose {
    isexit = true;
    layertimer = nil;
    layerarray = nil;
    maplayer = nil;
    mapnamelayer = nil;
}
//开启线程
- (void)startThread {

    if (!isexit && !isdrawlayer) {
        [NSThread detachNewThreadSelector:@selector(startTimer) toTarget:self withObject:nil];
    }
}
//结束线程
- (void)stopThread {

    isexit = true;
    [self stopTimer];
}

//开启定时器
- (void)startTimer {
    layertimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(workTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}
//结束定时器
- (void)stopTimer {
    [layertimer invalidate];
    layertimer = nil;
}

//定时器调用
- (void)workTime {
    if (!isdrawlayer) {
        isdrawlayer = true;
        [self drawMapLayerWork];
    }
}

//地图层工作
- (void)drawMapLayerWork {
    if (isexit) {
        return;
    }
    
    bool flag = false;
    AGSPoint *point = mainmapView.mapAnchor;
    if (isload) {
        if (fabs([point x] - [maplayerpoint x]) > 0.1 || fabs([point y] - [maplayerpoint y]) > 0.1) {
            flag = true;
        }
    } else {
    
        if (point == nil) {
            [self stopTimer];
            sleep(5);
            [self startTimer];
        } else {
            flag = true;
        }
    }
    
    if (flag) {
        isload = true;
        [self startDrawLayer:[NSString stringWithFormat:@"%f",[point x]] lat:[NSString stringWithFormat:@"%f",[point y]] diff:@"0.1"];
    }
}

- (bool)isContainArray:(LayerInfo *)li {

    if (layerarray.count > 0) {
        for (int i = 0; i < layerarray.count; i++) {
            LayerInfo *templi = layerarray[i];
            if ([templi.points isEqualToString:li.points]) {
                return true;
            }
        }
    }
    return false;
}


//开始画图
- (void)startDrawLayer:(NSString *)lon lat:(NSString *)lat diff:(NSString *)diff {

    NSString *layerStr = [[ShipInfo alloc]GetServerLayerListStr:lon Lat:lat Diff:diff];
    NSMutableArray *array = [[LayerInfo alloc]GetLayerInfoList:layerStr];//7
    
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            if (isexit) {
                return;
            }
            
            LayerInfo *li = array[i];
            
            if (li != nil) {
                if (![self isContainArray:li]) {
                    int typeint = [li.type intValue];
                    if (typeint < 10) {
                        [self DrawPointLayer:li];
                    }else {
                        [self DrawPolygonLayer:li];
                    }
                    [layerarray addObject:li];
                }
            }
        }
    }
    isdrawlayer = false;
}
-(void)DrawPointLayer:(LayerInfo *)li{
    
    if (li.points.length > 0) {
        NSArray *pts = [li.points componentsSeparatedByString:@","];
        if (pts.count > 1) {
            double x = [pts[0] doubleValue];
            double y = [pts[1] doubleValue];
            
            AGSPoint *point = [AGSPoint pointWithX:x y:y spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
            
            AGSTextSymbol *txtSymbol = nil;
            int a = [li.content intValue];
            char *b = (char *)&a;
            txtSymbol = [[AGSTextSymbol alloc]initWithText:[NSString stringWithCString:b encoding:NSUTF8StringEncoding] color:[UIColor redColor]];
            txtSymbol.fontFamily = @"cj57";//黑体
            txtSymbol.fontSize = 22;
            
            AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:point symbol:txtSymbol attributes:nil];
            [maplayer addGraphic:graphic];
            
            txtSymbol = [[AGSTextSymbol alloc]initWithText:li.namet color:[UIColor redColor]];
            txtSymbol.fontFamily = @"Heiti SC";
            CGPoint temp1 = txtSymbol.offset;
            temp1.x = 0;
            temp1.y = -15;
            txtSymbol.offset = temp1;
            AGSGraphic *graphtext = [AGSGraphic graphicWithGeometry:point symbol:txtSymbol attributes:nil];
            [mapnamelayer addGraphic:graphtext];
        }
    }
}


//画多边形图层
-(void)DrawPolygonLayer:(LayerInfo *)li{
    
    if (li.points.length > 0) {
        NSString *p = [li.points stringByReplacingOccurrencesOfString:@"[" withString:@""];
        p = [p stringByReplacingOccurrencesOfString:@"]" withString:@""];
        p = [p substringFromIndex:[p rangeOfString:@","].location + 2];
        p = [p substringToIndex:p.length - 4];
        p = [p stringByReplacingOccurrencesOfString:@",0),(" withString:@"|"];
        
        NSArray *array = [p componentsSeparatedByString:@"|"];//35个object
        if (array.count > 0) {
            AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc]initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
            //添加环
            [polygon addRingToPolygon];
            double sx = 0;
            double sy = 0;
            double minx = 200;
            double miny = 200;
            double maxx = 0;
            double maxy = 0;
            
            for (int i = 0; i < array.count; i++) {
                NSArray *pxy = [array[i] componentsSeparatedByString:@","];
                if (pxy.count == 2) {
                    double x = [pxy[0] doubleValue];
                    double y = [pxy[1] doubleValue];
                    if (i == 0) {
                        sx = x;
                        sy = y;
                        minx = x;
                        miny = y;
                        maxx = x;
                        maxy = y;
                    }else {
                        if (minx > x) {
                            minx = x;
                        }
                        if (miny > y) {
                            miny = y;
                        }
                        if (maxx < x) {
                            maxx = x;
                        }
                        if (maxy < y) {
                            maxy = y;
                        }
                    }
                    //添加节点
                    [polygon addPointToRing:[AGSPoint pointWithX:x y:y spatialReference:nil]];
                }
            }
            if (polygon.numPoints == array.count) {
                [polygon addPointToRing:[AGSPoint pointWithX:sx y:sy spatialReference:nil]];
                
                AGSSimpleFillSymbol *simple = [AGSSimpleFillSymbol simpleFillSymbol];
                NSString *color = [self ToHex:[li.fillcolor integerValue]];
                simple.color = [[self getColor:color] colorWithAlphaComponent:0.2];
                
                AGSGraphic *polyGraphic = [AGSGraphic graphicWithGeometry:polygon symbol:simple attributes:nil];//
                
                [maplayer addGraphic:polyGraphic];
                
                AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] initWithText:li.namet color:[UIColor blackColor]];
                txtSymbol.fontFamily = @"Heiti SC";
                CGPoint temp1 = txtSymbol.offset;
                temp1.x = 10;
                temp1.y = -5;
                txtSymbol.offset = temp1;
                AGSPoint *point = [AGSPoint pointWithX:(minx + maxx) / 2 y:(miny + maxy) / 2 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
                AGSGraphic *graphtext = [AGSGraphic graphicWithGeometry:point symbol:txtSymbol attributes:nil];
                [mapnamelayer addGraphic:graphtext];
            }
        }
    }
    isdrawlayer = false;
}

- (UIColor *)getColor:(NSString *)hexColor {

    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}
- (NSString *)ToHex:(long long int)tmpid{
    NSString *nLetterValue;
    NSString *str = @"";
    long long int ttmpig;
    
    for (int i = 0; i < 9; i++) {
        ttmpig = tmpid % 16;
        tmpid = tmpid / 16;
        switch (ttmpig) {
            case 10:
                nLetterValue = @"A";
                break;
            case 11:
                nLetterValue = @"B";
                break;
            case 12:
                nLetterValue = @"C";
                break;
            case 13:
                nLetterValue = @"D";
                break;
            case 14:
                nLetterValue = @"E";
                break;
            case 15:
                nLetterValue = @"F";
                break;
            default:
                nLetterValue = [[NSString alloc]initWithFormat:@"%lli",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}
@end
