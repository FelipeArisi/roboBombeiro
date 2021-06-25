  // ======================================================================
  // RB2021 version 1.0
  // Controller for the RB kit.
  //
  // Felipe Arisi
  // Last revision: 13/05/2021 
  // ======================================================================


  // ======================================================================
  // Constants
  // ======================================================================
  WAIT = 0
  NAVIGATE = 1
  APPROACH = 2
  PUT_OUT = 3
   
  NO_TAG = 0
  CIRCLE_TAG = 1
  LINE_TAG = 2 
   
  DIST_FRONT_LIMIT = 30
  DIST1 = 40
  DIST2 = 50 
   
  oX = 250
  oY = 50


  wallColor = GREEN
  lineColor = WHITE
  startColor = WHITE
  floorColor = BLACK
  candleColor = RED
  penColor = BLUE
  furnitureColor = YELLOW
  

   
  // ======================================================================
  // Main Program
  // ======================================================================
  mainProgram:
    goSub initializeVariables
    goSub initializeGUI
    goSub drawArena
    goSub initializeRobot
    goSub finiteStateMachine  
  end
    // ======================================================================
  // Variables
  // ======================================================================
initializeVariables:
  state = WAIT

  flameDirection = 0
  flameColor = BLACK
  flamDistance = 0
  flameFound = false
  flameInRoom = false
  flameBurning = true
  rooms = 0
  goToIslandRoom = 1
  inRoom = false
  stateName = ""

  arbitraryStart = false
  furniture = false
  furnitureDirection = 0
  returnTrip = false
