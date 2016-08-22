//
//  ShipInfo.m
//  ArcGIS test
//
//  Created by 潇 on 16/8/8.
//  Copyright © 2016年 潇. All rights reserved.
//

#import "ShipInfo.h"
#import "Utils.h"

@implementation ShipInfo

//经过经纬度查询周围的船舶
- (NSString *)GetServerShipInfoStr:(NSString *)mmsi Lon:(NSString *)lon Lat:(NSString *)lat Diff:(NSString *)diff {

    NSString *urlStr = @"%@/DTKJ.asmx/GetLastCBGPSDataDiffIOS?mymmsi=%@&lon=%@&lat=%@&diff=%@";
    
    urlStr = [NSString stringWithFormat:urlStr, WEBSERVICE_HEAD, mmsi, lon, lat, diff];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"经过经纬度查询周围的船舶的url =====%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:0 forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"GET"];
    
    NSData *webData;
    NSURLResponse *response;
    NSError *error;
    webData= [ NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    NSString *retStr=[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    NSLog(@"经纬度查询周围的船舶数据==%@",retStr);
    return retStr;
}

//经过船舶定位搜索查询周围的船舶
-(NSString *)GetServerShipStrDw:(NSString *)mmsi Lookmmsi:(NSString *)lmmsi Diff:(NSString *)diff Flag:(NSString *)flag
{
    NSString *urlStr = @"%@/DTKJ.asmx/GetLastCBGPSDataIOS?mymmsi=%@&lookmmsi=%@&diff=%@&@&flag=%@";
    
    urlStr=[NSString stringWithFormat:urlStr,WEBSERVICE_HEAD, mmsi,lmmsi,diff,flag];
    NSURL *url =[NSURL URLWithString:urlStr];
    NSLog(@"经过船舶定位搜索查询周围的船舶的url=%@",url);
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    NSData *webData;
    NSURLResponse *response;
    NSError *error;
    webData=[NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSString *retStr=[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    NSLog(@"船舶定位搜索查询周围的船舶数据===%@",retStr);
    return retStr;
}

//处理服务器返回的字符串，解析成实体集合
- (NSMutableArray *)GetShipInfoList:(NSString *)ServerShipStr {

    NSMutableArray *arrayList = [NSMutableArray arrayWithCapacity:0];
    NSString *shipStr = ServerShipStr;
    
    if (shipStr.length > 1 & [shipStr rangeOfString:@"|"].location != NSNotFound) {
        shipStr = [shipStr stringByReplacingOccurrencesOfString:@"|</string>" withString:@""];
        
        shipStr = [shipStr substringFromIndex:[shipStr rangeOfString:@"org"].location + 6];
        
        ShipInfo *shipinfo = [ShipInfo alloc];
        NSArray *array = [shipStr componentsSeparatedByString:@"|"];
        for (int i = 0; i < array.count; i++) {
            shipinfo = [self GetSingleShipByStr:array[i]];
            [arrayList addObject:shipinfo];
        }
    }
    return arrayList;
}

//船舶搜索定位
- (NSString *)GetSearchList:(NSString *)searchKey {

    NSString *urlStr=@"%@/DTKJ.asmx/SearchShip?key=%@";
    urlStr=[[NSString stringWithFormat:urlStr,WEBSERVICE_HEAD,searchKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url =[NSURL URLWithString:urlStr];
    NSLog(@"船舶搜索定位的 url ==%@",url);
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    NSData *webData;
    NSURLResponse *res;
    NSError *err;
    webData=[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    NSString *retStr=[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    
    return retStr;
}

//把单个船舶字符创处理成船的实体类
- (ShipInfo *)GetSingleShipByStr:(NSString *)singleShipStr {
    
    ShipInfo *ship = [ShipInfo alloc];
    if (singleShipStr.length < 1) {
        return ship;
    }
    
    NSArray *array = [singleShipStr componentsSeparatedByString:@","];
    
    if (array.count == 10) {
        ship.mmsi=array[0];
        ship.lon=array[1];
        ship.lat=array[2];
        ship.speed=array[3];
        ship.head=array[4];
        ship.systime=array[5];
        ship.zwcm=array[6];
        ship.cbcd = array[7];
        ship.cbxk = array[8];
        ship.lc = array[9];
    }
    return ship;
}

//获取绑定船舶预警信息
- (NSString *)GetWarningStr:(NSString *)mmsi Lon:(NSString *)lon Lat:(NSString *)lat Metre:(NSString *)metre Lastlon:(NSString *)lastlon Lastlat:(NSString *)lastlat {

    NSString *urlStr=@"%@/DTKJ.asmx/GetWarningInfo?mmsi=%@&lon=%@&lat=%@&metre=%@&lastlon=%@&lastlat=%@";
    urlStr=[NSString stringWithFormat:urlStr,WEBSERVICE_HEAD, mmsi,lon,lat,metre,lastlon,lastlat];
    NSURL *url =[NSURL URLWithString:urlStr];
    NSLog(@"获取绑定船舶预警信息的 url===%@",url);
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    NSData *webData;
    NSURLResponse *res;
    NSError *err;
    webData=[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    NSString *retStr=[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    return retStr;
}

//经过经纬度查询图层
- (NSString *)GetServerLayerListStr:(NSString *)lon Lat:(NSString *)lat Diff:(NSString *)diff {

    NSString *urlStr=@"%@/DTKJ.asmx/GetMapLayerDataIOS?lon=%@&lat=%@&diff=%@";
    urlStr = [NSString stringWithFormat:urlStr, WEBSERVICE_HEAD, lon, lat, diff];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"经过经纬度查询图层url====%@",urlStr);
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    NSData *webData;
    NSURLResponse *res;
    NSError *err;
    webData=[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    NSString *retStr=[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    return retStr;
}

//经过 mmsi查询船舶信息
- (ShipInfo *)GetShipInfoByMmsi:(NSString *)mmsi {

    ShipInfo *ship = [ShipInfo alloc];
    NSString *urlStr=@"%@/DTKJ.asmx/GetShipInfoByMmsi?mmsi=%@";
    urlStr=[NSString stringWithFormat:urlStr,WEBSERVICE_HEAD, mmsi];
    NSURL *url =[NSURL URLWithString:urlStr];
    NSLog(@"经过 mmsi查询船舶信息==%@",url);
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    NSData *webData;
    NSURLResponse *res;
    NSError *err;
    webData=[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    NSLog(@"经过九位码查询船舶信息的 data====%@",webData);
    NSString *shipStr=[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    
    if(shipStr.length>1&[shipStr rangeOfString:@","].location!=NSNotFound)
    {
        shipStr=[shipStr stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        shipStr=[shipStr substringFromIndex:[shipStr rangeOfString:@"org"].location+6];
        
        ship=[self GetSingleShipByStr:shipStr];
    }
    return ship;

}






@end
