#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // Set up allowed options
		  params.AddOption("string", "s", True, Params.AllowedOption.OptionTypes.String, "String Parameter")
		  params.AddOption("boolean", "b", True, Params.AllowedOption.OptionTypes.Boolean, "Boolean Parameter")
		  params.AddOption("integer", "i", True, Params.AllowedOption.OptionTypes.Integer, "Integer Parameter")
		  params.AddOption("float", "f", True, Params.AllowedOption.OptionTypes.Float, "Float Parameter")
		  params.AddOption("file", "", True, Params.AllowedOption.OptionTypes.File, "Required File Parameter with no option (requires that the file exists)")
		  params.AddOption("dir","d",False, Params.AllowedOption.OptionTypes.Folder, "Optional Folder parameter (requires that the folder exists)")
		  params.AddOption("path", "p", False, params.AllowedOption.OptionTypes.Path, "Optional Path parameter (doesn't require that the item exist)")
		  params.AddOption("flag", "x", False, Params.AllowedOption.OptionTypes.Flag, "Boolean flag parameter")
		  
		  // Any parameters that are specified AFTER the options are stored in Params.OtherItems()
		  If Not Params.ParseOptions(args) Then
		    Return 1
		  End If
		  
		  // Access options
		  // You can access options either by their long or short names regardless of what the user specified on the command-line
		  // params.Value("username") is equivalent to params.Value("u")
		  
		  Dim myString As String = params.Value("s")
		  Dim myBool As Boolean = params.Value("boolean")
		  
		  // For File, Folder and Path options, there are helper methods for parsing into a real FolderItem
		  Dim myfile As FolderItem = Params.GetFolderItem("file")
		End Function
	#tag EndEvent


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
