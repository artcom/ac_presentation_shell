/*
 * Keynote.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class KeynoteItem, KeynoteApplication, KeynoteColor, KeynoteSlideshow, KeynoteWindow, KeynoteAttributeRun, KeynoteCharacter, KeynoteParagraph, KeynoteText, KeynoteAttachment, KeynoteWord, KeynoteAppTheme, KeynoteAppTransition, KeynoteDocTheme, KeynoteMasterSlide, KeynoteSlide, KeynoteSlideTransition, KeynotePrintSettings;

enum KeynoteSavo {
	KeynoteSavoAsk = 'ask ' /* Ask the user whether or not to save the file. */,
	KeynoteSavoNo = 'no  ' /* Do not save the file. */,
	KeynoteSavoYes = 'yes ' /* Save the file. */
};
typedef enum KeynoteSavo KeynoteSavo;

enum KeynoteKCct {
	KeynoteKCctArea_2d = 'are2' /* two-dimensional area chart. */,
	KeynoteKCctArea_3d = 'are3' /* three-dimensional area chart */,
	KeynoteKCctHorizontal_bar_2d = 'hbr2' /* two-dimensional horizontal bar chart */,
	KeynoteKCctHorizontal_bar_3d = 'hbr3' /* three-dimensional horizontal bar chart */,
	KeynoteKCctLine_2d = 'lin2' /*  two-dimensional line chart. */,
	KeynoteKCctLine_3d = 'lin3' /* three-dimensional line chart */,
	KeynoteKCctPie_2d = 'pie2' /* two-dimensional pie chart */,
	KeynoteKCctPie_3d = 'pie3' /* three-dimensional pie chart. */,
	KeynoteKCctScatterplot_2d = 'scp2' /* two-dimensional scatterplot chart */,
	KeynoteKCctStacked_area_2d = 'sar2' /* two-dimensional stacked area chart */,
	KeynoteKCctStacked_area_3d = 'sar3' /* three-dimensional stacked area chart */,
	KeynoteKCctStacked_horizontal_bar_2d = 'shb2' /* two-dimensional stacked horizontal bar chart */,
	KeynoteKCctStacked_horizontal_bar_3d = 'shb3' /* three-dimensional stacked horizontal bar chart */,
	KeynoteKCctStacked_vertical_bar_2d = 'svb2' /* two-dimensional stacked vertical bar chart */,
	KeynoteKCctStacked_vertical_bar_3d = 'svb3' /* three-dimensional stacked bar chart */,
	KeynoteKCctVertical_bar_2d = 'vbr2' /* two-dimensional vertical bar chart */,
	KeynoteKCctVertical_bar_3d = 'vbr3' /* three-dimensional vertical bar chart */
};
typedef enum KeynoteKCct KeynoteKCct;

enum KeynoteKCgb {
	KeynoteKCgbColumn = 'KCgc' /* group by column */,
	KeynoteKCgbRow = 'KCgr' /* group by row */
};
typedef enum KeynoteKCgb KeynoteKCgb;

