unit Console;

interface

function Init(dwFlags:cardinal):boolean;

const SACE_BUILD = 0;

type

IConsole_Command_vftable = packed record
  _destructor:pointer;
  Execute:pointer;
  Status:pointer;
  Info:pointer;
  Save:pointer;
end;

type
pIConsole_Command_vftable = ^IConsole_Command_vftable;

IConsole_Command = packed record
  vftable:pIConsole_Command_vftable;
  cName:PChar;
  bEnabled:byte;
  bLowerCaseArgs:byte;
  bEmptyArgsHandled:byte;
  _reserved:byte;
end;

pIConsole_Command = ^IConsole_Command;

CCC_Mask = packed record
  base:IConsole_Command;
  value:pcardinal;
  mask:cardinal;  
end;
pCCC_Mask = ^CCC_Mask;

CCC_Integer = packed record
  base:IConsole_Command;
  value:pinteger;
  min:integer;
  max:integer;
end;
pCCC_Integer= ^CCC_Integer;
pCCC_SV_Integer=pCCC_Integer;

CCC_Float = packed record
  base:IConsole_Command;
  value:psingle;
  min:single;
  max:single;
end;
pCCC_Float= ^CCC_Float;
pCCC_SV_Float=pCCC_Float;

CConsole = packed record
  //TODO:fill
end;
pCConsole=^CConsole;
ppCConsole=^pCConsole;


var
  g_ppConsole:ppCConsole;
  c_snd_targets:pCCC_Integer;

  c_g_fov:CCC_Float;
  c_g_hud_fov:CCC_Float;  

  hud_fov:single;

{$IF SACE_BUILD>0}
  fov:single;
{$ELSE}
  g_fov:psingle;
{$IFEND}
  
  psHUD_FOV:psingle;
  c_snd_unlock:CCC_Mask;

  flags:cardinal;
  
const
  FLG_SNDUNLOCK:cardinal=1;

implementation
uses BaseGameData;






procedure CConsole__AddCommand(C:pIConsole_Command); stdcall;
asm
  pushad
    mov ecx, g_ppConsole
    mov ecx, [ecx]
    push C
    mov eax, xrengine_addr
    add eax, $4C830;
    call eax //CConsole::AddCommand(IConsole_Command* C);
  popad
end;

procedure CCC_Float__CCC_Float(this:pCCC_Float; name:PChar; value:psingle; min:single; max:single);stdcall;
asm
  pushad
    mov ecx, this
    push max
    push min
    push value
    push name
    mov eax, xrengine_addr
    add eax, $79B0
    call eax
  popad
end;

procedure CCC_Mask__CCC_Mask(this:pCCC_Mask; n:PChar; v:pcardinal; M:cardinal);stdcall;
asm
  pushad
    mov ecx, this
    push m
    push v
    push n
    mov eax, xrengine_addr
    add eax, $7490
    call eax
  popad
end;



procedure Actions_After_CCC_Float(c:pCCC_Float); stdcall;
begin
{$IF SACE_BUILD>0}
  psHUD_FOV^:=hud_fov/fov;
{$ELSE}
  psHUD_FOV^:=hud_fov/g_fov^;
{$IFEND}
end;

procedure CCC_Float__Execute_Patch(); stdcall
asm
  mov ecx, [esi+$0C]
  movss [ecx], xmm0

  pushad
    push esi
    call Actions_After_CCC_Float
  popad
end;

function Init(dwFlags:cardinal):boolean;
var
  addr:cardinal;
  ptr:pointer;
begin
  if dwFlags and FLG_PATCH_ENGINE >0 then begin
    c_snd_targets:=pointer(xrEngine_addr+$9725C);
    g_ppConsole:=pointer(xrEngine_addr+$96A24);
    psHUD_FOV := psingle(xrEngine_addr+$94B98);
    hud_fov:=30;
  end;

  if dwFlags and FLG_PATCH_GAME >0 then begin
{$IF SACE_BUILD>0}
    fov:=67.50;
    ptr:=@fov;
    WriteBufAtAdr(xrgame_addr+$1FBD69, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$1FBDE6, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$24FE53, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$254054, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$262EF0, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$26BD34, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$26BDA4, @ptr, sizeof(ptr));
    WriteBufAtAdr(xrgame_addr+$270E2D, @ptr, sizeof(ptr));


    CCC_Float__CCC_Float(@c_g_fov, 'g_fov', @fov, 65, 90);
    CCC_Float__CCC_Float(@c_g_hud_fov, 'g_hud_fov', @hud_fov, 25, 35);
{$ELSE}
    g_fov:=psingle(xrGame_addr+$5DC8F8);
    CCC_Float__CCC_Float(@c_g_fov, 'g_fov', g_fov, 65, 90);
    CCC_Float__CCC_Float(@c_g_hud_fov, 'g_hud_fov', @hud_fov, 25, 35);
{$IFEND}
  end;

  if dwFlags and FLG_PATCH_ENGINE >0 then begin
    CConsole__AddCommand(@c_g_fov);
    CConsole__AddCommand(@c_g_hud_fov);


    c_snd_targets.min:=128;
    c_snd_targets.max:=20000;
    if c_snd_targets.value^<128 then c_snd_targets.value^:=128;

    //возможность отключения разблокированных звуков
    flags:=0;
    CCC_Mask__CCC_Mask(@c_snd_unlock, 'snd_unlock', @flags,FLG_SNDUNLOCK);
    CConsole__AddCommand(@c_snd_unlock);

    //модифицирование обработчика для пересчета фова
    addr:=xrEngine_addr+$7a4c;
    if not WriteJump(addr, cardinal(@CCC_Float__Execute_Patch), 7, true) then exit;
  end;

  result:=true;
end;

end.
