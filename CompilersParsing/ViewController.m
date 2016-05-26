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
    int whichToken;
    
}

-(BOOL) isMulOp
{
    return ([[self currentToken] isEqualToString:@"*"] || [[self currentToken] isEqualToString:@"/"] );
}
-(BOOL) isAddOp
{
    return ([[self currentToken] isEqualToString:@"+"] || [[self currentToken] isEqualToString:@"-"] );
}


-(NSString*)currentToken
{
    if (whichToken >= [tokens count]) return nil;
    NSString *token = [tokens objectAtIndex:whichToken];
    if (token == nil)
        return nil;
    return token;
}
-(BOOL) nextToken
{
    // 0..count-1
    if (whichToken >= [tokens count])
        return NO;
    whichToken++;
    [self addMessage:[self currentToken] val:whichToken];
    return YES;
}

// <simple_ep> ::= <term> { <adding_ops>  <term> }
// <adding_ops> ::= + | -
-(long) simpleExpression
{
    [self addMessage:@"<simpleExpressions>"];
    long val = [self term];
    while ([self isAddOp])
    {
        BOOL isPlus = [[self currentToken] isEqualToString:@"+"];
        [self addMessage:@"<simpleExpressions>" m:[self currentToken]];
        
        [self nextToken];
        long val2 = [self term];
        
        if(isPlus)
            val = val + val2;
        else
            val = val - val2;
        
        
    }
    
    [self addMessage:@"<simpleExpressions>" val:val];
    
    return val;
    
}

// <term> ::= <factor> { <mul_ops>  <factor> }
// <mul_ops> ::= * | /
-(long) term
{
    [self addMessage:@"<term>"];
    long val = [self factor];
    while ([self isMulOp])
    {
        BOOL isMul = [[self currentToken] isEqualToString:@"*"];
        [self addMessage:@"<term>" m:[self currentToken]];
        
        [self nextToken];
        long val2 = [self factor];
        
        if(isMul)
            val = val * val2;
        else
            val = val / val2;
        
    }
    
    [self addMessage:@"<term>" val:val];
    
    return val;
    
}
// <factor> ::= <primary>
// <primary> ::= <integer_constant> ...
-(long) factor
{
    [self addMessage:@"<factor>" m:[self currentToken]];

    long val = [[self currentToken] longLongValue];
    [self addMessage:@"<factor>" val:val];
    
    // now increment next token pointer..
    [self nextToken];

    return val;
    
}
-(void) processExpression
{
    // <simple_exp>
    long result = [self simpleExpression];
    
    [self addMessage:@"<expression>" val:result];
}

-(void) parseText
{
    [self clearText];
    [self addText:@"Parsing.."];
    [self addText:self.expressionTextItem.text];
    
    // this should read the text and 'tokenize' it.
    // but for now:  1 + 5 * 8 / 3 - 8
    tokens = [[NSArray alloc] initWithObjects:@"1",@"+",@"5", @"*", @"8", @"/", @"2", @"-", @"8", nil];
    whichToken= 0;
    
    for (NSString *s in tokens)
    {
        [self addMessage:s];
    }
    
    //now process the expression..
    [self processExpression];

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

-(void) addMessage:(NSString *)msg val:(long)val
{
    NSString *s = [NSString stringWithFormat:@"%@ returns %ld",msg,val];
    [self addMessage:s];
}

-(void) addMessage:(NSString *)msg m:(NSString*)m
{
    NSString *s = [NSString stringWithFormat:@"%@ -  %@",msg,m];
    [self addMessage:s];
}

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
