pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--gametest
--by noah

momentum_x=0
on_wall=false
airborn=true
gvalue=5
fvalue=0.1
got_dash_power_up=false
rain={}
objects={}



rope={
	sprvalue=50,
	step=0,
	rand=1,
	draw=function(self,x,y)
	 line(x*8+4,y*8+8,x*8+4-self.rand,y*7+36,1)
	end,
	update=function(self)
		self.step+=1
		if self.step%40 == 0 then
			self.rand = rnd(4)
	 end 
	end
}

add(objects,rope)

collectible={
	sprvalue=8,
	has_touch=false,
	rand=3,
	step=0,
	draw=function(self)
		pal(3,self.rand)
		self.step+=1
	end,
	update=function(self,x,y)
		if self.step%30==0 then
	 	self.rand=rnd(15)+1
		end
		if hit(player.x,player.y,self).sprvalue.bottom then
			self.has_touch=true
			sfx(4)
			mset(x+map_index.x*16,y+map_index.y*16,0)
			start_particule(x,y,map_index.x,map_index.y)
		end
	end,
	offset={
		left=2,
		right=2,
		top=2,
		bottom=2
	}
}
add(objects,collectible)


player={
	x=30,
	y=150,
	hitbox={x=2,y=3,w=4,h=5},
	spr=1,
	step=0,
	flip=false
}

visual_player={
	x=player.x,
	y=player.y
}

ground={
	flag=3
}

spike={
	flag=0,
	up={
		sprvalue=19,
		offset={top=5}
	},
	down={
		sprvalue=23,
		offset={bottom=2}
	},
	left={
		sprvalue=21,
		offset={left=3}
	},
	right={
		sprvalue=22,
		offset={right=3}
	}
}

map_index={
	x=0,
	y=0
}

dash={
	cooldown=20,
	target=10,
	speed=3,
	step_x=0,
	step_y=0,
	can=true,
	direction={
		up=false,
		down=false,
		left=false,
		right=false
	}
}

---------------
building={}
local p
for p=0,64 do
	local buld={
		rand=rnd(3)+10,
		value=p,
		flip= rnd(2)<1
	}
	add(building,buld)			
end
----------------
--collectible particule

function start_particule(x,y,sx,sy)
 local i

 	in_colpart={}
 
 for i=0,6 do
  local colpart={
  	x=x*8+4,
  	y=y*8+4,
  	sx=sx,
  	sy=sy,
  	speed1=16,
  	speed2=35,
  	dx=rnd(2)-1,
  	dy=rnd(2)-1,
  	col=rnd(16)-1,
  	first_step=17
  }
 	add(in_colpart,colpart)
 end
end

function draw_all_colpart()
	if collectible.has_touch then
		foreach(in_colpart,draw_colpart)
	end
end


function draw_colpart(part)

	pset(part.x-(map_index.x-part.sx)*128,part.y-(map_index.y-part.sy)*128,part.col)

	part.x+=part.dx
	part.y+=part.dy
	
	if (part.speed1 >0) part.speed1-=1
	
	part.first_step-=1
	
	if part.first_step >0 then
	
		part.dx=part.speed1*part.dx/10
		part.dy=part.speed1*part.dy/10
	
	else
	
		if part.x-(map_index.x-part.sx)*128!=player.x+4 or part.y-(map_index.y-part.sy)*128!=player.y+4 then
			part.dx=(visual_player.x+4-(part.x-(map_index.x-part.sx)*128))/part.speed2
			part.dy=(visual_player.y+4-(part.y-(map_index.y-part.sy)*128))/part.speed2
			if part.speed2>0 then
				part.speed2-=1
				if (part.speed2<20) part.speed2+=0.3
			else
				part.speed2=0
				in_colpart={}
			end
		end
	end
	
end

--rain particule--

function draw_rain()

	if map_index.y < 2 then
  
 	local tears={
 					x=map_index.x+10+rnd(190),
 					y=map_index.y+rnd(60),
 					life=2
 					}
 
 	add(rain,tears)
 	
 	foreach(rain,make_tears)
 
 end
