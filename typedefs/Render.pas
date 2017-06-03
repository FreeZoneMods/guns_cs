unit Render;

interface
uses MatVectors;

////////////////////////////////////////////IRenderSector////////////////////////////////
function Init():boolean; stdcall;
type IRenderSector = packed record
  //todo:fill
end;
type pIRenderSector = ^IRenderSector;

////////////////////////////////////////////IRenderVisual////////////////////////////////
type IRenderVisual = packed record
  //todo:fill
end;
type pIRenderVisual = ^IRenderVisual;

////////////////////////////////////////////IRender_ObjectSpecific////////////////////////////////
type IRender_ObjectSpecific = packed record
  //todo:fill
end;
type pIRender_ObjectSpecific = ^IRender_ObjectSpecific;
////////////////////////////////////////////IRenderable////////////////////////////////
type unnamed_struct_IRenderable = packed record
  xform:FMatrix4x4;
  visual:pIRenderVisual;
  pROS:pIRender_ObjectSpecific;
  pROS_Allowed:cardinal;  //bool really
end;

type IRenderable = packed record
  vftable:pointer;
  renderable:unnamed_struct_IRenderable;
end;
type pIRenderable= ^IRenderable;

implementation

function Init():boolean; stdcall;
begin
 result:=true;
end;

end.
