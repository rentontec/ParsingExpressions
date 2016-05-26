//
//  ViewController.m
//  CompilersParsing
//
//  Created by Scott Moody on 5/26/16.
//  Copyright © 2016 Scott Moody. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *expressionTextItem;

@property (strong, nonatomic) IBOutlet UITextView *expressionResultsItem;
@end

@implementation ViewController
{
    NSArray *tokens;
    
}
-(void) parseText
{
    [self clearText];
    [self addText:@"Parsing.."];
    [self addText:self.expressionTextItem.text];
    
    // this should read the text and 'tokenize' it.
    // but for now:  1 + 5 * 8 / 3 - 8 * (5-1)
    tokens = [[NSArray alloc] initWithObjects:@"1",@"+",@"5", @"*", @"8", @"/", @"3", @"-", @"8", @"*", @"(", @"5", @"-", @"1", @")",nil];
    
    NSString *result = @"figure it out...";
    [self addText:result];

}

-(void)clearText
{
    [self clearCollaborationTextItem  ];
}


-(void) addText:(NSString*)text
{
    [self addMessage:text];
    
}

- (IBAction)parseExpressionTouched:(id)sender
{
    [self parseText];
    // parse..
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - text messages..

NSMutableAttributedString *textViewAttributedText;
NSMutableAttributedString *carriageReturn;
NSMutableAttributedString *emptyText;

//! Add a message to the text view
//!@see Barklets.setBarkletColorInMessage
-(void) addMessage:(NSString *)msg
{
    
    // must create an NSMutableAttributedString -- or get exception
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] initWithString:msg];
    
    
    //now do same for scrolling text message..
    
    if (!textViewAttributedText)
    {
        textViewAttributedText = [[ NSMutableAttributedString alloc ] init];
        carriageReturn= [[NSMutableAttributedString alloc] initWithString:@"\n"];
        emptyText= [[NSMutableAttributedString alloc] initWithString:@""];
        
    }
    
    // add m to end of text
    [textViewAttributedText insertAttributedString:m atIndex:textViewAttributedText.length];
    [textViewAttributedText insertAttributedString:carriageReturn atIndex:textViewAttributedText.length];
    
    
    //Add to the collaborationTextItem too..
    self.expressionResultsItem.attributedText = textViewAttributedText;
    
    [self scrollTextViewToBottom:self.expressionResultsItem];
    
    
}
//! clears the collaboration text item
-(void)clearCollaborationTextItem
{
    textViewAttributedText = emptyText;
    
    //Add to the collaborationTextItem too..
    self.expressionResultsItem.attributedText = textViewAttributedText;
    
}

//! Should scroll the window to the botton. This doesn't always work.
//! @see http://stackoverflow.com/questions/16698638/textview-scroll-textview-to-bottom
- (void)scrollTextViewToBottom:(UITextView *)textView
{
    NSRange range = NSMakeRange(textView.text.length, 0);
    [textView scrollRangeToVisible:range];
    // an iOS bug, see http://stackoverflow.com/a/20989956/971070
    //    [textView setScrollEnabled:NO];
    //   [textView setScrollEnabled:YES];
}

@end
