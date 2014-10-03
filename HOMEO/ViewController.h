//
//  ViewController.h
//  HOMEO
//
//  Created by ビザンコムマック０７ on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//







#import <UIKit/UIKit.h>
#import <OpenEars/OpenEarsEventsObserver.h>
@interface ViewController : UIViewController<OpenEarsEventsObserverDelegate>
//美女の画像を表示させるためのプロパティ
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
//読み上げる文章とメッセージを表示させるためのラベル
@property (weak, nonatomic) IBOutlet UILabel *message;
//チェンジボタンを押したら呼ばれるメソッド
- (IBAction)change:(id)sender;
//スタートボタンを押したら呼ばれるメソッド
- (IBAction)start:(id)sender;
//スタートボタンのプロパティ
@property (weak, nonatomic) IBOutlet UIButton *startbutton;
//チェンジボタンのプロパティ
@property (weak, nonatomic) IBOutlet UIButton *changebutton;
//画像を待ち画面
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
//話してくださいと表示するラベル
@property (weak, nonatomic) IBOutlet UILabel *kannyuu;
//キャンセルボタンのプロパティ
@property (weak, nonatomic) IBOutlet UIButton *cansel;
//キャンセルボタンを押したら呼ばれるメソッド
- (IBAction)stop:(id)sender;

@end
