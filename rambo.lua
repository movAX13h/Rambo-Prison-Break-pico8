-- rambo by movax13h, dec'15
intro=true
win=false
f=0
fshake=100
fflash=100
maxtime=30*60*5 --5 min
mwidth=32
mheight=32

--------------------------------
--game------------------------1-
game={}
game.reset=function()
  reload(0x2000,0x2000,0x1000)

  f=0
  fshake=100
  fflash=100
  win=false
  game.stats={t1=0,t2=0,t3=0,cops=0,doors=0,notes=0}
  game.npcs={}
  game.cops={}
  game.notes={}
  game.time=0
  
  p1.t1=0
  p1.t2=0
  p1.t3=0
  p1.f=0
  p1.x=122
  p1.y=120
  p1.dx=0
  p1.dy=0
  p1.sel=-1
  p1.esc=false --is escaping
  p1.walk=false
  p1.alive=true  
  p1.note=false
  p1.bot=false

  game.addnote(148,136,
    { "hey john!",
      "where are you?",
      "what?! again?",
      "*grml*",
      "understand.. well..",
      "are you sure?",
      "ok, i'll be waiting",
      "at the main entrance.",
      "meanwhile, keep cool,",
      "don't touch the cops!",
      "i just teleported an",
      "anti-personnel mine",
      "to your inventory.",
      "(hold [a] to open)",
      "you have 5 minutes.",
      "good luck my friend!"
    },0,1,0)

  game.addnote(8,78,
    { "yo! let me guess...",
      "you need more mines?",
      "here's another one.",
      "*click*"
    },0,1,0)

  game.addnote(200,16,
    { "take this biobot",
      "prototype v0.1!",
      "you can program them",
      "to chase cops and",
      "blast doors.",
      "have fun!"
    },0,0,1)

  game.addnote(31,136,
    { "try this turret!",
      "is has 4 bullets.",
      "the cops might be",
      "able to disable these",
      "turrets so use them",
      "wisely!"
    },1,0,0)
  
  game.addnote(28,54,
    { "you seem to run",
      "out of items fast!",
      "two more turrets",
      "for you!"
    },2,0,0)
  
  game.addnote(140,54,
    { "two more biobots",
      "should help you",
      "to get out of there!",
      "i'm waiting."
    },0,0,2)
  
  -- checking prisoner
  local cop=game.addnpc(4)
  cop.x=16
  cop.y=88
  cop.dir.x=1
  cop.dir.y=0
  cop.doortime=80
  cop.say="i'll keep an eye on you!"
  add(cop.dirs,{x=0,y=1})
  add(cop.dirs,{x=1,y=0})
  add(cop.dirs,{x=0,y=-1})
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=0,y=-1})
  add(cop.dirs,{x=1,y=0})

  -- patrol block left of prison
  cop=game.addnpc(4)
  cop.x=80
  cop.y=150
  cop.dir.x=1
  cop.dir.y=0
  cop.distract=true
  add(cop.dirs,{x=-1,y=1})
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=1,y=-1})
  add(cop.dirs,{x=0,y=-1})
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=0,y=1})
  add(cop.dirs,{x=1,y=0})

  -- cop top right in room
  cop=game.addnpc(4)
  cop.x=220
  cop.y=16
  cop.dir.x=1
  cop.dir.y=0
  cop.distract=true
  add(cop.dirs,{x=0,y=-1})
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=0,y=1})
  add(cop.dirs,{x=1,y=0})

  -- cop patrol left/right top  
  cop=game.addnpc(4)
  cop.x=140
  cop.y=40
  cop.dir.x=1
  cop.dir.y=0
  cop.distract=true
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=1,y=0})

  -- cop in room top of prison
  cop=game.addnpc(4)
  cop.x=110
  cop.y=60
  cop.dir.x=1
  cop.dir.y=0
  cop.distract=true
  add(cop.dirs,{x=0,y=1})
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=0,y=-1})
  add(cop.dirs,{x=1,y=0})
  
  cop=game.addnpc(4)
  cop.x=180
  cop.y=80
  cop.dir.x=-0.6
  cop.dir.y=-0.5

  --patrol left/right outside  
  cop=game.addnpc(4)
  cop.x=30
  cop.y=220
  cop.dir.x=1
  cop.dir.y=0
  cop.distract=true
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=1,y=0})

  --patrol left/right outside  
  cop=game.addnpc(4)
  cop.x=200
  cop.y=210
  cop.dir.x=1
  cop.dir.y=0
  cop.distract=false
  add(cop.dirs,{x=-1,y=0})
  add(cop.dirs,{x=1,y=0})

  
  --enable sliding doors
  local door
  for y=0,mheight do
    for x=0,mwidth do
      local s=mget(x,y)
      if fget(s,1) then
        --door hor
        door=game.addnpc(5)
        door.hor=true
        door.x=x*8
        door.y=y*8
        door.mx=x
        door.my=y
      elseif fget(s,2) then
        --door vert
        door=game.addnpc(5)
        door.hor=false
        door.x=x*8
        door.y=y*8
        door.mx=x
        door.my=y
      end
    end
  end
