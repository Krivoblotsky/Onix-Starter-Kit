//
//  XMLReader.h
//
//  Created by Troy on 9/18/10.
//  Copyright 2010 Troy Brant. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLReader : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
+ (NSArray *)arrayForXMLString:(NSString *)string error:(NSError **)errorPointer;

//LastFM
+ (NSString *)artistNameFromXMLString:(NSString *)xmlString;
+ (NSArray *)albumsFromXMLString:(NSString *)xmlString andArtistName:(NSString *)artistName;
+ (NSString *)idFromXMLString:(NSString *)xmlString;
+ (NSArray *)songsFromAlbumXMLString:(NSString *)xmlString;
+ (NSArray *)chartSongsFromXMLString:(NSString *)xmlString;

+ (NSString*)convertEntities:(NSString*)string;

@end
