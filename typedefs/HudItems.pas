unit HudItems;

interface
uses xr_strings, WeaponSound, BaseClasses, Spatial, Schedule, Render, Physics, MatVectors, Objects, Inventory;

type CHUDState = packed record
  vftable:pointer;
  m_hud_item_state:cardinal;
  m_nextState:cardinal;
  m_dw_curr_state_time:cardinal;
  m_dw_curr_substate_time:cardinal;
end;
pCHUDState = ^CHUDState;

CHUDItem = packed record
  base_CHUDState:CHUDState;
  m_huditem_flags:cardinal;
  m_current_motion_def:pointer {pCMotionDef};
  m_current_motion:shared_str;
  m_dwMotionCurrTm:cardinal;
  m_dwMotionStartTm:cardinal;
  m_dwMotionEndTm:cardinal;
  m_startedMotionState:cardinal;
  m_started_rnd_anim_idx:byte;
  m_bStopAtEndAnimIsRunning:byte; {bool}
  _unused1:word;
  hud_sect:shared_str;
  dwFP_Frame:cardinal;
  dwXF_Frame:cardinal;
  m_animation_slot:cardinal;
  m_sounds:HUD_SOUND_COLLECTION;
  m_object:pointer; {CPhysicItem*}
  m_item:pCInventoryItem;
end;
pCHUDItem = ^CHUDItem;


//-------------------------------------------------CWeapon-------------------------------------------------------

type firedeps = packed record
  m_FireParticlesXForm:FMatrix4x4;
  vLastFP:FVector3;
  vLastFP2:FVector3;
  vLastFD:FVector3;
  vLastSP:FVector3;      
end;

type CWeapon__SZoomParams = packed record
  m_bZoomEnabled:byte; {boolean}
  m_bHideCrosshairInZoom:byte; {boolean}
  m_bZoomDofEnabled:byte; {boolean}
  m_bIsZoomModeNow:byte; {boolean}
  m_fCurrentZoomFactor:single;
  m_fZoomRotateTime:single;
  m_fIronSightZoomFactor:single;
  m_fScopeZoomFactor:single;
  m_fZoomRotationFactor:single;
  m_ZoomDof:FVector3;
  m_ReloadDof:FVector4;
end;

type CameraRecoil = packed record
  RelaxSpeed:single;
  RelaxSpeed_AI:single;
  Dispersion:single;
  DispersionInc:single;
  DispersionFrac:single;
  MaxAngleVert:single;
  MaxAngleHorz:single;
  StepAngleHorz:single;
  ReturnMode:byte; {boolean}
  StopReturn:byte; {boolean}
  _unused1:word;
end;

type CWeapon__SPDM = packed record
  m_fPDM_disp_base:single;
  m_fPDM_disp_vel_factor:single;
  m_fPDM_disp_accel_factor:single;
  m_fPDM_disp_crouch:single;
  m_fPDM_disp_crouch_no_acc:single;
end;


type first_bullet_controller = packed record
  m_last_shot_time:cardinal;
  m_shot_timeout:cardinal;
  m_fire_dispertion:single;
  m_actor_velocity_limit:single;
  m_use_first_bullet:byte; {boolean}
  _unused1:byte;  
  _unused2:word;
end;

CWeapon = packed record
  _undescripted1:array [0..$2E7] of Byte;
  base_CHUDItem:CHUDItem;     //тут ошибка - наследуемс€ не от CHUDItem, а от CHUDItemObject, а он уже в свою очередь от CHUDItem. Ќо так проще, потому пока оставим так
  base_CShootingObject:CShootingObject;
  m_dwWeaponRemoveTime:int64;
  m_dwWeaponIndependencyTime:int64;
  m_bTriStateReload:byte; {boolean}
  m_sub_state:byte;
  bMisfire:byte; {boolean}
  _unused1:byte;
  m_bAutoSpawnAmmo:cardinal;
  m_flagsAddOnState:byte;
  _unused2:byte;
  _unused3:word;
  m_eScopeStatus:cardinal;
  m_eSilencerStatus:cardinal;
  m_eGrenadeLauncherStatus:cardinal;
  m_sScopeName:shared_str;
  m_sSilencerName:shared_str;
  m_sGrenadeLauncherName:shared_str;
  m_iScopeX:integer;
  m_iScopeY:integer;
  m_iSilencerX:integer;
  m_iSilencerY:integer;
  m_iGrenadeLauncherX:integer;
  m_iGrenadeLauncherY:integer;
  m_zoom_params:CWeapon__SZoomParams;
  m_UIScope:pointer {pCUIWindow};
  m_strap_bone0:PChar;
  m_strap_bone1:PChar;
  m_StrapOffset:FMatrix4x4;
  m_strapped_mode:byte; {boolean}
  m_can_be_strapped:byte;
  m_Offset:FMatrix4x4;
  _unused4:word;
  eHandDependence:cardinal; {enum EHandDependence}
  m_bIsSingleHanded:byte; {boolean}
  vLoadedFirePoint:FVector3;
  vLoadedFirePoint2:FVector3;
  m_current_firedeps:firedeps;
  _unused5:byte;
  _unused6:word;
  cam_recoil:CameraRecoil;
  zoom_cam_recoil:CameraRecoil;
  fireDispersionConditionFactor:single;
  misfireProbability:single;
  misfireConditionK:single;
  conditionDecreasePerShot:single;
  m_pdm:CWeapon__SPDM;
  m_crosshair_inertion:single;
  m_first_bullet_controller:first_bullet_controller;
  m_vRecoilDeltaAngle:FVector3;
  m_fMinRadius:single;
  m_fMaxRadius:single;
  m_sFlameParticles2:shared_str;
  m_pFlameParticles2:pointer{pCParticlesObject};
  iAmmoElapsed:integer;
  iMagazineSize:integer;
  iAmmoCurrent:integer;
  m_dwAmmoCurrentCalcFrame:cardinal;
  m_bAmmoWasSpawned:byte; {boolean}
  _unused7:byte;
  _unused8:word;
  m_ammoTypes:xr_vector; {xr_vector<shared_str>}
  m_pAmmo:pCWeaponAmmo;
  m_ammoType:cardinal;
  m_ammoName:shared_str;
  m_bHasTracers:cardinal; {boolean}
  m_u8TracerColorID:cardinal;
  m_set_next_ammoType_on_reload:cardinal;
  m_magazine:xr_vector; {xr_vector<CCartridge>}
  m_DefaultCartridge:CCartridge;
  m_fCurrentCartirdgeDisp:single;
  m_ef_main_weapon_type:cardinal;
  m_ef_weapon_type:cardinal;
  m_addon_holder_range_modifier:single;
  m_addon_holder_fov_modifier:single;
  m_hit_probability:array[0..3] of single;
