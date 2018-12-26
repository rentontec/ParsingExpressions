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
@property (weak, nonatomic) IBOutlet UILabel *resultLabelItem;
@end

//! This is the view controller for ParsingExpressions a BNF simple parser
//!@see http://KnowledgeShark.me
@implementation ViewController
{
    //recent tokens
    NSArray *tokens;
    //which token in that array (eg. 0..tokens.count-1)
    int whichToken;
    //amount to indent by..
    int indentAmount;
    //amount to indent..
    int currentIndentValue;
    
    //current array
    NSArray *currentTokenArray;
    // array of tokenArrays
    NSMutableArray *tokenArrays;
    // current tokenArray
    int currentTokenArrayIndex;
    
    //stack
    NSMutableArray *stack;

}
// creates a string from the tokens (in order)
-(NSString*)tokenArrayToString:(NSArray*)tokenArray
{
    //note: the string MUST have spaces otherwise the tokenizer doesn't work..
    NSString *stringVersion=nil;
    for (NSString *token in tokenArray)
    {
        if (!stringVersion)
            stringVersion = @"";
        else
            stringVersion = [stringVersion stringByAppendingString:@" "];
        stringVersion = [stringVersion stringByAppendingString:token];

    }
    return stringVersion;
}

//init the tokens..
-(void) initTokenArrays
{
    currentTokenArrayIndex = 0;

    tokenArrays = [[NSMutableArray alloc]init];
    // this should read the text and 'tokenize' it.
    // but for now:  1 + 5 * 8 / 3 - 8
    NSArray *t = [[NSArray alloc] initWithObjects:@"1",@"+",@"5", @"*", @"8", @"/", @"2", @"-", @"8", nil];
    NSString *s = @"1 + 5 * 8 / 2 - 8";
    [tokenArrays addObject:s];
    //global tokens..
    tokens = t;
    
    t = [[NSArray alloc] initWithObjects:@"5",@"+",@"5", @"+", @"20", @"*", @"2", @"*", @"8", nil];
    s = @"5 + 5 + 5 + 20 * 20 * 8";
    [tokenArrays addObject:s];
    
    t = [[NSArray alloc] initWithObjects:@"232",@"/",@"22", @"+", @"20", @"*", @"2", @"*", @"8", nil];
    s = @"232 / 22 + 20 * 2 * 8";
    [tokenArrays addObject:s];
    
}
//switches the token array in a circular list..
-(void)switchTokenArray
{
    currentTokenArrayIndex++;

    if (currentTokenArrayIndex >= [tokenArrays count])
        currentTokenArrayIndex=0;

   // tokens = [tokenArrays objectAtIndex:currentTokenArrayIndex];
   // NSString *s = [self tokenArrayToString:tokens];
    NSString *s = [tokenArrays objectAtIndex:currentTokenArrayIndex];
                   
    // set the input text item..
    [self.expressionTextItem setText:s];
    
    //empty the result
    [self.resultLabelItem setText:@"?"];

    //tokenize the list..
    [self tokenizeInput];
    whichToken= 0;
}

//actual parsing..
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
  //  [self addMessage:[self currentToken] val:whichToken];
    NSString *token = [NSString stringWithFormat:@"TOKEN = '%@'",[self currentToken]];
    [self outputRawMessage:token];
    return YES;
}

#pragma mark stack update

-(void)pushStack:(NSInteger)val
{
    //put on stack
    if (!stack) stack = [[NSMutableArray alloc] init];
   //long top = [stack count];
    NSNumber *number = [NSNumber numberWithLong:val];
    [stack addObject:number];
    NSLog(@"push %@, stack=\n%@",number,stack);
    
    [self showStack];
}
-(NSInteger)popStack
{
    long top = [stack count];
    NSNumber *number = [stack objectAtIndex:top-1];
    [stack removeLastObject];
    NSInteger num = [number integerValue];
    NSLog(@"pop %@, stack=\n%@",number,stack);

    return num;
}
-(void)stackMulop:(BOOL)isMulOp
{
    // pop 2
    // mul or div
    //push
    NSInteger right = [self popStack];
    NSInteger left = [self popStack];
    NSInteger val;
    if (isMulOp)
        val = left * right;
    else
        val = left / right;
    NSLog(@"%ld %@ %ld = %ld",(long)left,isMulOp?@"*":@"/",(long)right,(long)val);

    [self pushStack:val];
}
-(void)stackAddop:(BOOL)isAddOp
{
    // pop 2
    // + or -
    //push
    NSInteger right = [self popStack];
    NSInteger left = [self popStack];
    NSInteger val;
    if (isAddOp)
        val = left + right;
    else
        val = left - right;
    NSLog(@"%ld %@ %ld = %ld",(long)left,isAddOp?@"+":@"-",(long)right,(long)val);

    [self pushStack:val];
}
#pragma mark indent update
-(void)push
{
    currentIndentValue += indentAmount;
}
-(void)pop
{
    currentIndentValue -= indentAmount;
}
-(NSString*)indentOutput
{
    NSString *indent=@"";
    for (int i=0;i<currentIndentValue;i++)
        //add character to indent
        indent = [NSString stringWithFormat:@"%@ ",indent];
    return indent;
}
// <simple_ep> ::= <term> { <adding_ops>  <term> }
// <adding_ops> ::= + | -
-(long) simpleExpression
{
    BOOL inLoop = NO;
    [self push];
    [self addMessage:@"<simpleExpression>"];
    long val = [self term];
    while ([self isAddOp])
    {
        inLoop = YES;
        BOOL isPlus = [[self currentToken] isEqualToString:@"+"];
        [self addMessage:@"<simpleExpression>" m:[self currentToken]];
        
        [self nextToken];
        // long val2 = [self term];
        long val2 = [self simpleExpression];

      //  [self pushStack:val2];
        [self stackAddop:isPlus];
        
        long v = val;
        if(isPlus)
            val = val + val2;
        else
            val = val - val2;
        
        NSString *valString = [NSString stringWithFormat:@"%ld %@ %ld = %ld",v,isPlus?@"+":@"-",val2,val];
        //[self addMessage:@"<simpleExpression>" val:val];
        [self addMessage:@"<simpleExpression>" m:valString];

    }
    if (!inLoop)
        [self addMessage:@"<simpleExpression>" val:val];
    [self pop];

    return val;
    
}

