//
//  ViewController.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/3/2.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "ViewController.h"
#import "NotifyItem.h"

#import "ThemeColor.h"

@interface ViewController ()

@property NSString *soapMessage;
@property NSString *currentElement;
@property NSMutableData *webResponseData;

@property NSString *elementStart;
@property NSString *elementValue;
@property NSString *elementEnd;

@property BOOL doc;
@property BOOL isNotifyList;
@property BOOL isRoomName;

@property NotifyItem *item;
@property BOOL isFiltered;
@property BOOL is_item_press;

@property BOOL update;

@property ThemeColor *themeColor;
@property NSDate *today;
@property NSDateFormatter *dateFormat;
@end

@implementation ViewController

@synthesize activityIndicator;
@synthesize soapMessage, webResponseData, currentElement;
@synthesize user_id, uuid, status_bar_height, unread_sp_count;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    user_id = [defaults objectForKey:@"Account"];
    uuid = [defaults objectForKey:@"DeviceID"];
    
    //init orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    //init list
    //_notifyList = [[NSMutableArray alloc] init];
    [self initSearchBar];
    
    [self initLoading];
    [self initItemShow];
    
    //if ([self initObserver] != nil) {
    //   NSLog(@"initObserver success!");
    //}
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    _today = [NSDate date];
    _dateFormat = [[NSDateFormatter alloc] init];
    [_dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [super viewDidAppear:animated];
    
    [self showIndicator:true];
    
    [self sendHttpPost];
    
    //set filter = false
    _isFiltered = false;
    
    if ([self initObserver] != nil) {
        NSLog(@"initObserver success!");
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [self deallocObserver];
    
    //remove orientation observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self showNotifyDetail:false];
    
    [_notifyList removeAllObjects];
    [_filterNotifyList removeAllObjects];
    _notifyList = nil;
    _filterNotifyList = nil;
    
    _dateFormat = nil;
    
    [tableView reloadData];
    
    _update = false;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) orientationChanged:(NSNotification *)note{
    UIDevice *device = [UIDevice currentDevice];
    
    status_bar_height = self.topLayoutGuide.length-self.navigationController.navigationBar.frame.size.height;
    
    int width = self.view.bounds.size.width;
    int height = self.view.bounds.size.height;
    
    CGRect btnBackFrame = btnBack.frame;
    
    
    btnBackFrame.origin.x = width - 60;
    btnBackFrame.origin.y = 0;
    
    btnBack.frame = btnBackFrame;
    
    
    
    NSLog(@"status bar = %d, width = %d, height = %d", status_bar_height, width, height);
    huiView.contentSize = CGSizeMake(0, lbl_title_header.frame.origin.y + lbl_title_header.frame.size.height+50);
    
    CGSize background = CGSizeMake(width, height);
    CGRect backRect = CGRectMake(0, 0, width, height);
    
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            NSLog(@"UIDeviceOrientationPortrait");
            
            if (_is_item_press) {
                NSLog(@"_is_item_press");
                huiView.frame = CGRectMake(0, status_bar_height, width, height);
            } else {
                huiView.frame = CGRectMake(width, status_bar_height, width, height);
            }
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            
            if (_is_item_press) {
                NSLog(@"_is_item_press");
                huiView.frame = CGRectMake(0, status_bar_height, width, height);
            } else {
                huiView.frame = CGRectMake(width, status_bar_height, width, height);
            }
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            
            if (_is_item_press) {
                NSLog(@"_is_item_press");
                huiView.frame = CGRectMake(0, status_bar_height, width, height);
                if (huiView.contentSize.height > height) {
                    background = CGSizeMake(width, huiView.contentSize.height);
                    backRect = CGRectMake(0, status_bar_height, width, huiView.contentSize.height);
                }
            } else {
                huiView.frame = CGRectMake(width, status_bar_height, width, height);
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"UIDeviceOrientationLandscapeRight");
            
            if (_is_item_press) {
                NSLog(@"_is_item_press");
                huiView.frame = CGRectMake(0, status_bar_height, width, height);
            } else {
                huiView.frame = CGRectMake(width, status_bar_height, width, height);
            }
            break;
            
        default:
            break;
    };
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    long rowCount;
    if (_isFiltered) {
        rowCount = [_filterNotifyList count];
    } else {
        rowCount = [_notifyList count];
    }
    return rowCount;
    //return [mainArray count];
}

