# XojoConsoleOptionParser
A class for parsing command-line options in a xojo console app

For easy access, save this project as a binary project into the Project Templates folder next to your IDE or into the global Project Templates folder found here:

macOS/Linux: ~/Documents/Xojo/IDE/Project Templates<br>
Windows    : %HOME%\Documents\Xojo\IDE\Project Templates

## Usage
Initialize your parameters in the App.Run event using the Params.AddOption method. The parameters are:

1. Name as String – Long option name to be accessed with double dash (e.g. --file)
2. Letter as String – Short option letter to be accessed with single dash (e.g. -f)
3. Required as Boolean – whether or not the option is required for the app to run
4. Type as Params.AllowedOption.OptionTypes – specifies the type of data the parameter represents
5. Description as String – Description of the parameter for error display

Call Params.ParseOptions passing the args parameter supplied in App.Run. If one or more of the options are not satisfied, an error will be written to stderr and the method will return false.

## Signal Handling

Option parser includes a signal handler for interrupting signals on Linux and macOS.

## SystemD

Includes a way to hook into SystemD so Linux apps can be run as a daemon.

## ColorStream

An ANSI Color stream writer for color output in your app logs. To use, create a class which implements the Writable interface and pass it to a new instance of ColorStream.

```Xojo
Var tos as TextOutputStream = TextOutputStream.Create(myLogFile)
Var stream as New ColorStream(tos)
stream.TextColor = &cFF0000
stream.writeline "Hello World!"
```

ANSI color contains 15 base colors made from full (FF) and half (80) variants of colors and 24 shades of gray. All other colors are converted to the closest color in the 6x6x6 grid, resulting in 255 different possible colors. Where compatibility allows, the class also supports Bold, Italic, Underline, Blink and Hidden text as well as absolute and relative cursor positioning.