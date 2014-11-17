//
//  TimelineController.m
//  UCRChat
//
//  Created by Gustavo Blanco on 10/22/14.
//  Copyright (c) 2014 me.gustavob. All rights reserved.
//

#import "TimelineController.h"
#import "CustomCell.h"
#import "PostViewController.h"

@interface TimelineController ()

@end

@implementation TimelineController
@synthesize PostTable; //PostControllerPIC, PostControllerName, PostControllerPost;
;
static int numLikes = 0;
static NSUInteger numComments = 0;

PFObject *tempObject;
CustomCell *cell;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.PostTable setBackgroundColor: [UIColor clearColor]];
    [self.PostTable setOpaque: NO];
    self.PostTable.dataSource = self;
    self.PostTable.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(retrieveFromParse) forControlEvents:UIControlEventValueChanged];
    
    [self.PostTable addSubview:_refreshControl];
    [self.PostTable reloadData];
    
    [self retrieveFromParse ];
    
    
}

- (void) retrieveFromParse{
    PFQuery *retrievePosts = [PFQuery queryWithClassName:@"GlobalTimeline"];
    [retrievePosts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            PostArray = [[NSMutableArray alloc ] initWithArray:objects];
        }
        
        [self.PostTable reloadData];
        [_refreshControl endRefreshing];
    }];
    
}



//get number of sections in tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

//get number of rows by counting number of folders
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // NSLog(@"%lu", (unsigned long)PostArray.count);
    return PostArray.count;
}

//setup cells in tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //setup cell
    tempObject = [PostArray objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"mycell";
    
    cell = [tableView
            dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.Likebtn.tag = indexPath.row;
    cell.CommentBtn.tag = indexPath.row;
    [[cell Likebtn] addTarget:self action:@selector(LikeBTNUP:) forControlEvents:UIControlEventTouchUpInside];
    [[cell CommentBtn] addTarget:self action:@selector(commentBTNUP:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.NAME.text = [tempObject objectForKey:@"User"];
    cell.POST.text = [tempObject objectForKey:@"Post"];
    cell.IMG.image = [UIImage imageNamed:@"Default Profile.jpg"];
    numLikes = [[tempObject objectForKey:@"Likes"] intValue];
    cell.LikeText.text = [NSString stringWithFormat:@"%d", numLikes ];
    NSArray* array = [tempObject objectForKey:@"Comments"];
    numComments = array.count;
    cell.CommentBox.text = [NSString stringWithFormat:@"%ld", numComments ];
    
    
    return cell;
}

- (IBAction)LikeBTNUP:(id)sender {
    
    UIButton *LikeButton = (UIButton * )sender;
    PFObject *tmp = [PostArray objectAtIndex:LikeButton.tag];
    
    NSArray* tmp_Array = [tmp objectForKey:@"LikesID"] ;
    bool found = false;

    for(id item in tmp_Array)
    {
        if([item isEqualToString:[PFUser currentUser].username])
            found = true;
    }
    
    if(found == false){
        [tmp saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if(!error)
             {
                 [tmp incrementKey:@"Likes" byAmount:[NSNumber numberWithInt:1]];
                 [tmp addUniqueObject:[PFUser currentUser].username forKey:@"LikesID"];
                 [tmp saveInBackground];
                    [self.PostTable reloadData];
             cell.LikeText.text = [NSString stringWithFormat:@"%d", [[tmp objectForKey:@"Likes"] intValue]];
             }
         }];
    }
}


- (IBAction)commentBTNUP:(id)sender {
    
    //UIButton *CommentButton = (UIButton * )sender;
   // PFObject *tmp = [PostArray objectAtIndex:CommentButton.tag];
    NSLog(@"Commet button pressed");
    
   [self performSegueWithIdentifier:@"MySegue" sender:sender];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   //// if ([[segue identifier] isEqualToString:@"MySegue"])
   // {
        NSLog(@"It gets here");
        //if you need to pass data to the next controller do it here
        UIButton *CommentButton = (UIButton * )sender;
        PFObject *tmp = [PostArray objectAtIndex:CommentButton.tag];
        
        PostViewController *SecondController = segue.destinationViewController;
        SecondController.PARENT_NAME = [tmp objectForKey:@"User"];
        SecondController.PARENT_POST = [tmp objectForKey:@"Post"];
        
   // }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    
    [PostTable release];
    [super dealloc];
}
@end