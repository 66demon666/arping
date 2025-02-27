unit UserInteractive;

interface

type

  TUserInteractive = class
    function GetInterface(msg: string): integer; static;
  end;

implementation

function TUserInteractive.GetInterface(msg: string): integer; static;

end.
