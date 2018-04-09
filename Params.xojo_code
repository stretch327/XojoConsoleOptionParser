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
		Protected Function GetPathForOption(name as string) As FolderItem
		  if Options.HasKey(name) then
		    return ParsePath(params.value(name))
		  else
		    return nil
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasKey(name as string) As Boolean
		  // First, make sure we're asking for the correct name
		  if Options.HasKey(name) then
		    return True
		  end if
		  
		  for i as integer = 0 to UBound(AllowedOptions)
		    dim opt as Params.AllowedOption = AllowedOptions(i)
		    if opt.LongOptionName = name and Options.HasKey(opt.ShortOptionLetter) then
		      return True
		    elseif opt.ShortOptionLetter = name and Options.HasKey(opt.LongOptionName) then
		      return True
		    end if
		  next
		  
		  return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Lookup(name as string, defaultvalue as variant) As variant
		  // First, make sure we're asking for the correct name
		  if Options.HasKey(name) then
		    return Options.value(name)
		  end if
		  
		  for i as integer = 0 to UBound(AllowedOptions)
		    dim opt as Params.AllowedOption = AllowedOptions(i)
		    if opt.LongOptionName = name and Options.HasKey(opt.ShortOptionLetter) then
		      return Params.value(opt.ShortOptionLetter)
		    elseif opt.ShortOptionLetter = name and Options.HasKey(opt.LongOptionName) then
		      return Params.value(opt.LongOptionName)
		    end if
		  next
		  
		  return defaultvalue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ParseOptions(args() as string) As Boolean
		  options = new Dictionary
		  
		  dim errorMessages() as string
		  
		  for i as integer = 1 to UBound(args)
		    dim arg as string = args(i)
		    dim opt as Params.allowedOption
		    
		    select case true
		    case left(arg,2) = "--"
		      // Deal with extended options
		      arg = mid(arg,3)
		      if trim(arg)<>"" then
		        dim p as integer = instr(arg,"=")
		        dim argName as string
		        dim value as Variant
		        if p>0 then
		          argName = left(arg,p-1)
		          value = mid(arg,p+1)
		        else
		          argName = arg
		          value = true
		        end if
		        
		        // Match to allowed arguments
		        opt = GetAllowedOptionByName(argName)
		        if opt=nil then 
		          errorMessages.Append arg + " is not a supported option."
		          Continue for i
		        end if
		        
		        StoreOption(opt, value, errormessages)
		        
		      end if
		      
		    case left(arg,1) = "-"
		      arg = mid(arg,2)
		      // Deal with the compounded boolean properties
		      // e.g. -zxvf, zxv are boolean while f has a parameter
		      for j as integer = 1 to len(arg)-1
		        dim optname as string = mid(arg,j,1)
		        opt = GetAllowedOptionByName(optname)
		        if opt = nil then
		          errorMessages.Append optname + " is not a supported option."
		          Continue for i
		        end if
		        
		        Options.value(opt.StoreAs) = true
		      next
		      
		      dim lastarg as string = right(arg,1)
		      opt = GetAllowedOptionByName(lastarg)
		      if opt<>nil then
		        if opt.Type = AllowedOption.OptionTypes.Flag then
		          Options.Value(opt.StoreAs) = true
		        elseif UBound(args) > i and (left(args(i+1),1)<>"-" or CountFields(args(i+1)," ") > 1) then
		          Options.value(opt.StoreAs) = args(i+1)
		          i = i + 1
		        else
		          return False
		        end if
		      end if
		      
		    case else
		      // Anything that doesn't fall into the two cases above is probably a file
		      OtherItems.Append arg
		      
		    end select
		  next i
		  
		  // Now that everything's in, lets check to make sure the set is legal
		  dim acceptedItems() as string
		  for i as integer = 0 to UBound(AllowedOptions)
		    dim opt as Params.allowedoption = AllowedOptions(i)
		    acceptedItems.Append opt.LongOptionName
		    acceptedItems.Append opt.ShortOptionLetter
		    if opt.Required then
		      if not Options.HasKey(opt.LongOptionName) and _
		        not Options.HasKey(opt.ShortOptionLetter) then
		        errorMessages.Append opt.OptionErrorMessage()
		      end if
		    end if
		  next
		  
		  // Check for options that are specified, but not used
		  dim keys() as Variant = Options.keys
		  for i as integer = 0 to UBound(keys)
		    if acceptedItems.IndexOf(keys(i).StringValue)=-1 then
		      errorMessages.Append keys(i).StringValue + " is undefined and will be ignored."
		    end if
		  next
		  
		  if UBound(errorMessages)>-1 then
		    PrintUsage()
		    stderr.WriteLine ""
		    stderr.WriteLine join(errorMessages,EndOfLine)
		    return False
		  end if
		  
		  return True
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
		  stderr.writeline "Usage: " + app.ExecutableFile.Name.replace(".debug","")
		  
		  // Get the length of the longest option name
		  dim longestLength as integer = 0
		  for i as integer = 0 to UBound(AllowedOptions)
		    longestLength = max(longestLength,len(AllowedOptions(i).LongOptionName))
		  next
		  
		  for i as integer = 0 to UBound(AllowedOptions)
		    stderr.WriteLine AllowedOptions(i).OptionUsageMessage(longestLength)
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StoreOption(opt as allowedoption, value as Variant, byref errorMessages() as string)
		  select case opt.Type
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
		    
		  case AllowedOption.OptionTypes.path, AllowedOption.OptionTypes.File, AllowedOption.OptionTypes.Folder
		    // Check to see if it's actually a path
		    dim f as FolderItem = ParsePath(value)
		    if f = nil then 
		      stderr.WriteLine opt.LongOptionName + " is not a valid path"
		      return
		    end if
		    
		    dim mustexist as boolean = true
		    select case opt.type
		    case AllowedOption.OptionTypes.File
		      if f.Directory then
		        stderr.WriteLine opt.LongOptionName + " must be a file"
		        return
		      end if
		      
		    case AllowedOption.OptionTypes.Folder
		      if not f.Directory then
		        stderr.WriteLine opt.LongOptionName + " must be a folder"
		        return
		      end if
		      
		    case else
		      mustexist = False
		      
		    end select
		    
		    if mustexist and not f.Exists then
		      stderr.WriteLine opt.LongOptionName + " must exist"
		      return
		    end if
		    
		    Options.Value(opt.StoreAs()) = value.StringValue
		  end select
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
