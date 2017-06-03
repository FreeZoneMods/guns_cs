unit Inventory;

interface
uses BaseClasses, xr_strings, MatVectors, Hits;

type
CAttachableItem = packed record
  vftable:pointer;
  m_item:pointer{CInventoryItem*} ;
  m_bone_name:shared_str;
  m_offset:FMatrix4x4;
  m_bone_id:word;
  m_enabled:byte;{boolean} //offset 0x4E
  _unused:byte; //для удобства, если где-то нет, то надо убрать и перенести в наследников.
end;
pCAttachableItem = ^CAttachableItem;


CInventoryItem = packed record
  base_CAttachableItem:CAttachableItem;
  base_CHitImmunity:CHitImmunity;
  m_flags:cardinal {word};
  m_can_trade:cardinal{BOOL};
  m_pInventory:pointer {pCInventory};
  m_section_id:shared_str;
  m_name:shared_str;
  m_name_short:shared_str;
  m_name_complex:shared_str;
  m_eItemCurrPlace:cardinal;
  m_slot:cardinal;
  m_cost:cardinal;
  m_weight:single;
  m_fCondition:single;
  m_Description:shared_str;
  m_dwItemRemoveTime:int64;
  m_dwItemIndependencyTime:int64;
  m_fControlInertionFactor:single;
  m_icon_name:shared_str;
  m_net_updateData:pointer{net_updateInvData*}; 
  m_holder_range_modifier:single;
  m_holder_fov_modifier:single;
  m_object:pointer {pCPhysicsShellHolder};
  m_upgrades:xr_vector {shared_str};
  m_just_after_spawn:byte; {boolean}
  m_activated:byte; {boolean}
  _unused:word;
end;
pCInventoryItem = ^CInventoryItem;

CInventorySlot = packed record
  vftable:pointer;
  m_pIItem:pCInventoryItem;
  m_bPersistent:byte;
  m_bAct:byte;
  _unused:word;
  m_blockCounter:integer;
end;
pCInventorySlot=^CInventorySlot;


CInventory  = packed record
  vftable:pointer;
  m_all:xr_vector;
  m_ruck:xr_vector;
  m_belt:xr_vector;
  m_activ_last_items:xr_vector;
  m_slots:xr_vector;
  m_iActiveSlot:cardinal;
  m_iNextActiveSlot:cardinal;
  m_iPrevActiveSlot:cardinal;
  m_pOwner:pointer {CInventoryOwner*};
  m_bBeltUseful:byte;
  m_bSlotsUseful:byte;
  _unused1:word;
  m_fMaxWeight:single;
  m_fTotalWeight:single;
  m_dwModifyFrame:cardinal;
  m_drop_last_frame:byte;
  _unused2:byte;
  _unused3:word;
end;
pCInventory=^CInventory;


function GetActiveSlot(inv:pCInventory):pCInventorySlot; stdcall;


implementation

function GetActiveSlot(inv:pCInventory):pCInventorySlot; stdcall;
var
  slots_cnt:cardinal;
begin
  result:=nil;
  if (inv=nil) then exit;
  slots_cnt := (cardinal(inv.m_slots.last)-cardinal(inv.m_slots.start)) div sizeof(CInventorySlot);
  if inv.m_iActiveSlot>=slots_cnt then exit;

  result:=pCInventorySlot ( cardinal(inv.m_slots.start)+ inv.m_iActiveSlot*sizeof(CInventorySlot));

end;

end.
