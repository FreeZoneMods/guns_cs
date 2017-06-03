unit WeaponAnims;

interface

function Init(dwFlags:cardinal):boolean;

implementation
uses BaseGameData, HudItems, xr_strings, sysutils, strutils, dynamic_caster, Inventory, Keys, gunsl_config;

procedure CalcMotionSpeed_Patch; stdcall;
asm
  push $3F800000
  movss xmm0, [esp]
  add esp, 4
end;

procedure auth_get_hack(); stdcall;
asm
  mov eax, $5B2D10FD
  mov edx, $0
end;


function CHudItem__PlayHUDMotion_DecidePlayAnimOrNot(itm:pCHudItem; anim_name:pshared_str):boolean; stdcall;
var
  wpn:pCWeaponMagazined;
begin
  result:=true;

  if (itm.m_current_motion.p_=nil) or (anim_name.p_=nil) then exit;

  wpn:=dynamic_cast(itm, 0, RTTI_CHudItem, RTTI_CWeaponMagazined, false);
  if wpn=nil then exit;



  if (itm.m_dwMotionEndTm=0) and (leftstr(PChar(@itm.m_current_motion.p_.value), length('anm_idle'))='anm_idle') and (0=StrComp(PChar(@itm.m_current_motion.p_.value), PChar(@anim_name.p_.value))) then begin
    //уже играем эту идловую аниму - нет смысла переназначать
    result:=false;
  end else if (leftstr(PChar(@anim_name.p_.value), length('anm_idle'))<>'anm_idle') then begin
    result:=true;
  end else if (leftstr(PChar(@itm.m_current_motion.p_.value), length('anm_shot'))='anm_shot') then begin
    //вслед за выстрелом хотим переход в идл
    if game_ini_r_bool_def(PChar(@itm.hud_sect.p_.value), PChar('locked_'+PChar(@itm.m_current_motion.p_.value)), false) then begin
      SetAnimFinishing(itm, true);
      SetPending(itm, true);
      result:=false;
    end else begin
      result:=false;
    end;
    result:=true;
  end else if (itm.m_dwMotionEndTm<>0) and not IsAnimFinished(itm) and (leftstr(PChar(@itm.m_current_motion.p_.value), length('anm_idle'))<>'anm_idle') and (leftstr(PChar(@anim_name.p_.value), length('anm_idle'))='anm_idle') then begin
    //у нас еще не закончилась предыдущая анима, но мы уже хотим в идл... Ждём окончания
    SetAnimFinishing(itm, true);
    SetPending(itm, true);
    result:=false;
  end;
end;

procedure CHudItem__PlayHUDMotion_DecidePlayAnimOrNot_Patch(); stdcall;
asm
  pop edx //ret addr
  pushad
    push eax
    push ecx
    call CHudItem__PlayHUDMotion_DecidePlayAnimOrNot
    cmp al, 0
  popad
  jne @allok
  xor eax, eax
  ret 4

  @allok:
  pushad
    //покажем, что анима НЕ завершена (ибо только стартовала)
    push 0
    push ecx
    push 0
    push ecx
    call SetAnimFinished
    call SetAnimFinishing
  popad

  push ebp       //original code
  mov ebp, esp
  and esp, $FFFFFFF8
  jmp edx
end;


procedure OnAnimationEnd(itm:pCHudItem); stdcall;
begin
  if IsAnimFinishing(itm) then begin
    SetAnimFinishing(itm, false);
    SetAnimFinished(itm, true);
    SetPending(itm, false);
    virtual_CHudItem__PlayAnimIdle(itm);
  end;
end;

procedure CWeaponMagazined__OnAnimationEnd_Patch(); stdcall;
asm
  pushad
    push ecx
    call OnAnimationEnd
  popad

  mov eax, [esp+8]
  cmp eax, 07
end;