end

game.addnote=function(x,y,text,t1,t2,t3)
  local n={x=x,y=y,text=text,t1=t1,t2=t2,t3=t3}
  add(game.notes,n)
  return n
end

game.drwlvl=function()
  pal(14,0)
  map(0,0,0,0,mwidth,mheight)
  pal()
  for n in all(game.notes) do
    spr(90+f%5,n.x,n.y,1,1)
  end
end
game.drwnpcs=function()
  for n in all(game.npcs) do
    n.drw(n)
  end
end
game.updnpcs=function()
  for n in all(game.npcs) do
    n.upd(n)
  end
end
game.addnpc=function(nr)
  local n={}
  n.type=nr
  n.x=p1.x-2
  n.y=p1.y
  n.f=0
  if nr==1 then --turret
    n.upd=updturret      
    n.drw=drwturret
    n.exp=false
    n.bullets={}
    n.lock=0
    n.maxb=4
    game.stats.t1+=1
  elseif nr==2 then --mine
    n.upd=updmine
    n.drw=drwmine
    n.exp=false
    game.stats.t2+=1
  elseif nr==3 then --bot
    n.upd=updbot
    n.drw=drwbot
    n.exp=false
    n.dirs={}
    n.alive=true
    p1.bot=n
    game.stats.t3+=1
  elseif nr==4 then --cop
    n.upd=updcop
    n.drw=drwcop
    n.hit=cophit
    n.dir={x=0,y=0}
    n.wait=0
    n.exp=false
    n.colls=-1
    n.door={t=0}
    n.doortime=80
    n.say=""
    n.dirs={}
    n.distract=true
    add(game.cops,n)
  elseif nr==5 then --slide door
    n.upd=upddoor
    n.drw=drwdoor
    n.hor=true
  end
  add(game.npcs,n)
  return n
end

function removenpc(npc)
  del(game.npcs,npc)
end

function delcop(cop)
  removenpc(cop)
  del(game.cops,cop)
end

--------------------------------
-- turrets -------------------2-
function updturret(tur)
  if (tur.lock>0) tur.lock-=1
  -- update bullets
  local db={}
  local hit=false
  for b in all(tur.bullets) do
    b.f+=1
    b.x+=b.dx
    b.y+=b.dy
    hit=false
    -- bullet hits wall
    if coll(b.x,b.y).s>0 then
      hit=true
      sfx(11)
    else
      -- bullet hits cop
      for cop in all(game.cops) do
        if not cop.exp and abs(cop.x-b.x)<6 and abs(cop.y-b.y)<6 then
          cop.f=0
          cop.exp=true
          game.stats.cops+=1
          p1.escapes()
          sfx(10)
          hit=true
        end
      end
    end
    if (hit) add(db,b)
  end
  --remove dead bullets
  for b in all(db) do
    del(tur.bullets,b)
  end
  -- explode turret
  if tur.exp then
    tur.f+=0.5
    if (tur.f>6) removenpc(tur)
  else
    for i=1,count(game.cops) do
      local cop=game.cops[i]
      -- cop dismounts turret
      -- or turret is empty
      if (tur.lock<=0 and tur.maxb<=0 and 
          count(tur.bullets)==0) or 
          sees(tur,cop,10) then
        tur.exp=true
        p1.escapes()
        sfx(9)
      -- turret fires at cop
      elseif tur.maxb>0 and tur.lock<=0 and sees(tur,cop,50) then
        local dx,dy=cop.x-tur.x,cop.y-tur.y
        local len=sqrt(dx*dx+dy*dy)
        add(tur.bullets,{x=tur.x+4,y=tur.y+4,dx=dx/len,dy=dy/len,f=0})
        tur.lock=10
        tur.maxb-=1
        sfx(12)
      end
    end
  end
