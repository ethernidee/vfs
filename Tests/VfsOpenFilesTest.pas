unit VfsOpenFilesTest;

(***)  interface  (***)

uses
  Windows, SysUtils, TestFramework,
  Utils, WinUtils, DataLib,
  VfsBase, VfsUtils, VfsOpenFiles;

type
  TestOpenFiles = class (TTestCase)
   protected
    procedure SetUp; override;
    procedure TearDown; override;

   published
    procedure GetCombinedDirListing;
  end;


(***)  implementation  (***)


procedure TestOpenFiles.SetUp;
begin
  VfsBase.ResetVfs();
end;

procedure TestOpenFiles.TearDown;
begin
  VfsBase.ResetVfs();
end;

procedure TestOpenFiles.GetCombinedDirListing;
const
  VALID_FULLY_VIRT_DIR_LISTING = 'mms.cfg'#13#10'.'#13#10'..';
  VALID_COMBINED_LISTING       = 'Hobbots'#13#10'vcredist.bmp'#13#10'.'#13#10'..'#13#10'503.html'#13#10'default'#13#10'Mods';

var
{O} OpenedFile: VfsOpenFiles.TOpenedFile;
    DirPath:    WideString;
    RootDir:    string;

begin
  OpenedFile := nil;
  // * * * * * //
  RootDir := SysUtils.ExtractFileDir(WinUtils.GetExePath) + '\Tests\Fs';
  VfsBase.MapDir(RootDir, RootDir + '\Mods\FullyVirtual', DONT_OVERWRITE_EXISTING);
  VfsBase.MapDir(RootDir, RootDir + '\Mods\B', DONT_OVERWRITE_EXISTING);
  VfsBase.RunVfs(SORT_FIFO);

  DirPath    := VfsUtils.NormalizePath(RootDir + '\Hobbots');
  OpenedFile := VfsOpenFiles.TOpenedFile.Create(777, DirPath);
  OpenedFile.FillDirListing('*');
  Check(OpenedFile.DirListing <> nil, 'Directory listing must be assigned');
  Check(OpenedFile.DirListing.GetDebugDump() = VALID_FULLY_VIRT_DIR_LISTING, 'Invalid listing for fully virtual directory "' + DirPath + '". Got: ' + OpenedFile.DirListing.GetDebugDump());
  FreeAndNil(OpenedFile);

  OpenedFile := VfsOpenFiles.TOpenedFile.Create(888, RootDir);
  OpenedFile.FillDirListing('*');
  Check(OpenedFile.DirListing <> nil, 'Directory listing must be assigned');
  Check(OpenedFile.DirListing.GetDebugDump() = VALID_COMBINED_LISTING, 'Invalid combined listing for directory "' + RootDir + '". Got: ' + OpenedFile.DirListing.GetDebugDump());
  // * * * * * //
  SysUtils.FreeAndNil(OpenedFile);
end;

begin
  RegisterTest(TestOpenFiles.Suite);
end.