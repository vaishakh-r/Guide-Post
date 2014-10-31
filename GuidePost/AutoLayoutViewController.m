//
//  AutoLayoutViewController.m
//  GuestBook
//
//  Created by Vaishakh on 10/30/14.
//  Copyright (c) 2014 GuestBook. All rights reserved.
//

#import "AutoLayoutViewController.h"
#import "UIColor+HexKit.h"
#import "Constants.h"
#import "TFHpple.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface AutoLayoutViewController ()<UITextViewDelegate, NSURLConnectionDelegate>

// TextView & ImageView
@property (strong, nonatomic) IBOutlet UIImageView *ogImageView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextView *urlTextView;
@property (strong, nonatomic) IBOutlet UITextView *titleTextView;

@property (assign) BOOL isDataViewExpanded;
@property (strong, nonatomic) NSString *lastSearchedUrl;

@property (strong, nonatomic) UIActivityIndicatorView *spin;
@property (strong, nonatomic) NSMutableData *responseData;


// Constraints
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *doneButtonWidthConstraint;
@property (assign) CGFloat screenWidth;
@property (assign) CGFloat screenHeight;
@property (assign) CGFloat doneButtonInitialPosY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *doneBottomLayoutConstraint;

@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;

// Actions
- (IBAction)doneButtonClicked:(id)sender;

@end

@implementation AutoLayoutViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set Navigation Controller and Background Color
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexCode:@"00A267"];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"GUIDEPOST";
    self.view.backgroundColor = [UIColor colorFromHexCode:@"E3E8E7"];
    
    // Done Button Set UI
    _doneButton.layer.cornerRadius = _doneButtonWidthConstraint.constant/2.0;
    _doneButton.layer.borderColor = [UIColor colorFromHexCode:@"E0E0E0"].CGColor;
    _doneButton.layer.borderWidth = 1.0f;
    [_doneButton setBackgroundColor:[UIColor colorFromHexCode:@"F1F4F3"]];
    [_doneButton setImage:[UIImage imageNamed:@"download_disable.png"] forState:UIControlStateDisabled];
    [_doneButton setImage:[UIImage imageNamed:@"download_active.png"] forState:UIControlStateNormal];
    [_doneButton setEnabled:NO];
    
    // Set TextView Content Insets
    _urlTextView.contentInset = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
    _titleTextView.contentInset = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
    
    // Set Tags
    _urlTextView.tag = kUrlTag;
    _descriptionTextView.tag = kDescriptionTag;
    _titleTextView.tag = kTitleTag;
   
    // Set Placeholders
    _urlTextView.text = kPlaceholder;
    _titleTextView.text = kTitlePlaceholder;
    _descriptionTextView.text = kDescriptionPlaceholder;
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
    self.screenHeight = screenRect.size.height;
    _doneButtonInitialPosY = _urlTextView.frame.origin.y + _urlTextView.frame.size.height + 10;

}

- (void)viewDidAppear:(BOOL)animated
{
    [self hideContainer];
     _spin = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     _spin.center = _doneButton.center;
     [_doneButton.superview insertSubview:_spin aboveSubview:_doneButton];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Hide the Container View of Results
- (void)hideContainer
{
    self.doneBottomLayoutConstraint.constant = self.screenHeight-_doneButtonInitialPosY-_doneButton.frame.size.height;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.2f
                     animations:^{
                         
                         [self.view layoutIfNeeded];
                         [_containerView setHidden:YES];
                    
                     }];
}

// Show the Container View of Results
- (void)showContainer
{
    self.doneBottomLayoutConstraint.constant = 10;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.2f
                     animations:^{
                         
                         [self.view layoutIfNeeded];
                         [_containerView setHidden:NO];
                    
                     }];
}