end

function drwturret(tur)
  if tur.exp then
    exp(17,tur.x,tur.y,tur.f)
  else
    spr(20-tur.maxb,tur.x,tur.y,1,1)
  end
  
  for b in all(tur.bullets) do
    pset(b.x,b.y,8)
  end
end

--------------------------------
-- mines ---------------------3-
function updmine(mine)
  if mine.exp then
    mine.f+=2
    if (mine.f>20) removenpc(mine)
  else
    for cop in all(game.cops) do
      if sees(mine,cop,10) then
        mine.exp=true
        cop.f=0
        cop.exp=true
        game.stats.cops+=1
        fshake=0
        p1.escapes()
        applyexp(mine.x,mine.y,1)
        sfx(3)
      end
    end
  end
end

function drwmine(mine)
  if mine.exp then
    exp(33,mine.x,mine.y,mine.f)
  else
    spr(33+(flr(f*0.25)%4),mine.x,mine.y,1,1)
  end
end
--------------------------------
-- biobot --------------------4-
function updbot(bot)
  bot.f+=1
  if not bot.alive then
    if bot.f>20 then 
      removenpc(bot)
    end
    return
  end
  if (bot.f<10) return

  if count(bot.dirs)==0 then
    bot.f=0
    bot.alive=false
    sfx(3)
    return
  end
  
  local ox,oy=bot.x,bot.y
  bot.x+=bot.dirs[1].x
  bot.y+=bot.dirs[1].y

  local hit=coll_bot(bot)
  if hit.s==86 then
    bot.alive=false
    bot.f=0
    fshake=0
    p1.escapes()
    applyexp(bot.x,bot.y,1)
    sfx(3)
    return
  elseif hit.s>0 then
    bot.x=ox
    bot.y=oy
    del(bot.dirs,bot.dirs[1])
    if (count(bot.dirs)>0) sfx(16)
    return
  end

  for cop in all(game.cops) do
    if sees(bot,cop,10) then
      bot.alive=false
      bot.f=0
      cop.f=0
      cop.exp=true
      game.stats.cops+=1
      fshake=0
      p1.escapes()
      applyexp(bot.x,bot.y,1)
      sfx(3)
      return
    end
  end
end

function drwbot(bot)
  if bot.alive then
    spr(49+(flr(f*0.25)%4),bot.x,bot.y,1,1)
  else
    exp(49,bot.x,bot.y,bot.f)
  end
end

function coll_bot(bot)
  local hit={}
  hit=coll(bot.x+3,bot.y+3) if (hit.s>0) return hit
  hit=coll(bot.x+3,bot.y+6) if (hit.s>0) return hit
  hit=coll(bot.x+6,bot.y+3) if (hit.s>0) return hit
  hit=coll(bot.x+6,bot.y+3) if (hit.s>0) return hit
  return {s=0}
end

