#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
				Begin ExternalIDEScriptStep ExternalScript2
					AppliesTo = 2
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin ExternalIDEScriptStep ExternalScript3
					AppliesTo = 2
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin ExternalIDEScriptStep ExternalScript1
					AppliesTo = 2
				End
			End
#tag EndBuildAutomation
