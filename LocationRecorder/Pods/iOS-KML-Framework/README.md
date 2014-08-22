[![Version](http://cocoapod-badges.herokuapp.com/v/iOS-KML-Framework/badge.png)](http://cocoadocs.org/docsets/iOS-KML-Framework)
[![Platform](http://cocoapod-badges.herokuapp.com/p/iOS-KML-Framework/badge.png)](http://cocoadocs.org/docsets/iOS-KML-Framework)

[![License](http://img.shields.io/:license-mit-blue.svg)](http://opensource.org/licenses/mit-license.php)
[![Build](https://travis-ci.org/Pierre-Loup/iOS-GPX-Framework.svg)](https://travis-ci.org/Pierre-Loup/iOS-GPX-Framework)
 
iOS KML Framework 
============================

This is a iOS framework for parsing/generating KML files.
This Framework parses the KML from a URL or Strings and create Objective-C Instances of KML structure. 

Fork infos
---------------------------------
This fork is the "iOS-KML-Framework" pod's source repo.


Installation
---------------------------------

iOS-KML-Framework is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```ruby
platform :ios, '5.1'
pod 'iOS-GPX-Framework', "~> 0.0"
```

## Usage

```objc
#import "KML.h"

// Parsing the KML

KMLRoot *root = [KMLParser parseKMLWithString:kml];


// Generating the KML

KMLRoot *root = [KMLRoot new];

KMLDocument *doc = [KMLDocument new];
root.feature = doc;

KMLPlacemark *placemark = [KMLPlacemark new];
placemark.name = @"Simple placemark";
placemark.descriptionValue = @"Attached to the ground.";
[doc addFeature:placemark];

KMLPoint *point = [KMLPoint new];
placemark.geometry = point;

KMLCoordinate *coordinate = [KMLCoordinate new];
coordinate.latitude = 37.422f;
coordinate.longitude = -122.082f;
point.coordinate = coordinate;
```

## Requirements

- iOS 6.0 or later

## Author

Watanabe Toshinori, t@flcl.jp

## License

iOS-KML-Framework is available under the MIT license. See the LICENSE file for more info.

it uses [TBXML](http://tbxml.co.uk/TBXML/TBXML_Free.html) Copyright (c) 2009 Tom Bradley