- (IBAction)doneButtonClicked:(id)sender {
    
    //Check if done button is clicked and Container View is expanded
    if(!_isDataViewExpanded)
    {
        [_doneButton setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        [_spin startAnimating];
        _doneButton.userInteractionEnabled = NO;
        [_doneButton setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        _lastSearchedUrl = _urlTextView.text;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlTextView.text]];
        //Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
}

// Method to Validate URL
- (BOOL)validateUrl : (NSString *)urlString
{
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidURL = [urlPredic evaluateWithObject:urlString];
    return isValidURL;
}


#pragma mark - UITextView Delegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if(textView.tag == kUrlTag)
    {
        NSString *newUrl = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if(_isDataViewExpanded)
        {
            if (![newUrl isEqualToString:_lastSearchedUrl])
            {
                [_doneButton setImage:[UIImage imageNamed:@"download_active.png"] forState:UIControlStateNormal];
                [self resetSearchResults];
                [self hideContainer];
            }
        }
        
        NSString *urlPrependHttp = [NSString stringWithFormat:@"http://%@",newUrl];
        NSString *urlPrependHttps = [NSString stringWithFormat:@"https://%@",newUrl];
        
        if ([self validateUrl:newUrl] || [self validateUrl:urlPrependHttp] || [self validateUrl:urlPrependHttps])
        {
            [_doneButton setEnabled:YES];
        }
        else
        {
            [_doneButton setEnabled:NO];
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView.tag == kUrlTag)
    {
        if ([textView.text isEqualToString:kPlaceholder])
        {
            textView.text = kEmptyString;
            textView.textColor = [UIColor darkGrayColor]; //optional
        }
    }
    else if(textView.tag == kDescriptionTag)
    {
        if ([textView.text isEqualToString:kDescriptionPlaceholder])
        {
            textView.text = kEmptyString;
            textView.textColor = [UIColor darkGrayColor]; //optional
        }
    }
    else if(textView.tag == kTitleTag)
    {
        if ([textView.text isEqualToString:kTitlePlaceholder])
        {
            textView.text = kEmptyString;
            textView.textColor = [UIColor darkGrayColor]; //optional
        }
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.tag == kUrlTag)
    {
        if ([textView.text isEqualToString:kEmptyString]) {
            textView.text = kPlaceholder;
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
    }
    else if (textView.tag == kDescriptionTag)
    {
        if ([textView.text isEqualToString:kEmptyString]) {
            textView.text = kDescriptionPlaceholder;
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
    }
    else if(textView.tag == kTitleTag)
    {
        if ([textView.text isEqualToString:kEmptyString])
        {
            textView.text = kTitlePlaceholder;
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
    }

    [textView resignFirstResponder];
}

// Method to Reset Serach Results
- (void) resetSearchResults
{
    _isDataViewExpanded = NO;
    _titleTextView.text = kPlaceholder;
    _descriptionTextView.text = kDescriptionPlaceholder;
    _ogImageView.image = [UIImage imageNamed:@"camera_placeholder.png"];
    
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    [_spin stopAnimating];
    _isDataViewExpanded = YES;
    _urlTextView.userInteractionEnabled = YES;
    _doneButton.userInteractionEnabled = YES;
    [_urlTextView resignFirstResponder];
    [_doneButton setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    
    
    TFHpple *ogDataParser = [TFHpple hppleWithHTMLData:_responseData];
    NSString *imageXpathQueryString = @"//meta[@property='og:image']/@content";
    NSArray *imageNodes = [ogDataParser searchWithXPathQuery:imageXpathQueryString];
    if ([imageNodes count] > 0)
    {
        TFHppleElement *element = (TFHppleElement *)[imageNodes objectAtIndex:0];
        [_ogImageView sd_setImageWithURL:[NSURL URLWithString:[[element firstChild] content]] placeholderImage:[UIImage imageNamed:@"camera_placeholder.png"]];
    }
    
    NSString *titleXpathQueryString = @"//meta[@property='og:title']/@content";
    NSArray *titleNodes = [ogDataParser searchWithXPathQuery:titleXpathQueryString];
    if ([titleNodes count] > 0)
    {
        TFHppleElement *element = (TFHppleElement *)[titleNodes objectAtIndex:0];
        _titleTextView.textColor = [UIColor darkGrayColor];
        _titleTextView.text = [[element firstChild] content];
    }
    
    NSString *descriptionXpathQueryString = @"//meta[@property='og:description']/@content";
    NSArray *descriptionNodes = [ogDataParser searchWithXPathQuery:descriptionXpathQueryString];
    if ([descriptionNodes count] > 0)
    {
        TFHppleElement *element = (TFHppleElement *)[descriptionNodes objectAtIndex:0];
        _descriptionTextView.textColor = [UIColor darkGrayColor];
        _descriptionTextView.text = [[element firstChild] content];
    }
    
    [self showContainer];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [_spin stopAnimating];
    _isDataViewExpanded = YES;
    _doneButton.userInteractionEnabled = YES;
    _urlTextView.userInteractionEnabled = YES;
    [_urlTextView resignFirstResponder];
    [_doneButton setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [self showContainer];
    
}


@end