- (UITableViewCell * ) tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"notificationCell";
    
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.backgroundColor = [UIColor colorWithRed:(28/255.0) green:(28/255.0) blue:(28/255.0) alpha:1.0];
    
    
    //NotifyItem *item = [_notifyList objectAtIndex:indexPath.row];
    NotifyItem *item;
    
    if (_isFiltered) {
        item = [_filterNotifyList objectAtIndex:indexPath.row];
    } else {
        item = [_notifyList objectAtIndex:indexPath.row];
    }
    
    UILabel *subject = (UILabel *)[cell viewWithTag:100];
    UILabel *day = (UILabel *)[cell viewWithTag:103];
    //subject.textColor = [UIColor colorWithRed:(120/255.0) green:(120/255.0) blue:(120/255.0) alpha:1.0];
    subject.text = item.title;
    
    UILabel *time = (UILabel *) [cell viewWithTag:101];
    //time.textColor = [UIColor colorWithRed:(120/255.0) green:(120/255.0) blue:(120/255.0) alpha:1.0];
    
    NSString *todayDateString = [_dateFormat stringFromDate:_today];
    
    NSArray *end_split = [item.time componentsSeparatedByString:@" "];
    
    NSString *new_time = [end_split[1] substringToIndex:[end_split[1] length] - 3];
    
    time.text = new_time;
    
    if ([end_split[0] isEqualToString:todayDateString]) {
        day.text = NSLocalizedString(@"DATE_TODAY", nil);
    } else {
        NSString *year_string = [end_split[0] substringToIndex:[end_split[0] length] - 6];
        NSString *year_today = [todayDateString substringToIndex:[todayDateString length] - 6];
        if ([year_today isEqualToString:year_string]) { //same year
            day.text = [end_split[0] substringFromIndex:5];
        } else {
            day.text = end_split[0];
        }
        
    }
    
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:102];
    
    
    if ([item.sp isEqualToString:@"Y"]) {
        //NSLog(@"sp = Y");
        //UIImage *image = [UIImage imageNamed: @"star_green.png"];        [imageView setImage:image];
        //[cell.imageView setImage:[UIImage imageNamed:@"star_green.png"]];
        imageView.image = [UIImage imageNamed:@"star_green"];
        
    } else {
        //NSLog(@"sp = N");
        imageView.image = [UIImage imageNamed:@"new"];
        //[cell.imageView setImage:[UIImage imageNamed:@"new.png"]];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    long rowCount = indexPath.row;
    //Products *pInfo = [self.productInfo objectAtIndex:rowCount];
    //[ConfirmButton setTitle:@"修改" forState:UIControlStateNormal];
    //NotifyItem *item = [_notifyList objectAtIndex:rowCount];
    NotifyItem *item;
    
    if (_isFiltered) {
        item = [_filterNotifyList objectAtIndex:rowCount];
        
    } else {
        item = [_notifyList objectAtIndex:rowCount];
    }
    
    for (int i=0; i<_notifyList.count; i++) {
        NotifyItem *temp = [_notifyList objectAtIndex:i];
        if ([item.title isEqualToString: temp.title] && [temp.sp isEqualToString:@"N"]) {
            [temp setReadSp:@"Y"];
            [self sendHttpPost2:temp.title];
        }
    }
    
    
    
    
    
    [UIView animateWithDuration:0.7 animations:^{
        //productName Label
        
        [self showNotifyDetail:true];
        
        
        
        huiView.contentSize = CGSizeMake(0, lbl_title_header.frame.origin.y + lbl_title_header.frame.size.height+50);
        
        [lbl_title_show setText: item.title];
        
        [lbl_time_show setText: item.time];
        
        [lbl_msg_show setText: item.msg];
        
        
        
        
    }];
    
    _is_item_press = true;
}

-(void) initSearchBar {
    //[self.view setBackgroundColor:[UIColor colorWithRed:(28/255.0) green:(28/255.0) blue:(28/255.0) alpha:1.0]];
    
    
    //init theme color
    _themeColor = [[ThemeColor alloc] init];
    //setup button localized
    //[btnSetup setTitle:NSLocalizedString(@"SETUP_SEARCH", nil) forState:UIControlStateNormal];
    
    //search bar
    searchBar.barTintColor = [UIColor colorWithRed:(121/255.0) green:(27/255.0) blue:(87/255.0) alpha:1.0];
    //set search bar text white
    for (UIView *subView in searchBar.subviews) {
        for (UIView *secondLevelSubview in subView.subviews) {
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                searchBarTextField.textColor = [UIColor blackColor];
            }
        }
    }
    
    
    _notifyList = [[NSMutableArray alloc] init];
    _filterNotifyList = [[NSMutableArray alloc] init];
    searchBar.delegate = self;
}

