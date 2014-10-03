//
//  ViewController.m
//  HOMEO
//
//  Created by ビザンコムマック０７ on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/LanguageModelGenerator.h>

@interface ViewController ()<UIAlertViewDelegate>{
    //URLの変数
    NSURL *url;
    //画像のURLの文字列を格納するための変数
    NSString *imgurl;
    //ほめる言葉を格納するための配列
    NSArray *homeruarray;
    //メッセージを格納するための配列
    NSArray *messagearray;
    //ほめる言葉のローマ字列を格納するための配列
    NSArray *romanarray;
    //認識する言葉のモデルのパスを格納するための変数
    NSString *lmpath;
    //辞書ファイルのパスを格納するための変数
    NSString *dicpath;
    //音声認識するために使われる変数
    PocketsphinxController *controller;
    //OpenEarsにイベントに関する情報を受信するために使われる変数
    OpenEarsEventsObserver *observer;
    //アラートを表示するための変数
    UIAlertView *alert;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    self.activity.hidesWhenStopped = YES;
    self.kannyuu.hidden = YES;
    self.cansel.hidden = YES;
    //ラベルのフォントを設定
    self.message.font = [UIFont fontWithName:@"Courier-Bold" size:21];
    self.message.numberOfLines = 2;
    //apiを呼び出すURLの文字列を格納
    NSString *str = @"http://bjin.me/api/?type=rand&count=10&format=json";
    //strを元にNSURLを作成
    url = [NSURL URLWithString:str];
    //alertの初期化
    alert = [[UIAlertView alloc] initWithTitle:@"音声入力開始" message:@"話してください" delegate:self cancelButtonTitle:nil otherButtonTitles:@"キャンセル", nil];
    
    //配列の初期化
    homeruarray = [NSArray arrayWithObjects:@"いつも前向きに頑張ってるね",@"ほんとに面白い人だね",@"いつも、\nステキなファッションだね",@"頭のキレが早いよね",@"今日は\n時間とってくれてありがとう",@"目がきれいだね",@"いつもやさしいよね",@"いつも\nまわりのことよく見てるよね",@"笑顔が癒し系だね",nil];
    messagearray = [NSArray arrayWithObjects:@"そう?うれしいです",@"そんなこと言われると\n照れちゃいます",@"ありがとう、\nあなただって素敵よ", @"そう言ってくれるのはあなただけ...",@"君といっしょにいたら楽しそう",@"あなたが目の前にいるだけで\n私は満足",@"私をその気にさせないでよ",@"そんなあなたが嫌いじゃない",nil];
    romanarray = @[@"KIREI",@"UTUKUSII",@"SUKI",@"KAWAII",@"ANATA",@"KAMI",@"GA",@"WA",@"KIMI",@"YUUKO",@"FUKU",@"KAWAEE"];
    //言語モデルを生成
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    //エラー変数の生成
    NSError *err = [lmGenerator generateLanguageModelFromArray:romanarray
                                                withFilesNamed:@"languagemodel"
                                        forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    //エラーコードがnoErrでないか
    if([err code] != noErr) {
        //エラーの概要を説明する文章を表示
        NSLog(@"Error: %@",[err description]);
    } else {
        //errの付随情報を格納
        NSDictionary *languageGeneratorResults = [err userInfo];
        //キー「LMPath」の値を格納
        lmpath = languageGeneratorResults[@"LMPath"];
        //キー「DictionaryPath」の値を格納
        dicpath = languageGeneratorResults[@"DictionaryPath"];
        //変数の初期化
        controller = [[PocketsphinxController alloc] init];
        observer = [[OpenEarsEventsObserver alloc] init];
        //observerのデリゲートを自分自身に設定
        [observer setDelegate:self];
        //チェンジボタンを非表示
    }
    //アスペクト比を維持したまま、画像が表示されるように設定
    self.imageview.contentMode = UIViewContentModeScaleAspectFit;
    [super viewDidLoad];
    //スタートボタンを非表示
    self.startbutton.hidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
    [self show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//ランダムに画像を表示するメソッド
-(void)show{
    //チェンジボタンを非表示
    self.changebutton.hidden = YES;
    //インジケーターのアニメーションが停止していてimageviewが表示されているか
    if ((self.activity.hidesWhenStopped) && (!self.imageview.hidden)) {
        
        //imageviewを隠す
        self.imageview.hidden = YES;
        //メインキューの初期化
        dispatch_queue_t mainqueue = dispatch_get_main_queue();
        //グローバルキューの初期化
        dispatch_queue_t globalqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //インジケーターのアニメーションを開始
        [self.activity startAnimating];

        dispatch_async(globalqueue, ^{
            //バックグラウンドの処理
            //imagechoiceを呼ぶ
            [self imagechoice];
            dispatch_async(mainqueue, ^{
                //インジケーターのアニメーション停止
                [self.activity stopAnimating];
                //imageviewを表示
                self.imageview.hidden = NO;
                //スタートボタンを表示
                self.startbutton.hidden = NO;
                //dataをもとにimageviewに表示される画像を格納
                self.imageview.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgurl]]];
                //homeruarrayの中からランダムに選ばれた文字列を表示
                self.message.text = [homeruarray objectAtIndex:arc4random() % [homeruarray count]];
            });
        });
        self.message.text = @"画像が出るまで\nお待ちください";
        NSLog(@"メイン実行");
    }
}

