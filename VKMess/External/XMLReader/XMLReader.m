//
//  XMLReader.m
//
//  Created by Troy on 9/18/10.
//  Copyright 2010 Troy Brant. All rights reserved.
//

#import "XMLReader.h"
#import "NSString+HTML.h"

NSString *const kXMLReaderTextNodeKey = @"node";

@interface XMLReader (Internal)

- (id)initWithError:(NSError **)error;
- (NSDictionary *)objectWithData:(NSData *)data;

@end


@implementation XMLReader

#pragma mark -
#pragma mark Public methods

+ (NSString*)convertEntities:(NSString*)string {
	NSString    *returnStr = nil;
    if( string )     {
        returnStr = [ string stringByReplacingOccurrencesOfString:@"&amp;" withString: @"&"  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#x27;" withString:@"'"  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#x39;" withString:@"'"  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#x92;" withString:@"'"  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#x96;" withString:@"'"  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"  ];
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"  ];
        returnStr = [ [ NSString alloc ] initWithString:returnStr ];
    }
    return returnStr;
}


+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data];
    [reader release];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:error];
}

+ (NSArray *)arrayForXMLString:(NSString *)string error:(NSError **)error {
    NSString *secureHeader = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>";
    NSString *cleanXML = [string stringByReplacingOccurrencesOfString:secureHeader withString:@""];
	NSDictionary *dict = [[self class] dictionaryForXMLString:cleanXML error:error];

	NSMutableDictionary *workDict = [dict mutableCopy];
	if ([[workDict objectForKey:@"response"] objectForKey:@"audio"]) {
		
		if ([[[workDict objectForKey:@"response"] objectForKey:@"audio"] isKindOfClass:[NSArray class]]) {
			NSMutableArray *audioInfo = [[workDict objectForKey:@"response"] objectForKey:@"audio"];
			for (int i = 0; i < [audioInfo count]; i++) {
				
				NSMutableDictionary *currentAudio = [audioInfo objectAtIndex:i];
				for (int i = 0; i < [[currentAudio allKeys] count]; i++) {
					NSString *key = [[currentAudio allKeys] objectAtIndex:i];
					id text = [currentAudio objectForKey:key];
					if ([text isKindOfClass:[NSDictionary class]]) {
						NSString *str = [text objectForKey:@"text"];
						NSString *str2 = [[str stringByReplacingOccurrencesOfString:@"\n  " withString:@""] stringByReplacingOccurrencesOfString:@"\n " withString:@""];
						NSString *cleanStr = str2;//[str2 escapedUnicode];
						
						if ([key isEqualToString:@"title"]) {
							NSString *cleanStr1 = [[self class] convertEntities:[cleanStr stringByConvertingHTMLToPlainText]];
							NSString *truncStr = nil;
							if ([cleanStr1 length] > 245) {
								truncStr = [cleanStr1 substringToIndex:245];
							} else {
								truncStr = cleanStr1;
							}
							[currentAudio setObject:[truncStr stringByReplacingOccurrencesOfString:@"/" withString:@"."] forKey:key];
						} else {
							if ([key isEqualToString:@"artist"]) {
								[currentAudio setObject:[[self class] convertEntities:[cleanStr stringByConvertingHTMLToPlainText]] forKey:key];
							} else { 
								[currentAudio setObject:cleanStr forKey:key];
							}
						} 
					}
				}
			}
			NSMutableArray *result = [[NSMutableArray alloc] initWithArray:[[workDict objectForKey:@"response"] objectForKey:@"audio"]];
			[workDict release];
			return [result autorelease];
		} else {
			NSMutableDictionary *currentAudio = [[workDict objectForKey:@"response"] objectForKey:@"audio"];
			for (int i = 0; i < [[currentAudio allKeys] count]; i++) {
				NSString *key = [[currentAudio allKeys] objectAtIndex:i];
				id text = [currentAudio objectForKey:key];
				if ([text isKindOfClass:[NSDictionary class]]) {
					NSString *str = [text objectForKey:@"text"];
					
					NSString *str2 = [[str stringByReplacingOccurrencesOfString:@"\n  " withString:@""] stringByReplacingOccurrencesOfString:@"\n " withString:@""];
					NSString *cleanStr = str2;//[str2 escapedUnicode];

					if ([key isEqualToString:@"title"]) {
						NSString *cleanStr1 = [[self class] convertEntities:[cleanStr stringByConvertingHTMLToPlainText]];
						NSString *truncStr = nil;
						if ([cleanStr1 length] > 245) {
							truncStr = [cleanStr1 substringToIndex:245];
						} else {
							truncStr = cleanStr1;
						}
						[currentAudio setObject:[truncStr stringByReplacingOccurrencesOfString:@"/" withString:@"."] forKey:key];
					} else {
						if ([key isEqualToString:@"artist"]) {
							[currentAudio setObject:[[self class] convertEntities:[cleanStr stringByConvertingHTMLToPlainText]] forKey:key];
						} else { 
							[currentAudio setObject:cleanStr forKey:key];
						}
					} 

					
					
				}
			}
			NSMutableArray *result = [[NSMutableArray alloc] init];
			[result addObject:[[workDict objectForKey:@"response"] objectForKey:@"audio"]];
			[workDict release];
			return [result autorelease];
		}
	} 
	[workDict release];
	return nil;
}

