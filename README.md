# TextTransformer: an ExtensionKit sample app

This year's WWDC introduced many new APIs, two of which caught my attention: ExtensionFoundation and ExtensionKit.

We've been able to develop extensions for Apple's apps and operating systems for a while, but Apple never offered a native way for third-party apps to provide custom extension points that other apps can take advantage of.

With ExtensionFoundation and ExtensionKit on macOS, now we can.

However, Apple's documentation lacks crucial information on how to use these new APIs (`FB10140097`), and there were no WWDC sessions or sample code available in the weeks following the keynote.

Thanks to some trial and error, and some help from other developers, I was able to put together this sample code, demonstrating how one can use ExtensionFoundation/ExtensionKit to define custom extension points for their Mac apps. 
