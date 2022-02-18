local global = {}
global.session = {}
global.session.currentType = nil;
global.session.currentLevel = nil;
global.session.isFirstRun = false;


-- Calculate x and y based on percentage
function global.getXAndYByPerc(screenW,screenH,calculedWithMiddle,xPercentage,yPercentage,object)
  local xCalculed = screenW * (xPercentage / 100 ) --  - (object.width / 2)
  local yCalculed = screenH * (yPercentage / 100 ) - (object.height / 2)
   if calculedWithMiddle == true then
  	xCalculed = xCalculed - (object.width / 2)
   end
  return xCalculed, yCalculed
end

function global.getXbyPerc(screenW,object,xPercentage,calculatedWithMidle)
	local xCalculed = screenW * (xPercentage / 100 ) 
	if calculedWithMiddle == true then
  	xCalculed = xCalculed - (object.width / 2)
   end
   return xCalculed
end

function global.getYbyPerc(screenH,object,yPercentage,calculatedWithMidle)
	local yCalculed = screenH * (yPercentage / 100 ) 
	if calculedWithMiddle == true then
  		yCalculed = yCalculed - (object.width / 2)
   end
   return yCalculed
end

-- calculate width and heigth based on percentage
function global.getWithAndHeigthByPerc(screenW,screenH,widthPercentage,heigthPercentage)
  local widthCalculed = screenW * (widthPercentage / 100 )
  local heightCalculed = screenH * (heigthPercentage / 100 )
  return widthCalculed, heightCalculed

end

return global

