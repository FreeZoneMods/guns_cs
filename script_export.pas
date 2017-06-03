unit script_export;

interface
uses BaseGameData;


function Init(dwFlags:cardinal):boolean;
implementation
const
  CUIGameCustom__HideActorMenu_offset:cardinal=$47f120; //<NONPORTABLE>//

var
  CUIGameCustom__ShowActorMenu_adapter_ptr:pointer;
  CUIGameCustom__SwitchActorMenuState_ptr:pointer;


procedure CUIGameCustom__SwitchActorMenuState(); stdcall; //<NONPORTABLE>//
//todo: use structs!!
asm
    mov eax, [ecx+$30] //CUISimpleWindow
    cmp [eax+04], 0 //CUISimpleWindow.m_bShowMe
    jne @shown
    
    jmp CUIGameCustom__ShowActorMenu_adapter_ptr

    @shown:
    mov eax, xrgame_addr
    add eax, CUIGameCustom__HideActorMenu_offset
    jmp eax
end;

procedure CUIGameCustom__ShowActorMenu_adapter(); stdcall;
const
  CUIGameCustom__ShowActorMenu_offset:cardinal=$47f060; //<NONPORTABLE>//
asm
    mov eax, xrgame_addr
    add eax, CUIGameCustom__ShowActorMenu_offset

    mov ebx, ecx //ShowActorMenu требует this в ebx, а у нас он сейчас в ecx 
    jmp eax
end;

procedure CUIGameCustom__script_extension_Patch(); stdcall;
const

  registrator_offset:cardinal=$480DE6;                //<NONPORTABLE>//
  ShowActorMenu_name:PChar = 'ShowActorMenu';
  SwitchActorMenu_name:PChar = 'SwitchActorMenu';  
asm
/////////////////////////////////////////////////////////////
    push ecx    //save ECX from modifying by registrator

    push 0
    push CUIGameCustom__ShowActorMenu_adapter_ptr
    push ShowActorMenu_name
    push eax   //class_<T>*

    mov ecx, xrgame_addr
    add ecx, registrator_offset
    call ecx


    push 0
    push CUIGameCustom__SwitchActorMenuState_ptr
    push SwitchActorMenu_name
    push eax   //class_<T>*

    mov ecx, xrgame_addr
    add ecx, registrator_offset
    call ecx

    pop ecx  //Restore initial ECX
/////////////////////////////////////////////////////////////
//Original code
    mov ecx, eax
    xor eax, eax
    lea edi, [ebp-$0C]    
end;

function Init(dwFlags:cardinal):boolean;
var
  addr:cardinal;
begin
  result:=false;

  if dwFlags and FLG_PATCH_GAME >0 then begin
    CUIGameCustom__ShowActorMenu_adapter_ptr:=@CUIGameCustom__ShowActorMenu_adapter;
    CUIGameCustom__SwitchActorMenuState_ptr:=@CUIGameCustom__SwitchActorMenuState;

    addr:=xrGame_addr+$480BC7;                                                       //<NONPORTABLE>//
    if not WriteJump(addr, cardinal(@CUIGameCustom__script_extension_Patch), 7, true) then exit;
  end;

  result:=true;  
end;

end.
