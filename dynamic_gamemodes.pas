unit dynamic_gamemodes;

interface
uses gunsl_config, BaseGameData;

const
  SERVER_GAMETYPES_SECTION:PChar = 'sv_script_gametypes';
  CLIENT_GAMETYPES_SECTION:PChar = 'cl_script_gametypes';  

function Init(dwFlags:cardinal):boolean;

implementation

function GetClientGameCLSIDByName(name:PChar):PChar; stdcall;
begin
  Log('Searching client script CLSID for gametype '+name);
  if game_ini_line_exist(CLIENT_GAMETYPES_SECTION, name) then begin
    result:=game_ini_read_string(CLIENT_GAMETYPES_SECTION, name);
    Log('Found CLSID '+result);
  end else begin
    Log('Client gametype '+name+' not found!');
    result:='';
  end;
end;

function GetServerGameCLSIDByName(name:PChar):PChar; stdcall;
begin
  Log('Searching server script CLSID for gametype '+name);
  if game_ini_line_exist(SERVER_GAMETYPES_SECTION, name) then begin
    result:=game_ini_read_string(SERVER_GAMETYPES_SECTION, name);
    Log('Found CLSID '+result);
  end else begin
    Log('Server gametype '+name+' not found!');
    result:='';
  end;
end;


procedure ServerCLSIDSelector_Patch();
asm
 pop ecx //ret addr
 push 0
 push ecx //ret addr

 lea ecx, [esp+4]

 pushad
  lea ebx, [esp+$40]
  push ecx
  push ebx
  call GetServerGameCLSIDByName
  pop ecx
  mov [ecx], eax
 popad
end;

procedure ClientCLSIDSelector_Patch();
asm
 pop ecx //ret addr
 push 0
 push ecx //ret addr

 lea ecx, [esp+4]

 pushad
  lea ebx, [esp+$30]
  push ecx
  push ebx
  call GetClientGameCLSIDByName
  pop ecx
  mov [ecx], eax
 popad
end;

function Init(dwFlags:cardinal):boolean;
var
  addr:cardinal;
begin
  result:=false;

  if dwFlags and FLG_PATCH_GAME >0 then begin
    //серверный тип игры
    addr:=xrGame_addr+$31d30c;
    if not WriteJump(addr, cardinal(@ServerCLSIDSelector_Patch), 5, true) then exit;

    //клиентский тип игры
    addr:=xrGame_addr+$1E9292;
    if not WriteJump(addr, cardinal(@ClientCLSIDSelector_Patch), 5, true) then exit;
  end;
  
  result:=true;
end;

end.