-(void) showIndicator:(BOOL)show {
    
    if (show) {
        container.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        [activityIndicator startAnimating];
    } else {
        [activityIndicator stopAnimating];
        container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
    }
}

-(void) showNotifyDetail:(BOOL)show {
    if (show) {
        huiView.frame = CGRectMake(0, self.topLayoutGuide.length-self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        huiView.frame = CGRectMake((self.view.bounds.size.width), self.topLayoutGuide.length-self.navigationController.navigationBar.frame.size.height,self.view.bounds.size.width,self.view.bounds.size.height);
    }
}

-(void) initLoading {
    //[tableView setSeparatorColor:[UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0]];
    //[tableView setBackgroundColor:[UIColor colorWithRed:(28/255.0) green:(28/255.0) blue:(28/255.0) alpha:1.0]];
    
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 110, 30)];
    activityLabel = [[UILabel alloc] init];
    //activityLabel.text = NSLocalizedString(@"DATA_LOADING", nil);
    activityLabel.text = NSLocalizedString(@"DATA_LOADING", nil);
    activityLabel.textColor = [UIColor brownColor];
    activityLabel.font = [UIFont boldSystemFontOfSize:17];
    [container addSubview:activityLabel];
    activityLabel.frame = CGRectMake(0, 3, 70, 25);
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [container addSubview:activityIndicator];
    activityIndicator.frame = CGRectMake(80, 0, 30, 30);
    activityIndicator.hidesWhenStopped = YES;
    
    [self.view addSubview:container];
    container.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    //self.view.backgroundColor = [UIColor whiteColor];
}

-(void) initItemShow {
    huiView = [[UIScrollView alloc] initWithFrame:CGRectMake(
                                                             (self.view.bounds.size.height), self.topLayoutGuide.length-self.navigationController.navigationBar.frame.size.height,
                                                             self.view.bounds.size.width,
                                                             self.view.bounds.size.height)];
    huiView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    huiView.alpha=1.0;
    //huiView.layer.cornerRadius = 10;
    [self.view addSubview: huiView];
    
    btnBack = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 0, 60, 30)];
    [btnBack setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[btnBack setTitle:NSLocalizedString(@"BACK_TO_PAGE", nil) forState:UIControlStateNormal];
    [btnBack setTitle:NSLocalizedString(@"COMMON_BACK", nil) forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(backPersonalMeeting:) forControlEvents:(UIControlEventTouchUpInside)];
    [huiView addSubview:btnBack];
    
    //ID
    lbl_title_header = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 80, 21)];
    //[lbl_title_header setTextColor: [UIColor whiteColor]];
    //[lbl_title_header setText:  NSLocalizedString(@"MEETING_SHOW_DETAIL_ID", nil)] ;
    [lbl_title_header setText: NSLocalizedString(@"MSG_TITLE", nil)];
    [huiView addSubview:lbl_title_header];
    
    lbl_title_show = [[UILabel alloc] initWithFrame:CGRectMake(105, 30, self.view.bounds.size.width-100, 21)];
    //[lbl_title_show setTextColor: [UIColor whiteColor]];
    //[lbl_ID_show setTextAlignment:NSTextAlignmentCenter];
    [huiView addSubview:lbl_title_show];
    
    //Start time (h: 30+21+5
    lbl_time_header = [[UILabel alloc] initWithFrame:CGRectMake(5, 56, 80, 21)];
    //[lbl_time_header setTextColor:[UIColor whiteColor]];
    //[lbl_time_header setText: NSLocalizedString(@"MEETING_SHOW_DETAIL_START_TIME", nil)];
    [lbl_time_header setText:NSLocalizedString(@"MSG_TIME", nil)];
    [huiView addSubview:lbl_time_header];
    
    lbl_time_show = [[UILabel alloc] initWithFrame:CGRectMake(105, 56, self.view.bounds.size.width-100, 21)];
    //[lbl_time_show setTextColor:[UIColor whiteColor]];
    //[lbl_Start_time_show setTextAlignment:NSTextAlignmentCenter];
    [huiView addSubview: lbl_time_show];
    
    //End time (h: 30+26+26
    //lbl_msg_header = [[UILabel alloc] initWithFrame:CGRectMake(5, 82, 80, 21)];
    //[lbl_msg_header setTextColor:[UIColor whiteColor]];
    //[lbl_msg_header setText: NSLocalizedString(@"MEETING_SHOW_DETAIL_END_TIME", nil)];
    //[lbl_msg_header setText:@"Msg"];
    //[huiView addSubview: lbl_msg_header];
    
    //lbl_msg_show = [[UILabel alloc] initWithFrame: CGRectMake(105, 82, self.view.bounds.size.width-100, 21)];
    //[lbl_msg_show setTextColor:[UIColor whiteColor]];
    //[lbl_End_time_show setTextAlignment:NSTextAlignmentCenter];
    //[huiView addSubview: lbl_msg_show];
    
    
}

