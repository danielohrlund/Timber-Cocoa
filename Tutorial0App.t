module Tutorial0App where

import COCOA
import POSIX

root w = class
    env = new posix w
    osx = new cocoa w
    
    w1 = new mkCocoaWindow env

    applicationDidFinishLaunching app = action   
        w1.setPosition({x=100;y=300})
    	w1.setSize ({width=400;height=400})
    	w1.setBackgroundColor ({r=200;g=200;b=200})
    	app.addWindow w1

    result action
        osx.startApplication applicationDidFinishLaunching