end;
pCWeapon = ^CWeapon;

CWeaponMagazined = packed record
  base_CWeapon:CWeapon;
//todo:fill
end;

pCWeaponMagazined=^CWeaponMagazined;

const
  AddOnState_Flag_Scope:byte = 1;
  AddOnState_Flag_Silencer:byte = 4;
  AddOnState_Flag_GL:byte = 2;

  chuditem_flag_pending:cardinal=1;

  chuditem_flag_anim_finishing:cardinal=32;
  chuditem_flag_anim_finished:cardinal=64;

function Init:boolean;

function CHudItem__GetHUDmode(itm:pCHudItem):boolean; stdcall;
function IsPending(itm:pCHudItem):boolean; stdcall;
procedure SetPending(itm:pCHudItem; status:boolean); stdcall;

function IsAnimFinishing(itm:pCHudItem):boolean; stdcall;
procedure SetAnimFinishing(itm:pCHudItem; status:boolean); stdcall;

function IsAnimFinished(itm:pCHudItem):boolean; stdcall;
procedure SetAnimFinished(itm:pCHudItem; status:boolean); stdcall;

procedure virtual_CHudItem__PlayAnimIdle(itm:pCHudItem); stdcall;

const
  EWeaponStates__eReload:cardinal=7;
  EHudStates__eIdle:cardinal=0;

implementation
uses BaseGameData;

function CHudItem__GetHUDmode(itm:pCHudItem):boolean; stdcall;
asm
  pushad
    mov edi, itm
    mov eax, xrgame_addr
    add eax, $286C50
    call eax
    cmp eax, 0
    mov @result, al
  popad
end;

function IsPending(itm:pCHudItem):boolean; stdcall;
begin
  result:=(itm.m_huditem_flags and chuditem_flag_pending)>0;
end;

procedure SetPending(itm:pCHudItem; status:boolean); stdcall;
begin
  if status then begin
    itm.m_huditem_flags:=itm.m_huditem_flags or chuditem_flag_pending;
  end else begin
    itm.m_huditem_flags:=itm.m_huditem_flags and ($FFFFFFFF - chuditem_flag_pending);
  end;
end;

function IsAnimFinishing(itm:pCHudItem):boolean; stdcall;
begin
  result:=(itm.m_huditem_flags and chuditem_flag_anim_finishing)>0;
end;

procedure SetAnimFinishing(itm:pCHudItem; status:boolean); stdcall;
begin
  if status then begin
    itm.m_huditem_flags:=itm.m_huditem_flags or chuditem_flag_anim_finishing;
  end else begin
    itm.m_huditem_flags:=itm.m_huditem_flags and ($FFFFFFFF - chuditem_flag_anim_finishing);
  end;
end;

function IsAnimFinished(itm:pCHudItem):boolean; stdcall;
begin
  result:=(itm.m_huditem_flags and chuditem_flag_anim_finished)>0;
end;

procedure SetAnimFinished(itm:pCHudItem; status:boolean); stdcall;
begin
  if status then begin
    itm.m_huditem_flags:=itm.m_huditem_flags or chuditem_flag_anim_finished;
  end else begin
    itm.m_huditem_flags:=itm.m_huditem_flags and ($FFFFFFFF - chuditem_flag_anim_finished);
  end;
end;


procedure virtual_CHudItem__PlayAnimIdle(itm:pCHudItem); stdcall;
asm
  pushad
  mov ecx, itm
  mov edx, [ecx]
  mov eax, [edx+$60]
  call eax
  popad
end;

function Init:boolean;
begin
  result:=true;
end;

end.