- (void) backPersonalMeeting:(id)sender
{
    [UIView animateWithDuration:0.7 animations:^{
        huiView.frame = CGRectMake((self.view.bounds.size.width), self.topLayoutGuide.length-self.navigationController.navigationBar.frame.size.height,
                                   self.view.bounds.size.width,
                                   self.view.bounds.size.height);
    }];
    
    _is_item_press = false;
    [tableView reloadData];
}


/*
 #progma mark - search bar implementation
 */

- (void) searchTableList {
    
    [_filterNotifyList removeAllObjects];
    _filterNotifyList = nil;
    
    _filterNotifyList = [[NSMutableArray alloc] init];
    
    NSString *searchString = searchBar.text;
    
    NSLog(@"=============>searchTableList, searchString = %@", searchString);
    
    for (NotifyItem *tempItem in _notifyList) {
        NSLog(@"temp = %@", tempItem.title);
        //NSComparisonResult result = [tempItem.result compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if ([tempItem.title containsString:searchString ] ||
            [tempItem.msg containsString:searchString] ||
            [tempItem.time containsString:searchString]) {
            //if (result == NSOrderedSame) {
            
            NotifyItem *item = [[NotifyItem alloc] init];
            [item setTitle:tempItem.title];
            [item setReadSp:tempItem.sp];
            [item setMsg:tempItem.msg];
            [item setTime:tempItem.time];
            
            [_filterNotifyList addObject:item];
        }
    }
    
    NSLog(@"filter size = %lu", (unsigned long)[_filterNotifyList count]);
}


- (void) searchBar:(UISearchBar *)mySearchBar textDidChange:(nonnull NSString *)searchText
{
    
    
    if ([searchText length] == 0) {
        [mySearchBar resignFirstResponder];
        _isFiltered = false;
    } else {
        _isFiltered = true;
        
        
        [self searchTableList];
        
    }
    
    [tableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"Cancel click");
}


- (void) searchBarSearchButtonClicked:(UISearchBar *) mySearchBar {
    NSLog(@"search clicked");
    
    [mySearchBar resignFirstResponder];
    
    [self searchTableList];
    [tableView reloadData];
}

- (void) deallocObserver
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

- (id) initObserver
{
    self = [super init];
    if (!self) return nil;
    
    // Add this instance of TestClass as an observer of the TestNotification.
    // We tell the notification center to inform us of "TestNotification"
    // notifications using the receiveTestNotification: selector. By
    // specifying object:nil, we tell the notification center that we are not
    // interested in who posted the notification. If you provided an actual
    // object rather than nil, the notification center will only notify you
    // when the notification was posted by that particular object.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    
    return self;
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"TestNotification"]) {
        //NSLog (@"Successfully received the test notification! title = %@ body = %@", [notification.object objectForKey:@"title"], [notification.object objectForKey:@"body"]);
        NSLog (@"Successfully received the test notification!");
        
        
        /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        _item = [[NotifyItem alloc] init];
        
        NSLog(@"title = %@", [notification.userInfo objectForKey:@"title"]);
        [_item setTitle:[notification.userInfo objectForKey:@"title"]];
        [_item setMsg:[notification.userInfo objectForKey:@"body"]];
        [_item setTime:strDate];
        [_notifyList addObject:_item];
        NSLog(@"msg num = %lu", (unsigned long)_notifyList.count);
        _item = nil;
        dateFormatter = nil;*/
        
        [self sendHttpPost];
        
    }
}