//チェンジボタンを押したら呼ばれるメソッド
- (IBAction)change:(id)sender {
    //showメソッドを呼び出す
    [self show];
}

//スタートボタンを押したら呼ばれるメソッド
- (IBAction)start:(id)sender {
    //imageviewが表示されているか
    if (!self.imageview.hidden) {
        self.kannyuu.hidden = NO;
        //スタートボタンを非表示
        self.startbutton.hidden = YES;
        //キャンセルボタンを表示
        self.cansel.hidden = NO;
        //音声入力開始
        [controller startListeningWithLanguageModelAtPath:lmpath
                                         dictionaryAtPath:dicpath
                                      acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]
                                      languageModelIsJSGF:NO];
        
    }
}

//音声を検知したらよばれるメソッド
-(void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID{
    
    self.kannyuu.hidden = YES;
    self.cansel.hidden = YES;
    //チェンジボタンを表示
    self.changebutton.hidden = NO;
    //スタートボタンを非表示
    self.startbutton.hidden = YES;
    //messagearrayの中からランダムに選ばれた文字列を表示
    self.message.text = [messagearray objectAtIndex:arc4random() % [messagearray count]];
    //音声入力停止
    [controller stopListening];
}

//アラートのボタンを押したら呼ばれるメソッド
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //音声入力停止
    [controller stopListening];
}


//大きな容量の画像を取得するためのメソッド
-(void)imagechoice{
        //アプリの表示させるための画像のデータを調べるための変数
        NSData *imgdata;
        //urlからjsonに関するデータを格納
        NSData *data = [NSData dataWithContentsOfURL:url];
        //エラー変数の作成
        NSError *err = nil;
        //変数dataを元にJSONオブジェクト(今回はNSArray)を生成
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    //forループを開始
        for (int i = 0; i < [array count]; i++) {
            //arrayの中から辞書のデータを取り出しその中のキー「thumb」の値(画像のURL)を取り出す
            NSString *tmpurl = [[array objectAtIndex:arc4random() % [array count]] objectForKey:@"thumb"];
            //tmpurlから画像に関するデータを格納
            NSData *tmpdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmpurl]];
            //繰り返しが1回目であるかまたはimgdataの大きさがtmpdataより小さいか
            if ((i == 0) || (imgdata.length < tmpdata.length)) {
                //imgurlとimgdataの値を更新
                imgurl = tmpurl;
                imgdata = tmpdata;
            }
        }

}
- (IBAction)stop:(id)sender {
    self.cansel.hidden = YES;
    self.kannyuu.hidden = YES;
    //音声入力停止
    [controller stopListening];
    self.startbutton.hidden = NO;
    
}
@end
