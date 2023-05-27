#tag Class
Class AllowedOption
	#tag Method, Flags = &h0
		Sub Constructor(Name as String, Letter as String, Required as Boolean, Type as AllowedOption.OptionTypes, Description as string = "", StoreAsName as string = "")
		  Self.LongOptionName = name
		  Self.mStoreAs = name // Default to the long name
		  Self.ShortOptionLetter = Letter
		  Self.Required = Required
		  Self.Description = Description
		  Self.StoreAs = StoreAsName
		  Self.type = type
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OptionErrorMessage() As String
		  Dim s As String
		  
		  If LongOptionName<>"" Then
		    s = s + "--" + LongOptionName
		  End If
		  
		  If ShortOptionLetter<>"" Then
		    If LongOptionName<>"" Then s = s + "("
		    s = s + "-" + ShortOptionLetter
		    If LongOptionName<>"" Then s = s + ")"
		  End If
		  
		  If Required Then
		    s = s + " is missing"
		  End If
		  
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OptionUsageMessage(longestlength as integer) As String
		  Dim sa() As String
		  
		  If LongOptionName = "" Then
		    Break
		  End If
		  
		  longestlength = longestlength - Len(LongOptionName)
		  If LongOptionName<>"" Then
		    sa.Append "--" + LongOptionName
		  Else
		    sa.Append "  "
		  End If
		  
		  Dim s As String = ""
		  
		  // Add spacing to make them even
		  For i As Integer = 1 To longestlength
		    s = s + " "
		  Next
		  
		  If ShortOptionLetter<>"" Then
		    s = s + "-" + ShortOptionLetter
		  End If
		  
		  sa.Append s
		  
		  s = Join(sa,", ")
		  
		  If ShortOptionLetter="" Or LongOptionName = "" Then
		    s = s.Replace(","," ") + "  "
		  End If
		  
		  // Spacing before the description
		  s = s + "     "
		  
		  If Description<>"" Then s = s + Description + "."
		  If Required Then s = s + " Required. "
		  
		  Return s
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
			  If mStoreAs = "" Then
			    Return LongOptionName
			  Else
			    Return mStoreAs
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value<>"" Then
			    mStoreAs = value
			  Else
			    mStoreAs = LongOptionName
			  End If
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
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LongOptionName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Required"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShortOptionLetter"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StoreAs"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Visible=false
			Group="Behavior"
			InitialValue=""
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
