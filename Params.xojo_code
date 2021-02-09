#tag Module
Protected Module Params
	#tag Method, Flags = &h1
		Protected Sub AddOption(Name as String, Letter as String, Required as Boolean, Type as AllowedOption.OptionTypes, Description as string = "", StoreAsName as string = "")
		  AllowedOptions.Append(new AllowedOption(name,letter,Required,type,Description,StoreAsName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetAllowedOptionByName(name as string) As AllowedOption
		  for i as integer = 0 to UBound(AllowedOptions)
		    dim opt as allowedOption = AllowedOptions(i)
		    if opt.LongOptionName = name or opt.ShortOptionLetter = name then
		      return opt
		    end if
		  next
		  
		  return nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetFolderitem(optionName as string) As FolderItem
		  If Options.HasKey(optionName) Then
		    return ParsePath(params.value(optionName))
		  else
		    return nil
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetLongArgName(argname as string) As String
		  for i as integer = 0 to UBound(AllowedOptions)
		    // Shortcut in case we were sent a long name
		    if AllowedOptions(i).LongOptionName = argname then
		      return argname
		    end if
		    
		    // Use StrComp because "C" and "c" are considered different options
		    if StrComp(AllowedOptions(i).ShortOptionLetter,argname,0) = 0 then
		      return AllowedOptions(i).LongOptionName
		    end if
		    
		  next
		  
		  // We should never get here...
		  raise new UnsupportedOperationException
		  
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
		    return True
		  end if
		  
		  for i as integer = 0 to UBound(AllowedOptions)
		    dim opt as Params.AllowedOption = AllowedOptions(i)
		    If opt.LongOptionName = optionName And Options.HasKey(opt.ShortOptionLetter) Then
		      return True
		    elseif opt.ShortOptionLetter = optionName and Options.HasKey(opt.LongOptionName) then
		      return True
		    end if
		  next
		  
		  return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Lookup(optionName as string, defaultvalue as variant) As variant
		  // First, make sure we're asking for the correct name
		  If Options.HasKey(optionName) Then
		    Return Options.value(optionName)
		  end if
		  
		  for i as integer = 0 to UBound(AllowedOptions)
		    dim opt as Params.AllowedOption = AllowedOptions(i)
		    If opt.LongOptionName = optionName And Options.HasKey(opt.ShortOptionLetter) Then
		      return Params.value(opt.ShortOptionLetter)
		    elseif opt.ShortOptionLetter = optionName and Options.HasKey(opt.LongOptionName) then
		      return Params.value(opt.LongOptionName)
		    end if
		  next
		  
		  return defaultvalue
		  
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
		          Else
		            value = True
		          End If
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
		        Elseif UBound(args) > i And (Left(args(i+1),1)<>"-" Or CountFields(args(i+1)," ") > 1) Then
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
		  dim pth() as string = split(path,kPathDelimiter)
		  
		  dim f as FolderItem = SpecialFolder.CurrentWorkingDirectory
		  
		  try
		    for i as integer = 0 to UBound(pth)
		      // If we're looking at the first element on Windows, check to see if it's a volume
		      #if TargetWindows
		        if i = 0 and instr(pth(0),":") = len(pth(0)) then
		          for vol as integer = 0 to VolumeCount-1
		            dim g as FolderItem = Volume(vol)
		            if g.Name = pth(0) then
		              f = g
		              Continue for i
		            end if
		          next
		        end if
		      #endif
		      
		      select case pth(i)
		      case ""
		        #if TargetMacOS or TargetLinux
		          if i=0 then
		            f = GetFolderItem("/",FolderItem.PathTypeNative)
		          end if
		        #endif
		        
		      case "." // same directory
		        
		      case ".." // Parent Directory
		        f = f.Parent
		        
		      case "~" // User Home
		        f = SpecialFolder.UserHome
		        
		      case else
		        f = f.Child(pth(i))
		        
		      end select
		      
		      if f = nil then exit
		    next i
		    
		    return f
		  catch ex as NilObjectException
		    return nil
		  end try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub PrintUsage()
		  If trim(Description) = "" Then
		    stderr.WriteLine Description
		  End If
		  stderr.WriteLine ""
		  Dim usage As String = "usage: " + app.ExecutableFile.Name.replace(".debug", "")
		  
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
		    
		    If trim(type) <> "" Then
		      optname = trim(optname + " (" + type + ")")
		    End If
		    
		    If AllowedOptions(i).Required Then
		      requireds.Append optname
		    Else
		      optionals.Append "[" + optname + "]"
		    End If
		  Next
		  
		  usage = usage + " " + join(requireds, " ") + " " + join(optionals, " ")
		  
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
		  dim longestLength as integer = 0
		  for i as integer = 0 to UBound(AllowedOptions)
		    longestLength = max(longestLength,len(AllowedOptions(i).LongOptionName))
		  next
		  
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
		  case AllowedOption.OptionTypes.String
		    Options.value(opt.StoreAs()) = value.StringValue
		    
		  case AllowedOption.OptionTypes.Integer
		    if IsNumeric(value) then
		      Options.Value(opt.StoreAs()) = value.IntegerValue
		    else
		      errorMessages.Append value.StringValue + " is not a number."
		    end if
		    
		  case AllowedOption.OptionTypes.Float
		    if IsNumeric(value) then
		      Options.Value(opt.StoreAs()) = value.DoubleValue
		    else
		      errorMessages.Append value.StringValue + " is not a number."
		    end if
		    
		  case AllowedOption.optiontypes.boolean
		    dim v as string = left(value.StringValue,1)
		    Options.Value(opt.StoreAs()) = ( v = "T" or v = "1" )
		    
		  case AllowedOption.OptionTypes.Flag
		    Options.Value(opt.StoreAs()) = True
		    
		  Case AllowedOption.OptionTypes.path, AllowedOption.OptionTypes.File, AllowedOption.OptionTypes.Folder
		    // Check to see if it's actually a path
		    dim f as FolderItem = ParsePath(value)
		    if f = nil then 
		      errormessages.append opt.LongOptionName + " is not a valid path" 
		    End If
		    
		    If f <> Nil Then
		      Dim mustexist As Boolean = opt.Type = AllowedOption.OptionTypes.File Or opt.type = AllowedOption.OptionTypes.Folder
		      If mustexist And Not f.Exists Then
		        errormessages.append opt.LongOptionName + " must exist"
		      End If
		      
		      select case opt.type
		      case AllowedOption.OptionTypes.File
		        if f.Directory then
		          errormessages.append opt.LongOptionName + " must be a file"
		        end if
		        
		      case AllowedOption.OptionTypes.Folder
		        if not f.Directory then
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
