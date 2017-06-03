library guns_cs;

uses
  SysUtils,
  Classes,
  xr_strings in 'xr_strings.pas',
  BaseGameData in 'BaseGameData.pas',
  gunsl_config in 'gunsl_config.pas',
  dynamic_caster in 'dynamic_caster.pas',
  MatVectors in 'MatVectors.pas',
  Console in 'Console.pas',
  WeaponSound in 'WeaponSound.pas',
  BaseClasses in 'typedefs\BaseClasses.pas',
  Spatial in 'typedefs\Spatial.pas',
  Render in 'typedefs\Render.pas',
  Schedule in 'typedefs\Schedule.pas',
  Physics in 'typedefs\Physics.pas',
  Objects in 'typedefs\Objects.pas',
  HudItems in 'typedefs\HudItems.pas',
  WeaponAnims in 'WeaponAnims.pas',
  Misc in 'Misc.pas',
  Hits in 'typedefs\Hits.pas',
  Inventory in 'typedefs\Inventory.pas',
  Keys in 'typedefs\Keys.pas',
  dynamic_gamemodes in 'dynamic_gamemodes.pas',
  script_export in 'script_export.pas';

{$R *.res}

var
  patch_flags:cardinal;



procedure xrApplyPatch(dwFlags:cardinal); cdecl; export;
begin
  dwFlags:= dwFlags and (not patch_flags);
//  Log('Patching with flags: '+inttohex(dwFlags,8));

  if (patch_flags=0) and not BaseGameData.Init(dwFlags) then Log('BaseGameData module failed to initialize!', true) else
{$IFNDEF ONLY_FOR_GAMEMODES}
  if not Console.Init(dwFlags) then Log('Console module failed to initialize!', true) else
  if not WeaponSound.Init(dwFlags) then Log('WeaponSound module failed to initialize!', true) else
  if not Misc.Init(dwFlags) then Log('Misc module failed to initialize!', true) else
  if not WeaponAnims.Init(dwFlags) then Log('WeaponAnims module failed to initialize!', true) else
{$ENDIF}
  if not script_export.Init(dwFlags) then Log('script_export module failed to initialize!', true) else
  if not dynamic_gamemodes.Init(dwFlags) then Log('dynamic_gamemodes module failed to initialize!', true) else begin
    patch_flags:=patch_flags or dwFlags;
  end;
end;

procedure Patch(); stdcall; export;
begin
  xrApplyPatch($FFFFFFFF);
end;

exports
  Patch,
  xrApplyPatch;

begin
  patch_flags:=0;
end.