--------------------------------
-- cops ----------------------5-
function updcop(cop)
  srand(f)
  if cop.exp then
    cop.f+=2
    return
  end

  local l=0

  -- cop follows player  
  if p1.esc and cop.distract and sees(cop,p1,80) then
    local d={x=p1.x-cop.x,y=p1.y-cop.y}
    l=sqrt(d.x*d.x+d.y*d.y)
    cop.dir.x=d.x/l
    cop.dir.y=d.y/l    
  end
  --door is open
  if cop.door.t>0 then
    cop.door.t-=1
    if cop.door.t==0 then
      cop.say=""
      mset(cop.door.hit.x/8,cop.door.hit.y/8,86)
      sfx(4)
    end
  end
  -- wait after wall hit
  if cop.wait<0 then 
    cop.wait+=1
    if cop.wait==0 then
      if p1.esc then
        cop.wait=flr(rnd(15))+10
      else 
        cop.wait=flr(rnd(40))+20
      end
    end
  end
  
  if cop.wait>0 then 
    cop.wait-=1
    if cop.wait==0 then
      --resume in modified dir
      local numdirs=count(cop.dirs)
      if numdirs>0 then
        cop.dir.x=cop.dirs[cop.colls%numdirs+1].x
        cop.dir.y=cop.dirs[cop.colls%numdirs+1].y
      else
        cop.dir.x+=rnd(2)-1
        cop.dir.y+=rnd(2)-1      
      end
      --uniform length
      l=sqrt(cop.dir.x*cop.dir.x+cop.dir.y*cop.dir.y)
      cop.dir.x=cop.dir.x/l
      cop.dir.y=cop.dir.y/l
    end
    return
  end

  local ox,oy=cop.x,cop.y
  cop.x+=cop.dir.x
  local hit=coll_char(cop)
  if hit.s>0 then
    cop.x=ox
    cop.dir.x*=-1
    cop.colls+=1
    if cop.wait==0 then cop.wait=-6 end
    cop.hit(cop,hit)
    return
  end
  
  cop.y+=cop.dir.y
  hit=coll_char(cop)
  if hit.s>0 then 
    cop.y=oy
    cop.dir.y*=-1
    cop.colls+=1
    if cop.wait==0 then cop.wait=-6 end
    cop.hit(cop,hit)
    return
  end
  
  cop.f+=0.4
end

function cophit(cop,hit)
  if hit.s==86 then
    cop.door={t=cop.doortime,hit=hit}
    cop.wait=cop.doortime
    if (count(cop.dirs)==0) cop.wait=0--cop.wait*=0.5
    mset(hit.x/8,hit.y/8,87)
    sfx(2)
  end
end

function drwcop(cop)
  local sx=5
  local sy=0
  
  if cop.exp then
    exp(5,cop.x,cop.y,cop.f)
    if (cop.f>20) delcop(cop)
    return
  end
  
  if cop.door.t>0 and cop.say!="" then 
    sprint(cop.say,cop.x-39,cop.y+11,12,1)
  end
  
  if cop.wait<=0 and (cop.dir.x!=0 or cop.dir.y!=0) then
    if abs(cop.dir.x)>abs(cop.dir.y) then sx=9 
    elseif cop.dir.y<0 then sy=8 end
    local flip = cop.dir.x<0
    sspr(8*(sx+flr(cop.f%4)),sy,5,8,cop.x,cop.y,5,8,flip)
  else
    spr(sx,cop.x,cop.y)
  end
end

--------------------------------
--sliding doors---------------6-
function upddoor(d)
  --check sensor
  local sx,sy=d.x,d.y
  if d.hor then sx+=7 else sy+=7 end
  if doorsensor(sx,sy,12) then d.f=min(d.f+1,2)
  else d.f=max(d.f-1,0) end
  if (d.f==1) sfx(13) 

  --swap tiles
  if d.hor then 
    mset(d.mx,d.my,105+2*d.f)
    mset(d.mx+1,d.my,106+2*d.f)
  else 
    mset(d.mx,d.my,121+d.f)
    mset(d.mx,d.my+1,124+d.f) 
  end
end

function drwdoor(d) end

function doorsensor(ax,ay,dist)
  local dx,dy=abs(p1.x-ax),abs(p1.y-ay)
  if (dx<dist and dy<dist) return true
  for n in all(game.npcs) do
    if n.type==3 or n.type==4 then
      dx=abs(n.x-ax)
      dy=abs(n.y-ay)
      if (dx<dist and dy<dist) return true
    end
  end
  return false
end

--------------------------------
--player----------------------7-
p1={}
p1.drw=function()
  pal(11,0)
  if p1.walk then
    local sx,sy=5,2
    local flip=false
    if p1.dy<0 and p1.dx==0 then sy=3
    elseif p1.dx!=0 then 
      sx=9
      flip=p1.dx<0
    end
    sspr(8*(sx+flr(p1.f*0.4)%4),8*sy,5,8,p1.x,p1.y,5,8,flip)
	 else 
	   spr(37,p1.x,p1.y,1,1)
	 end
  pal()
  --selection menu  
  if p1.sel>-1 then
    for i=-1,1 do
      local c=7
      local s=0
      if i+2==p1.sel then 
        c=8-flr(f*0.5)%2 
        s+=1+flr(f*0.2)%4
      end
      local x,y=p1.x+2+i*14,p1.y-10+abs(i)*4
      circfill(x,y,5,0)
      circ(x,y,5,c)
      spr(32+i*16+s,x-4,y-4,1,1)
    end
  end
