module COCOA where


import CTApplication
import CTWindow -- imports CTCommon, CTContainer

import CTButton
import CTLabel
import CTTextField
import CTTextArea
import CTDropDown


struct CocoaEnv where
	startApplication	:: (App -> Action) -> Request ()   	-- what to do?           

extern cocoa :: World -> Class CocoaEnv