# XojoConsoleOptionParser
A class for parsing command-line options in a xojo console app

For easy access, save this project as a binary project into the Project Templates folder next to your IDE.

## Usage
Initialize your parameters in the App.Run event using the Params.AddOption method. The parameters are:

1. Name as String – Long option name to be accessed with double dash (e.g. --file)
2. Letter as String – Short option letter to be accessed with single dash (e.g. -f)
3. Required as Boolean – whether or not the option is required for the app to run
4. Type as Params.AllowedOption.OptionTypes – specifies the type of data the parameter represents
5. Description as String – Description of the parameter for error display

Call Params.ParseOptions passing the args parameter supplied in App.Run. If one or more of the options are not satisfied, an error will be written to stderr and the method will return false.