

#import "FingerViewController.h"

@interface FingerViewController () {
    int saveCount;
}


@end

@implementation FingerViewController
@synthesize callbackId = _callbackId;

VeridiumExportService* exportService;
VeridiumBiometrics4FConfig* exportConfig;
VeridiumTemplateFormat exportFormat = FORMAT_JSON;

VeridiumThumbMode thumbMode = ThumbNone;
static int const kThumbRightCode = 1;
static int const kThumbLeftCode = 6;

static int const kLeftHand = 2;
static int const kRightHand = 3;

+ (instancetype)sharedHelper:(NSString *)callbackid
{

    static FingerViewController *sharedClass = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
        sharedClass.callbackId = callbackid;
    });

    return sharedClass;
}

-(void)startConfig{
    // Fill in your license key here.
    VeridiumLicenseStatus* sdkStatus = [VeridiumSDK setup:@"yV8KKLqN+opTmyV/phKuTVAO/Fo7Pj4YrdpmCMU1ZWMB8W2ETucpSCqrfFLYFUMS5eT0ewS7+CBSqD9Ce94SA3siZGV2aWNlRmluZ2VycHJpbnQiOiJINzAxcndVaVRRM09NSDJLRWsva1N6MUhEVjIvNmwwVnVXVzRBUFNlVDRnPSIsImxpY2Vuc2UiOiIraE4rU0JIaWZWRGt0VU1sdHo3VHc0RURBZkZnUkhUOUpXODJvS2dtbkdPb0srQjhCK2I0SkNKajZ2T05Ld1lxTjV5MFlLaHgzZUhJeHRPV0VmVzdCbnNpZEhsd1pTSTZJbE5FU3lJc0ltNWhiV1VpT2lKVFJFc2lMQ0pzWVhOMFRXOWthV1pwWldRaU9qRTJNakE0TkRBME5UVXNJbU52YlhCaGJubE9ZVzFsSWpvaVNXNXpiMngxZEdsdmJuTWdSVzUwWld3aUxDSmpiMjUwWVdOMFNXNW1ieUk2SWpSR1JWWTBJR2xQVXk5QmJtUnliMmxrSUdOdmJTNWxiblJsYkM1dGIzWnBiQzVoZFhSdllXTjBhWFpoWTJsdmJpSXNJbU52Ym5SaFkzUkZiV0ZwYkNJNkltMXBaM1ZsYkM1b1pYSnVZVzVrWlhwQWFXNXpiMngxZEdsdmJuTXVjR1VpTENKemRXSk1hV05sYm5OcGJtZFFkV0pzYVdOTFpYa2lPaUlyT1V4NVF6QkJaRWx5WkZrcmMxWk1RbEV3WkRFMVkzaHpkSEJEZWxrdlJIZDVOVmxUYVZBclZHUlZQU0lzSW5OMFlYSjBSR0YwWlNJNk1UWXhPVFE1TmpBd01Dd2laWGh3YVhKaGRHbHZia1JoZEdVaU9qRTJOVEkyTnpNMk1EQXNJbWR5WVdObFJXNWtSR0YwWlNJNk1UWTFNamcwTmpRd01Dd2lkWE5wYm1kVFFVMU1WRzlyWlc0aU9tWmhiSE5sTENKMWMybHVaMFp5WldWU1FVUkpWVk1pT21aaGJITmxMQ0oxYzJsdVowRmpkR2wyWlVScGNtVmpkRzl5ZVNJNlptRnNjMlVzSW1KcGIyeHBZa1poWTJWRmVIQnZjblJGYm1GaWJHVmtJanBtWVd4elpTd2ljblZ1ZEdsdFpVVnVkbWx5YjI1dFpXNTBJanA3SW5ObGNuWmxjaUk2Wm1Gc2MyVXNJbVJsZG1salpWUnBaV1FpT21aaGJITmxmU3dpWlc1bWIzSmpaU0k2ZXlKd1lXTnJZV2RsVG1GdFpYTWlPbHNpWTI5dExtVnVkR1ZzTG0xdmRtbHNMbUYxZEc5aFkzUnBkbUZqYVc5dUlsMHNJbk5sY25abGNrTmxjblJJWVhOb1pYTWlPbHRkZlgwPSJ9"];


    // Check the result of the license system
    if(!sdkStatus.initSuccess){
        [VeridiumUtils alert: @"Your SDK license is invalid" title:@"Licence"];
        return ;
    }

    if(sdkStatus.isInGracePeriod) {
        [VeridiumUtils alert: @"Your SDK license will expire soon. Please contact your administrator for a new license." title:@"Licence"];
    }

    // Fill in your 4F TouchlessID license key here.
    VeridiumLicenseStatus* touchlessIDStatus = [VeridiumSDK.sharedSDK setupTouchlessID:@"ZNL1Dg58PylfXtzxYDmB7SbC8foW6HXWx5TMt7hQXggL3Hr3/ZJK7AZXwXiN5G7V54wOVJzf55BF/Lh/OzVdAHsiZGV2aWNlRmluZ2VycHJpbnQiOiJINzAxcndVaVRRM09NSDJLRWsva1N6MUhEVjIvNmwwVnVXVzRBUFNlVDRnPSIsImxpY2Vuc2UiOiJFS3hXYjJlZ0NIRHlUOWRObTE1bnRyWVg4b0NaNU5xY1J3cEFaWXFXV0VtOUppYWFCRDQ5NzF6OG9MTVB6SUZrU2oxWmpVcWp5SDRyY3BjZWx4RVRESHNpZEhsd1pTSTZJa0pKVDB4SlFsTWlMQ0p1WVcxbElqb2lORVlpTENKc1lYTjBUVzlrYVdacFpXUWlPakUyTWpBNE5EQTBOVFV4TlRRc0ltTnZiWEJoYm5sT1lXMWxJam9pU1c1emIyeDFkR2x2Ym5NZ1JXNTBaV3dpTENKamIyNTBZV04wU1c1bWJ5STZJalJHUlZZMElHbFBVeTlCYm1SeWIybGtJR052YlM1bGJuUmxiQzV0YjNacGJDNWhkWFJ2WVdOMGFYWmhZMmx2YmlJc0ltTnZiblJoWTNSRmJXRnBiQ0k2SW0xcFozVmxiQzVvWlhKdVlXNWtaWHBBYVc1emIyeDFkR2x2Ym5NdWNHVWlMQ0p6ZFdKTWFXTmxibk5wYm1kUWRXSnNhV05MWlhraU9pSXJPVXg1UXpCQlpFbHlaRmtyYzFaTVFsRXdaREUxWTNoemRIQkRlbGt2UkhkNU5WbFRhVkFyVkdSVlBTSXNJbk4wWVhKMFJHRjBaU0k2TVRZeE9UUTVOakF3TURBd01Dd2laWGh3YVhKaGRHbHZia1JoZEdVaU9qRTJOVEkyTnpNMk1EQXdNREFzSW1keVlXTmxSVzVrUkdGMFpTSTZNVFkxTWpnME5qUXdNREF3TUN3aWRYTnBibWRUUVUxTVZHOXJaVzRpT21aaGJITmxMQ0oxYzJsdVowWnlaV1ZTUVVSSlZWTWlPbVpoYkhObExDSjFjMmx1WjBGamRHbDJaVVJwY21WamRHOXllU0k2Wm1Gc2MyVXNJbUpwYjJ4cFlrWmhZMlZGZUhCdmNuUkZibUZpYkdWa0lqcG1ZV3h6WlN3aWNuVnVkR2x0WlVWdWRtbHliMjV0Wlc1MElqcDdJbk5sY25abGNpSTZabUZzYzJVc0ltUmxkbWxqWlZScFpXUWlPbVpoYkhObGZTd2labVZoZEhWeVpYTWlPbnNpWW1GelpTSTZkSEoxWlN3aWMzUmxjbVZ2VEdsMlpXNWxjM01pT25SeWRXVXNJbVY0Y0c5eWRDSTZkSEoxWlgwc0ltVnVabTl5WTJWa1VISmxabVZ5Wlc1alpYTWlPbnNpYldGdVpHRjBiM0o1VEdsMlpXNWxjM01pT21aaGJITmxmU3dpZG1WeWMybHZiaUk2SWpRdUtpSjkifQ=="];

    if(!touchlessIDStatus.initSuccess){
        [VeridiumUtils alert: @"Your TouchlessID license is invalid" title:@"Licence"];
        return ;
    }

    if(touchlessIDStatus.isInGracePeriod) {
        [VeridiumUtils alert: @"Your TouchlessID license will expire soon. Please contact your administrator for a new license." title:@"Licence"];
    }


    [VeridiumSDK.sharedSDK registerDefault4FExporter]; // Alternatively use [VeridiumSDK.sharedSDK registerCustom4FExporter]; if working from a custom ui.
}

