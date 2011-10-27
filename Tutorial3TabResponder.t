module Tutorial3TabResponder where

import CTWindow
import CTButton
import CTLabel
import CTTextArea

root w = class
    env = new posix w
    osx = new cocoa w
    
    w1 = new mkCocoaWindow
    
    applicationDidFinishLaunching app = action                         
        w1.setSize ({width=400;height=400}) 
        w1.setBackgroundColor ({r=200;g=200;b=200})
  	
        createComponentHierarchy
        
        app.addWindow w1
        
        addButtonResponder
        addWindowResponder
           
    label = new mkCocoaLabel
    tabCountLabel = new mkCocoaLabel
    button = new mkCocoaButton env
    
    createComponentHierarchy = do
        leftContainer = new mkCocoaContainer 
        leftContainer.setSize ({width=200; height=200})
        leftContainer.setBackgroundColor ({r=100;g=100;b=200})
        leftContainer.setPosition ({x=0;y=0})

        rightContainer = new mkCocoaContainer
        rightContainer.setSize ({width=200; height=200})
        rightContainer.setBackgroundColor ({r=100;g=200;b=100})
        rightContainer.setPosition ({x=200; y=0})    

        button.setTitle "Click me!"
        button.setSize ({width=110;height=21})
        button.setPosition ({x=40; y=100})

        label.setText "Click counter"
        label.setSize ({width=100; height=36})
        label.setPosition ({x=40; y=100})
        --label.setTextColor ({r=80; b=140; g=90})
        
        tabCountLabel.setText "TextArea Tab counter"
        tabCountLabel.setSize ({width=100; height=36})
        tabCountLabel.setPosition ({x=40; y=70})
        --tabCountLabel.setTextColor ({r=80; b=140; g=90})

        leftContainer.addComponent button
        rightContainer.addComponent label
        rightContainer.addComponent tabCountLabel

        w1.addComponent leftContainer
        w1.addComponent rightContainer

    addButtonResponder = do
        handler = new buttonHandler label
        button.addResponder handler

    ta = new mkCocoaTextArea

    addWindowResponder = do
        ta.setSize ({width=300; height=80})
        ta.setPosition ({x=50; y=250})  

        w1.addComponent ta

        windowResponderObj = new windowResponder ta env
        w1.setWindowResponder windowResponderObj
        replaceTabResponder
        
    replaceTabResponder = do
        tabResponder = new myTabResponder tabCountLabel
        ta.setResponders [tabResponder]

    result action
        osx.startApplication applicationDidFinishLaunching  
        
buttonHandler label = class
    clickCount := 0

    respondToInputEvent (MouseEvent event) modifiers = request
        -- here we will place the code for handling mouse events
        case event of
            MouseClicked pos ->
                clickCount := clickCount + 1
                label.setText ("Click #" ++ show clickCount)
                result True
            _ ->
                result False     
        
    respondToInputEvent _ modifiers = request
        result False
    
    result RespondsToInputEvents {..}
                       
windowResponder :: TextArea -> POSIX.Env -> Class RespondsToWindowEvents
windowResponder textarea env = class
    onWindowResize size = request

        newWidth = floor ((fromInt size.width) * 0.8)
        newTaSize = {width=newWidth; height=80}
        
        newX = floor ((fromInt size.width) * 0.1)
        newTaPosition = {x=newX; y=250}

        textarea.setSize newTaSize
        textarea.setPosition newTaPosition
        result ()
    
    onWindowCloseRequest = request
        result True

    setWindowResponder responder = request 
    
    result RespondsToWindowEvents {..}
    
    
myTabResponder label = class
    tabCount := 0
    
    getKey (KeyPressed key) = key
    getKey (KeyReleased key) = key
    getKey _ = raise 9

    respondToInputEvent (KeyEvent (KeyPressed key)) modifiers = request	
        if (key == Tab) then
            tabCount := tabCount + 1
            label.setText ("Tabs blocked #" ++ (show tabCount))
        result True

    respondToInputEvent _ modifiers = request
        result False

    result RespondsToInputEvents {..}