// <term> ::= <factor> { <mul_ops>  <factor> }
// <mul_ops> ::= * | /
-(long) term
{
    BOOL inLoop = NO;

    [self push];

    [self addMessage:@"<term>"];
    long val = [self factor];
    while ([self isMulOp])
    {
        inLoop = YES;
        BOOL isMul = [[self currentToken] isEqualToString:@"*"];
      //  [self addMessage:@"<term>" m:[self currentToken]];
        
        [self nextToken];
        long val2 = [self factor];
        
       // [self pushStack:val2];
        [self stackMulop:isMul];
        
        long v = val;
        if(isMul)
            val = val * val2;
        else
            val = val / val2;
        NSString *valString = [NSString stringWithFormat:@"%ld %@ %ld = %ld",v,isMul?@"*":@"/",val2,val];
       // [self addMessage:@"<term>" val:val];
        [self addMessage:@"<term>" m:valString];


    }
    if (!inLoop)
        [self addMessage:@"<term>" val:val];
    [self pop];

    return val;
    
}
// <factor> ::= <primary>
// <primary> ::= <integer_constant> ...
-(long) factor
{
    [self push];

    //[self addMessage:@"<factor>" m:[self currentToken]];

    long val = [[self currentToken] longLongValue];
    [self addMessage:@"<factor>" val:val];
    [self pushStack:val];

    // now increment next token pointer..
    [self nextToken];

    [self pop];
    return val;
    
}
-(void) processExpression
{
    [self showStack];

    // <simple_exp>
    long result = [self simpleExpression];
    
    [self showStack];

   // NSInteger stackVal = [self popStack];
    
    [self addMessage:@"<expression>" val:result];
}

// this works if there are spaces around tokens
-(void) tokenizeInput
{
   //
    NSString *line = self.expressionTextItem.text;
    NSArray *bits = [line componentsSeparatedByString: @" "];

    tokens = bits;
}


- (IBAction)nextExpressionTouched:(id)sender
{
    [self switchTokenArray];
}

-(void)clearStack
{
    [stack removeAllObjects];
}
-(void) parseText
{
    [self.resultLabelItem setText:@""];
    
    [self clearStack];
    [self clearText];
    [self addText:@"Parsing.."];
    [self addText:self.expressionTextItem.text];
  
#ifdef WAS_HERE
    // this should read the text and 'tokenize' it.
    // but for now:  1 + 5 * 8 / 3 - 8
    tokens = [[NSArray alloc] initWithObjects:@"1",@"+",@"5", @"*", @"8", @"/", @"2", @"-", @"8", nil];
#endif

    [self tokenizeInput];
    whichToken = 0;
//
//    for (NSString *s in tokens)
//    {
//        [self addMessage:s];
//    }
    
    //now process the expression..
    [self processExpression];

}

-(void)clearText
{
    [self clearCollaborationTextItem];
    currentIndentValue = 3;
    indentAmount = 4;

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

- (IBAction)clearTouched:(id)sender
{
    [self clearCollaborationTextItem];
    // parse..
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    carriageReturn= [[NSMutableAttributedString alloc] initWithString:@"\n"];
    emptyText= [[NSMutableAttributedString alloc] initWithString:@""];
    
    [self initTokenArrays];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - text messages..

NSMutableAttributedString *textViewAttributedText;
NSMutableAttributedString *carriageReturn;
NSMutableAttributedString *emptyText;

-(void)setResultText:(NSString *)s
{
    [self.resultLabelItem setText:s];

}
-(void) addMessage:(NSString *)msg val:(long)val
{
    NSString *v = [NSString stringWithFormat:@"%ld",val];

    NSString *s = [NSString stringWithFormat:@"%@ returns: %@",msg,v];
    [self addMessage:s];
    
    //add to the results..
    [self setResultText:v];
}

-(void) addMessage:(NSString *)msg m:(NSString*)m
{
    NSString *s = [NSString stringWithFormat:@"%@ %@",msg,m];
    [self addMessage:s];
}

//! Add a message to the text view
//!@see Barklets.setBarkletColorInMessage
-(void) addMessage:(NSString *)msg
{
    NSString *startMsg = [NSString stringWithFormat:@"%@%@",[self indentOutput],msg];
    msg = startMsg;
    [self outputRawMessage:msg];
}
-(void)showStack
{
    NSString *s = [NSString stringWithFormat:@"STACK:%@",stack];
    [self outputRawMessage:s];
}

//! Add a message to the text view
//!@see Barklets.setBarkletColorInMessage
-(void) outputRawMessage:(NSString *)msg
{
    NSLog(@"\n%@%@",[self indentOutput],msg);

    // must create an NSMutableAttributedString -- or get exception
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] initWithString:msg];
    
    
    //now do same for scrolling text message..
    
    if (!textViewAttributedText)
    {
        textViewAttributedText = [[ NSMutableAttributedString alloc ] init];
        
        
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
    emptyText= [[NSMutableAttributedString alloc] initWithString:@""];

    textViewAttributedText = emptyText;
    
    //Add to the collaborationTextItem too..
    self.expressionResultsItem.attributedText = emptyText; //textViewAttributedText;
    
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