return   

  // ======================================================================
  // GUI
  // ======================================================================

  initializeGUI:
    addButton "START", oX, oY - 30 - 10, 80, 30
    addButton "STOP", oX + 80 + 10, oY - 30 - 10, 80, 30

    call header(10, 10, "Configuration", 12)
      
    addButton "RESET", 10, oY, 80, 30

    xyString 10, oY + 30 + 10, "Flame position: "
    addEdit "EFlamePos", 195, oY + 30 + 10, 23, 23, 0
    setEditMask "EFlamePos", "0" 

    xyString 10, oY + 60 + 10, "Arena configuration: "
    addEdit "EArenaConfig", 195, oY + 60 + 10, 23, 23, 0
    setEditMask "EArenaConfig", "0" 

    addCheckBox "CBPen", 10, oY + 90 + 10, "Pen", true, false
    addCheckBox "CBAStart", 10, oY + 110 + 10, "Arbitrary start", false, false
    addCheckBox "CBFurniture", 10, oY + 130 + 10, "Furniture", false, false  
    addCheckBox "CBRTrip", 10, oY + 150 + 10, "Return trip", false, false
    
    call header(10, 300, "Screen", 12)

    onCheckBox cbHandler

    goSub setLedOFF
  return


  // ======================================================================
  // Initialization
  // ======================================================================
  initializeRobot:
    rLocate oX + 200, oY + 45, 180 //--> posi?o original 
    //rLocate oX + 50, oY + 45, 180
    rInvisible floorColor, lineColor, startColor, penColor
    rPen Down, penColor
    LineWidth 3
    rSlip 20
  return

  // ======================================================================
  // Arena
  // ======================================================================
  drawArena:
  // Draw the floor.
    rectangle oX, oY, oX + 496, oY + 496, floorColor, floorColor

    // Draw exterior walls
    line oX, oY, oX, oY + 496, 3, wallColor //Left
    line oX, oY, oX + 496, oY, 3, wallColor //Top
    line oX + 496, oY, oX + 496, oY + 496, 3, wallColor //Right
    line oX, oY + 496, oX + 496, oY + 496, 3, wallColor //Botom
   
    // Draw room 1
    line oX + 154, oY, oX + 154, oY + 182, 3, wallColor 
    line oX + 96, oY + 182, oX + 154, oY + 182, 3, wallColor 
    line oX + 3, oY + 182, oX + 93, oY + 182, 3, lineColor //*** line ***
   
    // Draw room 2
    line oX, oY + 274, oX + 154, oY + 274, 3, wallColor
    line oX + 154, oY + 274, oX + 154, oY + 396, 3, wallColor 
    line oX + 154, oY + 396, oX + 154, oY + 493, 3, lineColor //*** line ***
    
    // Use room configuration given by the user or choose a random configuration.
    arenaConfig = ToNumber(GetEdit("EArenaConfig"))
    if(arenaConfig < 1 or arenaConfig > 4)
      arenaConfig = Random(3) + 1
      SetEdit "EArenaConfig", arenaConfig
    endif  

    // Draw room 3.
    if (arenaConfig = 1) or (arenaConfig = 2)
       Line oX + 246, oY + 314, oX + 496, oY + 314, 3, wallColor 
       Line oX + 246, oY + 406, oX + 246, oY + 496, 3, wallColor 
       Line oX + 246, oY + 317, oX + 246, oY + 403, 3, lineColor //*** line ***
       Line oX + 407, oY + 314, oX + 493, oY + 314, 3, lineColor //*** line ***
     elseif (arenaConfig = 3)  or (arenaConfig = 4)
       Line oX + 246, oY + 314, oX + 496, oY + 314, 3, wallColor 
       Line oX + 246, oY + 314, oX + 246, oY + 396, 3, wallColor 
       Line oX + 246, oY + 399, oX + 246, oY + 493, 3, lineColor //*** line ***
       Line oX + 407, oY + 314, oX + 493, oY + 314, 3, lineColor //*** line ***
    endif
    
    // Draw room 4.
    if (arenaConfig = 1) or (arenaConfig = 4)  
        Line oX + 246, oY + 92, oX + 246, oY + 214, 3, wallColor 
        Line oX + 246, oY + 92, oX + 398, oY + 92, 3, wallColor 
        Line oX + 398, oY + 92, oX + 398, oY + 214, 3, wallColor 
        Line oX + 398, oY + 214, oX + 342, oY + 214, 3, wallColor 
        Line oX + 249, oY + 214, oX + 339, oY + 214, 3, lineColor //*** line ***
    elseif (arenaConfig = 2) or (arenaConfig = 3)
        Line oX + 246, oY + 92, oX + 246, oY + 214, 3, wallColor 
        Line oX + 298, oY + 92, oX + 398, oY + 92, 3,  lineColor //*** line ***
        Line oX + 398, oY + 92, oX + 398, oY + 214, 3, wallColor 
        Line oX + 246, oY + 92, oX + 298, oY + 92, 3, wallColor 
        Line oX + 249, oY + 214, oX + 398, oY + 214, 3, wallColor 
    endif

    // Draw white circle (start position)
    circle oX + 170, oY + 16, oX + 170 + 60, oY + 16 + 60, startColor, startColor
    
     // Draw the flame
    // Use position given by the user or choose random position for the flame
    candleBasePos = toNumber(getEdit("EFlamePos"))
    if(candleBasePos < 1 or candleBasePos > 8)
      candleBasePos = random(7) + 1
      setEdit "EFlamePos", candleBasePos
    endif  
    
     if (candleBasePos = 1)
      candleBaseOX = oX + 3
      candleBaseOY = oY + 3
      candleX = 1 
      candleY = 1
    elseif (candleBasePos = 2)
      candleBaseOX = oX + 154 - 2
      candleBaseOY = oY + 3
      candleX = -1 
      candleY = 1
    elseif (candleBasePos = 3)
      candleBaseOX = oX + 246 + 3
      candleBaseOY = oY + 92 + 3
      candleX = 1 
      candleY = 1

      // Reposition the candle because of the orientation of the island room.
      if(arenaConfig == 2 or arenaConfig == 3) 
        candleBaseOY = candleBaseOY + 55      
      endif  
      
    elseif (candleBasePos = 4)
      candleBaseOX = oX + 398 - 1
      candleBaseOY = oY + 92 + 3
      candleX = -1 
      candleY = 1

      // Reposition the candle because of the orientation of the island room.
      if(arenaConfig == 2 or arenaConfig == 3)
        candleBaseOY = candleBaseOY + 55
      endif  
    elseif (candleBasePos = 5)
      candleBaseOX = oX + 496 - 1
      candleBaseOY = oY + 496 - 1
      candleX = -1 
      candleY = -1
    elseif (candleBasePos = 6)
      candleBaseOX = oX + 3 
      candleBaseOY = oY + 496 - 1
      candleX = 1 
      candleY = -1
    elseif (candleBasePos = 7)
      candleBaseOX = oX + 3
      candleBaseOY = oY + 274 + 3
      candleX = 1 
      candleY = 1
    elseif (candleBasePos = 8)
      candleBaseOX = oX + 154 - 1
      candleBaseOY = oY + 274 + 3
      candleX = -1
      candleY = 1
    endif
    
    candleR = 5            // Radius of the candle base (corresponds to the candle itself).
    candleX = candleX * 30 // X position of the candle inside the semicircle.
    candleY = candleY * 30 // Y position of the candle inside the semicircle.
    
    // Draw the candle. 
    circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, candleColor, candleColor 
    
    // Draw the furnitures
    if(getCheckBox("CBFurniture") == true)
      furnitureR = candleR * 2
      // room 1
      x = random(124)+10
      y = random(50)+70
      circle oX + x - furnitureR, oY + y - furnitureR, oX + x + furnitureR, oY + y + furnitureR, furnitureColor, furnitureColor
      // room 2
      x = random(104)+30
      y = random(50)+350
      circle oX + x - furnitureR, oY + y - furnitureR, oX + x + furnitureR, oY + y + furnitureR, furnitureColor, furnitureColor
      // room 3
      x = random(60)+350
      y = random(80)+400
      circle oX + x - furnitureR, oY + y - furnitureR, oX + x + furnitureR, oY + y + furnitureR, furnitureColor, furnitureColor
      // room 4
      x = random(20)+300
      y = random(1)+150
      circle oX + x - furnitureR, oY + y - furnitureR, oX + x + furnitureR, oY + y + furnitureR, furnitureColor, furnitureColor
    endif   
  return


  // ======================================================================
  // Finite Satte Machine
  // ======================================================================
  finiteStateMachine:
     while true
      goSub screen_1
       if(state == WAIT)
         goSub waitState
       elseif(state == NAVIGATE)
         goSub navigateState_v2
       elseif(state == APPROACH)
         goSub approachState
       elseif(state == PUT_OUT)
         goSub putOutStateV2    
       endif  
       getButton btn
       if(btn == "STOP") then state = WAIT
     wend
  return

  waitState:
    goSub setLedOFF
    enableButton "START", true
    repeat
      getButton btn   
      if(btn == "RESET")
        goSub initializeVariables 
        goSub drawArena
        goSub initializeRobot
      endif
    until btn == "START" 
    
    enableButton "START", false
    enableCheckBox "CBAStart", false

    goSub maneuverToExitWhiteCircle
    state = NAVIGATE
  return


  navigateState_v2:

    if(rRange(0) < DIST_FRONT_LIMIT) then rTurn -90    
    goSub checkBumpers
    
    dist = rRange(90*goToIslandRoom)
    if(dist >= DIST1 and dist <= DIST2)
      rForward 1
    elseif(dist < DIST1)
      rTurn -1*goToIslandRoom
      rForward 1
    elseif(dist > DIST2)
      rTurn 1*goToIslandRoom
      rForward 1
    endif      
      
    gosub getFloorTag   

    // Verificar quando entra ou sai do quarto 
    if(tag == LINE_TAG and inRoom == true)
        inRoom = false
    elseif(tag == LINE_TAG and inRoom == false)
        inRoom = true
    endif

    if(tag == LINE_TAG and flameBurning == true)
      rooms = rooms + 1    
      call moveForward(50)
      if(rooms == 2) 
        rTurn 45
        goSub scanRoom
      else
        goSub scanRoom
      endif
      if(flameInRoom == true)
        goSub getFlameDirection
        if(flameDirection != 0)
          goSub setLedON 
          state = APPROACH  
          return
        endif  
      else
         if(rooms == 2) then rTurn -45
         goSub maneuverToGoToNextRoom
      endif    
    elseif(tag == LINE_TAG and flameBurning == false and inRoom == true)
         goSub maneuverToGoToTheEnd
    elseif(tag == CIRCLE_TAG and flameBurning == false)
        goSub maneuverToStop
        state = WAIT
    elseif(tag == CIRCLE_TAG and flameBurning == true)
        goSub meneuverToGoToIslandRoom
        goToIslandRoom = -1
    endif    
  return


  approachState:
     // Se achar um objeto, tenha desviar
     goSub checkBumpers
     goSub getFurnitureDirection
     if(furnitureDirection != 0) then goSub maneuverToDodgeTheFurniture  
     goSub getFlameDirection
     
     if(flameDirection == 0)
       goSub meneuverToScanRoom
       goSub scanRoom
     elseif(flameDirection == 1)     
       rTurn 2
     elseif(flameDirection == 2)     
       rTurn 1
     elseif(flameDirection == 3)
       if(rRange(0) < 15)
         state = PUT_OUT
         return
       endif  
       rForward 1
     elseif(flameDirection == 4)                        
       rTurn -1
     elseif(flameDirection == 5)            
       rTurn -2
     endif
  return

  putOutStateV2:
     x = random(99) + 1
     if(x < 75)
       circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, GRAY, GRAY       
     endif
     
     rForward -10
     goSub getFlameDirection
     if(flameDirection != 0)
       goSub setLedON 
       state = APPROACH
       return
     endif
     goSub setLedOFF  
     flameBurning = false
     if(returnTrip == true)
       state = NAVIGATE
     else
       state = WAIT
     endif
  return


  // ======================================================================
  // Actuator functions
  // ======================================================================
  maneuverToExitWhiteCircle:
   repeat
     rForward 1
     goSub getFloorTag
   until tag == NO_TAG  
  return
  
  maneuverToStop:
    call moveForward(50)
    rTurn 270
  return

  maneuverToGoToNextRoom:
     rTurn 210
     call moveForward(30)
     inRoom = false
   return

  meneuverToGoToIslandRoom:
    call moveForward(50)
    rTurn 270
    call moveForward(50)
  return

  maneuverToGoToTheEnd:
     inRoom = false
     rForward -10
     rTurn 270
  return

  maneuverToDodgeTheFurniture:
      if(rRange(90) < rRange(-90))
        rTurn -90
        call moveForward(20)
        rTurn 90
        call moveForward(1)
      else
        rTurn 90
        call moveForward(20)
        rTurn -90
        call moveForward(1)
      endif
  return

  meneuverToScanRoom:
    if (rooms == 1)
      rTurn 90
      rForward 5
      rTurn -90
    elseif(rooms == 2)
      rForward 5
    elseif(rooms == 3)
      rTurn 10
      rForward 10
    elseif(rooms == 4)
      rTurn -90
      rForward 10
      rTurn 90
    elseif(rooms == 5)
      rForward 2
    endif
  return

  Sub moveForward(dist):
    for d = 1 to dist
      rForward 1
      delay 10
    next  
  return




  // ======================================================================
  // Sensor functions
  // ======================================================================

  checkBumpers:

    bmp = rBumper()
    
    if(bmp & 4)      //0   bmp = 1001 & 4 = 0100 = 0000  bmp = x1xx  &  4 = 0100 = x1xx !=0
      rForward -10
      rTurn -45
    elseif(bmp & 8)
      rForward -10
      rTurn 45
    elseif(bmp & 2)
      rForward -10
      rTurn -45  
    endif  
  return

  getFlameDirection:
    flameDirection = 0
    
    for i = -12 to 12
      if(rLook(i) == RED)
        if(i < - 8)
          flameDirection = 5
        elseif(i < -2)
          flameDirection = 4
        elseif(i  < 2)
          flameDirection = 3
        elseif(i < 8)
          flameDirection = 2
        else
          flameDirection = 1
        endif           
      endif
    next
  return

  getFurnitureDirection:
    furnitureDirection = 0
    for i = -8 to 8
      if(rLook(i) == YELLOW)
        if(i < - 8)
          furnitureDirection = 5
        elseif(i < -2)
          furnitureDirection = 4
        elseif(i  < 2)
          furnitureDirection = 3
        elseif(i < 8)
          furnitureDirection = 2
        else
          furnitureDirection = 1
        endif  
      endif
    next
  return

  getFloorTag:
    if(rSense(WHITE) & 2)
      rForward 5
      if(rSense(WHITE) & 2)
        tag = CIRCLE_TAG
      else
        tag = LINE_TAG
      endif
    else
      tag = NO_TAG
    endif        
  return

  scanRoom:
    for ang = 1 to 45
      gosub getFlameDirection
      if(flameDirection != 0)
        flameInRoom = true
        return
      endif
      rTurn 2
      delay 10
    next
    
    for ang = 1 to 45
      rTurn -2
      delay 10
    next
    
    for ang = 1 to 45
      gosub getFlameDirection
      if(flameDirection != 0)
        flameInRoom = true
        return
      endif
      rTurn -2
      delay 10
    next
    
    for ang = 1 to 45
      rTurn 2
      delay 10
    next
  return


  // ======================================================================
  // Interface functions
  // ======================================================================
  setLedON:
    circleWH oX + 200, oY - 43, 35, 35, BLACK, RED
  return

  setLedOFF:
    circleWH oX + 200, oY - 43, 35, 35, BLACK, GRAY
  return

  cbHandler:
    cb = lastCheckbox()
    if(cb == "CBPen") 
      if(getCheckBox("CBPen") == true)
        rPen Down, penColor
      else
        rPen Up
      endif   
    elseif(cb == "CBAStart")
      arbitraryStart =getCheckBox("CBAStart")
      //goSub startArbitraryStart
    elseif(cb == "CBFurniture")
      furniture = getCheckBox("CBFurniture")
    elseif(cb == "CBRTrip")
      returnTrip = getCheckBox("CBRTrip")
    endif
    onCheckBox cbHandler
  return


  sub header(x, y, str, size):
    xyText x, y, str, "Verdana", size, FS_BOLD, RED, WHITE  
  return


  screen_1:
    if(state == 0)
      stateName = "WAIT    "
    elseif(state == 1)
      stateName = "NAVIGATE"
    elseif(state == 2)
      stateName = "APPROACH" 
    elseif(state == 3)
      stateName = "PUT OUT "    
    endif
    xyString 10, 340, "State: " + stateName
    
    xyString 10, 360, "Rooms: " + rooms
    
    xyString 10, 380, "Flame: " + flameDirection  

    xyString 10, 400, "flameBurning: "+ flameBurning

    xyString 10, 420, "goToIslandRoom: "+ goToIslandRoom

    xyString 10, 440, "flameInRoom: "+ flameInRoom
   
    xyString 10, 460, "inRoom: "+ inRoom  

    xyString 10, 480, "returnTrip: "+ returnTrip

    xyString 10, 500, "furnitureDirection: "+ furnitureDirection        
    
return