end

p1.upd=function()
  p1.f+=1
  
  if p1.y>234 then
    win=true
    f=0
    p1.f=0
    sfx(19)
    return
  end
  
  if (f<15) return
  if btn(4) then
    p1.sel=max(0,p1.sel)
    if btn(0) then p1.sel=1 end
    if btn(1) then p1.sel=3 end
    if btn(2) then p1.sel=2 end
    if btn(3) then p1.sel=0 end
    p1.sel=p1.sel%4
  else
    if p1.sel>0 then
      if p1.sel==1 and p1.t1>0 then
        p1.t1-=1
        sfx(14)
        game.addnpc(p1.sel)
      elseif p1.sel==2 and p1.t2>0 then
        p1.t2-=1
        sfx(14)
        game.addnpc(p1.sel)
      elseif p1.sel==3 and p1.t3>0 then
        p1.t3-=1
        sfx(14)
        game.addnpc(p1.sel)
      else
        sfx(8)
      end
    end
    p1.sel=-1
    p1.walk=false
    local ox,oy=p1.x,p1.y
    if btn(0) then p1.x-=1 p1.walk=true end
    if btn(1) then p1.x+=1 p1.walk=true end
    if coll_char(p1).s>0 then p1.x=ox end	
    if btn(2) then p1.y-=1 p1.walk=true end
    if btn(3) then p1.y+=1 p1.walk=true end
    if coll_char(p1).s>0 then p1.y=oy end
    p1.dx=p1.x-ox
    p1.dy=p1.y-oy
  end
  
  if (entityat(p1,game.cops)) die()
  local note=entityat(p1,game.notes)
  if (note) processnote(note)
end

die=function()
  p1.walk=false
  p1.alive=false
  f=0
  fshake=0
  sfx(0)
end

processnote=function(note)
  f=0
  p1.walk=false
  p1.note=note
  game.stats.notes+=1
  sfx(18)
  del(game.notes,note)
end

p1.escapes=function()
  if (p1.esc) return
  p1.f=0
  p1.esc=true
  fflash=0
  sfx(5)
end

--------------------------------
-- helpers -------------------8-
function coll_char(p)
  local hit={}
  hit=coll(p.x  ,p.y+7) if (hit.s>0) return hit
  hit=coll(p.x+4,p.y+7) if (hit.s>0) return hit
  hit=coll(p.x+2,p.y+7) if (hit.s>0) return hit
  hit=coll(p.x  ,p.y+4) if (hit.s>0) return hit
  hit=coll(p.x+4,p.y+4) if (hit.s>0) return hit
  return {s=0}
end

function coll(x,y)
  local s=mget(x/8,y/8)
  if fget(s,0) then 
    local c=sget(8*(s%16)+x%8,8*flr(s/16)+y%8)
    if (c>0) return {s=s,x=x,y=y}
  end
  return {s=0}
end

function collcell(x,y)
  local s=mget(x,y)
  return fget(s,0)
end

function entityat(a,list)
  for i=1,count(list) do
    local b=list[i]
    local dx,dy=b.x-a.x,b.y-a.y
    if (abs(dx)<6 and abs(dy)<6) return b
  end
  return false
end

function exp(id,x,y,t)
  t*=1.8
  local mx,my=8*(id%16),8*(flr(id/16))
  srand(id)
  for j=0,8 do for i=0,8 do
    local c=sget(mx+i,my+j)
    if c>0 then
      pset(x+i+t*(rnd(2)-1),y+j+t*(rnd(2)-1),c)
    end
  end end
end

-- xchg tiles on the map
function applyexp(x,y,rad)
  for j=-rad,rad do for i=-rad,rad do
    local mx,my=flr(x/8)+i,flr(y/8)+j
    local s=mget(mx,my)
    if s==86 or s==87 then
      mset(mx,my,102)
      game.stats.doors+=1
    end
  end end
end

