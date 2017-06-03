unit Objects;

interface
uses MatVectors, BaseClasses, Spatial, Render, Schedule, Physics, xr_strings;



/////////////////////////////////////////////////CObject////////////////////////////
type CObject__SavedPosition = packed record
  dwTime:cardinal;
  vPosition:FVector3;
end;

type svector_CObject__SavedPosition_4 = packed record
  _data:array[0..3] of CObject__SavedPosition;
  count:cardinal;
end;

type CObject__ObjectProperties = packed record
  net_ID:word;
  bActiveCounter:byte;
  other_flags:byte;
end;

type CObject = packed record
  base_DLLPure:DLL_Pure;
  base_ISpatial:ISpatial;
  base_ISheduled:IScheduled;
  base_IRenderable:IRenderable;
  base_ICollidable:ICollidable;
  Props:CObject__ObjectProperties;
  NameObject:shared_str;
  NameSection:shared_str;
  NameVisual:shared_str;
  Parent:pointer;{pCObject really}
  PositionStack:svector_CObject__SavedPosition_4;
  dwFrame_UpdateCL:cardinal;
  dwFrame_AsCrow: cardinal;
end;
type pCObject = ^CObject;


type CShootingObject__SilencerKoeffs = packed record
  hit_power:single;
  hit_impulse:single;
  bullet_speed:single;
  fire_dispersion:single;
  cam_dispersion:single;
  cam_disper_inc:single;
end;

type CShootingObject = packed record
  base_IAnticheatDumpable:IAnticheatDumpable;
  m_vCurrentShootDir:FVector3;
  m_vCurrentShootPos:FVector3;
  m_iCurrentParentID:word;
  bWorking:byte;
  _unused1:byte;
  fOneShotTime:single;
  fvHitPower: array [0..3] of single;
  fvHitPowerCritical: array [0..3] of single;
  fHitImpulse:single;
  m_fStartBulletSpeed:single;
  fireDistance:single;
  fireDispersionBase:single;
  fShotTimeCounter:single;
  m_silencer_koef:CShootingObject__SilencerKoeffs;
  cur_silencer_koef:CShootingObject__SilencerKoeffs;  
  m_fMinRadius:single;
  m_fMaxRadius:single;
  light_base_color:_color_float;
  light_base_range:single;
  light_build_color:_color_float;
  light_build_range:single;
  light_render:pointer{resptr_core_IRender_Light_resptrcode_light};
  light_var_color:single;
  light_var_range:single;
  light_lifetime:single;
  light_frame:cardinal;
  light_time:single;
  m_bLightShotEnabled:byte; {boolean}
  _unused2:byte;
  _unused3:word;
  m_sShellParticles:shared_str;
  vLoadedShellPoint:FVector3;
  m_fPredBulletTime:single;
  m_fTimeToAim:single;
  m_bUseAimBullet:integer;
  m_sFlameParticlesCurrent:shared_str;
  m_sFlameParticles:shared_str;
  m_pFlameParticles:pointer{pCParticlesObject};
  m_sSmokeParticlesCurrent:shared_str;
  m_sSmokeParticles:shared_str;
  m_sShotParticles:shared_str; 

end;
type pCShootingObject = ^CShootingObject;

/////////////////////////////////////////////////CWeaponAmmo/////////////////////////////////////////////////////
type CWeaponAmmo = packed record
  //todo:fill
end;
type pCWeaponAmmo = ^CWeaponAmmo;

/////////////////////////////////////////////////CCartridge/////////////////////////////////////////////////////
type SCartridgeParam = packed record
  kDist:single;
  kDisp:single;
  kHit:single;
  kCritical:single;
  kImpulse:single;
  kAP:single;
  kAirRes:single;
  buck_shot:integer;
  impair:single;
  fWallmarkSize:single;
  u8ColorID:byte;
  _unused1:byte;
  _unused2:word;  
end;

type CCartridge = packed record
  base_IAnticheatDumpable:IAnticheatDumpable;
  m_ammoSect: shared_str;
  param_s:SCartridgeParam;
  m_local_ammotype:byte;
  _unused1:byte;
  bullet_material_idx:word;
  _flags:cardinal;
  m_InvShortName: shared_str;
end;



procedure CObject__cNameVisualSet(o:pCObject; vis:pshared_str); stdcall;
implementation
uses BaseGameData;

procedure CObject__cNameVisualSet(o:pCObject; vis:pshared_str); stdcall;
asm
  //Warning! do not decrement dwReference after calling this proc!
  pushad
    mov ecx, o
    mov eax, vis
    mov eax, [eax]
    push eax
    mov eax, xrEngine_addr
    add eax, $1A9C0
    call eax
  popad
end;

end.
