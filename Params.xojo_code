#tag Module
Protected Module Params
	#tag Method, Flags = &h1
		Protected Sub AddOption(Name as String, Letter as String, Required as Boolean, Type as AllowedOption.OptionTypes, Description as string = "", StoreAsName as string = "")
		  AllowedOptions.Append(New AllowedOption(name,letter,Required,type,Description,StoreAsName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetAllowedOptionByName(name as string) As AllowedOption
		    if opt.LongOptionName = name or opt.ShortOptionLetter = name then
		  For i As Integer = 0 To UBound(AllowedOptions)
		    Dim opt As allowedOption = AllowedOptions(i)
		      Return opt
		    End If
		  Next
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetFolderitem(optionName as string) As FolderItem
		  If Options.HasKey(optionName) Then
		    Return ParsePath(params.value(optionName))
		  Else
		    Return Nil
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetLongArgName(argname as string) As String
		  For i As Integer = 0 To UBound(AllowedOptions)
		    // Shortcut in case we were sent a long name
		    If AllowedOptions(i).LongOptionName = argname Then
		      Return argname
		    End If
		    
		    // Use StrComp because "C" and "c" are considered different options
		    If StrComp(AllowedOptions(i).ShortOptionLetter, argname, 0) = 0 Then
		      Return AllowedOptions(i).LongOptionName
		    End If
		    
		  Next
		  
		  // We should never get here...
		  Raise New UnsupportedOperationException
		  
		  return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Attributes( Deprecated = "GetFolderItem" ) Protected Function GetPathForOption(name as string) As FolderItem
		  if Options.HasKey(name) then
		    return ParsePath(params.value(name))
		  else
		    return nil
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasKey(optionName as string) As Boolean
		  // First, make sure we're asking for the correct name
		  If Options.HasKey(optionName) Then
		    Return True
		  End If
		  
		  For i As Integer = 0 To UBound(AllowedOptions)
		    Dim opt As Params.AllowedOption = AllowedOptions(i)
		    If opt.LongOptionName = optionName And Options.HasKey(opt.ShortOptionLetter) Then
		      Return True
		    ElseIf strcomp(opt.ShortOptionLetter, optionName, 0) = 0 And Options.HasKey(opt.LongOptionName) Then
		      Return True
		    End If
		  Next
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Lookup(optionName as string, defaultvalue as variant) As variant
		  // First, make sure we're asking for the correct name
		  If Options.HasKey(optionName) Then
		    Return Options.value(optionName)
		  End If
		  
		  For i As Integer = 0 To UBound(AllowedOptions)
		    Dim opt As Params.AllowedOption = AllowedOptions(i)
		    If opt.LongOptionName = optionName And Options.HasKey(opt.ShortOptionLetter) Then
		      Return Params.value(opt.ShortOptionLetter)
		    ElseIf opt.ShortOptionLetter = optionName And Options.HasKey(opt.LongOptionName) Then
		      Return Params.value(opt.LongOptionName)
		    End If
		  Next
		  
		  Return defaultvalue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ParseOptions(args() as string, appDescription as string = "") As Boolean
		  // First, lets make sure there are no duplicates
		  Dim optionDuplicate As Boolean = False
		  For i As Integer = 0 To UBound(AllowedOptions) - 1
		    For j As Integer = i + 1 To UBound(AllowedOptions)
		      If AllowedOptions(i).ShortOptionLetter = AllowedOptions(j).ShortOptionLetter And AllowedOptions(i).ShortOptionLetter <> "" Then
		        stderr.WriteLine "Duplicate Short Option Definition: " + AllowedOptions(i).ShortOptionLetter + " on " + AllowedOptions(i).LongOptionName + " and " + AllowedOptions(j).LongOptionName
		        optionDuplicate = True
		      End If
		      If AllowedOptions(i).LongOptionName = AllowedOptions(j).LongOptionName And AllowedOptions(i).LongOptionName <> "" Then
		        stderr.WriteLine "Duplicate Long Option Definition: " + AllowedOptions(i).LongOptionName + " on " + AllowedOptions(i).ShortOptionLetter + " and " + AllowedOptions(j).ShortOptionLetter
		        optionDuplicate = True
		      End If
		    Next
		  Next
		  
		  If optionDuplicate Then
		    Return False
		  End If
		  
		  options = New Dictionary
		  
		  Dim errorMessages() As String
		  
		  For i As Integer = 1 To UBound(args)
		    Dim arg As String = args(i)
		    Dim opt As Params.allowedOption
		    
		    Select Case True
		    Case Left(arg,2) = "--"
		      // Deal with extended options
		      arg = Mid(arg,3)
		      
		      If Trim(arg) <> "" Then
		        Dim argName As String
		        Dim value As Variant
		        
		        If InStr(arg, "=") = 0 Then
		          argName = arg
		          
		        Else
		          Dim p As Integer = InStr(arg, "=")
		          If p>0 Then
		            argName = Left(arg,p-1)
		            value = Mid(arg,p+1)
		          Else
		            argName = arg
		            value = True
		          End If
		        End If
		        
		        // Match to allowed arguments
		        opt = GetAllowedOptionByName(argName)
		        If opt=Nil Then 
		          errorMessages.Append arg + " is not a supported option."
		          Continue For i
		        End If
		        
		        If opt.type <> AllowedOption.OptionTypes.Flag Then
		          If value = Nil Then
		            errorMessages.Append arg + " must be followed by ="
		          End If
		        Else
		          value = True
		        End If
		        
		        StoreOption(opt, value, errormessages)
		        
		      End If
		      
		    Case Left(arg,1) = "-"
		      arg = Mid(arg,2)
		      // Deal with the compounded boolean properties
		      // e.g. -zxvf, zxv are boolean while f has a parameter
		      For j As Integer = 1 To Len(arg)-1
		        Dim optname As String = Mid(arg,j,1)
		        opt = GetAllowedOptionByName(optname)
		        If opt = Nil Then
		          errorMessages.Append optname + " is not a supported option."
		          Continue For i
		        End If
		        
		        Options.value(opt.StoreAs) = True
		      Next
		      
		      Dim lastarg As String = Right(arg,1)
		      opt = GetAllowedOptionByName(lastarg)
		      If opt<>Nil Then
		        If opt.Type = AllowedOption.OptionTypes.Flag Then
		          Options.Value(opt.StoreAs) = True
		        ElseIf UBound(args) > i And (Left(args(i+1),1)<>"-" Or CountFields(args(i+1)," ") > 1) Then
		          Options.value(opt.StoreAs) = args(i+1)
		          i = i + 1
		        Else
		          stderr.WriteLine "Option " + lastarg + " requires a value."
		          Return False
		        End If
		      End If
		      
		    Case Else
		      // Anything that doesn't fall into the two cases above is probably a file
		      OtherItems.Append arg
		      
		    End Select
		  Next i
		  
		  // Now that everything's in, lets check to make sure the set is legal
		  Dim acceptedItems() As String
		  For i As Integer = 0 To UBound(AllowedOptions)
		    Dim opt As Params.allowedoption = AllowedOptions(i)
		    acceptedItems.Append opt.LongOptionName
		    acceptedItems.Append opt.ShortOptionLetter
		    If opt.Required Then
		      If Not Options.HasKey(opt.LongOptionName) And _
		        Not Options.HasKey(opt.ShortOptionLetter) Then
		        errorMessages.Append opt.OptionErrorMessage
		      End If
		    End If
		  Next
		  
		  // Check for options that are specified, but not used
		  Dim keys() As Variant = Options.keys
		  For i As Integer = 0 To UBound(keys)
		    If acceptedItems.IndexOf(keys(i).StringValue)=-1 Then
		      errorMessages.Append keys(i).StringValue + " is undefined and will be ignored."
		    End If
		  Next
		  
		  If UBound(errorMessages)>-1 Then
		    PrintUsage
		    stderr.WriteLine ""
		    stderr.WriteLine Join(errorMessages,EndOfLine)
		    Return False
		  End If
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParsePath(path as string) As FolderItem
		  Dim pth() As String = Split(path,kPathDelimiter)
		  
		  Dim f As FolderItem = SpecialFolder.CurrentWorkingDirectory
		  
		  Try
		    For i As Integer = 0 To UBound(pth)
		      // If we're looking at the first element on Windows, check to see if it's a volume
		      #If TargetWindows
		        If i = 0 And InStr(pth(0),":") = Len(pth(0)) Then
		          For vol As Integer = 0 To VolumeCount-1
		            Dim g As FolderItem = Volume(vol)
		            If g.Name = pth(0) Then
		              f = g
		              Continue For i
		            End If
		          Next
		        End If
		      #EndIf
		      
		      Select Case pth(i)
		      Case ""
		        #If TargetMacOS Or TargetLinux
		          If i=0 Then
		            f = GetFolderItem("/",FolderItem.PathTypeNative)
		          End If
		        #EndIf
		        
		      Case "." // same directory
		        
		      Case ".." // Parent Directory
		        f = f.Parent
		        
		      Case "~" // User Home
		        f = SpecialFolder.UserHome
		        
		      Case Else
		        f = f.Child(pth(i))
		        
		      End Select
		      
		      If f = Nil Then Exit
		    Next i
		    
		    Return f
		  Catch ex As NilObjectException
		    Return Nil
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub PrintUsage()
		  If Trim(Description) = "" Then
		    stderr.WriteLine Description
		  End If
		  stderr.WriteLine ""
		  Dim usage As String = "usage: " + app.ExecutableFile.Name.Replace(".debug", "")
		  
		  // add all of the parameters to the usage statement by type
		  Dim requireds() As String
		  Dim optionals() As String
		  For i As Integer = 0 To UBound(AllowedOptions)
		    Dim optname As String = "-" + AllowedOptions(i).ShortOptionLetter
		    If optname = "-" Then optname = "--" + AllowedOptions(i).LongOptionName
		    
		    Dim type As String
		    Select Case AllowedOptions(i).Type
		    Case AllowedOption.OptionTypes.Boolean
		      type = "boolean"
		      
		    Case AllowedOption.OptionTypes.File
		      type = "file"
		      
		    Case AllowedOption.OptionTypes.Flag
		      // No type, it's just a flag
		      
		    Case AllowedOption.OptionTypes.Float
		      type = "float"
		      
		    Case AllowedOption.OptionTypes.Folder
		      type = "folder"
		      
		    Case AllowedOption.OptionTypes.Integer
		      type = "integer"
		      
		    Case AllowedOption.OptionTypes.Path
		      type = "path"
		      
		    Case AllowedOption.OptionTypes.String
		      type = "string"
		      
		    End Select
		    
		    If Trim(type) <> "" Then
		      optname = Trim(optname + " (" + type + ")")
		    End If
		    
		    If AllowedOptions(i).Required Then
		      requireds.Append optname
		    Else
		      optionals.Append "[" + optname + "]"
		    End If
		  Next
		  
		  usage = usage + " " + Join(requireds, " ") + " " + Join(optionals, " ")
		  
		  stderr.WriteLine usage
		  
		  Dim names() As Params.PositionalItemHelp
		  
		  If UBound(names) > -1 Then
		    stderr.WriteLine ""
		    stderr.WriteLine "positional arguments:"
		    For i As Integer = 0 To UBound(names)
		      stderr.WriteLine "  " + names(i).Name + "  " + names(i).Description
		    Next
		  End If
		  
		  // Get the length of the longest option name
		  Dim longestLength As Integer = 0
		  For i As Integer = 0 To UBound(AllowedOptions)
		    longestLength = Max(longestLength,Len(AllowedOptions(i).LongOptionName))
		  Next
		  
		  Redim requireds(-1)
		  Redim optionals(-1)
		  For i As Integer = 0 To UBound(AllowedOptions)
		    If AllowedOptions(i).Required Then
		      requireds.append AllowedOptions(i).OptionUsageMessage(longestLength)
		    Else
		      optionals.append AllowedOptions(i).OptionUsageMessage(longestLength)
		    End If
		  Next
		  stderr.WriteLine ""
		  stderr.WriteLine "required arguments:"
		  For i As Integer = 0 To UBound(requireds)
		    stderr.WriteLine requireds(i)
		  Next
		  stderr.WriteLine ""
		  stderr.WriteLine "optional arguments:"
		  For i As Integer = 0 To UBound(optionals)
		    stderr.WriteLine optionals(i)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StoreOption(opt as allowedoption, value as Variant, byref errorMessages() as string)
		  
		  Select Case opt.Type
		  Case AllowedOption.OptionTypes.String
		    Options.value(opt.StoreAs()) = value.StringValue
		    
		  Case AllowedOption.OptionTypes.Integer
		    If IsNumeric(value) Then
		      Options.Value(opt.StoreAs()) = value.IntegerValue
		    Else
		      errorMessages.Append value.StringValue + " is not a number."
		    End If
		    
		  Case AllowedOption.OptionTypes.Float
		    If IsNumeric(value) Then
		      Options.Value(opt.StoreAs()) = value.DoubleValue
		    Else
		      errorMessages.Append value.StringValue + " is not a number."
		    End If
		    
		  Case AllowedOption.optiontypes.Boolean
		    Dim v As String = Left(value.StringValue,1)
		    Options.Value(opt.StoreAs()) = ( v = "T" Or v = "1" )
		    
		  Case AllowedOption.OptionTypes.Flag
		    Options.Value(opt.StoreAs()) = True
		    
		  Case AllowedOption.OptionTypes.path, AllowedOption.OptionTypes.File, AllowedOption.OptionTypes.Folder
		    // Check to see if it's actually a path
		    Dim f As FolderItem = ParsePath(value)
		    If f = Nil Then 
		      errormessages.append opt.LongOptionName + " is not a valid path" 
		    End If
		    
		    If f <> Nil Then
		      Dim mustexist As Boolean = opt.Type = AllowedOption.OptionTypes.File Or opt.type = AllowedOption.OptionTypes.Folder
		      If mustexist And Not f.Exists Then
		        errormessages.append opt.LongOptionName + " must exist"
		      End If
		      
		      Select Case opt.type
		      Case AllowedOption.OptionTypes.File
		        If f.Directory Then
		          errormessages.append opt.LongOptionName + " must be a file"
		        End If
		        
		      Case AllowedOption.OptionTypes.Folder
		        If Not f.Directory Then
		          errormessages.append opt.LongOptionName + " must be a folder"
		        End If
		        
		      End Select
		    End If
		    
		    Options.Value(opt.StoreAs()) = value.StringValue
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Value(name as string) As Variant
		  return Lookup(name,nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Value(Name as String, Assigns Value as Variant)
		  options.Value(name) = Value
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private AllowedOptions() As Params.AllowedOption
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			This Is a description Of what your app does, For use by the PrintUsage method
		#tag EndNote
		Description As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private options As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		OtherItems() As String
	#tag EndProperty


	#tag Constant, Name = kPathDelimiter, Type = String, Dynamic = False, Default = \"/", Scope = Private
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"\\"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Description"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