- (NSMutableArray *) sendHttpPost {
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (_notifyList.count > 0 ) {
        [_notifyList removeAllObjects];
        [_filterNotifyList removeAllObjects];
    }
    
    
    
    _notifyList = nil;
    _filterNotifyList = nil;
    
    
    _notifyList = [[NSMutableArray alloc] init];
    
    
    
    //first create the soap envelope
    soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                   "<soap:Body>"
                   "<Get_TT_PO_list xmlns=\"http://tempuri.org/\">"
                   "<user_no>%@</user_no>"
                   "<ime_code>%@</ime_code>"
                   "</Get_TT_PO_list>"
                   "</soap:Body>"
                   "</soap:Envelope>", user_id, uuid];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://60.249.239.47:9571/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    //ad required headers to the request
    [theRequest addValue:@"60.249.239.47" forHTTPHeaderField:@"Host"];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/Get_TT_PO_list" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:theRequest];
    [dataTask resume];
    
    //if (connection)
    if(dataTask)
    {
        webResponseData = [NSMutableData data] ;
    }
    else
    {
        NSLog(@"Connection is NULL");
    }
    
    //_meeting_count = 0;
    _doc = false;
    _isNotifyList = false;
    _isRoomName = false;
    
    
    //[NSThread detachNewThreadSelector:@selector(actIndicatorEnd) toTarget:self withObject:nil];
    return _notifyList;
}

- (NSMutableArray *) sendHttpPost2:(NSString *)doc_no {
    _updateList = [[NSMutableArray alloc] init];
    
    NSLog(@"doc_no = %@", doc_no);
    
    //first create the soap envelope
    soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                    "<soap:Body>"
                    "<Update_Read_Status xmlns=\"http://tempuri.org/\">"
                    "<doc_type>PO</doc_type>"
                    "<doc_no>%@</doc_no>"
                    "<user_no>%@</user_no>"
                    "<ime_code>%@</ime_code>"
                    "</Update_Read_Status>"
                    "</soap:Body>"
                    "</soap:Envelope>", doc_no, user_id, uuid];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://60.249.239.47:9571/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    //ad required headers to the request
    [theRequest addValue:@"60.249.239.47" forHTTPHeaderField:@"Host"];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/Update_Read_Status" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:theRequest];
    
    
    [dataTask resume];
    
    //if (connection)
    if(dataTask)
    {
        webResponseData = [NSMutableData data] ;
    }
    else
    {
        NSLog(@"Connection is NULL");
        //[activityIndicator stopAnimating];
        //container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
    }
    
    return _updateList;
}

//Implement the connection delegate methods.
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"### handler 1");
    
    completionHandler(NSURLSessionResponseAllow);
    
    [self.webResponseData  setLength:0];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"=== didReceiveData ===");
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //_received_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"received = %@", _received_data);
    [self.webResponseData  appendData:data];
}

//-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        //success
        NSLog(@"Received %lu Bytes", (unsigned long)[webResponseData length]);
        NSString *theXML = [[NSString alloc] initWithBytes:
                            [webResponseData mutableBytes] length:[webResponseData length] encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@",theXML);
        
        theXML = [theXML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        theXML = [theXML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        theXML = [theXML stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        //NSLog(@"%@",theXML);
        
        
        NSData *myData = [theXML dataUsingEncoding:NSUTF8StringEncoding];
        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:myData];
        
        //setting delegate of XML parser to self
        xmlParser.delegate = self;
        
        // Run the parser
        @try{
            unread_sp_count = 0;
            BOOL parsingResult = [xmlParser parse];
            NSLog(@"parsing result = %d",parsingResult);
            NSLog(@"notify_count = %ld", (unsigned long)_notifyList.count );
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = unread_sp_count;
            
            //save badge to default
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (unread_sp_count >= 0) {
                NSString *unread_badge = [NSString stringWithFormat:@"%ld", unread_sp_count];
                [defaults setObject:unread_badge forKey:@"Badge"];
            }
            //for(int i=0;i<_personalMeetingList.count; i++) {
            //    MeetingItem *item = [_personalMeetingList objectAtIndex:i];
            //NSLog(@"<subject %03d> %@", i, item.subject);
            //}
            if (!_update)
                [tableView reloadData];
            //[activityIndicator stopAnimating];
            //container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
            [self showIndicator:false];
            
        }
        @catch (NSException* exception)
        {
            NSString *message = NSLocalizedString(@"SERVER_ERROR", nil);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            int duration = 2;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[alert dismissViewControllerAnimated:YES completion:nil];});
            
            [activityIndicator stopAnimating];
            container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
            return;
        }
        
        
    } else {
        NSString *message = NSLocalizedString(@"COMPLETE_ERROR", nil);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        int duration = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[alert dismissViewControllerAnimated:YES completion:nil];});
        
        [activityIndicator stopAnimating];
        container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
    }
    
    
    
}


