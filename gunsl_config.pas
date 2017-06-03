unit gunsl_config;

interface
uses MatVectors;

const
  gd_novice:cardinal=0;
  gd_stalker:cardinal=1;
  gd_veteran:cardinal=2;
  gd_master:cardinal=3;


//------------------------------Общие функции работы с игровыми конфигами---------------------------------
  function game_ini_read_string(section:PChar; key:PChar):PChar;stdcall;
  function game_ini_read_vector3_def(section:PChar; key:PChar; def:pfvector3):FVector3;stdcall;
  function game_ini_line_exist(section:PChar; key:PChar):boolean;stdcall;
  function game_ini_r_single_def(section:PChar; key:PChar; def:single):single;stdcall;
  function game_ini_r_single(section:PChar; key:PChar):single;stdcall;
  function game_ini_r_bool(section:PChar; key:PChar):boolean;stdcall;
  function game_ini_r_bool_def(section:PChar; key:PChar; def:boolean):boolean;stdcall;
  function game_ini_r_int_def(section:PChar; key:PChar; def:integer):integer; stdcall;

implementation
uses BaseGameData, sysutils;
//--------------------------------------------------Общие вещи---------------------------------------------------
function GetGameIni():pointer;stdcall;
asm
  mov eax, xrgame_addr
  mov eax, [eax+$4DA824]
  mov eax, [eax]
  mov @result, eax
end;

function game_ini_line_exist(section:PChar; key:PChar):boolean;stdcall;
asm
    pushad
    pushfd

    push key
    push section

    call GetGameIni
    mov ecx, eax

    mov eax, xrCore_addr
    add eax, $188F0
    call eax
    mov @result, al

    popfd
    popad
end;

function game_ini_r_bool(section:PChar; key:PChar):boolean;stdcall;
asm
    pushad
    pushfd

    push key
    push section
    call GetGameIni
    mov ecx, eax

    mov eax, xrCore_addr
    add eax, $18F70
    call eax

    mov @result, al

    popfd
    popad
end;

function game_ini_read_string(section:PChar; key:PChar):PChar;stdcall;
asm
    pushad
    pushfd

    push key
    push section

    call GetGameIni
    mov ecx, eax

    mov eax, xrCore_addr
    add eax, $18B40
    call eax
    
    mov @result, eax

    popfd
    popad
end;

function game_ini_r_bool_def(section:PChar; key:PChar; def:boolean):boolean;stdcall;
begin
  if game_ini_line_exist(section, key) then
    result:=game_ini_r_bool(section, key)
  else
    result:=def;
end;

function game_ini_r_int_def(section:PChar; key:PChar; def:integer):integer; stdcall;
begin
  if game_ini_line_exist(section, key) then
    result:=strtointdef(game_ini_read_string(section, key), def)
  else
    result:=def;
end;

function game_ini_r_single(section:PChar; key:PChar):single;stdcall;
begin
  result:= strtofloatdef(game_ini_read_string(section, key),0);
end;


function game_ini_r_single_def(section:PChar; key:PChar; def:single):single;stdcall;
begin
  if game_ini_line_exist(section, key) then
    result:=game_ini_r_single(section, key)
  else
    result:=def;
end;


function game_ini_read_vector3_def(section:PChar; key:PChar; def:pfvector3):FVector3;stdcall;
var
  tmp, coord:string;
begin
  if game_ini_line_exist(section, key) then begin
    tmp:=game_ini_read_string(section, key);

    GetNextSubStr(tmp, coord, ',');
    result.x:=strtofloatdef(coord, 0);

    GetNextSubStr(tmp, coord, ',');
    result.y:=strtofloatdef(coord, 0);

    GetNextSubStr(tmp, coord, ',');
    result.z:=strtofloatdef(coord, 0);

  end else if def<>nil then begin
    result:=def^;
  end else begin
    result.x:=0;
    result.y:=0;
    result.z:=0;
  end;
end;

end.
