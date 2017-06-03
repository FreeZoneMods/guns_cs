unit BaseClasses;

interface

function Init():boolean; stdcall;

/////////////////////////////////////////////DLL_Pure//////////////////////////////////

type DLL_Pure = packed record
  vftable:pointer;
  unknown:cardinal;
  CLS_ID:array[0..7] of char;
end;
type pDLL_Pure = ^DLL_Pure;

/////////////////////////////////////////////IAnticheatDumpable//////////////////////////////////

type IAnticheatDumpable = packed record
  vftable:pointer;
end;
type pIAnticheatDumpable = ^IAnticheatDumpable;


////////////////////////////////////////////CInifile///////////////////////////////////
type CIniFile = packed record
  //todo:fill
end;
type pCIniFile = ^CIniFile;


////////////////////////////////////////////_color<float>///////////////////////////////////
type _color_float = packed record
  r:single;
  g:single;
  b:single;
  a:single;
end;

type xr_vector = packed record
  start:pointer;
  last:pointer;
  memory_end:pointer;
end;





implementation

function Init():boolean; stdcall;
begin
 result:=true;
end;

end.
