unit Physics;

interface
function Init():boolean; stdcall;

/////////////////////////////////////////////////ICollisionForm////////////////////////////////////////////////////////////
type ICollisionForm = packed record
  //todo:fill
end;

type pICollisionForm = ^ICollisionForm;

/////////////////////////////////////////////////ICollidable////////////////////////////////////////////////////////////
type unnamed_struct_ICollidable = packed record
  model:pICollisionForm;
end;

type ICollidable = packed record
  vftable:pointer;
  collidable:unnamed_struct_ICollidable;
end;
type pICollidable = ^ICollidable;

/////////////////////////////////////////////////IObjectPhysicsCollision/////////////////////////////////////////////////////

type IObjectPhysicsCollision = packed record
  vftable:pointer;
end;
type pIObjectPhysicsCollision = ^IObjectPhysicsCollision;

/////////////////////////////////////////////////CPhysicsShell/////////////////////////////////////////////////////

type CPhysicsShell = packed record
  vftable:pointer;
end;
type pCPhysicsShell = ^CPhysicsShell;

/////////////////////////////////////////////////CKinematics/////////////////////////////////////////////////////

type CKinematics = packed record
  //todo:fill
end;
type pCKinematics = ^CKinematics;

/////////////////////////////////////////////////CPHShellSimpleCreator/////////////////////////////////////////////////////
type CPHShellSimpleCreator = packed record
  vftable:pointer;
end;



implementation
function Init():boolean; stdcall;
begin
  result:=true;
end;

end.
