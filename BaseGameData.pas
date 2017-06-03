unit BaseGameData;

interface

type TKeyHoldState = record
  IsActive: boolean;
  IsHoldContinued:boolean;
  ActivationStart: cardinal;
  HoldDeltaTimePeriod: cardinal; //�����, ����� ��������� �������� �� ����������� ��������� �������
end;

function Init(dwFlags:cardinal):boolean;
function WriteJump(var write_addr:cardinal; dest_addr:cardinal; addbytescount:cardinal=0; writecall:boolean=false):boolean;
function nop_code(addr:cardinal; count:cardinal; opcode:char = CHR($90)):boolean;

function WriteBufAtAdr(addr:cardinal; buf:pointer; count:cardinal):boolean;

function GetNextSubStr(var data:string; var buf:string; separator:char=char($00)):boolean;
procedure Log(text:string; IsError:boolean = false);stdcall;

var
  xrGame_addr:cardinal;
  xrCore_addr:cardinal;
  xrEngine_addr:cardinal;
  xrCDB_addr:cardinal;
  xrRender_R1_addr:cardinal;
  xrRender_R2_addr:cardinal;
  xrRender_R3_addr:cardinal;
  xrRender_R4_addr:cardinal;
  mydll_handle:cardinal;
  hndl:cardinal;

const
  FLG_PATCH_CORE:cardinal=1;
  FLG_PATCH_ENGINE:cardinal=2;
  FLG_PATCH_SOUND:cardinal=4;
  FLG_PATCH_GAME:cardinal=8;

implementation
uses windows, strutils, sysutils;

const
  xrGame:PChar='xrGame';
  xrCore:PChar='xrCore';
  xrEngine:PChar='xrEngine.exe';
  xrCDB:PChar='xrCDB';  
  xrRender_R1:PChar='xrRender_R1';  
  xrRender_R2:PChar='xrRender_R2';
  xrRender_R3:PChar='xrRender_R3';
  xrRender_R4:PChar='xrRender_R4';
  mydll:PChar='guns_cs';

  
function nop_code(addr:cardinal; count:cardinal; opcode:char = CHR($90)):boolean;
var rb:cardinal;
    i:cardinal;
begin
  result:=true;
  for i:=addr to addr+count-1 do begin
    writeprocessmemory(hndl, PChar(i), @opcode, 1, rb);
    if rb<>1 then result:=false;
  end;
end;

function WriteBufAtAdr(addr:cardinal; buf:pointer; count:cardinal):boolean;
var rb:cardinal;
begin
  result:=true;
  writeprocessmemory(hndl, PChar(addr), buf, count, rb);
  if rb<>count then result:=false;
end;

function WriteJump(var write_addr:cardinal; dest_addr:cardinal; addbytescount:cardinal=0; writecall:boolean=false):boolean;
var offsettowrite:cardinal;
    rb:cardinal;
    opcode:char;
begin
  result:=true;
  if writecall then opcode:=CHR($E8) else opcode:=CHR($E9);
  offsettowrite:=dest_addr-write_addr-5;
  writeprocessmemory(hndl, PChar(write_addr), @opcode, 1, rb);
  if rb<>1 then result:=false;
  writeprocessmemory(hndl, PChar(write_addr+1), @offsettowrite, 4, rb);
  if rb<>4 then result:=false;
  if addbytescount>5 then nop_code(write_addr+5, addbytescount-5);
  write_addr:=write_addr+addbytescount;
end;

function GetNextSubStr(var data:string; var buf:string; separator:char=char($00)):boolean;
var p, i:integer;
begin
  p:=0;
  for i:=1 to length(data) do begin
    if data[i]=separator then begin
      p:=i;
      break;
    end;
  end;

  if p>0 then begin
    buf:=leftstr(data, p-1);
    buf:=trim(buf);
    data:=rightstr(data, length(data)-p);
    data:=trim(data);
    result:=true;
  end else begin
    if trim(data)<>'' then begin
      buf:=trim(data);
      data:='';
      result:=true;
    end else result:=false;
  end;
end;

procedure Log(text:string; IsError:boolean = false);stdcall;
var
  paramText:PChar;
begin
  try
    text:='GUNS_CS: '+text;
    if IsError then
      text:= '! ' + text
    else
      text:= '~ ' + text;

    paramText:=PChar(text);
    asm
      pushad
      pushf

      push paramText

      mov eax, xrCore_addr
      add eax, $16270
      call eax
      add esp, 4

      popf
      popad
    end;
  except
  end;
end;

function Init(dwFlags:cardinal):boolean;
begin
  result:=false;
  hndl:=GetCurrentProcess;
  xrGame_addr := GetModuleHandle(xrGame);
  xrCore_addr := GetModuleHandle(xrCore);
  xrEngine_addr:=GetModuleHandle(xrEngine);
  xrCDB_addr:=GetModuleHandle(xrCDB);
  xrRender_R1_addr:=GetModuleHandle(xrRender_R1);
  xrRender_R2_addr:=GetModuleHandle(xrRender_R2);
  xrRender_R3_addr:=GetModuleHandle(xrRender_R3);
  xrRender_R4_addr:=GetModuleHandle(xrRender_R4);

  mydll_handle:=GetModuleHandle(mydll);
  
  if xrEngine_addr=0 then xrEngine_addr:=$400000;

  if (xrGame_addr = 0) or (xrCore_addr = 0) then exit;


  //� ������� 16 ����� GetModuleHandle ����� ���������� ����� - ������� �������� �� ��� ��������� ������ �������� ������ 
  xrGame_addr := (xrGame_addr shr 16) shl 16;
  result:=true;
end;


end.
