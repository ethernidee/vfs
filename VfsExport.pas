unit VfsExport;
(*

*)


(***)  interface  (***)

uses
  Windows,
  Utils,
  VfsDebug, VfsBase, VfsControl, VfsWatching, VfsUtils;

exports
  VfsDebug.SetLoggingProc,
  VfsDebug.WriteLog_ name 'WriteLog',
  VfsControl.RunVfs,
  VfsBase.PauseVfs,
  VfsBase.ResetVfs,
  VfsBase.RefreshVfs,
  VfsBase.CallWithoutVfs;


(***)  implementation  (***)


function Externalize (const Str: AnsiString): {O} pointer; overload;
begin
  GetMem(result, Length(Str) + 1);
  Utils.CopyMem(Length(Str) + 1, pchar(Str), result);
end;

function Externalize (const Str: WideString): {O} pointer; overload;
begin
  GetMem(result, (Length(Str) + 1) * sizeof(WideChar));
  Utils.CopyMem((Length(Str) + 1) * sizeof(WideChar), PWideChar(Str), result);
end;

function MapDir (const VirtPath, RealPath: PWideChar; OverwriteExisting: boolean; Flags: integer = 0): LONGBOOL; stdcall;
begin
  result := VfsBase.MapDir(WideString(VirtPath), WideString(RealPath), OverwriteExisting, Flags);
end;

function MapDirA (const VirtPath, RealPath: PAnsiChar; OverwriteExisting: boolean; Flags: integer = 0): LONGBOOL; stdcall;
begin
  result := VfsBase.MapDir(WideString(VirtPath), WideString(RealPath), OverwriteExisting, Flags);
end;

function MapModsFromList (const RootDir, ModsDir, ModListFile: PWideChar; Flags: integer = 0): LONGBOOL; stdcall;
begin
  result := VfsControl.MapModsFromList(WideString(RootDir), WideString(ModsDir), WideString(ModListFile), Flags);
end;

function MapModsFromListA (const RootDir, ModsDir, ModListFile: PAnsiChar; Flags: integer = 0): LONGBOOL; stdcall;
begin
  result := VfsControl.MapModsFromList(WideString(RootDir), WideString(ModsDir), WideString(ModListFile), Flags);
end;

function GetSerializedModList: {O} pointer; stdcall;
begin
  result := VfsControl.GetSerializedModList;
end;

function GetSerializedModListA: {O} pointer; stdcall;
begin
  result := VfsControl.GetSerializedModListA;
end;

function RunWatcher (const WatchDir: PWideChar; DebounceInterval: integer): LONGBOOL; stdcall;
begin
  result := VfsWatching.RunWatcher(WatchDir, DebounceInterval);
end;

function RunWatcherA (const WatchDir: pchar; DebounceInterval: integer): LONGBOOL; stdcall;
begin
  result := VfsWatching.RunWatcher(WatchDir, DebounceInterval);
end;

(* Frees buffer, that was transfered to client earlier using other VFS API *)
procedure MemFree ({O} Buf: pointer); stdcall;
begin
  FreeMem(Buf);
end;

(* Returns text with all applied mappings, separated via #13#10. If ShortenPaths is true, common part
   of real and virtual paths is stripped. Call MemFree to release result buffer *)
function GetMappingsReport: {O} PWideChar; stdcall;
begin
  result := Externalize(VfsBase.GetMappingsReport);
end;

function GetMappingsReportA: {O} PAnsiChar; stdcall;
begin
  result := Externalize(AnsiString(VfsBase.GetMappingsReport));
end;

(* Returns text with all applied mappings on per-file level, separated via #13#10. If ShortenPaths is true, common part
   of real and virtual paths is stripped *)
function GetDetailedMappingsReport: {O} PWideChar; stdcall;
begin
  result := Externalize(VfsBase.GetDetailedMappingsReport);
end;

function GetDetailedMappingsReportA: {O} PAnsiChar; stdcall;
begin
  result := Externalize(AnsiString(VfsBase.GetDetailedMappingsReport));
end;

procedure ConsoleLoggingProc (Operation, Message: pchar); stdcall;
begin
  WriteLn('>> ', string(Operation), ': ', string(Message), #13#10);
end;

(* Allocates console and install logger, writing messages to console *)
procedure InstallConsoleLogger; stdcall;
var
  Rect:    TSmallRect;
  BufSize: TCoord;
  hIn:     THandle;
  hOut:    THandle;

begin
  AllocConsole;
  SetConsoleCP(GetACP);
  SetConsoleOutputCP(GetACP);
  hIn                       := GetStdHandle(STD_INPUT_HANDLE);
  hOut                      := GetStdHandle(STD_OUTPUT_HANDLE);
  pinteger(@System.Input)^  := hIn;
  pinteger(@System.Output)^ := hOut;
  BufSize.x                 := 120;
  BufSize.y                 := 1000;
  SetConsoleScreenBufferSize(hOut, BufSize);
  Rect.Left                 := 0;
  Rect.Top                  := 0;
  Rect.Right                := 120 - 1;
  Rect.Bottom               := 50 - 1;
  SetConsoleWindowInfo(hOut, true, Rect);
  SetConsoleTextAttribute(hOut, (0 shl 4) or $0F);

  VfsDebug.SetLoggingProc(@ConsoleLoggingProc);
end; // .procedure InitConsole;

(* Returns real path for vfs item by its virtual path or empty string on error *)
function GetRealPath (const VirtPath: WideString): {O} PWideChar; stdcall;
begin
  result := Externalize(VfsBase.GetVfsItemRealPath(VfsUtils.NormalizePath(VirtPath)));
end;

function GetRealPathA (const VirtPath: AnsiString): {O} PAnsiChar; stdcall;
begin
  result := Externalize(AnsiString(VfsBase.GetVfsItemRealPath(VfsUtils.NormalizePath(VirtPath))));
end;

exports
  GetDetailedMappingsReport,
  GetDetailedMappingsReportA,
  GetMappingsReport,
  GetMappingsReportA,
  GetRealPath,
  GetRealPathA,
  GetSerializedModList,
  GetSerializedModListA,
  InstallConsoleLogger,
  MapDir,
  MapDirA,
  MapModsFromList,
  MapModsFromListA,
  MemFree,
  RunWatcher,
  RunWatcherA;
end.
