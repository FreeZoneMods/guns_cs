unit WeaponSound;

interface
uses xr_strings, Console;

type ref_sound = packed record
  _p:{ref_sound_data_ptr}pointer;
end;
type pref_sound = ^ref_sound;


type HUD_SOUND_ITEM_SSnd = packed record
  snd:ref_sound;
  delay:single;
  volume:single;
end;
type pHUD_SOUND_ITEM_SSnd = ^HUD_SOUND_ITEM_SSnd;

type HUD_SOUND_ITEM = packed record
  m_alias:shared_str;
  m_activeSnd:pHUD_SOUND_ITEM_SSnd;
  sounds_start:pHUD_SOUND_ITEM_SSnd;
  sounds_end:pHUD_SOUND_ITEM_SSnd;
  sounds_mem:pHUD_SOUND_ITEM_SSnd;
end;
type pHUD_SOUND_ITEM = ^HUD_SOUND_ITEM;

type HUD_SOUND_COLLECTION = packed record
  first:pHUD_SOUND_ITEM;
  last:pHUD_SOUND_ITEM;
  mem:pHUD_SOUND_ITEM;
end;
type pHUD_SOUND_COLLECTION = ^HUD_SOUND_COLLECTION;


function Init(dwFlags:cardinal):boolean;
procedure HUD_SOUND_COLLECTION__LoadSound(hcs:pHUD_SOUND_COLLECTION; section:PChar; line:PChar; alias:PChar; snd_type:cardinal);stdcall;
procedure HUD_SOUND_COLLECTION_LoadSoundIfNotLoaded(hcs:pHUD_SOUND_COLLECTION; section:PChar; line:PChar; alias:PChar; snd_type:cardinal); stdcall;


implementation
uses BaseGameData, sysutils, MatVectors, HudItems, Objects, gunsl_config, dynamic_caster;


/////////////////////////////////////////Engine wrappers////////////////////////////////////////////////////////////
procedure HUD_SOUND_COLLECTION__LoadSound(hcs:pHUD_SOUND_COLLECTION; section:PChar; line:PChar; alias:PChar; snd_type:cardinal);stdcall;
asm
    pushad
    pushfd
    push snd_type
    push alias
    push line
    push section
    mov eax, hcs

    mov ebx, xrgame_addr
    add ebx, $287560
    call ebx // HUD_SOUND_COLLECTION::LoadSound
    popfd
    popad
end;

procedure HUD_SOUND_COLLECTION__PlaySound(hcs:pHUD_SOUND_COLLECTION; alias:PChar; position:pFVector3; parent:pCObject; hud_mode:boolean; looped:boolean=false; index:byte=$FF);stdcall;
asm
  pushad
    mov esi, hcs
    mov edi, alias

    movzx eax, index
    push eax

    movzx eax, looped
    push eax

    movzx eax, hud_mode
    push eax

    push parent
    push position

    mov eax, xrgame_addr
    add eax, $287380
    call eax
  popad
end;

procedure HUD_SOUND_ITEM__StopSound(hud_snd:pHUD_SOUND_ITEM); stdcall;
asm
  pushad
    mov eax, xrGame_addr
    add eax, $2872B0
    mov edi, hud_snd
    call eax
  popad
end;

procedure HUD_SOUND_ITEM__DestroySound(hud_snd:pHUD_SOUND_ITEM); stdcall;
asm
  pushad
    mov eax, xrGame_addr
    add eax, $287120
    mov esi, hud_snd
    call eax
  popad
end;

procedure HUD_SOUND_COLLECTION__SetPosition(collection:pHUD_SOUND_COLLECTION; alias:PChar; pos:pFVector3); stdcall;
asm
  pushad
    push pos
    mov edi, alias
    mov eax, collection

    mov ebx, xrGame_addr
    add ebx, $287460
    call ebx
  popad
end;

procedure HUD_SOUND_COLLECTION_UnLoadSound(collection:pHUD_SOUND_COLLECTION; snd:pHUD_SOUND_ITEM); stdcall;
begin
  if snd=nil then begin
    Log('HUD_SOUND_COLLECTION_UnLoadSound got snd=nil!', true);
    exit;
  end;
  HUD_SOUND_ITEM__StopSound(snd);
  HUD_SOUND_ITEM__DestroySound(snd);
  collection.last:=(pHUD_SOUND_ITEM(cardinal(collection.last)-sizeof(HUD_SOUND_ITEM)));

  if snd<>collection.last then snd^:=collection.last^;

end;

function HUD_SOUND_COLLECTION__FindSoundItem(collection:pHUD_SOUND_COLLECTION; alias:PChar):pHUD_SOUND_ITEM; stdcall;
var
  i:pHUD_SOUND_ITEM;
begin
  result:=nil;

  i:=collection.first;
  while cardinal(i)<cardinal(collection.last) do begin
    if StrComp(@i.m_alias.p_.value, alias)=0 then begin
      result:=i;
      break;
    end;
    i:= pHUD_SOUND_ITEM(cardinal(i)+sizeof(HUD_SOUND_ITEM));
  end;