enum KeynoteEnum {
	KeynoteEnumStandard = 'lwst' /* Standard PostScript error handling */,
	KeynoteEnumDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum KeynoteEnum KeynoteEnum;



/*
 * Standard Suite
 */

// A scriptable object.
@interface KeynoteItem : SBObject

@property (copy) NSDictionary *properties;  // All of the object's properties.

- (void) closeSaving:(KeynoteSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  // Save an object.
- (void) addChartColumnNames:(NSString *)columnNames data:(NSInteger)data groupBy:(KeynoteKCgb)groupBy rowNames:(NSString *)rowNames type:(KeynoteKCct)type;  // Add a chart to a slide
- (void) addFilePath:(NSString *)path;  // Add an image to a slide
- (void) advance;  // Advance one build or slide
- (void) makeImageSlidesPaths:(NSString *)paths master:(KeynoteMasterSlide *)master setTitles:(BOOL)setTitles;  // Make a series of slides from a list of image paths.  Returns a list of paths from which new slides could not be made.
- (void) pauseSlideshow;  // Pause the slideshow
- (void) resumeSlideshow;  // Resume the slideshow
- (void) showNext;  // Advance one build or slide
- (void) showPrevious;  // Go to the previous slide
- (void) start;  // Play an object.
- (void) startFrom;  // Play the containing slideshow starting with this object
- (void) stopSlideshow;  // Stop the slideshow

@end

// An application's top level scripting object.
@interface KeynoteApplication : SBApplication

- (SBElementArray *) slideshows;
- (SBElementArray *) windows;

@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *name;  // The name of the application.
@property (copy, readonly) NSString *version;  // The version of the application.

- (KeynoteSlideshow *) open:(NSURL *)x;  // Open an object.
- (void) print:(NSURL *)x printDialog:(BOOL)printDialog withProperties:(KeynotePrintSettings *)withProperties;  // Print an object.
- (void) quitSaving:(KeynoteSavo)saving;  // Quit an application.
- (void) acceptSlideSwitcher;  // Hide the slide switcher, going to the slide it has selected
- (void) cancelSlideSwitcher;  // Hide the slide switcher without changing slides
- (void) GetURL:(NSString *)x;  // Open and start the document at the given URL.  Must be a file URL.
- (void) moveSlideSwitcherBackward;  // Move the slide switcher backward one slide
- (void) moveSlideSwitcherForward;  // Move the slide switcher forward one slide
- (void) pause;  // Pause the slideshow
- (void) showSlideSwitcher;  // Show the slide switcher in play mode

@end

// A color.
@interface KeynoteColor : KeynoteItem


@end

// A document.
@interface KeynoteSlideshow : KeynoteItem

@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *name;  // The document's name.
@property (copy) NSString *path;  // The document's path.


@end

// A window.
@interface KeynoteWindow : KeynoteItem

@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (copy, readonly) KeynoteSlideshow *document;  // The document whose contents are being displayed in the window.
@property (readonly) BOOL floating;  // Whether the window floats.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property (readonly) BOOL miniaturizable;  // Whether the window can be miniaturized.
@property BOOL miniaturized;  // Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  // Whether the window is the application's current modal window.
@property (copy) NSString *name;  // The full title of the window.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property (readonly) BOOL titled;  // Whether the window has a title bar.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.


@end



/*
 * Text Suite
 */

// This subdivides the text into chunks that all have the same attributes.
@interface KeynoteAttributeRun : KeynoteItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into characters.
@interface KeynoteCharacter : KeynoteItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into paragraphs.
@interface KeynoteParagraph : KeynoteItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// Rich (styled) text
@interface KeynoteText : KeynoteItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) GetURL;  // Open and start the document at the given URL.  Must be a file URL.

@end

// Represents an inline text attachment.  This class is used mainly for make commands.
@interface KeynoteAttachment : KeynoteText

@property (copy) NSString *fileName;  // The path to the file for the attachment


@end

// This subdivides the text into words.
@interface KeynoteWord : KeynoteItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end



/*
 * Keynote Suite
 */

// Keynote's top level scripting object.
@interface KeynoteApplication (KeynoteSuite)

- (SBElementArray *) appThemes;
- (SBElementArray *) appTransitions;

@property BOOL frozen;  // Is Keynote frozen during playback?  When true, the show is playing but no motion occurs.
@property (readonly) BOOL playing;  // Is Keynote playing a show?
@property (readonly) BOOL slideSwitcherVisible;  // Is the slide selector visible?

@end

// The themes available to the appliction
@interface KeynoteAppTheme : KeynoteItem

- (NSInteger) id;  // The unique identifier of this slide.
@property (copy, readonly) NSString *name;  // The name of the theme, as it would appear in the theme chooser.


@end

// The transistions available for applying to a slide.
@interface KeynoteAppTransition : KeynoteItem

@property (copy, readonly) NSDictionary *attributes;  // Map of attribute names to potential values
@property (copy, readonly) NSString *name;  // The name of the transition.


@end

// A theme as applied to a document
@interface KeynoteDocTheme : KeynoteItem

- (SBElementArray *) masterSlides;


@end

// A master slide in a document's theme.
@interface KeynoteMasterSlide : KeynoteItem

- (SBElementArray *) slides;

- (NSInteger) id;  // The unique identifier of this slide.
@property (copy, readonly) NSString *name;  // The name of the master slide.


@end

// A slide in a slideshow
@interface KeynoteSlide : KeynoteItem

@property (copy) NSString *body;  // The body text of this slide.
- (NSInteger) id;  // The unique identifier of this slide.
@property (copy) KeynoteMasterSlide *master;  // The master of the slide.
@property (copy) NSString *notes;  // The speaker's notes for this slide.
@property BOOL skipped;  // Whether the slide is hidden.
@property (readonly) NSInteger slideNumber;  // index of the slide in the document
@property (copy) NSString *title;  // The title of this slide.
@property (copy, readonly) KeynoteSlideTransition *transition;  // The transition of the slide

- (void) jumpTo;  // Jump to the given slide
- (void) show;  // Show (or jump to) the recipient.

@end

// A slideshow
@interface KeynoteSlideshow (KeynoteSuite)

- (SBElementArray *) docThemes;
- (SBElementArray *) masterSlides;
- (SBElementArray *) slides;

@property (copy) KeynoteSlide *currentSlide;  // The slide that is currently selected.
@property (readonly) BOOL playing;  // Is Keynote playing the receiving document?

@end

// The transition of a slide
@interface KeynoteSlideTransition : KeynoteItem

@property (copy, readonly) NSDictionary *attributes;  // Map of attribute names to values
@property (copy) KeynoteAppTransition *type;  // The type of the transition


@end



/*
 * Type Definitions
 */

@interface KeynotePrintSettings : SBObject

@property NSInteger copies;  // the number of copies of a document to be printed
@property BOOL collating;  // Should printed copies be collated?
@property NSInteger startingPage;  // the first page of the document to be printed
@property NSInteger endingPage;  // the last page of the document to be printed
@property NSInteger pagesAcross;  // number of logical pages laid across a physical page
@property NSInteger pagesDown;  // number of logical pages laid out down a physical page
@property (copy) NSDate *requestedPrintTime;  // the time at which the desktop printer should print the document
@property KeynoteEnum errorHandling;  // how errors are handled
@property (copy) NSString *faxNumber;  // for fax number
@property (copy) NSString *targetPrinter;  // for target printer

- (void) closeSaving:(KeynoteSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  // Save an object.
- (void) addChartColumnNames:(NSString *)columnNames data:(NSInteger)data groupBy:(KeynoteKCgb)groupBy rowNames:(NSString *)rowNames type:(KeynoteKCct)type;  // Add a chart to a slide
- (void) addFilePath:(NSString *)path;  // Add an image to a slide
- (void) advance;  // Advance one build or slide
- (void) makeImageSlidesPaths:(NSString *)paths master:(KeynoteMasterSlide *)master setTitles:(BOOL)setTitles;  // Make a series of slides from a list of image paths.  Returns a list of paths from which new slides could not be made.
- (void) pauseSlideshow;  // Pause the slideshow
- (void) resumeSlideshow;  // Resume the slideshow
- (void) showNext;  // Advance one build or slide
- (void) showPrevious;  // Go to the previous slide
- (void) start;  // Play an object.
- (void) startFrom;  // Play the containing slideshow starting with this object
- (void) stopSlideshow;  // Stop the slideshow

@end

