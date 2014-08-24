//
//  PhotoDetailViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/24.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "PhotoDetailViewController.h"

@interface PhotoDetailViewController ()


@property (nonatomic, weak) IBOutlet UIImageView *imgView;


@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    APP_ASSERT(self.img);
    
    self.imgView.image = self.img;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
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


































@end
