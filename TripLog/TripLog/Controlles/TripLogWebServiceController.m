//
//  TripLogWebServiceController.m
//  TripLog
//
//  Created by Student17 on 6/6/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import "TripLogWebServiceController.h"

@implementation TripLogWebServiceController

static TripLogWebServiceController* webController;

+(id)sharedInstance{
    @synchronized(self){
        if (!webController) {
            webController = [[TripLogWebServiceController alloc] init];
        }
    }
    
    return webController;
}

-(instancetype)init{
    if(webController){
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    }
    else{
        self = [super init];
        if(self){
            webController = self;
        }
    }
    
    return webController;
}

-(void)sendSignInRequestToParseWithUsername:(NSString*)username andPassword:(NSString*)password{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *headers = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
                              @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo",
                              @"X-Parse-Revocable-Session":@"1"};
    
    [configuration setHTTPAdditionalHeaders:headers];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.parse.com/1/login?username=%@&password=%@", username, password]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if ([httpResponse statusCode] == 200) {
            User *current = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.loggedUser = current;
            
            [self.delegate userDidSignInSuccessfully:YES];
        }
        else {
            [self.delegate userDidSignInSuccessfully:NO];
        }
        
    }];
    
    [dataTask resume];
    
}

-(void)sendSignUpRequestToParseWithUsername:(NSString *)username password:(NSString *)pass andPhone:(NSString *)number{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.parse.com/1/users/"]];
    
    [request setHTTPMethod:@"POST"];
    
    // Set HTTP headers
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"1" forHTTPHeaderField:@"X-Parse-Revocable-Session"];
    
    NSDictionary *dict = @{@"username":username, @"password":pass, @"phone":number};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:jsonData];
   
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (!data)
         {
             [self.delegate userDidSignUpSuccessfully:NO];
             return;
         }
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
         NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
         
         if ([httpResponse statusCode] == 201) {
             NSLog(@"Registration successful!");
             [self.delegate userDidSignUpSuccessfully:YES];
         }
         else{
             NSLog(@"Registration failed!");
             [self.delegate userDidSignUpSuccessfully:NO];
         }
     }];
}



// POST TRIP

//-(void)uploadTestTrip{
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Trip"]];
//    
//    [request setHTTPMethod:@"POST"];
//    
//    // Set HTTP headers
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU" forHTTPHeaderField:@"X-Parse-Application-Id"];
//    [request setValue:@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
//    
//    NSDictionary *dict = @{@"Name":@"test1", @"Country":@"test country", @"City":@"test city"};
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
//    
//    [request setHTTPBody:jsonData];
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//     {
//         if (!data)
//         {
//             [self.delegate userDidSignUpSuccessfully:NO];
//             return;
//         }
//         
//         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//         NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//         
//         if ([httpResponse statusCode] == 201) {
//             NSLog(@"Registration successful!");
//             [self.delegate userDidSignUpSuccessfully:YES];
//         }
//         else{
//             NSLog(@"Registration failed!");
//             [self.delegate userDidSignUpSuccessfully:NO];
//         }
//     }];
//
//}


// GET TRIPS

//-(void)getTestTrip{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSDictionary *headers = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
//                              @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo"};
//
//    [configuration setHTTPAdditionalHeaders:headers];
//
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
//
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Trip"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//
//        if ([httpResponse statusCode] == 200) {
//           NSString *current = [NSString stringWithFormat:@"%@",[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
//            self.loggedUser = current;
//
//            [self.delegate userDidSignInSuccessfully:YES];
//        }
//        else {
//            [self.delegate userDidSignInSuccessfully:NO];
//        }
//
//    }];
//
//    [dataTask resume];
//}

//-(void)getTestTrip{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSDictionary *headers = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
//                              @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo"};
//
//    [configuration setHTTPAdditionalHeaders:headers];
//
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
//
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Trip"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//
//        if ([httpResponse statusCode] == 200) {
//           NSString *current = [NSString stringWithFormat:@"%@",[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
//            self.loggedUser = current;
//
//            [self.delegate userDidSignInSuccessfully:YES];
//        }
//        else {
//            [self.delegate userDidSignInSuccessfully:NO];
//        }
//
//    }];
//
//    [dataTask resume];
//}

-(void)getTestTripWithQuery{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *headers = @{@"X-Parse-Application-Id":@"t4rnGe5XRyz1owsyNOs8ZWITPS1Eo8tKzAUOeNTU",
                              @"X-Parse-REST-API-Key":@"r4WSZnlYMfSTD5VRWuMlvKQRdMZidX9acxec1mMo"};

    [configuration setHTTPAdditionalHeaders:headers];
    NSString *urlString = @"https://api.parse.com/1/classes/TripComment?where={\"Trip\": {\"__type\": \"Pointer\",\"className\": \"Trip\",\"objectId\": \"1J4y3aSCCP\"}}";
    NSString* urlString2 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    //NSString *encodedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)urlString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    

    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString2] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);

        if ([httpResponse statusCode] == 200) {
           NSString *current = [NSString stringWithFormat:@"%@",[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
            self.loggedUser = current;

            [self.delegate userDidSignInSuccessfully:YES];
        }
        else {
            [self.delegate userDidSignInSuccessfully:NO];
        }
    }];

    [dataTask resume];
}

-(NSString *)urlencode: (NSString*)url {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[url UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end