- (void)viewDidLoad {
    [super viewDidLoad];

    exportService =  [[VeridiumExportService alloc] init];
    exportConfig = [VeridiumBiometrics4FConfig new];

    self->saveCount = 0;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)showThumbScanWithHand:(int)handCode{
    exportConfig.individualThumb = false;
    exportConfig.individualIndex = true;
    exportConfig.individualMiddle = true;
    exportConfig.individualRing = true;
    exportConfig.individualLittle = true;
    exportConfig.individualCapture = true;
    exportConfig.chosenHand = handCode;
}

- (void)onExportFingerWithLeftCode:(int)leftCode andRightCode:(int)rightCode {

    [self startConfig];

    self.leftCodeFinger = leftCode;
    self.rightCodeFinger = rightCode;

    //Initialize class
    exportService =  [[VeridiumExportService alloc] init];
    exportConfig = [VeridiumBiometrics4FConfig new];

    if (rightCode == kThumbRightCode) {
        [self showThumbScanWithHand:kRightHand];
        [self commonExport:NO withTargetIndex:NO andTargetLittle:NO];
    }else if (leftCode == kThumbLeftCode){
        [self showThumbScanWithHand:kLeftHand];
        [self commonExport:NO withTargetIndex:NO andTargetLittle:NO];
    }else{
        exportConfig.chosenHand = Veridium4FAnalyzeHandDefaultRight;
        exportConfig.individualCapture = false;
        [self commonExport:NO withTargetIndex:YES andTargetLittle:NO];
    }
}



