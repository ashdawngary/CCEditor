--ad3aUsVw
string.rpad = function(str, len, char)
    return str..string.rep(char,len-#str)
end



y = colors.yellow
b = colors.lightBlue;
o = colors.orange
trigtarget = {" and"," or"," no"," function"," local"," do","if","else","elseif"," then ","while","repeat","until","print","end"}
trigresults = {y,y,y,o,o,y,y,y,y,y,y,b,o,b,o}
y = "4";
b = "9"
o = "1"
qText = ""
qFore = ""
qBack = ""
cBackgroundColor = "f" -- current black background
cForegroundColor = "0" -- current white foreground
trigblitcode = {y,y,y,o,o,y,y,y,y,y,y,b,o,b,o}
args = {...}
HEADER_SIZE = 2;
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num*mult + 0.5)/mult;
end
function isDigit(c)
	local p = string.byte(c)
	return p >= 48 and p<= 57;
end
function genFontTable(ML)
	local isString = false;
	local comment = false;
	local cidx = 1
	local vp = "";
	fonts = {}
	while (cidx <= #ML) do
		if(ML:sub(cidx,cidx) == "\"" or ML:sub(cidx,cidx) == "\'") then
			isString = not isString
		end
		if(ML:sub(cidx-1,cidx) == "--") then
			comment = true;
		end
		
		if(comment) then
			fonts[cidx] = "d"
		elseif(isString or ML:sub(cidx,cidx) == "\"" or ML:sub(cidx,cidx) == "\'") then
			fonts[cidx] = "e"
		elseif(isDigit(ML:sub(cidx,cidx))) then
			fonts[cidx] = "3"
		elseif(ML:sub(cidx,cidx) == "#") then
			fonts[cidx] = "3"
		else
			local foundmatch = false;
			for i = 1,#trigtarget do
				if(ML:sub(cidx-#trigtarget[i]+1,cidx) == trigtarget[i]) then
				--print("matched: "..trigtarget[i])
					foundmatch = true;
					for overwriteindex=cidx-#trigtarget[i]+1,cidx do
						fonts[overwriteindex] = trigblitcode[i];
					end
				end
			end
			if(foundmatch == false) then
				fonts[cidx] = "0";
			end
		end
		cidx = cidx+1;
		
	end
	return fonts;
end
function qWrite(car) 
	qText = qText..car
	qFore = qFore..cForegroundColor;
	qBack = qBack..cBackgroundColor;
end
function qClear()
	qText = ""
	qFore = ""
	qBack = ""
end
function qPush(mon,y)
	mon.setCursorPos(1,y)
	mon.blit(qText,qFore,qBack)
	qClear()
end
function renderProgram(name,cline,ccol,cdata,mon,linestoRender)
	srend = os.time()
    -- render on advapi?
	program = split(cdata,"\n")
	w,l = mon.getSize()
	offsetrender = 0
	l = l-3; -- keep 3 for debug space.
	if(ccol > w-3) then
		offsetrender = ccol-w+3
	end
	start_line = math.max(0,cline-l+4);
	mon.setTextColor(colors.white)
	mon.setBackgroundColor(colors.black)
	mon.setCursorPos(1,1)
	--mon.write("Current File: ");
	mon.setTextColor(colors.red);
	mon.write(name);
	mon.setTextColor(colors.white)
	local paddedline = string.format("%03d", cline);
	local paddedcol =  string.format("%03d",ccol);
	mon.write("[Line "..paddedline.."] [Col"..paddedcol.."]")	
	for current_line = 0,linestoRender do
		local c = current_line + start_line+1;
		if(program[c] ~= nil) then
			toDisplay = program[c]:sub(offsetrender,offsetrender+w);
		else
			toDisplay = string.rep(" ",w)

		end
		mon.setTextColor(colors.white)
		cForegroundColor = "0"
		
		--mon.setCursorPos(1,c+HEADER_SIZE-start_line); 
		if(c ~= cline) then
			mon.setBackgroundColor(colors.black)
			mon.setTextColor(colors.white)
			dtx = string.rpad(toDisplay,w+1," ");
			fonttable = genFontTable(dtx);
			for font_index=1,#dtx do
				cForegroundColor = fonttable[font_index]
				qWrite(dtx:sub(font_index,font_index))
			end
		else
			local fonttable = genFontTable(toDisplay);
			for disp = 0,w do
				r = toDisplay:sub(disp+1,disp+1);
				renderunderscore = false
				if(offsetrender + disp+1 == ccol) then
					if(r == " ") then
						cBackgroundColor = "d"
					else
						cForegroundColor = "d"
					end
					renderunderscore = true		
				else
					if(fonttable[disp+1] ~= nil) then
						cForegroundColor = fonttable[disp + 1]
					else
						cForegroundColor = "0"
					end
					cBackgroundColor = "f"
				end
				
				if(#toDisplay:sub(disp+1,disp+1)== 1) then
					qWrite(toDisplay:sub(disp+1,disp+1));
				elseif((renderunderscore == true)and (#toDisplay:sub(disp+1,disp+1) == 0)) then
					qWrite("_");
				elseif (#toDisplay:sub(disp+1,disp+1) == 0) then
					qWrite(" ")
				else
				end
			 end
		end
		
		qPush(mon,c+HEADER_SIZE-start_line);
	end
	--mon.setCursorPos(1,l+1)
	--mon.setTextColor(colors.blue);
	--mon.write("Debug: "..w.." "..l.." "..offsetrender.." "..start_line)
 erend = round(os.time()-srend,4)
 mon.setCursorPos(35,1)
 mon.setTextColor(colors.green)
 mon.write(erend.." on "..#cdata.."B")	
end


function split(str, on)
  local ret = {};
  local s, e;
  while str:find(on) do
    s, e = str:find(on);
    table.insert(ret, str:sub(0, s - 1));
    str = str:sub(e + 1);
  end
  table.insert(ret, str);
  return ret;
end