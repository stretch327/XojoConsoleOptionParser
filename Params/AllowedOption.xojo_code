#tag Class
Protected Class AllowedOption
	#tag Method, Flags = &h0
		Sub Constructor(Name as String, Letter as String, Required as Boolean, Type as AllowedOption.OptionTypes, Description as string = "", StoreAsName as string = "")
		  self.LongOptionName = name
		  self.mStoreAs = name // Default to the long name
		  self.ShortOptionLetter = Letter
		  self.Required = Required
		  self.Description = Description
		  self.StoreAs = StoreAsName
		  self.type = type
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OptionErrorMessage() As String
		  dim s as string
		  
		  if LongOptionName<>"" then
		    s = s + "--" + LongOptionName
		  end if
		  
		  if ShortOptionLetter<>"" then
		    if LongOptionName<>"" then s = s + "("
		    s = s + "-" + ShortOptionLetter
		    if LongOptionName<>"" then s = s + ")"
		  end if
		  
		  if Required then
		    s = s + " is missing"
		  end if
		  
		  return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OptionUsageMessage(longlength as integer) As String
		  dim sa() as string
		  
		  longlength = longlength - len(LongOptionName)
		  if LongOptionName<>"" then
		    sa.Append "--" + LongOptionName
		  end if
		  
		  dim s as string = ""
		  // Add spacing to make them even
		  for i as integer = 1 to longlength
		    s = s + " "
		  next
		  
		  if ShortOptionLetter<>"" then
		    s = s + "-" + ShortOptionLetter
		  end if
		  
		  sa.Append s
		  
		  s = join(sa,", ")
		  
		  if ShortOptionLetter="" then
		    s = s + "   "
		  end if
		  
		  // Spacing before the description
		  s = s + "     "
		  
		  
		  if Description<>"" then s = s + Description + "."
		  if Required then s = s + " Required. "
		  
		  return s
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Description As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LongOptionName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStoreAs As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Required As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ShortOptionLetter As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if mStoreAs = "" then
			    return LongOptionName
			  else
			    return mStoreAs
			  end if
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if value<>"" then
			    mStoreAs = value
			  else
			    mStoreAs = LongOptionName
			  end if
			End Set
		#tag EndSetter
		StoreAs As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Type As OptionTypes
	#tag EndProperty


	#tag Enum, Name = OptionTypes, Type = Integer, Flags = &h0
		String
		  Boolean
		  Integer
		  Float
		  File
		  Folder
		  Path
		Flag
	#tag EndEnum


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
			Name="LongOptionName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Required"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShortOptionLetter"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StoreAs"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
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
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			Type="OptionTypes"
			EditorType="Enum"
			#tag EnumValues
				"0 - String"
				"1 - Boolean"
				"2 - Integer"
				"3 - Float"
				"4 - File"
				"5 - Folder"
				"6 - Path"
				"7 - Flag"
			#tag EndEnumValues
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
