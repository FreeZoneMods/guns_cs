unit Hits;

interface
uses BaseClasses;

function Init():boolean; stdcall;

type svector_float_11 = packed record
  _data:array [0..10] of single;
  count:cardinal;
end;

type CHitImmunity = packed record
  vftable:pointer;
  m_HitImmunityKoefs:svector_float_11;
end;
type pCHitImmunity = ^CHitImmunity;

implementation
function Init():boolean; stdcall;
begin
  result:=true;
end;

end.
