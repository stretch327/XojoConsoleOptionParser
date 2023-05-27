#tag Module
Protected Module SystemD
	#tag Method, Flags = &h1
		Protected Sub Initialize()
		  SignalHandling.Initialize
		  send(states.Ready)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function mSystemDIsAvailable() As Boolean
		  //int sd_watchdog_enabled(int unset_environment, uint64_t *usec);
		  #If TargetLinux
		    Soft Declare Function sd_watchdog_enabled Lib "libsystemd.so" (env As Integer, ByRef usec As UInt64) As Integer
		    If System.IsFunctionAvailable("sd_watchdog_enabled", "libsystemd.so") Then
		      
		      Dim n As UInt64
		      Dim rv As Integer = sd_watchdog_enabled(0, n)
		      Return rv > 0
		    End If
		  #EndIf
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit))
		Protected Sub Send(status as States)
		  Send(status, "1")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit))
		Protected Sub Send(status as States, value as integer)
		  Send(status, str(value, "-0"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit))
		Protected Sub Send(status as States, statusmessage as string)
		  //  int sd_notify(int unset_environment, const char *state);
		  #If TargetLinux And TargetConsole
		    If mSystemDIsAvailable Then
		      Soft Declare Sub sd_notify Lib "libsystemd.so" (env As Integer, state As CString)
		      If System.IsFunctionAvailable("sd_notify", "libsystemd.so") Then
		        Dim msg As String
		        If statusmessage = "" Then
		          statusmessage = "1"
		        End If
		        
		        Select Case status
		        Case States.Ready
		          msg = "READY"
		          
		        Case States.Stopping
		          msg = "STOPPING"
		          
		        Case States.Status
		          msg = "STATUS"
		          
		        Case States.MainPID
		          Soft Declare Function getpid Lib "libc" () As Integer
		          If System.IsFunctionAvailable("getpid", "libc") Then
		            msg = "MAINPID"
		            statusmessage = Str(getpid, "0")
		          End If
		          
		        Case States.Watchdog
		          msg = "WATCHDOG"
		          
		          // Check to see if watchdog is enabled
		          If System.IsFunctionAvailable("sd_watchdog_enabled", "libsystemd.so") Then
		            Soft Declare Function sd_watchdog_enabled Lib "libsystemd.so" (env As Integer, ByRef usec As UInt64) As Integer
		            Dim usec As UInt64
		            Dim sdEnabled As Integer = sd_watchdog_enabled(0, usec)
		            If sdEnabled < 1 Then
		              msg = ""
		              statusmessage = ""
		            End If
		          Else
		            stderr.WriteLine "watchdog is not enabled"
		          End If
		          
		        End Select
		        
		        If msg<>"" And statusmessage<>"" Then
		          sd_notify(0, msg + "=" + statusmessage)
		          stderr.WriteLine msg + "=" + statusmessage
		        End If
		      Else
		        stderr.WriteLine "sd_notify is unavailable"
		      End If
		    End If
		  #EndIf
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SendWatchdog()
		  systemd.Send(systemd.States.Watchdog)
		End Sub
	#tag EndMethod


	#tag Note, Name = README
		
		1. Make your run loop include a check for SystemD.ShouldShutdown and do a clean exit if it returns true
		2. Call SystemD.Initialize at the top of App.Run, once you are sure the app can run
		3. Call SendWatchdog periodically to tell SystemD that your app is still running
	#tag EndNote


	#tag Enum, Name = States, Flags = &h1, Attributes = \""
		Ready
		  Stopping
		  Status
		  MainPID
		Watchdog
	#tag EndEnum


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
End Module
#tag EndModule
