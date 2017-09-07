# ShopSearch

[![CI Status](http://img.shields.io/travis/Ricardo Koch/ShopSearch.svg?style=flat)](https://travis-ci.org/Ricardo Koch/ShopSearch)
[![Version](https://img.shields.io/cocoapods/v/ShopSearch.svg?style=flat)](http://cocoapods.org/pods/ShopSearch)
[![License](https://img.shields.io/cocoapods/l/ShopSearch.svg?style=flat)](http://cocoapods.org/pods/ShopSearch)
[![Platform](https://img.shields.io/cocoapods/p/ShopSearch.svg?style=flat)](http://cocoapods.org/pods/ShopSearch)

## Usage

ShopSearch shared instance public methods

Search for any product containing the provided keywords
```
public func search(keywords words:String, completionBlock: @escaping ShopSearchCallback)
```

Fetch full product details with the provided product id
```
public func fetchProduct(_ productId:String, completionBlock: @escaping ShopProductCallback)
```

Fetch specifications for a product
```
public func fetchSpecs(_ productId:String, completionBlock: @escaping ShopSpecsCallback)
```

Get a sorted list of all product cagetories available
```
public func getSortedCategories() -> [GoogleCategory]?
```

Get a sorted list of all categories from a specific parent
```
public func getSortedCategories(_ parentId:String) -> [GoogleCategory]?
```

Get a category object with the provided category id
```
public func getCategoryById(categoryId: String) -> GoogleCategory?
```

Get the category's bread crumb navigation path from a category id
```
public func getCategoryPath(categoryId: String) -> String
```

## Requirements

## Installation

ShopSearch is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ShopSearch"
```

## Author

Ricardo Koch, ricardo@ricardokoch.com

## License

ShopSearch is available under the MIT license. See the LICENSE file for more info.

## Description

Cocoapods component for searching and scraping all google shopping catalog.
Easily integrate with any iOS app to get products information, compare prices and much more.

## How to Use

TBD

```ruby
TBD
```
