#tag Module
Protected Module SignalHandling
	#tag Method, Flags = &h21
		Private Sub AppSignalHandler(Signal as SignalHandling.Signals)
		  
		  //let the app spin down on its own
		  mShouldShutdown = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub HandleSignal(sigID As SignalHandling.Signals)
		  #If Not TargetWin32
		    Dim p As Pair = mSignalDictionary.Value(sigID)
		    Dim handler As SignalHandler = p.Left
		    
		    handler.Invoke(sigID)
		    
		    #If TargetLinux
		      Declare Sub exit_func Lib "libc" Alias "exit" (exitCode As Integer)
		    #ElseIf TargetMacOS
		      Declare Sub exit_func Lib "System.framework" Alias "exit" (exitCode As Integer)
		    #EndIf
		    
		    If sigID = SignalHandling.Signals.SIGINT Then
		      exit_func(0)
		    End If
		    
		    Exception err As RuntimeException
		      // Msgbox "Caught unknown signal " + Str(sigID)
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Initialize()
		  If Not mInitialized Then
		    mInitialized = True
		    
		    // Add some signal handling so killed apps can still run their cleanup routines
		    SignalHandling.RegisterSignal(SignalHandling.Signals.SIGCONT, AddressOf AppSignalHandler)
		    SignalHandling.RegisterSignal(SignalHandling.Signals.SIGABRT, AddressOf AppSignalHandler)
		    SignalHandling.RegisterSignal(SignalHandling.Signals.SIGINT, AddressOf AppSignalHandler)
		    SignalHandling.RegisterSignal(SignalHandling.Signals.SIGTERM, AddressOf AppSignalHandler)
		    
		    // don't know if we're going to have time to process these, but we'll try
		    SignalHandling.RegisterSignal(SignalHandling.Signals.SIGKILL, AddressOf AppSignalHandler)
		    SignalHandling.RegisterSignal(SignalHandling.Signals.SIGSTOP, AddressOf AppSignalHandler)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub RegisterSignal(sig As SignalHandling.Signals, handler As SignalHandler)
		  #If Not TargetWin32
		    Dim sa As sigaction
		    sa.handler = AddressOf HandleSignal
		    
		    #If TargetLinux
		      Declare Function sigaction Lib "libc" (sig As SignalHandling.Signals, ByRef action As sigaction, oldAction As Ptr ) As Integer
		    #ElseIf TargetMacOS
		      Declare Function sigaction Lib "System.framework" (sig As SignalHandling.Signals, ByRef action As sigaction, oldAction As Ptr ) As Integer
		    #EndIf
		    
		    Dim oldAction As sigaction
		    // Hmmm we'll pass in Nil for now as I'm getting a crash when passing the oldAction
		    If -1 = sigaction( sig, sa, Nil ) Then
		      // Error
		      Break
		    Else
		      If mSignalDictionary = Nil Then mSignalDictionary = New Dictionary
		      Dim p As New Pair( handler, oldAction )
		      mSignalDictionary.Value(sig) = p
		    End If
		  #EndIf
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h1
		Protected Delegate Sub SignalHandler(sigID As SignalHandling . Signals)
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h1
		Protected Sub UnRegisterSignal(sigID As SignalHandling.Signals)
		  #If Not TargetWin32
		    Dim p As Pair = mSignalDictionary.Value(sigID)
		    
		    #If TargetLinux
		      Declare Sub sigaction Lib "libc" (sig As SignalHandling.Signals, ByRef action As sigaction, oldAction As Ptr )
		    #Else
		      Declare Sub sigaction Lib "System.framework" (sig As SignalHandling.Signals, ByRef action As sigaction, oldAction As Ptr )
		    #EndIf
		    
		    Dim action As sigAction = p.Right
		    sigaction( sigID, action, Nil )
		    
		    Exception err As RuntimeException
		      // Msgbox "Signal " + Str(sigID) + " was not registered"
		  #EndIf
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mInitialized As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShouldShutdown As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSignalDictionary As Dictionary
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  Return mShouldShutdown
			End Get
		#tag EndGetter
		Protected ShouldShutdown As Boolean
	#tag EndComputedProperty


	#tag Structure, Name = sigaction, Flags = &h21
		handler As Ptr
		  mask As UInt64
		  flags As UInt32
		restorer As Ptr
	#tag EndStructure


	#tag Enum, Name = Signals, Type = Integer, Flags = &h1
		SIGHUP = 1
		  SIGINT
		  SIGQUIT
		  SIGILL
		  SIGTRAP
		  SIGABRT = 6
		  SIGIOT = 6
		  SIGBUS
		  SIGPPE
		  SIGKILL
		  SIGUSR1
		  SIGSEGV
		  SIGUSR2
		  SIGPIPE
		  SIGALRM
		  SIGTERM
		  SIGSTKFLT
		  SIGCHLD
		  SIGCONT
		  SIGSTOP
		  SIGTSTP
		  SIGTTIN
		  SIGTTOU
		  SIGURG
		  SIGXCPU
		  SIGXFSZ
		  SIGVTALRM
		  SIGPROF
		  SIGWINCH
		  SIGIO
		  SIGPWR
		SIGSYS
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
