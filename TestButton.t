module TestButton where

import POSIX
import COCOA
import CTButton

root :: RootType
root w = class
    osx = new cocoa w
    w1 = new mkCocoaWindow
    c2 = new mkCocoaContainer
    button1 = new mkCocoaButton
    button2 = new mkCocoaButton
    
    start app = action                         
        app.addWindow w1
        
    result action
        w1.setSize ({width=500;height=500})

        button1.setName "button1"
        button1.setTitle "I am button 1"
        button1.setPosition ({x=100;y=100})
        button1.addResponder (new buttonClickHandler button2)
        w1.addComponent button1
        
        button2.setName "button2"
        button2.setTitle "I am button 2"
        button2.setPosition ({x=100;y=130})
        button2.addResponder (new buttonClickHandler2 button2 env.stdout.write)
        w1.addComponent button2
        
        osx.startApplication start

buttonClickHandler2 btn writer = class
    c := 0
    respondToInputEvent (MouseEvent ev) modifiers = request
        case ev of
            MouseClicked pos ->
                c := c+1
                writer (show c ++ "\n")
                result True
            _ ->
                result False
            
    respondToInputEvent _ _ = request 
        result False
    
    result RespondsToInputEvents {..}
        
buttonClickHandler btn = class
    respondToInputEvent (MouseEvent ev) modifiers = request
        case ev of
            MouseClicked pos ->
                -- this leads to deadlock until we've fixed so that responders are actions!!!
                -- btn.setSize ({width=200;height=150})
                -- this is a temporary solution !!!
                send action btn.setSize ({width=200;height=150})
                result True
            _ ->
                result False
            
    respondToInputEvent _ _ = request 
        result False
    
    result RespondsToInputEvents {..}