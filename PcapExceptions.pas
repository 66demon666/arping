unit PcapExceptions;

interface

uses
  System.Classes, SysUtils;

type
  EFindAllDevicesException = class(Exception)
  end;

  EOpenInterfaceException = class(Exception)
  end;

implementation

end.
