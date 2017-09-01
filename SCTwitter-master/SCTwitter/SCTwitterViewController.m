//
//  SCTwitterViewController.m
//  SCTwitter
//
//  Created by Lucas Correa on 29/02/12.
//  Copyright (c) 2012 Siriuscode Solutions. All rights reserved.
//

#import "SCTwitterViewController.h"
#import "SCTwitter.h"
#import <TwitterKit/TwitterKit.h>
#define SCAlert(title,msg) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

@interface SCTwitterViewController(){
    
    ACAccount *myAccount;
    NSMutableString *paramString;
    NSMutableArray *resultFollowersNameList;
    NSArray *accountsList;
}

@property(nonatomic,retain) ACAccount *myAccount;
@property(nonatomic, retain) NSMutableString *paramString;
@property(nonatomic, retain) NSMutableArray *resultFollowersNameList;

@end

@implementation SCTwitterViewController



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    myAccount = [NSArray new];
    //Loading
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
	loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
	UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[loadingView addSubview:aiView];
	[aiView startAnimating];
	aiView.center =  loadingView.center;
	[aiView release];
	[self.view addSubview:loadingView];
	loadingView.hidden = YES;
}

- (void)viewDidUnload
{
    [self setMessageText:nil];
    [self setBackground:nil];
	[super viewDidUnload];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationPortrait == interfaceOrientation);
}



#pragma mark - Button Action

- (IBAction)loginButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter loginViewControler:self callback:^(BOOL success, id result){
        loadingView.hidden = YES;
        if (success) {
            NSLog(@"Login is Success -  %i", success);
            SCAlert(@"Alert", @"Success");            
        }
    }];
}

- (IBAction)logoutButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter logoutCallback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        NSLog(@"Logout is Success -  %i", success);        
        SCAlert(@"Alert", @"Logout successfully");
    }];
}

- (IBAction)postBackgroundButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter postWithMessage:@"Test upload image" uploadPhoto:[UIImage imageNamed:@"Default"] latitude:-46.0123 longitude:-23.5133 callback:^(BOOL success, id result) {
        
//    [SCTwitter postWithMessage:self.messageText.text callback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            NSLog(@"Message send -  %i \n%@", success, result); 
            SCAlert(@"Alert", @"Send message in background");            
        }else {
            SCAlert(@"Alert", @"Not Login");            
        }
    }];
}

- (IBAction)publicTimelineButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter getPublicTimelineWithCallback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            //Return array NSDictonary
            NSLog(@"%@", result);
            SCAlert(@"Alert", @"Request public timeline success");
        }else {
            SCAlert(@"Alert", @"Not Login");   
        } 
    }];
}

- (IBAction)userTimelineButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter getUserTimelineFor:@"lucasc0rrea" sinceID:0 startingAtPage:0 count:200 callback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            //Return array NSDictonary
            NSLog(@"%@", result);
                SCAlert(@"Alert", @"Request user timeline success");
        }else {
            SCAlert(@"Alert", @"Not Login");   
        }
    }];
}

- (IBAction)userInformationButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter getUserInformationCallback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            //Return array NSDictonary
            NSLog(@"%@", result);
            SCAlert(@"Alert", @"Request user information success");   
        }else {
            SCAlert(@"Alert", @"Not Login");   
        }         
    }];
}

- (IBAction)directMessageButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter directMessage:self.messageText.text to:nil callback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            //Return array NSDictonary
            SCAlert(@"%@", result);
        }else{
            NSLog(@"Error : %@", result);
            SCAlert(@"Alert", result);
        }
    }];
}

- (IBAction)retweetButtonAction:(id)sender 
{
    loadingView.hidden = NO;
    
    [SCTwitter retweetMessageUpdateID:nil callback:^(BOOL success, id result) {
        loadingView.hidden = YES;
        
        if (success) {
            //Return array NSDictonary
            NSLog(@"%@", result);
            SCAlert(@"Alert", @"Request retweet success");   
        }else{
            NSLog(@"%@", result);
            SCAlert(@"Alert", @"Error retweet");   
        }
    }];
    
}

- (IBAction)listFriends:(id)sender {
    [self getTwitterAccounts];
    
}
-(void)getTwitterAccounts {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType
                            withCompletionHandler:^(BOOL granted, NSError *error) {
                                
                                if (granted && !error) {
                                    accountsList = [accountStore accountsWithAccountType:accountType];
                                    
                                    int NoOfAccounts = [accountsList count];
                                    
                                    if (NoOfAccounts > 1) {
                                        
                                        NSLog(@"device has more then one twitter accounts %i",NoOfAccounts);
                                        
                                    }
                                    else
                                    {
                                        myAccount = [accountsList objectAtIndex:0];
                                        [self getTwitterFriendsIDListForThisAccount];
                                        NSLog(@"device has single twitter account : 0");
                                        
                                    }
                                }
                                else
                                {
                                    // show alert with information that the user has not granted your app access, etc.
                                }
                                
                            }];
}


/************* getting followers/friends ID list code start here *******/
// so far we have instnce of current account, that is myAccount //

-(void) getTwitterFriendsIDListForThisAccount{
    
    /*** url for all friends *****/
    // NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/friends/ids.json"];
    
    /*** url for Followers only ****/
    //followers
    NSURL *followingURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json?"];
    
    NSDictionary *parameters= [NSDictionary dictionaryWithObjectsAndKeys:myAccount.username,@"screen_name", nil];
    
    
    SLRequest *twitterRequest =[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:followingURL parameters:parameters];
    
    [twitterRequest setAccount:myAccount];
    
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            //DEAL WITH THE ERROR
        }
        NSError *jsonError =nil;
        NSDictionary *twitterFriends = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:&jsonError];
        
        
        NSLog(@"");
    }
     ];
    
}


-(void) getFollowerNameFromID:(NSString *)ID{
    
    
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/users/lookup.json"];
    NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"user_id",nil];
    NSLog(@"make a request for ID %@",p);
    
    SLRequest *twitterRequest = [[SLRequest alloc] initWithURL:url
                                                    parameters:p
                                                 requestMethod:SLRequestMethodGET];    
    [twitterRequest setAccount:myAccount];
    
    
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            
        }
        NSError *jsonError = nil;       
        
        
        NSDictionary *friendsdata = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:&jsonError];
        //  NSLog(@"friendsdata value is %@", friendsdata);
        
        
        //  resultFollowersNameList = [[NSArray alloc]init];
        resultFollowersNameList = [friendsdata valueForKey:@"name"];
        NSLog(@"resultNameList value is %@", resultFollowersNameList);
        
        
    }];        
    
}

#pragma mark - 
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)dealloc {
    [self setMessageText:nil];
    [_background release];
    [super dealloc];
}

@end