end

function make_tears(tears)

	line(tears.x-1,tears.y+5,tears.x,tears.y,12)
	tears.x-=10
	tears.y+=70
	tears.life-=1
	if tears.life <=0 then
		del(rain,tears)
	end
	
end

---------------


function update_map_index()
 map_index={
 	x=(player.x+4)/128-((player.x+4)%128)/128,	
 	y=(player.y+4)/128-((player.y+4)%128)/128
 }
end

function update_player_room()
	visual_player.x=player.x
 visual_player.y=player.y
 visual_player.x=visual_player.x-map_index.x*128
 visual_player.y=visual_player.y-map_index.y*128

end

function _init()

end

---------collision-----------
function hit(x,y,obj)

	local result={
		sprvalue={
			left=false,
			right=false,
			top=false,
			bottom=false
		},
		flag={
			left=false,
			right=false,
			top=false,
			bottom=false
		}
	}

--left--
	if obj.offset and obj.offset.left then
 	xi=	x+player.hitbox.x-1+obj.offset.left
	else
		xi=	x+player.hitbox.x-1
	end
	for yi = y+player.hitbox.y,y+player.hitbox.y+player.hitbox.h-1 do
		id= mget(xi/8,yi/8) 
		if id == obj.sprvalue then
			result.sprvalue.left=true
		end
		if obj.flag then
 		if fget(id,obj.flag) then
 			result.flag.left=true
 		end
 	end
	end
	
--right--
	if obj.offset and obj.offset.right then
		xi=	x+player.hitbox.x+player.hitbox.w-obj.offset.right
	else
		xi=	x+player.hitbox.x+player.hitbox.w
	end
	for yi = y+player.hitbox.y,y+player.hitbox.y+player.hitbox.h-1 do
	 id =mget(xi/8,yi/8)
 	if id == obj.sprvalue then
 		result.sprvalue.right=true
 	end
 	if obj.flag then
 		if fget(id,obj.flag) then
 			result.flag.right=true
 		end
 	end
 end
	
--top--
	if obj.offset and obj.offset.top then
		yi=	y+player.hitbox.y-1+obj.offset.top
	else
		yi=	y+player.hitbox.y-1
	end
	for xi = x+player.hitbox.x,x+player.hitbox.x+player.hitbox.w-1 do
		id=mget(xi/8,yi/8)
		if id == obj.sprvalue then
			result.sprvalue.top=true
		end
 	if obj.flag then
 		if fget(id,obj.flag) then
 			result.flag.top=true
 		end
 	end
	end
	
	
--bottom--
	if obj.offset and obj.offset.bottom then
		yi=	y+player.hitbox.y+player.hitbox.h-obj.offset.bottom
	else
		yi=	y+player.hitbox.y+player.hitbox.h
	end
	for xi = x+player.hitbox.x,x+player.hitbox.x+player.hitbox.w-1 do
		id= mget(xi/8,yi/8)
		if id == obj.sprvalue then
			result.sprvalue.bottom=true
		end
 	if obj.flag then
 		if fget(id,obj.flag) then
 			result.flag.bottom=true
 		end
 	end
	end
	
	return result
end

----------------
--momentum------
function momentum(z)
	z=z+momentum_x
	return z
end

function slow_down()

	if not btn(⬅️) and not btn(➡️) then
		if (momentum_x > 0) momentum_x -=0.2
		if (momentum_x < 0)	momentum_x +=0.2

	end
end
----------------

function grounded(x,y)
	return hit(x,y,ground).flag.bottom or hit(x,y,spike).flag.bottom and not hit(x,y,spike.up).sprvalue.bottom
end

function wall_left(x,y)
 return hit(x,y,ground).flag.left or (hit(x,y,spike).flag.left and not hit(x,y,spike.right).sprvalue.left)            
end

function wall_right(x,y)
 return hit(x,y,ground).flag.right or hit(x,y,spike).flag.right and not hit(x,y,spike.left).sprvalue.right
end

