unit Spatial;

interface
uses MatVectors, Render;

function Init():boolean; stdcall;

/////////////////////////////////////////////ISpatial_NODE//////////////////////////////////
type ISpatial_NODE = packed record
  //todo:fill
end;
type pISpatial_NODE = ^ISpatial_NODE;

/////////////////////////////////////////////ISpatial_DB//////////////////////////////////
type ISpatial_DB = packed record
  //todo:fill
end;
type pISpatial_DB = ^ISpatial_DB;
/////////////////////////////////////////////ISpatial//////////////////////////////////
type ISpatial__spatial = packed record
  type_:cardinal;
  sphere:_sphere_float;
  node_center:FVector3;
  node_radius:single;
  node_ptr:pISpatial_NODE;
  sector:pIRenderSector;
  space:pISpatial_DB;
end;
type ISpatial = packed record
  vftable:pointer;
  spatial:ISpatial__spatial;
end;
type pISpatial = ^ISpatial;

implementation

function Init():boolean; stdcall;
begin
 result:=true;
end;

end.