function sees(a,b,far)
  local ax,ay=a.x,a.y
  local d={x=b.x-ax,y=b.y-ay}
  if (abs(d.x)>80 or abs(d.y)>80) return false
  local l=sqrt(d.x*d.x+d.y*d.y)
  if (l<8) return true
  if (l>far) return false
  local steps=flr(l/5)
  for i=0,steps do
    local j=i/steps
    if collcell((ax+j*d.x+2)/8,(ay+j*d.y+4)/8) then
      return false
    end
  end
  return true
end


--------------------------------
-- hud/ui --------------------9-

bcsel=-1
bcwait=0
function rstbotcode()
end

function updbotcode()
  bcsel=-1
  if bcwait>0 then
    bcwait-=1
    if bcwait==0 then
      p1.bot=false
    end
    return
  end
  
  local to={x=0,y=0}
  local l,r,u,d=btn(0),btn(1),btn(2),btn(3)
  if     u and r then bcsel=1 to.x=0.7 to.y=-0.7
  elseif d and r then bcsel=3 to.x=0.7 to.y=0.7
  elseif d and l then bcsel=5 to.x=-0.7 to.y=0.7
  elseif u and l then bcsel=7 to.x=-0.7 to.y=-0.7
  elseif u then bcsel=0 to.x=0 to.y=-1
  elseif r then bcsel=2 to.x=1 to.y=0
  elseif d then bcsel=4 to.x=0 to.y=1
  elseif l then bcsel=6 to.x=-1 to.y=0
  end
  
  if btnp(4) then
    if bcsel>-1 then
      add(p1.bot.dirs,{id=bcsel,x=to.x,y=to.y})
      if count(p1.bot.dirs)==4 then
        bcwait=40
        sfx(15)
      else sfx(6) end
    else
      sfx(8)
    end
  end
end

function drwbotcode()
  rectfill(5,10,122,118,0)
  rect(5,10,122,118,8)
  print("biobot v0.1 program",14,21,9)
  spr(48,108,19)
  line(14,27,114,27,9)
  print("list of directions ("..count(p1.bot.dirs).."/4)",17,42,6)
  print("hold and select with [a]",16,100,1)
  print("(diagonals available)",22,108,1)

  if bcwait>0 then
    spr(103,31,81,1,1)
    print("uploading...",45,80,8)
    rectfill(45,86,85-bcwait,88,8)
  else
    spr(iconfromsel(bcsel),60,82,1,1)
  end
  
  for i=0,3 do
    local x=25+i*20
    if i<count(p1.bot.dirs) then
      local d=p1.bot.dirs[i+1]
      spr(iconfromsel(d.id),x+5,58)
      rect(x,53,x+16,69,8)
    else
      rect(x,53,x+16,69,9)
    end
  end
  
end

function iconfromsel(n)
  local id=n
  if id==7 then id=95
  elseif id==-1 then id=89
  else id+=73 end
  return id
end

function drwhud()
  camera(0,0)
  
  if p1.bot then
    drwbotcode()
    return
  end
  
  if p1.alive then
    -- note
    if p1.note then
      rectfill(5,10,122,40,0)
      rect(5,10,122,40,8)
      spr(14,10,12,2,3)
      print(p1.note.text[1],31,18,7)
      local c=count(p1.note.text)
      if (c>1) print(p1.note.text[2],31,28,7)
      if (c>2) spr(4,116,36)
      if c<=2 and (p1.note.t1>0 or p1.note.t2>0 or p1.note.t3>0) then
        rectfill(108,36,118,46,0)
        rect(108,36,118,46,8)
        if f%8>2 then
          if (p1.note.t1>0) spr(16,109,37)
          if (p1.note.t2>0) spr(32,109,37)
          if (p1.note.t3>0) spr(48,109,37)
        end
      end
    else -- inventory
      spr(16,1,0,1,1)
      spr(32,1,8,1,1)
      spr(48,1,16,1,1)
      print(p1.t1,10,2,7)
      print(p1.t2,10,10,7)
      print(p1.t3,10,18,7)
      spr(200+flr(6*game.time/maxtime),119,1,1,1)
    end
  end
  
  -- red blinking frame
  if p1.esc and fflash<20 then
    if fflash%2==0 then
      rect(0,0,127,127,8)
      rect(1,1,126,126,8)
      rect(2,2,125,125,8)
    end
  end
end

