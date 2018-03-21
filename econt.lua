-- editor controller
args = {...}


if(#args ~= 1) then
	print("No File Specified.")
 return;
end

function addChar(cline,ccol,cdata,car)
	scanline = 1
	scancol = 1
	cidx = 0
	while(scanline ~= cline or scancol ~= ccol) do
		cidx = cidx + 1;
		if(cdata:sub(cidx,cidx) == '\n') then
   --print(cidx.." has a newline.")
			scanline = scanline + 1
			scancol = 1
		else 
			scancol = scancol + 1
		end
	end
	print("Located "..cline.." "..ccol.." at "..cidx)
 return cdata:sub(0,cidx)..car..cdata:sub(cidx+1,#cdata)
end

function deleteChar(cline,ccol,cdata)
 scanline = 1
 scancol = 1
 cidx = 0
	while(scanline ~= cline or scancol ~= ccol) do
		cidx = cidx + 1;
		if(cdata:sub(cidx,cidx) == '\n') then
			scanline = scanline + 1
			scancol = 1
		else 
			scancol = scancol + 1
		end
	end
	return cdata:sub(0,cidx-1)..cdata:sub(cidx+1,#cdata)
end

os.loadAPI("demo1")


t = fs.open(args[1],"r")
contents = t.readAll()
contents = string.gsub(contents,"\r","\n")
contents = string.gsub(contents,"\t","   ")

ls = demo1.split(contents,"\n")
t.close()
mon = peripheral.wrap("monitor_152")
mon.clear()
ln = 1
col = 1
w,l = mon.getSize()
function EDITMODE_KEY(kc) then
	if(kc == 200) then
		ln = ln -1
		col = math.min(col,#ls[ln]+1)
	end
	if(kc == 203) then
		col = col-1
		if(col == 0) then
			ln = ln -1;
			col  = #ls[ln] + 1;
		end
	end
	if(kc == 205) then
		col = col +1
		if(col == #ls[ln] + 2) then
			col = 1
			ln = ln + 1
		end
	end
	if(kc == 208) then
		ln = ln + 1
		col = min(col,#ls[ln]+1)
		
	end
	if(kc == 14) then
		contents = deleteChar(ln,col,contents)
		if(col > 1) then
			col = col - 1;
		elseif(col == 1) then
			col = #ls[ln-1] + 1
			ln = ln - 1;
		end
		ls = demo1.split(contents,"\n")

	end
	if(kc == 28) then
		contents = addChar(ln,col,contents,"\n")
		ln = ln + 1;
		col = 1
		ls = demo1.split(contents,"\n")

	end
end
function EDITMODE_CHAR(kc) then
	contents = addChar(ln,col,contents,kc)
	col = col + 1
	ls = demo1.split(contents,"\n")
end
MODE = "EDITMODE"
while true do
	ty,kc,p1,p2 = os.pullEvent()
	--print(tostring(ty).." "..tostring(kc).." "..tostring(p1).." "..tostring(p2))
	if(ty == "key") then
		if(MODE == "EDITMODE") then
			
		elseif(mode == "MENUMODE") then
			
		end
	elseif(ty == "char") then
		if(MODE == "EDITMODE") then
				EDITMODE_CHAR(kc)
		elseif(mode == "MENUMODE") then
		
		end
	end
        --mon.clear()
        demo1.renderProgram(args[1],ln,col,contents,mon,l-6)
end