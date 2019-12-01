{Hier also die lauffähige Version. Einfach diese Unit in das Projekt einbinden
und die Methode TSingleInstance.OnStartUp mit eigenen Leben füllen.
Nicht vergessen den Wert sTitle mit einem eigenen eindeutigen Wert zu ändern.
}
unit SingleInstance;

interface
uses Winapi.Windows, Winapi.Messages, SysUtils, Vcl.Dialogs;


////////  SingleInstance
type
  TSingleInstance = class
    class procedure WndProc(var Msg: TMessage);
    class procedure Start;
    class procedure Stop;
    class function GetParamStr(P: PChar; var Param: string): PChar;
    class function ParamCount: Integer;
    class function ParamStrEx(Index: Integer): string;
    class procedure OnStartup;
  end;


implementation
uses Main, Forms, Classes;

const
{$IFDEF WIN32}
  sTitle = 'xAvsPThumbByGPo_x32';  // dieser Wert MUSS individuell angepasst werden
{$else}
  sTitle = 'xAvsPThumbByGPo_x64';
{$endif}
var
  CmdLine: PChar = nil; // ParamStr() der 2. Instance per wm_CopyData transportiert

class procedure TSingleInstance.OnStartup;
var
    s,w: String;
    x: Integer;
    Thread1,
    Thread2: Cardinal;
