//
//  MapViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/9.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapModeNumberPinView.h"
#import "PosPinAnnotation.h"
#import "RecordStorageManager.h"
#import "RecordModel.h"
#import "TransformCorrdinate.h"
#import "SGInfoAlert+ShowAlert.h"


@interface MapViewController ()
<
    MKMapViewDelegate
>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;


@property (nonatomic, strong) NSArray *recordArray;
@property (nonatomic, strong) NSMutableArray *annotationsArray;
@property (nonatomic, assign) CLLocationCoordinate2D mapCenterLoc;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"地图";
    
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _recordArray = @[];
    _annotationsArray = [[NSMutableArray alloc] init];
    
//    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    _mapView.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadData];
}

- (IBAction)refreshBtn:(id)sender
{
    [self reloadData];
    [SGInfoAlert showAlert:@"刷新成功" duration:0.3f inView:self.view];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    //判断是否是自己
    if ([annotation isKindOfClass:[PosPinAnnotation class]])
    {
        PosPinAnnotation *pin = (PosPinAnnotation *)annotation;
        
        MapModeNumberPinView* pinView = (MapModeNumberPinView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"MapModeNumberPinView"];
        if (!pinView){
            // If an existing pin view was not available, create one.
            pinView = [[MapModeNumberPinView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:@"MapModeNumberPinView"];
            [pinView setPinColor:MKPinAnnotationColorRed];
            [pinView setCanShowCallout:YES];    // 是否显示点击大头针后的弹出标注框
        }
        else
        {
            pinView.annotation = annotation;
        }
        
        if (pin.m_img)
        {
            pinView.image = pin.m_img;
        }else{}
        
        [pinView showIndex:pin.m_iUserInfoIndex+1];
        
        return pinView;
    }else{}
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[PosPinAnnotation class]])
    {
//        PosPinAnnotation *pin = view.annotation;
    }
    else{}
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    CLLocationCoordinate2D locCurr = userLocation.location.coordinate;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [SGInfoAlert showAlert:@"定位当前位置失败" duration:0.6f inView:self.view];
}

#pragma mark -
- (void)reloadData
{
    _recordArray = [RecordStorageManagerObj allRecords];

    [self resetPins];
}

- (void)initMapWithRecords
{
    _annotationsArray = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D objAreaNorthEast;
    CLLocationCoordinate2D objAreaSouthWest;
    
    objAreaNorthEast.latitude = 0.0f;
    objAreaNorthEast.longitude = 0.0f;
    objAreaSouthWest.latitude = 0.0f;
    objAreaSouthWest.longitude = 0.0f;
    
    [self getMapShowAreaAndAddPinForNorthEast:&objAreaNorthEast southWest:&objAreaSouthWest];
    
    // 设置地图显示区域 显示中心和范围
    _mapCenterLoc.latitude = (objAreaSouthWest.latitude + objAreaNorthEast.latitude) / 2.0f;
    _mapCenterLoc.longitude = (objAreaSouthWest.longitude + objAreaNorthEast.longitude) / 2.0f;
    
    CGFloat fLatDelta = 0.02f;
    CGFloat fLngDelta = 0.02f;
    fLatDelta = MAX(fabs(_mapCenterLoc.latitude - objAreaNorthEast.latitude), fabs(_mapCenterLoc.latitude - objAreaSouthWest.latitude)) * 2.2f;
    fLngDelta = MAX(fabs(_mapCenterLoc.longitude - objAreaNorthEast.longitude), fabs(_mapCenterLoc.longitude - objAreaSouthWest.longitude)) * 2.2f;
    
    fLatDelta = MAX(0.02f, fLatDelta);
    fLngDelta = MAX(0.02f, fLngDelta);
    
    MKCoordinateRegion newRegion;
    newRegion.center = [TransformCorrdinate GPSLocToGoogleLoc:_mapCenterLoc];
    newRegion.span = MKCoordinateSpanMake(fLatDelta, fLngDelta);
    
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:newRegion];
    
    [_mapView setRegion:adjustedRegion animated:NO];
    
    [_mapView removeAnnotations:_mapView.annotations];  // remove any annotations that exist
    [_mapView addAnnotations:_annotationsArray];
}

- (void)addPin:(CLLocationCoordinate2D)objLoc title:(NSString *)title subTitle:(NSString *)subTitle index:(NSInteger)index
{
    CLLocationCoordinate2D objGoogleLoc;
    objGoogleLoc = [TransformCorrdinate GPSLocToGoogleLoc:objLoc];
    
    PosPinAnnotation *pinAnnotation = [[PosPinAnnotation alloc] initWithCoordinate:objGoogleLoc];
    pinAnnotation.title = title;
    pinAnnotation.subtitle = subTitle;
    pinAnnotation.m_img = [UIImage imageNamed:@"PinBlue"];
    pinAnnotation.m_iUserInfoIndex = index;
    [_annotationsArray addObject:pinAnnotation];
}

- (void)getMapShowAreaAndAddPinForNorthEast:(CLLocationCoordinate2D *)pAreaNorthEast
                                  southWest:(CLLocationCoordinate2D *)pAreaSouthWest
{
    APP_ASSERT(_recordArray)
    if (pAreaNorthEast && pAreaSouthWest)
    {
        NSUInteger iIndex = 0;
        for (RecordModel *recordModel in _recordArray)
        {
            [self resetNorthEast:pAreaNorthEast southWest:pAreaSouthWest by:recordModel.location.coordinate];
            
            iIndex++;
        }
    }else{APP_ASSERT_STOP}
}

- (void)resetNorthEast:(CLLocationCoordinate2D *)pAreaNorthEast
             southWest:(CLLocationCoordinate2D *)pAreaSouthWest
                    by:(CLLocationCoordinate2D)objLoc
{
    
    if (pAreaNorthEast && pAreaSouthWest)
    {
        if (objLoc.latitude > (*pAreaNorthEast).latitude)
        {
            (*pAreaNorthEast).latitude = objLoc.latitude;
        }else{}
        if (objLoc.longitude > (*pAreaNorthEast).longitude)
        {
            (*pAreaNorthEast).longitude = objLoc.longitude;
        }else{}
        if ((0.0f == (*pAreaSouthWest).latitude) || (objLoc.latitude < (*pAreaSouthWest).latitude))
        {
            (*pAreaSouthWest).latitude = objLoc.latitude;
        }else{}
        if ((0.0f == (*pAreaSouthWest).longitude) || (objLoc.longitude < (*pAreaSouthWest).longitude))
        {
            (*pAreaSouthWest).longitude = objLoc.longitude;
        }else{}
    }else{APP_ASSERT_STOP}
}

- (void)resetPins
{
    [self initMapWithRecords];
    
    _annotationsArray = [[NSMutableArray alloc] init];
    if (_recordArray)
    {
        NSInteger iIndex = 0;
        for (RecordModel *recordModel in _recordArray)
        {
            NSString *detail = [NSString stringWithFormat:@"%.4f,%.4f;海拔%.2f(±%.2fm)", recordModel.location.coordinate.longitude, recordModel.location.coordinate.latitude, recordModel.location.altitude, recordModel.location.verticalAccuracy];
            [self addPin:recordModel.location.coordinate title:recordModel.title subTitle:detail index:iIndex];
            
            iIndex++;
        }
    }else{APP_ASSERT_STOP}

    [_mapView removeAnnotations:_mapView.annotations];  // remove any annotations that exist
    [_mapView addAnnotations:_annotationsArray];
}




































@end
