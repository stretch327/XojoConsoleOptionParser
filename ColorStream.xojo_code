#tag Class
Protected Class ColorStream
	#tag Method, Flags = &h0
		Sub BackgroundColor(Assigns c as color)
		  Dim n As Integer
		  
		  // Base colors
		  If n = 0 Then
		    Select Case c
		    Case &c000000
		      n = 0
		    Case &c800000
		      n = 1
		    Case &c008000
		      n = 2
		    Case &c808000
		      n = 3
		    Case &c000080
		      n = 4
		    Case &c800080
		      n = 5
		    Case &c008080
		      n = 6
		    Case &cc0c0c0
		      n = 7
		    Case &c808080
		      n = 8
		    Case &cFF0000
		      n = 9
		    Case &c00FF00
		      n = 10
		    Case &cFFFF00
		      n = 11
		    Case &c0000FF
		      n = 12
		    Case &cFF00FF
		      n = 13
		    Case &c00FFFF
		      n = 14
		    Case &cFFFFFF
		      n = 15
		    End Select 
		  End If
		  
		  If n = 0 Then
		    // 24 shades of gray, between 8 and 238
		    If c.Red = c.Green And c.Green = c.Blue Then
		      If c.Red >= 8 And c.Red <= 238 Then
		        n = Round((c.Red - 8) / 10) + 232
		      End If
		    End If
		  End If
		  
		  // Last, fall back to calculating the color in the 6x6x6 grid
		  If n = 0 Then
		    Dim r As Integer = Ceil(c.Red / 255 * 5)
		    Dim g As Integer = Ceil(c.Green / 255 * 5)
		    Dim b As Integer = Ceil(c.Blue / 255 * 5)
		    n = 16 + (36 * r) + (6 * g) + b
		  End If
		  
		  mstream.write &u1B + "[48;5;" + Str(n) + "m"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearLine()
		  mStream.write &u1B + "[2K"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearLineToLeft()
		  mStream.write &u1B + "[1K"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearLineToRight()
		  mStream.write &u1B + "[0K"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearScreen()
		  mstream.write &u1B + "[2J"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearScreenToBottom()
		  mstream.write &u1B + "[0J"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearScreenToTop()
		  mstream.write &u1B + "[1J"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(stream as Writeable)
		  mStream = stream
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Self.Reset
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Flush()
		  mStream.Flush
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveCursor(row as integer, column as integer)
		  mStream.write &u1B + "[" + Str(row) + ";" + Str(column) + "H"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveCursorDown(Rows as integer)
		  mStream.write &u1B + "[" + Str(Rows) + "B"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveCursorLeft(Columns as integer)
		  mStream.write &u1B + "[" + Str(Columns) + "D"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveCursorRight(Columns as integer)
		  mStream.write &u1B + "[" + Str(Columns) + "C"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveCursorUp(Rows as integer)
		  mStream.write &u1B + "[" + Str(Rows) + "A"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  mstream.write &u1B + "[0m" // reset text attributes
		  
		  TextColor = &cFFFFFF
		  mBlink = False
		  mBold = False
		  mHidden = False
		  mItalic = False
		  mReversed = False
		  mUnderline = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResetTerminal()
		  mstream.write &u1B + "c" // reset whole terminal
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RestoreCursor()
		  mstream.write &u1B + "[u"
		  mstream.write &u1B + "8"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveCursor()
		  mstream.Write &u1B + "[s"
		  mstream.Write &u1B + "7"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TextColor() As Color
		  Return mTextColor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TextColor(Assigns c as color)
		  mTextColor = c
		  
		  Dim n As Integer
		  // Base colors
		  If n = 0 Then
		    Select Case c
		    Case &c000000
		      n = 0
		    Case &c800000
		      n = 1
		    Case &c008000
		      n = 2
		    Case &c808000
		      n = 3
		    Case &c000080
		      n = 4
		    Case &c800080
		      n = 5
		    Case &c008080
		      n = 6
		    Case &cc0c0c0
		      n = 7
		    Case &c808080
		      n = 8
		    Case &cFF0000
		      n = 9
		    Case &c00FF00
		      n = 10
		    Case &cFFFF00
		      n = 11
		    Case &c0000FF
		      n = 12
		    Case &cFF00FF
		      n = 13
		    Case &c00FFFF
		      n = 14
		    Case &cFFFFFF
		      n = 15
		    End Select 
		  End If
		  
		  If n = 0 Then
		    // 24 shades of gray, between 8 and 238
		    If c.Red = c.Green And c.Green = c.Blue Then
		      If c.Red >= 8 And c.Red <= 238 Then
		        n = Round((c.Red - 8) / 10) + 232
		      End If
		    End If
		  End If
		  
		  // Last, fall back to calculating the color in the 6x6x6 grid
		  If n = 0 Then
		    Dim r As Integer = Ceil(c.Red / 255 * 5)
		    Dim g As Integer = Ceil(c.Green / 255 * 5)
		    Dim b As Integer = Ceil(c.Blue / 255 * 5)
		    n = 16 + (36 * r) + (6 * g) + b
		  End If
		  
		  mstream.write &u1B + "[38;5;" + Str(n) + "m"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(data as string)
		  mStream.Write data
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteLine(data as string)
		  mStream.write data
		  mStream.write EndOfLine
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBlink
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBlink = value
			  
			  If value Then
			    mStream.write &u1B + "[5m"
			  Else
			    mStream.write &u1B + "[25m"
			  End If
			End Set
		#tag EndSetter
		Blink As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBold
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBold = value
			  
			  If value Then
			    mStream.write &u1B + "[1m"
			  Else
			    mStream.write &u1B + "[21m"
			  End If
			End Set
		#tag EndSetter
		Bold As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mHidden
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHidden = value
			  
			  If value Then
			    mStream.write &u1B + "[8m"
			  Else
			    mStream.write &u1B + "[28m"
			  End If
			End Set
		#tag EndSetter
		Hidden As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mBlink As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBold As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHidden As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mItalic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mReversed As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStream As Writeable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextColor As Color = &cFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUnderline As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mReversed
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mReversed = value
			  
			  If value Then
			    mStream.write &u1B + "[7m"
			  Else
			    mStream.write &u1B + "[27m"
			  End If
			End Set
		#tag EndSetter
		Reversed As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBold
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mUnderline = value
			  
			  If value Then
			    mStream.write &u1B + "[4m"
			  Else
			    mStream.write &u1B + "[24m"
			  End If
			End Set
		#tag EndSetter
		Underline As Boolean
	#tag EndComputedProperty


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
			InitialValue=""
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
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Bold"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Underline"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Blink"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Hidden"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Reversed"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