begin
    //If ParamCount> 0 then s:= ParamStrEx(1);
    //If ParamCount > 1 then w:= ParamStrEx(2);

    Thread1 := GetCurrentThreadId;
    Thread2 := GetWindowThreadProcessId(GetForegroundWindow, nil);
    AttachThreadInput(Thread1, Thread2, true);
    try
      If not Form1.Showing or IsIconic(Form1.Handle) then
        ShowWindow(Form1.Handle, SW_RESTORE);
      SetForegroundWindow(Application.Handle);
    finally
      AttachThreadInput(Thread1, Thread2, false);
    end;

   { h:= GetForegroundWindow;
    If h <> Form1.Handle then
    begin
      SetWindowPos(h,HWND_BOTTOM,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
      SetForegroundWindow(Form1.Handle);
      If Form1.Showing then Form1.SetFocus;
    end; }
    //ShowMessage(CmdLine);
    If Form1.Panel1.Visible then
    begin
      beep;
      exit;
    end;

    // TODO make it better
    If ParamCount > 0 then
    begin
      x:= 1;
      While x <= ParamCount do
      begin
        w:= '';
        s:= ParamStrEx(x);
        If x < ParamCount then
        begin
          inc(x);
          w:= ParamStrEx(x);
        end;
        If (w <> '') then
        begin
          If not FileExists(w) then
             Form1.ProzessParamStr(s, w)
          else begin
            Form1.ProzessParamStr(s, '');
            Form1.ProzessParamStr(w, '');
          end;
        end
        else Form1.ProzessParamStr(s, '');
        inc(x);
      end;
    end;

    {
    If not Form1.Panel1.Visible then  // dann beim Laden
      Form1.ProzessParamStr(s,w)
    else beep;
    }
end;

// ab hier Implementierung
var
  WndHandle: hWnd;      // die 1. Instance erzeugt ein Fensterhandle
const
  cMagic  = $BADF00D;  // dient zur Idententifizierung der Message wm_CopyData
  cResult = $DAED;



{class function TSingleInstance.GetParamStr(P: PChar; var Param: string): PChar;
// diese funktion musste aus System.pas kopiert werden für unser
// ParamStr() und ParamCount() nötig 
var 
  Len: Integer;
  Buffer: array[0..4095] of WChar;
begin

  while True do 
  begin 
    while (P[0] <> #0) and (P[0] <= ' ') do Inc(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break; 
  end; 
  Len := 0; 
  while (P[0] > ' ') and (Len < SizeOf(Buffer)) do 
    if P[0] = '"' then 
    begin 
      Inc(P); 
      while (P[0] <> #0) and (P[0] <> '"') do 
      begin
        Buffer[Len] := P[0]; 
        Inc(Len); 
        Inc(P); 
      end;
      if P[0] <> #0 then Inc(P); 
    end else 
    begin 
      Buffer[Len] := P[0];
      Inc(Len); 
      Inc(P); 
    end;

  SetString(Param, Buffer, Len); 
  Result := P; 
end;}

class function TSingleInstance.GetParamStr(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S: PChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      Inc(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Inc(Len);
        Inc(P);
      end;
      if P[0] <> #0 then
        Inc(P);
    end
    else
    begin
      Inc(Len);
      Inc(P);
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
      if P[0] <> #0 then Inc(P);
    end
    else
    begin
      S[i] := P^;
      Inc(P);
      Inc(i);
    end;
  end;

  Result := P;
end;

class function TSingleInstance.ParamCount: Integer;
// diese Funktion musste aus System.pas kopiert werden für unser 
// ParamStr() und ParamCount() nötig da System.pas NICHT auf die 
// globale Variable System.CmdLine zugreift sondern per Funktion GetCommandLine() arbeitet. 
var 
  P: PChar;
  S: string;
begin 
  P := GetParamStr(CmdLine, S); // CmdLine statt GetCommandLine
  Result := 0; 
  while True do
  begin 
    P := GetParamStr(P, S); 
    if S = '' then Break;
    Inc(Result); 
  end; 
end;

class function TSingleInstance.ParamStrEx(Index: Integer): string;
// siehe ParamCount 
var
  P: PChar;
  Buffer: array[0..260] of Char;
begin
  If Index = 0 then
    SetString(Result, Buffer, GetModuleFileName(0, Buffer, SizeOf(Buffer))) 
  else begin
    P := CmdLine; // CmdLine statt GetCommandLine
    While True do
    begin 
      P := GetParamStr(P, Result);
      If (Index = 0) or (Result = '') then Break;
      Dec(Index);
    end; 
  end; 
end;

class procedure TSingleInstance.WndProc(var Msg: TMessage);
// das ist die Fensterprocedure von WndHandle, sie empfängt innerhalb 
// der 1. Instance die wm_CopyData Message mit der CommandLine der 
// 2. Instance
var 
    dEvent: Integer;
begin

  With Msg do
    Case Msg of
      WM_CopyData:
      begin
        dEvent:= PCopyDataStruct(lParam).dwData;
        Case dEvent of
          cMagic:
          begin
            If Form1.popSingleInstance.Checked then
            begin
              Result := cResult;
              CmdLine := PCopyDataStruct(lParam).lpData;
              OnStartup;
            end
            else Result := DefWindowProc(WndHandle, Msg, wParam, lParam);
          end;
      end;
      end
      else Result := DefWindowProc(WndHandle, Msg, wParam, lParam);
  end;
end;

class procedure TSingleInstance.Start;
var
  Data: TCopyDataStruct;
  PrevWnd: hWnd;
begin
  If MainInstance = GetModuleHandle(nil) then // nur in EXE's möglich, nicht in DLL's oder packages
  begin
    PrevWnd := FindWindow('TPUtilWindow', sTitle); // suche unser Fenster
    if IsWindow(PrevWnd) then
    begin
      // 1. Instance läuft also schon, sende CommandLine an diese
      Data.dwData := cMagic;
      Data.cbData := (StrLen(PWideChar(GetCommandLine))*2) + 1; // Änderung wegen Unicode String
      Data.lpData := GetCommandLine;

      If SendMessage(PrevWnd, WM_CopyData, 0, Integer(@Data)) = cResult then Halt;
    end;

   // keine 1. Instance gefunden, wir sind also die 1. Instance
   WndHandle := AllocateHWnd(WndProc);
   SetWindowText(WndHandle, sTitle);

// falls auch bei der 1. Instance OnStartup aufgerufen werden soll
//    CmdLine := System.CmdLine;
//    OnStartup;
  end;
end;

class procedure TSingleInstance.Stop;
begin 
  If IsWindow(WndHandle) then DeallocateHWnd(WndHandle);
end;

initialization
  TSingleInstance.Start;

finalization
  TSingleInstance.Stop;

end.