//Implement the NSXmlParserDelegate methods
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:
(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
    //NSLog(@"didStartElement");
    //NSLog(@"<%@>", elementName);
    for(id key in attributeDict)
    {
        NSLog(@"attribute %@", [attributeDict objectForKey:key]);
    }
    _elementStart = elementName;
    
    if ([elementName isEqualToString:@"DocumentElement"]) {
        _doc = true;
    } else if ([elementName isEqualToString:@"fxs"]) {
        _isNotifyList = true;
        NSLog(@"<%@>", elementName);
        _item = [[NotifyItem alloc] init];
    } else if ([elementName isEqualToString:@"room_name"]) {
        _isRoomName = true;
    }
    else if ([elementName isEqualToString:@"Update_Read_StatusResponse"]) {
        _update = true;
    } else if([elementName isEqualToString:@"Update_Read_StatusResult"]) {
        NSLog(@"<%@>", elementName);
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //if ([currentElement isEqualToString:@"CelsiusToFahrenheitResult"]) {
    //    self.resultLabel.text = string;
    //}
    //NSLog(@"foundCharacters %@", string);
    //_elementValue = string;
    //NSLog(@"value = %@", string);
    NSLog(@"value = %@, size = %ld", string, (unsigned long)string.length);
    if (_isRoomName) {
        //if (![string isEqualToString:@" "]) {
        _elementValue = [NSString stringWithFormat: @"%@%@", _elementValue, string];
        NSCharacterSet *dont = [NSCharacterSet characterSetWithCharactersInString:@"\n "];
        _elementValue = [[_elementValue componentsSeparatedByCharactersInSet:dont]componentsJoinedByString:@""];
        //}
    }
    else {
        _elementValue = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"Parsed Element : %@", currentElement);
    //NSLog(@"didEndElement");
    //NSLog(@"elementName %@", elementName);
    _elementEnd = elementName;
    //NSLog(@"<%@>%@</%@>", _elementStart, _elementValue, _elementEnd);
    //NSLog(@"</%@>", elementName);
    
    if ([elementName isEqualToString:@"DocumentElement"]) {
        _doc = false;
    } else if ([elementName isEqualToString:@"fxs"]) {
        _isNotifyList = false;
        NSLog(@"</%@>", elementName);
        
        [_notifyList addObject:_item];
        _item = nil;
        
        
        
    } else if ([elementName isEqualToString:@"po_no"]) {
        if (_doc && _isNotifyList) {
            NSLog(@"<%@>%@</%@>", _elementStart, _elementValue, _elementEnd);
            [_item setTitle:_elementValue];
        }
    } else if ([elementName isEqualToString:@"send_datetime"]) {
        if (_doc && _isNotifyList) {
            NSLog(@"<%@>%@</%@>", _elementStart, _elementValue, _elementEnd);
            
            [_item setTime:_elementValue];
        }
    } else if ([elementName isEqualToString:@"read_sp"]) {
        if (_doc && _isNotifyList) {
            NSLog(@"<%@>%@</%@>", _elementStart, _elementValue, _elementEnd);
            
            [_item setReadSp:_elementValue];
            if ([[_item sp] isEqualToString:@"N"]) {
                unread_sp_count++;
            }
        }
    } else if ([elementName isEqualToString:@"Update_Read_StatusResponse"]) {
        _update = false;
    } else if([elementName isEqualToString:@"Update_Read_StatusResult"]) {
        NSLog(@"value = %@", _elementValue);
        NSLog(@"</%@>", elementName);
        
        if ([_elementValue isEqualToString:@"OK"]) {
            
            NSLog(@"update readSp success!");
            
            //load badge
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *unread_badge = [defaults objectForKey:@"Badge"];
            unread_sp_count = [unread_badge intValue];
            
            NSLog(@"current badge = %ld", unread_sp_count);
            if (unread_sp_count > 0) {
                
                
                unread_sp_count--;
                //[UIApplication sharedApplication].applicationIconBadgeNumber = unread_sp_count;
                
                //save badge to default
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if (unread_sp_count > 0) {
                    NSString *unread_badge = [NSString stringWithFormat:@"%ld", unread_sp_count];
                    [defaults setObject:unread_badge forKey:@"Badge"];
                }
            }
        } else {
            NSLog(@"update readSp failed!");
        }
    }
}



-(id) initWithFrame:(CGRect)theFrame {
    if (self = [super init]) {
        frame = theFrame;
        self.view.frame = theFrame;
    }
    return self;
}




@end