end;

procedure HUD_SOUND_COLLECTION_LoadSoundIfNotLoaded(hcs:pHUD_SOUND_COLLECTION; section:PChar; line:PChar; alias:PChar; snd_type:cardinal); stdcall;
begin
  if HUD_SOUND_COLLECTION__FindSoundItem(hcs, alias) = nil then begin
    HUD_SOUND_COLLECTION__LoadSound(hcs, section, line, alias, snd_type);
  end;
end;

//////////////////////////////////////////////PATCHES////////////////////////////////////////////////////////////////////////

procedure HUD_SOUND_COLLECTION__LoadSound_Patch; stdcall;
asm
  pushad
    push eax
    push esi
    call HUD_SOUND_COLLECTION_UnLoadSound
  popad
end;

procedure UpdateSoundsPos(collection:pHUD_SOUND_COLLECTION; pos:pFVector3);stdcall;
var
  snd:pHUD_SOUND_ITEM;
begin
  snd:=collection.first;
  while(snd<>collection.last) do begin
    if snd.m_activeSnd<>nil then begin
      HUD_SOUND_COLLECTION__SetPosition(collection, @snd.m_alias.p_.value, pos);
    end;
    snd:=pHUD_SOUND_ITEM(cardinal(snd)+sizeof(HUD_SOUND_ITEM));
  end;
end;

procedure CWeaponMagazined__UpdateSounds_Patch(); stdcall;
asm
  lea edx, [esp+$c]

  pushad
  push edx
  push esi
  call UpdateSoundsPos
  popad

  pop edi  //ret addr
  push edx
  jmp edi
end;


//ѕравка на отключение прерывани€ звука при его рестарте (дл€ стрельбы главным образом)

procedure ref_sound__play_at_pos(this:pref_sound; O:pointer; pos:pFVector3; flags:cardinal; d:single); stdcall;
asm
  pushad
    push d
    push flags
    push pos
    push o
    push this

    mov ecx, xrgame_addr;
    mov ecx, [ecx+$4DB300]
    mov ecx, [ecx]
    mov edi, [ecx]
    mov eax, [edi+$38]
    call eax
  popad
end;

procedure ref_sound__play_no_feedback(this:pref_sound; O:pointer; flags:cardinal; d:single; pos:pFVector3; vol:psingle; freq:psingle; range:pFVector2); stdcall;
asm
  pushad
    push range
    push freq
    push vol
    push pos
    push d
    push flags
    push O
    push this

    mov ecx, xrgame_addr;
    mov ecx, [ecx+$4DB300]
    mov ecx, [ecx]
    mov edi, [ecx]
    mov eax, [edi+$3C]
    call eax
  popad
end;

function DecideHowToPlaySnd(snd:pHUD_SOUND_ITEM; O:pointer; pos:pFVector3; flags:cardinal):boolean; stdcall;
const
  sm_Looped:cardinal = $1;
begin
  if (Console.flags and FLG_SNDUNLOCK=0) or (snd.m_activeSnd.volume>=0) or ((flags and sm_Looped)<>0)  then begin
    ref_sound__play_at_pos(@snd.m_activeSnd.snd, O, pos, flags, snd.m_activeSnd.delay);
    result:=true;
  end else begin
    ref_sound__play_no_feedback(@snd.m_activeSnd.snd, O, flags, snd.m_activeSnd.delay, pos,nil,nil,nil);
    result:=false;
  end;
end;

procedure HUD_SOUND_ITEM__PlaySound_Patch();
asm
  push ebp
  mov ebp, esp
  
  pushad
  push [ebp+$14]
  push [ebp+$10]
  push [ebp+$c]
  push edi
  call DecideHowToPlaySnd
  popad

  pop ebp
  ret $14
end;


procedure PlaySoundWhenAnimStarts(itm:pCHudItem; anim_name:pshared_str); stdcall;
var
  o:pCObject;
  pos:FVector3;
  snd_name:string;
  hud_sect:PChar;
  snd_type:cardinal;

  pwpn:pCWeapon;
