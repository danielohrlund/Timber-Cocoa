module CTContainer where

import CocoaDef

--------------------------------------------------------------------------------------------------
------          ** CONTAINER **         ----------------------------------------------------------

mkCocoaContainer :: World -> Class Container
mkCocoaContainer w = class
    myComponents := []    
    color        := {r=255; g=255; b=255}
    appRef       := Nothing
    state        := Inactive

    BaseComponent {getAllChildren=dummy; setPosition = setPositionImpl; setSize = setSizeImpl; ..} = 
        new basicComponent False Nothing "Container"

    setPosition p = request
        if isActive state then
            Active ref = state
            containerSetPosition ref p
        setPositionImpl p

    setSize s = request
        if isActive state then
            Active ref = state
            containerSetSize ref s
        setSizeImpl s
    
    getAllChildren = request
        cs <- forall c <- myComponents do
            list <- c.getAllChildren
            result list ++ [c] -- order is important here (for reactions to mouse events)
        result concat cs

    setBackgroundColor c = request
        if isActive state then
            Active ref = state
            containerSetBackgroundColor ref c
        color := c

    getBackgroundColor = request
        result color
    
    addComponent c = request        
        myComponents := c : myComponents
        c.setParent this
        if isActive state then
            Active ref = state
            c_ref <- c.initComp (fromJust appRef)
            containerAddComponent ref c_ref
            
    removeComponent c = request
        myComponents := [x | x <- myComponents, not (x == c)]
        if isActive state then
            Active ref = state
            c.destroyComp
            (Destroyed c_ref) <- c.getState
            if isJust c_ref then
                containerRemoveComponent ref (fromJust c_ref)
            
    removeAllComponents = request
        removeAllComponentsImpl

    removeAllComponentsImpl = do
        if isActive state then
            Active ref = state
            forall c <- myComponents do
                s <- c.getState
                if isActive s then
                    Active c_ref = s
                    containerRemoveComponent ref c_ref
                c.destroyComp
        myComponents := []

    getComponents = request
        result myComponents
    
    destroyComp = request
        if (isActive state) then
            removeAllComponentsImpl
            Active ref = state
            destroyContainer ref
        state := destroyState state
        
    initComp app = request
        appRef := Just app
        ref <- initContainer w
        state := Active ref
        containerSetSize ref (<-getSize)
        containerSetBackgroundColor ref color
        containerSetPosition ref (<-getPosition)
        forall c <- myComponents do
            c_ref <- c.initComp app
            containerAddComponent ref c_ref
        result ref
    
    getState = request
        result state
       
    this = Container {id = self; ..}  

    result this

basicHasResponders :: Class DefaultEventResponder
basicHasResponders = class
    responders := []
    addResponder a = request
        responders := responders ++ [a]
    setResponders aa = request
        responders := aa
    getResponders = request
        result responders
    -- return true (block cocoa) if any of the installed responders say so
    returnVal := False    
    respondToInputEvent inputEvent modifiers = request
        returnVal := False
        forall h <- responders do
            if returnVal == False then
                returnVal := <- h.respondToInputEvent inputEvent modifiers
        result returnVal
    result DefaultEventResponder {..}

basicComponent :: Bool -> (Maybe Component) -> String -> Class BaseComponent
basicComponent f p n = class
    DefaultEventResponder {..}     = new basicHasResponders
    (getName,setName)               = new wrapper n
    (getParent,setParentImpl)       = new wrapper p
    setParent p = request setParentImpl (Just p)
    (getIsFocusable,setIsFocusable) = new wrapper f
    (getPosition,setPosition)       = new wrapper ({x=0; y=0})
    (getSize,setSize)               = new wrapper ({width=100; height=100})    
    getAllChildren                  = request result []
    result BaseComponent {..}

private
    
wrapper :: a -> Class (Request a, a -> Request ())    
wrapper s = class
    a := s
    set b = request a := b
    get = request result a
    result (get,set)

extern initContainer                :: World -> Request CocoaRef
extern destroyContainer             :: CocoaRef -> Request ()
extern containerSetBackgroundColor  :: CocoaRef -> Color -> Request ()
extern containerSetSize             :: CocoaRef -> Size -> Request ()
extern containerSetPosition         :: CocoaRef -> Position -> Request ()
extern containerAddComponent        :: CocoaRef -> CocoaRef -> Request ()
extern containerRemoveComponent     :: CocoaRef -> CocoaRef -> Request ()