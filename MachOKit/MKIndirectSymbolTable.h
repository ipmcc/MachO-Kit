//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKIndirectSymbolTable.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#include <MachOKit/macho.h>
@import Foundation;

#import <MachOKit/MKLinkEditNode.h>

@class MKMachOImage;

//----------------------------------------------------------------------------//
//! The \c MKIndirectSymbolTable class parses the entries in the indirect
//! symbol table, which are simply indexes into the symbol table.
//! The sections that contain "symbol pointers" and "routine stubs" have
//! indexes and (implied counts based on the size of the section and fixed
//! size of the entry) into the "indirect symbol" table for each pointer
//! and stub.
//
@interface MKIndirectSymbolTable : MKLinkEditNode {
@package
    NSArray *_symbols;
}

//! Initializes the receiver with the provided \ref MKMachOImage.
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error;

//! An array of \ref MKIndirectSymbol instances, each representing an entry
//! in the indirect symbol table.  The order of this array matches the
//! ordering of the entries in the indirect symbol table in the Mach-O image.
@property (nonatomic, readonly) NSArray /*MKIndirectSymbol*/ *symbols;

@end