begin
//  log('PlaySnd');
//  log (inttohex(cardinal(itm),8));
//  log(PChar(@anim_name.p_.value));
  
  if itm.m_object=nil then exit;
  o:=pCObject(itm.m_object);
  pos:= pFVector3(@o.base_IRenderable.renderable.xform.c)^;
  hud_sect:=PChar(@itm.hud_sect.p_.value);

  //≈сли на оружии глушитель и прописан звук дл€ него - играем звук с глушителем, иначе всЄ как обычно
  pwpn:=dynamic_cast(itm, 0, RTTI_CHudItem, RTTI_CWeapon, false);
  if pwpn<>nil then begin
    if (pwpn.m_flagsAddOnState and AddOnState_Flag_Silencer)>0 then begin
      snd_name:='snd_sil_'+PChar(@anim_name.p_.value);
      if not game_ini_line_exist(hud_sect, PChar(snd_name)) then begin
        snd_name:='snd_'+PChar(@anim_name.p_.value);
      end;
    end else begin
      snd_name:='snd_'+PChar(@anim_name.p_.value);
    end;
  end else begin
    snd_name:='snd_'+PChar(@anim_name.p_.value);
  end;


  if game_ini_line_exist(hud_sect, PChar(snd_name)) then begin
    snd_type:=game_ini_r_int_def(hud_sect, PChar(snd_name+'_aitype'), -1);
    HUD_SOUND_COLLECTION__LoadSound(@itm.m_sounds, hud_sect, PChar(snd_name), PChar(snd_name), snd_type);
    HUD_SOUND_COLLECTION__PlaySound(@itm.m_sounds, PChar(snd_name),@pos, o, CHudItem__GetHUDmode(itm));
  end;

  //Ќо у нас может быть необходимо проиграть еще один звук... Ќапример, дл€ гаусса и болтовок сам выстрел в пространстве никак не св€зан с перезар€дкой
  snd_name:='sec_'+snd_name;
  if game_ini_line_exist(hud_sect, PChar(snd_name)) then begin
    snd_type:=game_ini_r_int_def(hud_sect, PChar(snd_name+'_aitype'), -1);
    HUD_SOUND_COLLECTION__LoadSound(@itm.m_sounds, hud_sect, PChar(snd_name), PChar(snd_name), snd_type);
    HUD_SOUND_COLLECTION__PlaySound(@itm.m_sounds, PChar(snd_name),@pos, o, CHudItem__GetHUDmode(itm));
  end;  
end;

procedure CHudItem__PlayHudMotion_Patch(); stdcall
asm

  pushad
    push eax
    push ecx
    call PlaySoundWhenAnimStarts
  popad

  pop esi //ret addr
  push edi
  push esi //ret addr

  mov esi, [eax]
  test esi, esi
end;


procedure CHudItem__Load_PrepareSoundContainer(itm:pCHudItem; hsc:pHUD_SOUND_COLLECTION); stdcall;
var
  i, sz:integer;
  hud_sect:PChar;
begin
  hud_sect:=PChar(@itm.hud_sect.p_.value);
  sz:=game_ini_r_int_def(hud_sect, 'min_sound_container_size', 64);
  //раздуваем хранилище до указанных в конфиге размеров
  //log('Insreasing HUD_SOUND_COLLECTION on '+hud_sect+' on '+inttostr(sz)+' item(s)'); 

  for i:=0 to sz-1 do begin
    HUD_SOUND_COLLECTION__LoadSound(hsc, hud_sect, PChar('_tmp_snd_'+inttostr(i)), PChar('_tmp_snd_'+inttostr(i)), $FFFFFFFF);
  end;

  for i:=0 to sz-1 do begin
    HUD_SOUND_COLLECTION_UnLoadSound(hsc, HUD_SOUND_COLLECTION__FindSoundItem(hsc, PChar('_tmp_snd_'+inttostr(i))));
  end;
end;

procedure CHudItem__Load_Patch(); stdcall;
asm
  mov [esi+$40], eax
  pop eax //ret addr
  push edi
  push eax
  lea eax, [esi+$44]

  pushad
    push eax
    push esi
    call CHudItem__Load_PrepareSoundContainer
  popad
end;

function Init(dwFlags:cardinal):boolean;
var
  addr:cardinal;
begin
  result:=false;

  if dwFlags and FLG_PATCH_GAME >0 then begin
    //[bug] баг иногда про€вл€етс€ при попытках заюзать смену звука у оружи€ (в апгрейдах, например) - нужна перезагрузка звука в HUD_SOUND_COLLECTION вместо вылета.
    addr:=xrGame_addr+$287596;
    if not nop_code(addr, 37) then exit;
    if not WriteJump(addr, cardinal(@HUD_SOUND_COLLECTION__LoadSound_Patch), 5, true) then exit;

    //обновл€ем позиции всех звуков
    addr:=xrGame_addr+$261426;
    if not WriteJump(addr, cardinal(@CWeaponMagazined__UpdateSounds_Patch), 5, true) then exit;

    //фикс обрыва звука
    addr:=xrGame_addr+$28723F;
    if not WriteJump(addr, cardinal(@HUD_SOUND_ITEM__PlaySound_Patch), 5, true) then exit;

    //назначение звука при старте анимы
    addr:=xrGame_addr+$286BA7;
    if not WriteJump(addr, cardinal(@CHudItem__PlayHudMotion_Patch), 5, true) then exit;

    //отключаем стандартную схему назначени€ звука путем вырезани€ CHudItem__PlaySound
    addr:=xrGame_addr+$286510;
    if not WriteJump(addr, xrGame_addr+$286545, 5, false) then exit;

    //ѕодготовка контейнера на указанное число звуков
    addr:=xrGame_addr+$2864FC;
    if not WriteJump(addr, cardinal(@CHudItem__Load_Patch), 7, true) then exit;
  end;

  result:=true;
end;

end.
