program arping;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  DebugUtils in 'DebugUtils.pas',
  packet in 'packet.pas',
  PcapExceptions in 'PcapExceptions.pas',
  PcapTypes in 'PcapTypes.pas',
  PcapUtils in 'PcapUtils.pas',
  TPcapClass in 'TPcapClass.pas',
  UserInteractive in 'UserInteractive.pas',
  SysUtils;

const
  IF_ID = '\Device\NPF_{077C8EF5-CB84-4C34-9C2A-66006D41D835}';
  IF_ID_2 = '\Device\NPF_{9C22769D-724A-4B92-814A-605A36AAF2CC}';

var
  pcap: TPcap;
  UserInteractive: TUserInteractive;

begin
  try
    try
      pcap := TPcap.Create;
    except
      on e: EFindAllDevicesException do
        writeln('Interfaces fetching error: ' + e.Message);
    end;
    UserInteractive := TUserInteractive.Create(@pcap);
    UserInteractive.FSelectedInterface := UserInteractive.GetInterface
      ('Select interface:');
    writeln('Selected interface: ' + UserInteractive.FSelectedInterface.
      description);
    try
      begin
        pcap.OpenInterface(@UserInteractive.FSelectedInterface);
        writeln('Adapter open in promiscious mode');
      end;
    except
      on e: EOpenInterfaceException do
        writeln('Open adapter failed: ' + e.Message);
    end;

    readln;
  except
    on e: Exception do
    begin
      writeln(e.ClassName, ': ', e.Message);
      readln;
    end;
  end;

end.
