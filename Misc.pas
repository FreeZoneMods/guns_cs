unit Misc;

interface

function Init(dwFlags:cardinal):boolean;

implementation
uses xr_strings, HudItems, Objects, dynamic_caster, gunsl_config, BaseGameData, sysutils;




procedure ReadFlameParticlesFromHudSection(itm:pCShootingObject); stdcall;
var
  phi:pCHudItem;
  hud_sect:PChar;
const
  prefix:string='';
begin
  phi:=dynamic_cast(itm, 0, RTTI_CShootingObject, RTTI_CHudItem, false);
  if phi=nil then exit;

  hud_sect:=PChar(@phi.hud_sect.p_.value);
  if game_ini_line_exist(hud_sect, PChar(prefix+'flame_particles')) then begin
    assign_string(@itm.m_sFlameParticles, game_ini_read_string(hud_sect, PChar(prefix+'flame_particles')));
  end;

  if game_ini_line_exist(hud_sect, PChar(prefix+'smoke_particles')) then begin
    assign_string(@itm.m_sSmokeParticles, game_ini_read_string(hud_sect, PChar(prefix+'smoke_particles')));
  end;

  if game_ini_line_exist(hud_sect, PChar(prefix+'shot_particles')) then begin
    assign_string(@itm.m_sShotParticles, game_ini_read_string(hud_sect, PChar(prefix+'shot_particles')));
  end;
end;


procedure CShootingObject__LoadFlameParticles_Patch; stdcall;
asm
  pushad
    push esi
    call ReadFlameParticlesFromHudSection
  popad
  mov ecx, [esi+$F4]
end;

procedure ReadShellsFromHudSection(itm:pCShootingObject); stdcall;
var
  phi:pCHudItem;
  hud_sect:PChar;
const
  prefix:string='';
begin
  phi:=dynamic_cast(itm, 0, RTTI_CShootingObject, RTTI_CHudItem, false);
  if phi=nil then exit;

  hud_sect:=PChar(@phi.hud_sect.p_.value);
  if game_ini_line_exist(hud_sect, PChar(prefix+'shell_particles')) then begin
    assign_string(@itm.m_sShellParticles, game_ini_read_string(hud_sect, PChar(prefix+'shell_particles')));
  end;

  if game_ini_line_exist(hud_sect, PChar(prefix+'world_shell_point')) then begin
    itm.vLoadedShellPoint:=game_ini_read_vector3_def(hud_sect, PChar(prefix+'world_shell_point'), nil);
  end;
end;


function IsCollimator(itm:pCHudItem):boolean; stdcall;
var
  hud_sect:PChar;
begin
  hud_sect:=PChar(@itm.hud_sect.p_.value);
  result:=game_ini_r_bool_def(hud_sect, 'integrated_collimator', false);
end;

procedure CWeapon__need_renderable_Patch(); stdcall;
asm
  xor eax, eax
  pushad
    push edi //CHudItem
    call IsCollimator
    cmp al, 0
  popad
  je @finish
  mov eax, 1

  @finish:
  pop edi
  pop esi
  ret

end;

procedure CWeapon__render_item_ui_query_Patch(); stdcall;
asm
  ja @f

  pushad
    add esi, $2E8 //casting to CHudItem
    push esi
    call IsCollimator
    cmp al, 1
  popad
  je @f

  mov al, 01
  pop esi
  ret

  @f:
  xor al, al
  pop esi
  ret 
end;


procedure CShootingObject__LoadShellParticles_Patch; stdcall;
asm
  pushad
    push esi
    call ReadShellsFromHudSection
  popad
end;


procedure LoadCollimatorZoomFactor(wpn:pCWeapon); stdcall;
begin
  if IsCollimator(@wpn.base_CHUDItem) then begin
    wpn.m_zoom_params.m_fScopeZoomFactor:=game_ini_r_single_def(PChar(@wpn.base_CHUDItem.hud_sect.p_.value), 'collimator_zoom_factor', wpn.m_zoom_params.m_fScopeZoomFactor);
  end;
end;

procedure CWeaponMagazined__InitAddons_permanentscopezoomfactor_Patch(); stdcall
asm
  fstp [edi+$4a4]
  pushad
    push edi
    call LoadCollimatorZoomFactor
  popad
end;


procedure SelectItemVisual(wpn:pCWeapon); stdcall;
var
  huds_count:cardinal;
  hud_sect:PChar;
  skin_id:cardinal;
  itm:pCHudItem;

  wvis:PChar;
  wvis_shared:shared_str;
begin
  itm:=@wpn.base_CHUDItem;

  if itm.m_object=nil then exit;
  hud_sect:=PChar(@itm.hud_sect.p_.value);
  huds_count:=game_ini_r_int_def(hud_sect, 'skins_count', 0);
  if huds_count<=1 then exit;

  skin_id:=pCObject(itm.m_object).Props.net_ID mod huds_count;
  hud_sect:=game_ini_read_string(hud_sect, PChar('skin_'+inttostr(skin_id)));
  assign_string(@itm.hud_sect, hud_sect);

  log('Selected skin id='+inttostr(skin_id)+' ('+hud_sect+')');

  if game_ini_line_exist(hud_sect, 'weapon_visual') then begin
    wvis:=game_ini_read_string(hud_sect, 'weapon_visual');
    assign_string(@wvis_shared, wvis);
    //log('wvis refount = '+inttostr(wvis_shared.p_.dwReference));
    CObject__cNameVisualSet(pCObject(itm.m_object), @wvis_shared);
    //assign_string(@wvis_shared, nil) здесь НЕ нужно!!!
  end;
end;

procedure CWeapon__net_Spawn_multivisual_Patch(); stdcall
asm

  pushad
    push edi
    call SelectItemVisual
  popad

  pop edi
  pop esi
  pop ebp
  ret 4
end;

function Init(dwFlags:cardinal):boolean;
var
  addr:cardinal;
begin
  result:=false;

  if dwFlags and FLG_PATCH_GAME >0 then begin
    //загрузка партиклов из худовой секции
    addr:=xrGame_addr+$24eec3;
    if not WriteJump(addr, cardinal(@CShootingObject__LoadShellParticles_Patch), 5, false) then exit;

    addr:=xrGame_addr+$24f062;
    if not WriteJump(addr, cardinal(@CShootingObject__LoadFlameParticles_Patch), 6, true) then exit;

    //непоказ прицельной сетки и несокрытие худа при установленном прицеле, но наличии параметра в худовой секции
    addr:=xrGame_addr+$252a71;
    if not WriteJump(addr, cardinal(@CWeapon__need_renderable_Patch), 5, false) then exit;

    addr:=xrGame_addr+$2557E6;
    if not WriteJump(addr, cardinal(@CWeapon__render_item_ui_query_Patch), 5, false) then exit;

    addr:=xrGame_addr+$262599;
    if not WriteJump(addr, cardinal(@CWeaponMagazined__InitAddons_permanentscopezoomfactor_Patch), 6 , true) then exit;

    //разные скины одного оружия
    addr:=xrGame_addr+$252145;
    if not WriteJump(addr, cardinal(@CWeapon__net_Spawn_multivisual_Patch), 6 , false) then exit;
  end;

  result:=true;
end;

end.