#pragma mark -
#pragma mark LastFM parsing

//Parse artist name

+ (NSString *)artistNameFromXMLString:(NSString *)xmlString {
	NSDictionary *result = [XMLReader dictionaryForXMLString:xmlString error:nil];
	NSString *findedArtist = nil;
	id lfm = [result objectForKey:@"lfm"];
	if ([lfm isKindOfClass:[NSDictionary class]]) {
		id results = [[result objectForKey:@"lfm"] objectForKey:@"results"];
		if ([results isKindOfClass:[NSDictionary class]]) {
			id query = [[[result objectForKey:@"lfm"] objectForKey:@"results"] objectForKey:@"Query"];
			
			if ([query isKindOfClass:[NSDictionary class]]) {
				findedArtist = [[[[result objectForKey:@"lfm"] objectForKey:@"results"] objectForKey:@"Query"] objectForKey:@"searchTerms"];
			}
			
		}
	}
	
	if (!findedArtist) {
		NSLog(@"Artist not found");
		return nil;
	} 
	return findedArtist;
} 

//Parse albums
+ (NSArray *)albumsFromXMLString:(NSString *)xmlString andArtistName:(NSString *)artistName {
	NSDictionary *result = [XMLReader dictionaryForXMLString:xmlString error:nil];
	NSArray *albumbs = [[[result objectForKey:@"lfm"] objectForKey:@"topalbums"] objectForKey:@"album"];
	if (![albumbs count]) {
		return nil;
	}
	
	if ([albumbs isKindOfClass:[NSDictionary class]]) {
		NSMutableArray *albumsResult = [NSMutableArray new];
		
		NSMutableDictionary *artistAlbum = [NSMutableDictionary new];
		
		NSDictionary *currentAlbum = (NSDictionary *)albumbs;
		
		//album mbid
		NSString *albumMbid = [[currentAlbum objectForKey:@"mbid"] objectForKey:@"text"];
		NSString *cleanMbidStr = [[albumMbid stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanMbidStr forKey:@"mbid"];
		
		//album name 
		NSString *albumName = [[currentAlbum objectForKey:@"name"] objectForKey:@"text"];
		NSString *cleanAlbumStr = [[albumName stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanAlbumStr forKey:@"album"];
		
		//album thumb
		NSDictionary *imageLinkDict = [[currentAlbum objectForKey:@"image"] objectAtIndex:3];
		NSString *cleanImgUrl = [[[imageLinkDict objectForKey:@"text"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanImgUrl forKey:@"thumb"];
		
		//album artist
		
		NSDictionary *artistDict = [[currentAlbum objectForKey:@"artist"] objectForKey:@"name"];
		NSString *cleanArtistStr = [[[artistDict objectForKey:@"text"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanArtistStr forKey:@"artist"];
		
		[albumsResult addObject:artistAlbum];
		
		[artistAlbum release];
		
		NSMutableArray *albums = [[[NSMutableArray alloc] init] autorelease];
		for (int i = 0; i < [albumsResult count]; i++) {
			NSDictionary *current = [albumsResult objectAtIndex:i];
			if ([[[current objectForKey:@"artist"] lowercaseString] isEqualToString:[artistName lowercaseString]]) {
				[albums addObject:[albumsResult objectAtIndex:i]];
			}
		}
		[albumsResult release];
		return albums;
	}
	
	
	NSMutableArray *albumsResult = [NSMutableArray new];
	
	for (int i = 0; i < [albumbs count]; i++) {
		NSMutableDictionary *artistAlbum = [NSMutableDictionary new];
		
		NSDictionary *currentAlbum = [albumbs objectAtIndex:i];
		
		//album mbid
		NSString *albumMbid = [[currentAlbum objectForKey:@"mbid"] objectForKey:@"text"];
		NSString *cleanMbidStr = [[albumMbid stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanMbidStr forKey:@"mbid"];
		
		//album name 
		NSString *albumName = [[currentAlbum objectForKey:@"name"] objectForKey:@"text"];
		NSString *cleanAlbumStr = [[albumName stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanAlbumStr forKey:@"album"];
		
		//album thumb
		NSDictionary *imageLinkDict = [[currentAlbum objectForKey:@"image"] objectAtIndex:3];
		NSString *cleanImgUrl = [[[imageLinkDict objectForKey:@"text"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanImgUrl forKey:@"thumb"];
		
		//album artist
		
		NSDictionary *artistDict = [[currentAlbum objectForKey:@"artist"] objectForKey:@"name"];
		NSString *cleanArtistStr = [[[artistDict objectForKey:@"text"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[artistAlbum setObject:cleanArtistStr forKey:@"artist"];
		
		[albumsResult addObject:artistAlbum];
		
		[artistAlbum release];
	}
	
	//Replace Various Artists and Various
	

	
	NSMutableArray *albums = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 0; i < [albumsResult count]; i++) {
		NSDictionary *current = [albumsResult objectAtIndex:i];
//		NSLog(@"current - %@", [current objectForKey:@"artist"]);
		if ([[[current objectForKey:@"artist"] lowercaseString] isEqualToString:[artistName lowercaseString]]) {
			[albums addObject:[albumsResult objectAtIndex:i]];
		}
//		if ((![ isEqualToString:@"Various Artists"]) && (![[current objectForKey:@"artist"] isEqualToString:@"Various"])) {
//			[albums addObject:[albumsResult objectAtIndex:i]];
//		} else {
//			NSLog(@"Various finded");
//		}
	}
	[albumsResult release];
	
	return albums;
}

//AlbumId parsing
+ (NSString *)idFromXMLString:(NSString *)xmlString {
	NSDictionary *result = [XMLReader dictionaryForXMLString:xmlString error:nil];
    NSDictionary *albumMatches = [[[result objectForKey:@"lfm"] objectForKey:@"results"] objectForKey:@"albummatches"];
    NSString *idToClean = [[[albumMatches objectForKey:@"album"] objectForKey:@"id"] objectForKey:@"text"];
    NSString *cleanId = [[idToClean stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return cleanId;
}

+ (NSArray *)songsFromAlbumXMLString:(NSString *)xmlString {
    NSDictionary *result = [XMLReader dictionaryForXMLString:xmlString error:nil];
    
    id songs = [[[[result objectForKey:@"lfm"] objectForKey:@"playlist"] objectForKey:@"trackList"] objectForKey:@"track"];
    if ([songs isKindOfClass:[NSArray class]]) {
        NSArray *songsArray = [[[[result objectForKey:@"lfm"] objectForKey:@"playlist"] objectForKey:@"trackList"] objectForKey:@"track"];
        if (![songsArray count]) {
            return nil;
        }
        
        NSMutableArray *cleanResult = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < [songsArray count]; i++) {
            NSMutableDictionary *result = [NSMutableDictionary new];
            NSDictionary *current = [songsArray objectAtIndex:i];
            NSString *creator = [[current objectForKey:@"creator"] objectForKey:@"text"];
            NSString *cleanCreator = [[creator stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *duration = [[current objectForKey:@"duration"] objectForKey:@"text"];
            NSString *cleanDuration = [[duration stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *title = [[current objectForKey:@"title"] objectForKey:@"text"];
            NSString *cleanTitle = [[title stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [result setObject:cleanCreator forKey:@"artist"];
            
            NSInteger durationValue = [cleanDuration intValue] / 1000.0;
            NSString *dur = [[NSString alloc] initWithFormat:@"%d", durationValue];
            [result setObject:dur forKey:@"duration"];
            [dur release];
            [result setObject:cleanTitle forKey:@"title"];
            [cleanResult addObject:result];
            [result release];
        }
        return cleanResult;
    } else {
        NSDictionary *oneAlbum = [[[[result objectForKey:@"lfm"] objectForKey:@"playlist"] objectForKey:@"trackList"] objectForKey:@"track"];
        
        NSMutableArray *cleanResult = [[[NSMutableArray alloc] init] autorelease];
        NSMutableDictionary *result = [NSMutableDictionary new];
        NSString *creator = [[oneAlbum objectForKey:@"creator"] objectForKey:@"text"];
        NSString *cleanCreator = [[creator stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *duration = [[oneAlbum objectForKey:@"duration"] objectForKey:@"text"];
        NSString *cleanDuration = [[duration stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *title = [[oneAlbum objectForKey:@"title"] objectForKey:@"text"];
        NSString *cleanTitle = [[title stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (cleanCreator == nil || cleanDuration == nil || cleanTitle == nil) {
            [cleanResult release];
            [result release];
            return nil;
        }
        
        [result setObject:cleanCreator forKey:@"artist"];
        
        NSInteger durationValue = [cleanDuration intValue] / 1000.0;
        NSString *dur = [[NSString alloc] initWithFormat:@"%d", durationValue];
        [result setObject:dur forKey:@"duration"];
        [dur release];
        
        [result setObject:cleanTitle forKey:@"title"];
        [cleanResult addObject:result];
        [result release];
        
        return cleanResult;
        
    }
    return nil;
}


//Chart Parsing
+ (NSArray *)chartSongsFromXMLString:(NSString *)xmlString {
    NSDictionary *result = [XMLReader dictionaryForXMLString:xmlString error:nil];
	
	id songs = [[[result objectForKey:@"lfm"] objectForKey:@"toptracks"] objectForKey:@"track"];
    if ([songs isKindOfClass:[NSArray class]]) {
		NSArray *songsArray = [[[result objectForKey:@"lfm"] objectForKey:@"toptracks"] objectForKey:@"track"];
        if (![songsArray count]) {
            return nil;
        }
		
		NSMutableArray *cleanResult = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < [songsArray count]; i++) {
            NSMutableDictionary *result = [NSMutableDictionary new];
            NSDictionary *current = [songsArray objectAtIndex:i];
			
            NSString *creator = [[[current objectForKey:@"artist"] objectForKey:@"name"] objectForKey:@"text"];
            NSString *cleanCreator = [[creator stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *duration = [[current objectForKey:@"duration"] objectForKey:@"text"];
            NSString *cleanDuration = [[duration stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *title = [[current objectForKey:@"name"] objectForKey:@"text"];
            NSString *cleanTitle = [[title stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [result setObject:cleanCreator forKey:@"artist"];
            [result setObject:cleanDuration forKey:@"duration"];
            [result setObject:cleanTitle forKey:@"title"];
            [cleanResult addObject:result];
            [result release];
        }
        return cleanResult;
	} else {
		NSDictionary *oneSong = [[[result objectForKey:@"lfm"] objectForKey:@"toptracks"] objectForKey:@"track"];
        
        NSMutableArray *cleanResult = [[[NSMutableArray alloc] init] autorelease];
        NSMutableDictionary *result = [NSMutableDictionary new];
        NSString *creator = [[[oneSong objectForKey:@"artist"] objectForKey:@"name"] objectForKey:@"text"];
        NSString *cleanCreator = [[creator stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *duration = [[oneSong objectForKey:@"duration"] objectForKey:@"text"];
        NSString *cleanDuration = [[duration stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *title = [[oneSong objectForKey:@"name"] objectForKey:@"text"];
        NSString *cleanTitle = [[title stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (cleanCreator == nil || cleanDuration == nil || cleanTitle == nil) {
            [cleanResult release];
            [result release];
            return nil;
        }
        
        [result setObject:cleanCreator forKey:@"artist"];
        [result setObject:cleanDuration forKey:@"duration"];
        [result setObject:cleanTitle forKey:@"title"];
        [cleanResult addObject:result];
        [result release];
        
        return cleanResult;
	}
	return nil;
}

#pragma mark -
#pragma mark Parsing

- (id)initWithError:(NSError **)error
{
    self = [super init];
    if (self)
    {
//        errorPointer = error;
    }
    return self;
}

- (void)dealloc
{
    [dictionaryStack release];
    [textInProgress release];
    [super dealloc];
}

- (NSDictionary *)objectWithData:(NSData *)data
{
    // Clear out any old data
    [dictionaryStack release];
    [textInProgress release];
    
    dictionaryStack = [[NSMutableArray alloc] init];
    textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    parser.delegate = self;
	[parser setShouldProcessNamespaces:YES];
    BOOL success = [parser parse];
    
    // Return the stack's root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [dictionaryStack lastObject];
    
    // Set the text property
    if ([textInProgress length] > 0)
    {
        [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];

        // Reset the text
        [textInProgress release];
        textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
//    *errorPointer = parseError;
}

@end