function ceiling(x,y)
 return hit(x,y,ground).flag.top or hit(x,y,spike).flag.top and not hit(x,y,spike.down).sprvalue.top
end

---gravity-----------

function fall(x,y)
 local next_y = y+fvalue 
 if grounded(player.x,next_y) then
 	airborn=false 
	 while grounded(player.x,next_y-1) do
	 	next_y= next_y-1
	 end
	 gvalue=5
	 reset_fvalue()
	else
	 fvalue=fvalue+0.18
 	if (fvalue < 0.5) fvalue=fvalue+0.2
	end 	
	return next_y
	
end

----------------
--sounds--------

function sound_effects()
	--if map_index.y< 2 then
	--	sfx(2,3)
	--else
		sfx(3,3)
	--end
end
----------------

---player action-------

--resets----------
function reset_fvalue()
	fvalue=0.1
end


function reset_dash()
	dash.step_x=0
	dash.step_y=0
	dash.can=true
end


function dash_direction_reset()
	
	dash.direction={
		up=false,
		down=false,
		left=false,
		right=false
	}
	dash.cooldown=0	
 reset_fvalue()
	dash.can=false
	
end

-----------------
--dash----------

function can_player_dash()
	
	if dash.direction.up or dash.direction.down or dash.direction.right or dash.direction.left then
		is_dashing=true
	else
		is_dashing=false
	end

	if dash.cooldown<20 then
		dash.cooldown+=1
	end

	if dash.cooldown==20 then
	
		if grounded(player.x,player.y) then
			if not is_dashing then
				reset_dash()
			end
		end
	
 	if btn(➡️) then
 		if btnp(🅾️) then
 			if not wall_right(player.x,player.y) then
 				if dash.can then
 					dash.direction.right=true			
 				end
 			end 
 		end
 	end
 	
 	if btn(⬅️) then
 		if btnp(🅾️) then
 			if not wall_left(player.x,player.y) then
 				if dash.can then
 					dash.direction.left=true			
 				end
 			end 
 		end
 	end
 	
 	if btn(⬆️) then
 		if btnp(🅾️) then
 			if not ceiling(player.x,player.y) then
 				if dash.can then
 					dash.direction.up=true			
 				end
 			end 
 		end
 	end
 	
 	if btn(⬇️) then
 		if btnp(🅾️) then
 			if not grounded(player.x,player.y) then
 				if dash.can then
 					dash.direction.down=true			
 				end
 			end 
 		end
 	end
 		
	end
	
end

function player_dashing()

	if dash.direction.right then
		if dash.step_x<dash.target then
			player.x+=dash.speed
			dash.step_x+=dash.speed
		else
			dash_direction_reset()
			
		end
	end
	
		if dash.direction.left then
		if dash.step_x<dash.target then
			player.x-=dash.speed
			dash.step_x+=dash.speed
			
		else
			dash_direction_reset()
			
		end
	end
	
	if dash.direction.up then
		if dash.step_y<dash.target then
			player.y-=dash.speed
			dash.step_y+=dash.speed
		else
			dash_direction_reset()
		end
	end
	
	if dash.direction.down then
		if dash.step_y<dash.target then
			player.y+=dash.speed
			dash.step_y+=dash.speed
		else
			dash_direction_reset()
		end
	end
	
end
---------------------

function player_jump()
	local next_y = player.y-gvalue
	if (btn(❎)) then
		jump_anim()
 	if not ceiling(player.x,next_y) then
  	sfx(0)
  	else
		while ceiling(player.x,next_y) do
			next_y=next_y+1
		end
 		player.y=next_y-1
	 	gvalue=0
			airborn=true
 end
   player.y = player.y-gvalue
 	 if (gvalue > 0) then   	 
    gvalue = gvalue-0.8
   else
   	gvalue=0
   	airborn=true
 	 end 
 	else
 		if (gvalue != 0) then
 			if( not grounded(player.x,player.y)) airborn=true
 		end 
 	end
end

