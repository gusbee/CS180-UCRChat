//
//  UIViewController+AddMultiPost.m
//  UCRChat
//
//  Created by user24887 on 11/23/14.
//  Copyright (c) 2014 me.gustavob. All rights reserved.
//

#import "AddMultiPost.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface AddMultiPost ()
@end


@implementation AddMultiPost

- (id)initWithCoder: (NSCoder *) aDecoder{
    
    if(self = [super initWithCoder:aDecoder]){
        _Photo = nil;
        _VideoPost = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.427 green:0.517 blue:0.705 alpha:1.0];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
}

- (void)dealloc {
    [_Photo release];
    [super dealloc];
}
- (IBAction)BackBTN:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SUMIT:(id)sender {
    
    //storng objcts to cloud
    PFObject *GlobalTimeline =  [PFObject objectWithClassName:@"GlobalTimeline"];
    if(_Photo.image != nil){
        //PFFile *send = [PFFile fileWithName:_Photo data:imageData];
        NSData* data = UIImageJPEGRepresentation(_Photo.image, 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    
        GlobalTimeline[@"MultimediaPost"] = imageFile;
        GlobalTimeline[@"User"] = [PFUser currentUser].username;
        GlobalTimeline[@"Likes"] = [NSNumber numberWithInt:0];
        GlobalTimeline[@"Dislikes"] = [NSNumber numberWithInt:0];
        GlobalTimeline[@"PhotoPost"] = [NSNumber numberWithBool:YES];
        GlobalTimeline[@"VideoPost"] = [NSNumber numberWithBool:NO];
        [GlobalTimeline saveInBackground];
    }
    if(_VideoPost != nil)
    {
        //PFFile *send = [PFFile fileWithName:_Photo data:imageData];
        NSData* videoData = [NSData dataWithContentsOfURL:_URL];
        PFFile *VideoFile = [PFFile fileWithName:@"video.mov" data: videoData];
        
        GlobalTimeline[@"MultimediaPost"] = VideoFile;
        GlobalTimeline[@"User"] = [PFUser currentUser].username;
        GlobalTimeline[@"Likes"] = [NSNumber numberWithInt:0];
        GlobalTimeline[@"Dislikes"] = [NSNumber numberWithInt:0];
        GlobalTimeline[@"PhotoPost"] = [NSNumber numberWithBool:YES];
        [GlobalTimeline saveInBackground];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)TakePic:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [NSArray arrayWithObjects:
                         (NSString *) kUTTypeImage,
                         (NSString *) kUTTypeMovie, nil];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)SelectPic:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [NSArray arrayWithObjects:
                         (NSString *) kUTTypeImage,
                         (NSString *) kUTTypeMovie, nil];
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType =
    [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        // Media is an image
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        _Photo.image = chosenImage;
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Media is a video
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        _VideoPost = [[MPMoviePlayerController alloc]initWithContentURL:url];
        _URL = url;
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