function drwbusted()
  pal(11,0)
  for i=0,4 do
    sspr(120,48,8,8,i*24+12,0,8,min(128,f*6))
  end
  pal()
  
  if (f<26) return
  if (f==26) sfx(1)
  local y=min(0,-288+f*8)
  
  rectfill(23,35+y,105,75+y,0)
  rect(23,35+y,105,75+y,8)
  
  local c=8
  if (f%8<4) c=14
  if game.time>maxtime then sprint("time is up!",43,44+y,c,1)
  else sprint("escape failed!",38,44+y,c,1) end
  
  print("press key",47,55+y,1)
  print("to try again",41,63+y,1)
end

function sprint(s,x,y,c1,c2)
  print(s,x,y+1,c2)
  print(s,x,y,c1)
end

--------------------------------
--intro----------------------10-
function updintro()
  if btnp()>0 then 
    intro=false
    music(-1)
    f=0
    sfx(17)
    return
  end
end

function drwintro()
  spr(128,32,14,8,8)
  spr(136,32,82,8,2)
  spr(168,102,0,3,1)
  spr(62,0,0,2,1)
  
  line(0,118,127,118,1)
  line(0,6,127,6,1)
  local a=flr(f*0.5)%4
  spr(9+a,f%300-10,110)
  spr(49+a,f%300-30,111)
  
  print("prison break",48,100,7-f%2)
  print("by movax13h, december 2015",13,120,1)
end

--------------------------------
--win------------------------11-
function updwin()
  p1.y+=max(0,sgn(240-p1.y))
  p1.walk=false
  p1.f+=1
  if f==90 then
    p1.f=0
    sfx(3)
  end
end

function drwwin()
  pal(11,0)
  if f<90 then
    spr(37,p1.x,p1.y)
    spr(25+2*(flr(f*0.5)%2),max(p1.x,200-f*2),242,2,1)
  else  
    exp(37,p1.x,p1.y,p1.f)
    spr(25,p1.x,242,2,1)
  end
  pal()
  
  camera()
  rectfill(10,10,117,100,0)
  rect(10,10,117,100,8)
  print("congratulations!!",30,22,2)
  print("congratulations!!",30,21,8)
  print("escape successful",30,29,5)
  
  spr(16,30,40)
  print(game.stats.t1.." turrets used",42,42,7)
  spr(32,30,48)
  print(game.stats.t2.." mines used",42,50,7)
  spr(48,30,56)
  print(game.stats.t3.." biobots used",42,58,7)
  spr(86,30,68)
  print(game.stats.doors.." doors blasted",42,70,7)
  spr(5,32,78)
  print(game.stats.cops.." cops done",42,80,7)
  
end


--------------------------------
--main-----------------------12-
function _init()
  game.reset()
  music(10)
end

function _update()
  f+=1
  if intro then
    updintro()
    return
  end
  
  if win then
    updwin()
    return
  end

  fshake+=1
  fflash+=1
  game.time+=1
  if (game.time==maxtime) die()
  
  if p1.bot then 
    updbotcode()
    return
  else
    rstbotcode()
  end
  
  if p1.note then
    -- advance note  
    if f>20 and btnp()>0 then
      sfx(7)
      del(p1.note.text,p1.note.text[1])
      if (count(p1.note.text)>0) del(p1.note.text,p1.note.text[1])
      if count(p1.note.text)==0 then
        p1.t1+=p1.note.t1
        p1.t2+=p1.note.t2
        p1.t3+=p1.note.t3
        if (p1.note.t1+p1.note.t2+p1.note.t3>0) sfx(6)
        p1.note=false
      end
    end
    return
  end
  
  if p1.alive then
    p1.upd()
    game.updnpcs()
  elseif f>40 then
    if (btnp()>0) game.reset()
  end
end

function _draw()
  cls()
  camera(0,0)

  if intro then
    drwintro()
    return
  end
  
  rectfill(0,0,127,127,13)
  local r1,r2=0,0
  if fshake<26 then
    r1=rnd(4)-2
    r2=rnd(4)-2
  end
  
  camera(min(125,max(3,p1.x-64+r1)),min(125,max(2,p1.y-64+r2)))
  game.drwlvl()
  game.drwnpcs()
  if win then drwwin()
  else 
    p1.drw()
    drwhud() 
  end
  if (not p1.alive) drwbusted()
end