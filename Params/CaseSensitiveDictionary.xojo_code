#tag Class
Protected Class CaseSensitiveDictionary
	#tag Method, Flags = &h0
		Sub Constructor()
		  mData = New Dictionary(AddressOf Dictionary_KeyComparisonDelegate)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Dictionary_KeyComparisonDelegate(leftKey As Variant, rightKey As Variant) As Integer
		  Return StrComp(leftKey.StringValue, rightKey.StringValue, 0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasKey(key as String) As Boolean
		  Return mData.HasKey(key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Keys() As Variant()
		  Return mData.keys
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(key as Variant) As Variant
		  Return mData.Value(key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Value(key as variant, assigns value as variant)
		  mData.Value(key) = value
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mData As dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
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
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