function player_move()
 
 local is_right_wall
 
	if not wall_left(player.x,player.y) and not wall_right(player.x,player.y) then
		slow_down()
	else
		momentum_x=0
	end
	
	if btn(⬅️) then
		if not wall_left(player.x,player.y)  then
		 if (momentum_x > -0.9) momentum_x-=0.2
		else
			if airborn then
			 is_left_wall =true
			 wall_sliding()
			end
		end
	end
	
	if btn(➡️) then
		if not wall_right(player.x,player.y) then	
		 if (momentum_x < 0.9) momentum_x+=0.2
		else
			if airborn then
			 is_left_wall=false
				wall_sliding()
			end
		end
	end
	
	player.x= momentum(player.x)

end

	

function jump_anim()
		player.spr=7
end

function walk_anim()

 if not airborn then
 	player.spr=1+player.step/2
 	player.step=(player.step+1)%8
 	if (momentum_x == 0) then
 		player.spr=1
 	else
 		player.flip= momentum_x<0
 	end
	else
		player.spr=6
	end
	
	--looking up and down
	if btn(⬆️) and not btn(⬅️) and not btn(➡️) and not airborn then
	 player.spr=7	 
	end
	if btn(⬇️) and not btn(⬅️) and not btn(➡️) and not airborn then
	 player.spr=6	 
	end
	--
		
end


function wall_sliding()
	on_wall=true
 player.y=player.y+rnd(1)
 reset_fvalue()
	gvalue=5
	player.spr=5
	player.flip=  is_left_wall
end

function is_spike()
	

	if hit(player.x,player.y,spike.up).sprvalue.top or hit(player.x,player.y,spike.down).sprvalue.top or hit(player.x,player.y,spike.right).sprvalue.left or hit(player.x,player.y,spike.left).sprvalue.right then
		player_die()
	end		




	
end


function player_die()
		player.x= 14
		player.y=132
		fvalue=0
		sfx(1)

end

function fake_wall()

	local w
	local z
	for w=0,16 do
		for z=0,16 do
			if	mget(w+map_index.x*16,z+map_index.y*16) == 20 then
				spr(20,w*8,z*8)
			end
		end
	end
end

function draw_building(buld)

	spr(buld.rand,buld.value*8,-map_index.y*32+90,1,1,buld.flip)
	
end


function draw_background()

if map_index.y < 2 then
		foreach(building,draw_building)				
	local i
		for i=0,128 do
			if i%2==0 then
				pset(i,89-map_index.y*32,8)
			end
			if i%4==0 then
				pset(i+1,87-map_index.y*32,8)
			end
			
		end
	end
end







-->8
function make_objects(obj)

	local x
	local y
	for x=0,16 do
		for y=0,16 do
			if	mget(x+map_index.x*16,y+map_index.y*16) == obj.sprvalue then
 			obj:draw(x,y)
 			obj:update(x,y)
 		end
		end
	end
end


function _update()

	sound_effects()
--update function--

	update_map_index()
	update_player_room()

	


--animation_____

	walk_anim()
	

--passive test--

	is_spike()
	
---------------
 player_move()
 
 if got_dash_power_up then
 	can_player_dash()
 	player_dashing()
 end
 
 
	if airborn and not is_dashing then
  player.y= fall(player.x,player.y)
 else
 	player_jump()
 end
 
end



function _draw()
	cls()	
---------------
--bachground----
	
	draw_background()
-----------------

	map(map_index.x*16,map_index.y*16)
	spr(player.spr,visual_player.x,visual_player.y,1,1,player.flip)
---particule---------
 
 draw_rain()
 draw_all_colpart()

	--passif test drawing--
	fake_wall()
	
	
 foreach(objects,make_objects)

end

