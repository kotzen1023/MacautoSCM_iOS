//
//  LoginViewController.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/4.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "LoginViewController.h"
#import "Firebase.h"

@interface LoginViewController ()

@property NSString *soapMessage;
@property NSString *currentElement;
@property NSMutableData *webResponseData;
//@property NSString *received_data;
@property NSString *elementStart;
@property NSString *elementValue;
@property NSString *elementEnd;
@property BOOL doc;

@property NSInteger login_error_count;
@end

@implementation LoginViewController
@synthesize activityIndicator;
@synthesize textFieldID, textFieldPassword;
@synthesize uuid;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIDevice *currentDevice = [UIDevice currentDevice];
    uuid = [[currentDevice identifierForVendor] UUIDString];
    
    NSLog(@"uuid  = %@", uuid);
    
    [_labelTitle setText:NSLocalizedString(@"MACAUTO_SCM", nil)];
    
    [textFieldID setPlaceholder:NSLocalizedString(@"LOGIN_ID", nil)];
    [textFieldPassword setPlaceholder:NSLocalizedString(@"LOGIN_PASSWORD", nil)];
    
    [_btnLogin setTitle:NSLocalizedString(@"LOGIN_LOGIN_BTN", nil) forState:UIControlStateNormal];
    [_btnClear setTitle:NSLocalizedString(@"LOGIN_CLEAR_BTN", nil) forState:UIControlStateNormal];
    
    [textFieldID setReturnKeyType:UIReturnKeyDone];
    [textFieldPassword setReturnKeyType:UIReturnKeyDone];
    
    [self initLogging];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _login_error_count = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initLogging {
    
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 110, 30)];
    activityLabel = [[UILabel alloc] init];
    activityLabel.text = NSLocalizedString(@"LOGIN_PROGRESS", nil);
    activityLabel.textColor = [UIColor whiteColor];
    activityLabel.font = [UIFont boldSystemFontOfSize:17];
    [container addSubview:activityLabel];
    activityLabel.frame = CGRectMake(0, 3, 70, 25);
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [container addSubview:activityIndicator];
    activityIndicator.frame = CGRectMake(80, 0, 30, 30);
    activityIndicator.hidesWhenStopped = YES;
    
    [self.view addSubview:container];
    //[self.view setBackgroundColor:[UIColor colorWithRed:(28/255.0) green:(28/255.0) blue:(28/255.0) alpha:1.0]];
    container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
    //self.view.backgroundColor = [UIColor whiteColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnLogin:(id)sender {
    
    if (_login_error_count >= 3) {
        /*UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ErrorWaitViewController"];
        [self presentViewController:vc animated:YES completion:nil];*/
    } else {
        NSString *message;
        UIAlertController *alert;
        
        
        
        if (textFieldID.text.length == 0) {
            message = NSLocalizedString(@"LOGIN_ID_EMPTY", nil);
            
            alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            int duration = 2;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[alert dismissViewControllerAnimated:YES completion:nil];});
            
            _login_error_count++;
        } else {
            
            

            
            [self showIndicator:true];
            
            [self sendHttpPost];
            
        }
    }
}

- (IBAction)btnClear:(id)sender {
    [textFieldID setText:@""];

    [textFieldPassword setText:@""];
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

- (NSMutableArray *) sendHttpPost {
    _loginlSCM = [[NSMutableArray alloc] init];
    
    //first create the soap envelope
    _soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                    "<soap:Body>"
                    "<login xmlns=\"http://tempuri.org/\">"
                    "<message_type>PO</message_type>"
                    "<user_no>%@</user_no>"
                    "<password>%@</password>"
                    "<ime_code>%@</ime_code>"
                    "</login>"
                    "</soap:Body>"
                    "</soap:Envelope>", textFieldID.text, textFieldPassword.text, uuid];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://60.249.239.47:9571/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[_soapMessage length]];
    
    //ad required headers to the request
    [theRequest addValue:@"60.249.239.47" forHTTPHeaderField:@"Host"];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/login" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [_soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:theRequest];
    
    
    [dataTask resume];
    
    //if (connection)
    if(dataTask)
    {
        _webResponseData = [NSMutableData data] ;
    }
    else
    {
        NSLog(@"Connection is NULL");
        [activityIndicator stopAnimating];
        container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
    }
    
    return _loginlSCM;
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
    //NSLog(@"Received String %@", _received_data);
    [self.webResponseData  appendData:data];
}

//-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
-(void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (error == nil) {
        //success
        NSLog(@"Received %lu Bytes", (unsigned long)[_webResponseData length]);
        NSString *theXML = [[NSString alloc] initWithBytes:
                            [_webResponseData mutableBytes] length:[_webResponseData length] encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",theXML);
        
        
        
        
        NSData *myData = [theXML dataUsingEncoding:NSUTF8StringEncoding];
        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:myData];
        
        //setting delegate of XML parser to self
        xmlParser.delegate = self;
        
        // Run the parser
        @try{
            BOOL parsingResult = [xmlParser parse];
            NSLog(@"parsing result = %d",parsingResult);
            
            [self showIndicator:false];
            //[activityIndicator stopAnimating];
            //container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
        }
        @catch (NSException* exception)
        {
            NSString *message = @"Server error";
            
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
    _currentElement = elementName;
    //NSLog(@"didStartElement");
    //NSLog(@"<%@>", elementName);
    for(id key in attributeDict)
    {
        NSLog(@"attribute %@", [attributeDict objectForKey:key]);
    }
    _elementStart = elementName;
    
    if ([elementName isEqualToString:@"loginResponse"]) {
        _doc = true;
    } else if ([elementName isEqualToString:@"loginResult"]) {
        //_MeetingList = true;
        //_checkno = true;
        NSLog(@"<%@>", elementName);
        //_item = [[MeetingItem alloc] init];
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
    
    _elementValue = string;
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
    
    if ([elementName isEqualToString:@"loginResponse"]) {
        _doc = false;
    } else if ([elementName isEqualToString:@"loginResult"]) {
        //_MeetingList = false;
        //_checkno = false;
        NSLog(@"value = %@", _elementValue);
        NSLog(@"</%@>", elementName);
        
        //[_personalMeetingList addObject:_item];
        //_item = nil;
        if ([_elementValue isEqualToString:@"OK"]) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (textFieldID.text.length > 0) {
                NSString *strID = textFieldID.text;
                [defaults setObject:strID forKey:@"Account"];
            }
            
            if (uuid.length > 0) {
                NSString *deviceID = uuid;
                [defaults setObject:deviceID forKey:@"DeviceID"];
            }
            
            //subscribe title
            NSString *topic = [NSString stringWithFormat: @"/topics/%@", textFieldID.text];
            
            
            [[FIRMessaging messaging] subscribeToTopic:topic];
            NSLog(@"Subscribed to topic: %@", topic);
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            NSString *message = NSLocalizedString(@"LOGIN_FAIL", nil);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            int duration = 2;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[alert dismissViewControllerAnimated:YES completion:nil];});
            
            _login_error_count++;
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


- (IBAction)nameInputDone:(id)sender {
    [sender becomeFirstResponder];
    [sender resignFirstResponder];
}

- (IBAction)passwordInputDone:(id)sender {
    [sender becomeFirstResponder];
    [sender resignFirstResponder];
}
@end
