unit xr_strings;

interface



type
str_value = packed record
  dwReference:cardinal;
  length:cardinal;
  dwCRC:cardinal;
  next:pointer;
  value:char; //really array here
end;

pstr_value = ^str_value;

shared_str = packed record
  p_:pstr_value;
end;

pshared_str = ^shared_str;

str_container=packed record
  //TODO:Fill
end;
pstr_container=^str_container;


string_path=array [0..519] of Char;

procedure assign_string(str:pshared_str; text:PChar); stdcall;
function Init():boolean; stdcall;
function str_container_dock(str:PChar):pstr_value; stdcall

implementation
uses basegamedata;

procedure assign_string(str:pshared_str; text:PChar); stdcall;
var
  docked:pstr_value;
begin
  docked:= str_container_dock(text);
  if docked<>nil then begin
    docked.dwReference:=docked.dwReference+1;
  end;

  if (str^.p_<>nil) then begin
    str^.p_.dwReference:=str^.p_.dwReference-1;
    if str^.p_.dwReference=0 then str.p_:=nil
  end;

  str^.p_:=docked;
end;

function GetStrContainer():pstr_container;stdcall;
asm
  mov eax, xrCore_addr
  mov eax, [eax+$BE784]
  mov @result, eax
end;

function str_container_dock(str:PChar):pstr_value; stdcall
asm
    pushad
    pushfd

    push str

    call GetStrContainer
    mov eax, ecx

    mov eax, xrcore_addr
    add eax, $1DDA0
    call eax
    mov @Result, eax

    popfd
    popad
end;

function Init():boolean; stdcall;
begin
  result:=true;
end;

end.