__gfx__
00000000000000000000000000222200000000000000000000000000000000000000000066666666888888888888888888888888000000000000000000000000
00000000002222000022220002227220002222000022220000222200002272000000000061111116888888888888888888888888000000000000000000000000
00700700022272200222722002707070022272200227222002227220022070200033330061667616008880080088888808888800000000000000000000000000
00077000027070700270707002777770027070700707072002777770022777200033330061676616000880080008880000888800000000000000000000000000
00077000027777700277777000777700027777700777772002707070027777700033330061766616000800000008880000080000000000000000000000000000
00700700007777000077770000cfcf00007777000077770000777700007777000033330061666616000800000000880000000000000000000000000000000000
0000000000cfcf0000cfcf700700007007cfcf0000fcfc7000cfcf0000cfcf000000000061111116000000000000000000000000000000000000000000000000
0000000000c00c000070000000000000000007000007000000700700007007000000000066666666000000000000000000000000000000000000000000000000
11000000111111116666666600700070666666660766666666666600666666661111111166666666000000000000000000000000000000000000000000000000
11100000111111106666666607770777611111167766666666666670666666660100001066666666000000000000000000000000000000000000000000000000
11100000111111006666666666666666610070160766666666666677666666660010010066666666000000000000000000000000000000000000000000000000
111100001111000066666666666666666107001600666666666666706666666600011000666bb666000000000000000000000000000000000000000000000000
111100001111000066666666666666666170001607666666666666006666666600011000666bb666000000000000000000000000000000000000000000000000
11111110111000006666666666666666610000167766666666666670666666660010010066666666000000000000000000000000000000000000000000000000
11111111100000006666666666666666611111160766666666666677077707770100001066666666000000000000000000000000000000000000000000000000
11111111100000006666666666666666666666660066666666666670007000701111111166666666000000000000000000000000000000000000000000000000
000000111111111110000001666666660000000110000000dddddddddddddddddddddddd6666666d000000000000000000000000000000000000000000000000
000011111111111111000011060000600000001001000000d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
000011111111111110100101006006000000010000100000d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
000111111111111110011001000660000000100000010000d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
000111111111111110011001000660000001000000001000d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
000111111111111110100101006006000010000000000100d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
001111111111111111000011060000600100000000000010d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
111111111111111110000001666666661000000000000001d66666666666666d666666666666666d000000000000000000000000000000000000000000000000
008000000008000000000100600000061111111111111111d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
080000000000080000000100660000661111111100000000d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
008880000000800000000100606006061100101111111111d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
008888000088880000000100600660061101001100000000d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
088778800887788000000100600660061110001100000000d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
087777800877778000000100606006061100001100000000d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
087777800877778000001000660000661111111100000000d66666666666666d66666666d6666666000010000000000000000000000000000000000000000000
008778000087780000001000600000061111111111111111ddddddddddddddddddddddddd6666666000010000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000512121210000000000000000000000000000000000000000000000000000000021212121210000000021212121212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000021212100000000000000514141410000000000000000000000000000000000000000000000000000000021212121219221210021212121212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002100000000000000514121410000000000000000000000000000000000000000000000000000000021722121212121214121212121212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000021212121000000000000cccc21410000000000000000000000000000000000000000000000000000000021212162212121214121212121212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000cccc51410000000000000000000000000000000000000000000000000000000021902121212121000000212121212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000cccc514100000000000000000000000000000000000000000000000000000000212121627221000000b1009321212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000212121410000000000000000000000000000000000000000000000000000000021712121832100000000009321212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072524292414100000000416341004121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021805283733232323290414141904121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021929191910000314141903232214121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021218282820041000041410000334221
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021212100714132323232414100330021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000909041414121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000071717121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021212100212121212121212121212121
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021212100212100000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002100000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002100000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002100000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002100212121000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002121000000210000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002100000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000002100000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000000000000300002100000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021210000000000000000002100000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021212121212121212121212100000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021212121212121212121212121212121
__gff__
0000000000000000000800000000000000000801000101010000080000000000000000080000080808080000000000000000000800000808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1200000000000000000000000012121212121200000000000000000000000000000000000000000000000000000000001200000000000000000000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000080000333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000333323232323232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000333323232323232323232323232323232323232323232300000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000333300002500333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000003300000025333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000003200000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000000000000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000330000000000000000000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000002412120000000000000000000000000000000000000000000000000000000000330000000000000000000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000000000000000000000240012120000000000000000000000000000000000000000000000000000000000330000000000000000000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000002222000000000024000012120000000000000000000000000000000000000000000000003300000000330000000000000000000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000002222000000002400000012120000000000000000000000000000000023232300000000003300000000330000000000000000000000333300000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000002222000000240000000012120000002200000000000000000000121223232323230000003300000000330000000000000000000000333300000000000000000000c8c8c8003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000002222000024000000002412120000002200000000000022000000121223232323000000223300000000330000000000000000000000333300000000000000000000c8c8c8003a00000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212000000002222002400000000240012120000132200000000000022000000121217170000000000223300000000330000000000000000000000333300000000000000000000c8c800001800000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000001212100008002212240000220024000000000000121717000000002422000000000000000022000000223300000000330000000000000000000000333300000000000000000000c8c8c8240025000000000000000000000000000000000000000000000000000000000000000000000000
120000000000000000000000000000121221000000222223232322232300001212170016220000000024002200000012121700002323231823330000c8c83300203410c8c8c8c8c8c8c83333c8c8c800c8c8c8c8c8c8c8c824c83000250000000000000000000000000000000000000000000000000000000000000000000000
1210000000000000000000000000001212210000001722000000223217171712160024122225000024000022000023121600000033000000223300c8c8c8330021212125c8c8c8c8c8c83333c8c8c800c8c8c8c8c8c8c82323232323232300000000000000000000000000000000000000000000000000000000000000000000
1221000000000000000000000000001212210000002222000000220000000012162400152200232300000022000000121600152323182323233300c823233320212121c825c8c8c8c8243333c8c8c800c8c8c8c8c8c8c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
1221000000000000000000000000201212211000002212130000220000000012120000152200003a00000022230000121624150000000000003300c80032333421212110c825c8c824c83333c8c8c800c8c8c8c8c8c8c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
1221100000000000000000002021212121212100002222001600220000000012122513122216002200002222221212121225151823232323233325c8c800332121212100c8c82524c8c83333c8c8c800c8c8c8c8c8c8c8c800000000000000000000000000000000000000000000000000000000000000000000000000000000
292121000000000020002021211212121212211000222200220022000000001212242512220000220000001512191919162412002200000022330025c8c833212121110000c82425c8c83322c8c8c800c8c8c8c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000000000
292121110000000021342121121212121212121100222200221222000000001216250025370000320000131414141219162512232323232300332323c8c83321212125000024c8c825c82222c8c8c800c8c8c8c8c8c8c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
293434102000002021211126122415121221210000222110221522000000001216002524222200000000151427141219162400002323333300222325c82420212121001818c8c8c8c8252223c8c8c800c8c8c800c8c8c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
2921212121002021171700001500151212211100222221211222220000000012121312381222000000000000121412191928000000002623270000c823202121212110000020c8c8353533330000c8000000c8c8c8c8c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
1227212134212111000000080000151212110000222212211122131300000019192425083916000023000000151412121919131700222213353922c820342121212121212121c8353523232323350000c8c8c8c8c800c8c8c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
1212212612282700000024121100391212000000131312111313121213000019192500232323232323230000151412131219190022223533172922202112121212212112122110352323232323233500c8c8c8c8c8000008c8c80000000000000000000000000000000000000000000000000000000000000000000000000000
1212282812131200121313121313121212131313121212131212121212131312121313121212121212121212121412121212121312221212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
__sfx__
000900000c0700a0000a000040000a000050000a000050000a0000a00022700344002c7002c700217002370024700267002770027700277000000000000000000000000000000000000000000000000000000000
001000001535015300000002730028300293002930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c6101061014610176101761015610116100e6100d6100b6100a610096100a6100c6100d6100e610106101461016610166101761014610116100f6100d6100d6100c6100d6100d6100b6100a6100a610
001000000161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610
0008000008630086200e610146001570015700157001570015700157001570007700097000b7000970009700097000670008700097000870008700087000a7000870007700077000670007700087000870008700
__music__
04 41424344