-(void)commonExport:(bool)record8F withTargetIndex:(bool)target_index andTargetLittle:(bool)target_little {
  NSLog(@" format : %lu record8F %s", (unsigned long)exportFormat, record8F ? "true":"false");

    thumbMode = ThumbNone;
    exportConfig.record8F = record8F;
    exportConfig.exportFormat = FORMAT_JSON;
    exportConfig.targetIndexFinger = target_index;
    exportConfig.targetLittleFinger = target_index && target_little;
    exportConfig.wsq_compression_ratio = COMPRESS_10to1;
    exportConfig.pack_debug_data = NO;
    exportConfig.calculate_nfiq = NO;
    exportConfig.background_remove = YES;
    exportConfig.twoShotLiveness = NO;
    exportConfig.extra_scaled_image = YES;
    exportConfig.fixed_print_width = 0;
    exportConfig.fixed_print_height = 0;
    exportConfig.pack_audit_image = YES;
    exportConfig.reliability_mask = NO;
//    exportConfig.padding_width = 500;
//    exportConfig.padding_height = 500;
    exportConfig.keepResource = NO;
    exportConfig.captureThumb = ThumbNone;
    exportConfig.nist_type = Nist_type_T14_9;

    [VeridiumBiometrics4FService exportTemplate:exportConfig
                         onSuccess:^(VeridiumBiometricVector * _Nonnull biometricVector) {
                             // Generate a file path in which to save the fingerprints.
//                             NSString* basefilename = @"fingerprints_";

                             NSDictionary * arr = [NSJSONSerialization JSONObjectWithData:biometricVector.biometricData options:NSJSONReadingMutableContainers error:nil];

                             NSArray* fingerPrints = [[arr objectForKey:@"SCALE085"] objectForKey:@"Fingerprints"];

                             int bestFinger = 0;
                             for (NSDictionary* finger in fingerPrints) {
                                 int positionCode = [[finger objectForKey:@"FingerPositionCode"] intValue];
                                 if (positionCode == self.leftCodeFinger || positionCode == self.rightCodeFinger) {
                                     break;
                                 }
                                 bestFinger++;
                             }

                             int fingerPositionCode = [[[fingerPrints objectAtIndex:bestFinger] objectForKey:@"FingerPositionCode"] intValue];
                             NSString * wsq = [[[fingerPrints objectAtIndex:bestFinger] objectForKey:@"FingerImpressionImage"] objectForKey:@"BinaryBase64ObjectWSQ"];

                             NSString * hand;
                             if (fingerPositionCode == self.leftCodeFinger) {
                                 hand = @"LEFT";
                             }else if (fingerPositionCode == self.rightCodeFinger){
                                 hand = @"RIGHT";
                             }

                            NSMutableDictionary * dict = [NSMutableDictionary new];
                            [dict setObject:wsq forKey:@"wsq"];
                            [dict setObject:hand forKey:@"hand"];
                            NSLog(@"Successful export");

                            [EntelFingerPlugin.entelFingerPlugin sendResponseFingerDict:dict callbackId:self.callbackId];
                        } onFail:^(NSString * _Nullable message) {
                            [EntelFingerPlugin.entelFingerPlugin sendResponseFinger:@"FAIL" callbackId:self.callbackId];
                        } onCancel:^{
                            [EntelFingerPlugin.entelFingerPlugin sendResponseFinger:@"CANCEL" callbackId:self.callbackId];
                        } onError:^(NSString * _Nullable message) {
                            [EntelFingerPlugin.entelFingerPlugin sendResponseFinger:@"ERROR" callbackId:self.callbackId];
                        }];
}



@end
