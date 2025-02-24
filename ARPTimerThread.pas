unit ARPTimerThread;

interface

uses
  System.Classes, SysUtils, DateUtils;

type
  Timer = class(TThread)
  protected
    timeout: integer;
    procedure Execute; override;
  public
    constructor Create(timeout: integer);
  end;

implementation

constructor Timer.Create(timeout: integer);
begin
  inherited Create(false);
  self.timeout := timeout;
end;

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure Timer.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ Timer }

procedure Timer.Execute;
begin
  NameThreadForDebugging('ARP Timer');
  sleep(timeout);
  writeln('Thread completed');
  self.FreeOnTerminate := true;
  { Place thread code here }
end;

end.
