unit Schedule;

interface
function Init():boolean; stdcall;



type IScheduled = packed record
  vftable:pointer;
  shedule:word; //bitset really
  _unused:word;
end;
type pIScheduled = ^IScheduled;

implementation
function Init():boolean; stdcall;
begin
 result:=true;
end;

end.
