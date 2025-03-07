unit ARPTimerThread;

interface

uses
        System.Classes, SysUtils, DateUtils, PcapTypes;

type
        Timer = class(TThread)
        protected
                timeout: integer;
                adhandle: PPcap_t;

                procedure Execute; override;
        public
                isTimeout: Boolean;
                constructor Create(timeout: integer; adhandle: PPcap_t);
        end;

implementation

constructor Timer.Create(timeout: integer; adhandle: PPcap_t);
begin
        inherited Create(false);
        self.timeout := timeout;
        self.adhandle := adhandle;
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
        isTimeout := false;
        sleep(timeout);
        writeln('Thread completed');
        pcap_breakloop(adhandle);
        self.FreeOnTerminate := true;
        { Place thread code here }
end;

end.