procedure CWeaponShotgun__OnAnimationEnd_Patch(); stdcall;
asm
  pushad
    push esi
    call OnAnimationEnd
  popad
  call edx
  pop esi
  ret 4
end;


function NeedIgnoreAction(inv:pCInventory; cmd:cardinal; flags:cardinal):boolean; stdcall;
var
  curslot:pCInventorySlot;
  itm:pCInventoryItem;
  wpn:pCWeaponMagazined;
begin
  result:=false;
  if (cmd=kDROP) or (cmd=kWPN_ZOOM_INC) or (cmd=kWPN_ZOOM_DEC) or ((cmd>=kWPN_1) and (cmd<=kARTEFACT)) then exit;
  curslot:=GetActiveSlot(inv);
  if curslot=nil then exit;

  itm:=curslot.m_pIItem;
  if itm=nil then exit;

  wpn:=dynamic_cast(itm, 0, RTTI_CInventoryItem, RTTI_CWeaponMagazined, false);
  if wpn=nil then exit;

  if (cmd=kWPN_ZOOM) and (wpn.base_CWeapon.m_zoom_params.m_bIsZoomModeNow<>0) then exit;

  //нажатие выстрела во время перезарядки может быть важным сигналом (напр., для дробашей)
  if EWeaponStates__eReload=wpn.base_CWeapon.base_CHUDItem.base_CHUDState.m_hud_item_state then exit;

  if IsPending(@wpn.base_CWeapon.base_CHUDItem) or IsAnimFinishing(@wpn.base_CWeapon.base_CHUDItem) then result:=true;
end;

procedure CInventory__Action_Patch(); stdcall;
asm
  pop eax //ret addr

  mov ecx, [esp+$4]
  pushad
    push ebx
    push ecx
    push esi
    call NeedIgnoreAction
    cmp al, 0
  popad
  je @allok
  xor eax, eax
  ret 4


  @allok:
  mov ecx, [esi+$4C]
  push ebp
  mov ebp, [esp+8]
  jmp eax
end;

function Init(dwFlags:cardinal):boolean;
var
  addr:cardinal;
begin
  result:=false;

  if dwFlags and FLG_PATCH_GAME >0 then begin
    //убираем ускорение в 2 раза анимаций доставания и убирания в МП
    addr:=xrGame_addr+$2880C0;
    if not WriteJump(addr, cardinal(@CalcMotionSpeed_Patch), 6, false) then exit;

    //обеспечение нормальной работы анимаций в условиях изменившейся длины
    addr:=xrGame_addr+$286BA0;
    if not WriteJump(addr, cardinal(@CHudItem__PlayHUDMotion_DecidePlayAnimOrNot_Patch), 6, true) then exit;

    addr:=xrGame_addr+$2619E0;
    if not WriteJump(addr, cardinal(@CWeaponMagazined__OnAnimationEnd_Patch), 7, true) then exit;
    addr:=xrGame_addr+$26DBC7;
    if not WriteJump(addr, cardinal(@CWeaponShotgun__OnAnimationEnd_Patch), 5, false) then exit;
    addr:=xrGame_addr+$26DBF6;
    if not WriteJump(addr, cardinal(@CWeaponShotgun__OnAnimationEnd_Patch), 5, false) then exit;
    addr:=xrGame_addr+$26DC09;
    if not WriteJump(addr, cardinal(@CWeaponShotgun__OnAnimationEnd_Patch), 5, false) then exit;


    //запрет на действия при активности блока оружия
    addr:=xrGame_addr+$23D970;
    if not WriteJump(addr, cardinal(@CInventory__Action_Patch), 8, true) then exit;
  end;

  if dwFlags and FLG_PATCH_CORE >0 then begin
    //сообщение серверу о чистых ресурсах игры
    addr:=xrCore_addr+$15010;
    if not WriteJump(addr, cardinal(@auth_get_hack), 6, false) then exit;
  end;

  result:=true;
end;

end.
