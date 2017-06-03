unit dynamic_caster;

interface

function dynamic_cast(inptr:pointer; vfdelta:cardinal; srctype:cardinal; targettype:cardinal; isreference:boolean):pointer; stdcall;

const
  //all xrGame-based

  RTTI_CHudItem:cardinal = $5FAA20;
  RTTI_CWeapon:cardinal = $5FBD04;
  RTTI_CShootingObject:cardinal = $5F2728;
  RTTI_CWeaponMagazined:cardinal = $5FAA00;
  RTTI_CInventoryItem:cardinal = $5D0D70;
   

implementation
uses BaseGameData;

function dynamic_cast(inptr:pointer; vfdelta:cardinal; srctype:cardinal; targettype:cardinal; isreference:boolean):pointer; stdcall;
asm
  pushad

  movzx eax, isreference
  push eax

  mov eax, xrgame_addr
  add eax, targettype
  push eax

  mov eax, xrgame_addr
  add eax, srctype
  push eax

  push vfdelta
  push inptr

  mov eax, xrgame_addr
  add eax, $4D563C
  call eax

  mov @result, eax
  add esp, $14
  
  popad
end;


end.
