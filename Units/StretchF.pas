unit stretchf;

interface
uses Windows, SysUtils, Graphics;

type
  TRGBColor = record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
  TRGBColorArray = array[0..400000] of TRGBColor;
  PRGBColorArray = ^TRGBColorArray;

  TIntArray = array[0..400000] of Integer;
  PIntArray = ^TIntArray;

  TInt4Array = array[0..3] of Integer;
  TInt4AA = array[0..400000] of TInt4Array;
  PInt4AA = ^TInt4AA;

  TProgressProc = procedure(Progress: Integer);

  procedure Stretch(const Src: TBitmap; const Width,Height: Integer; const PProc: TProgressProc= nil);overload
  //procedure Stretch(const Dst,Src: TBitmap; const Width,Height: Integer; const PProc: TProgressProc= nil);overload

implementation

procedure ProgressProcCaller(Progress: Integer; PProc: TProgressProc);
begin
  if Assigned(PProc) then PProc(Progress);
end;

procedure HLI3(const Src, Dst: TBitmap; const PProc: TProgressProc);
var
  SP, DP: PRGBColorArray;
  SXA: PIntArray;
  LR: PInt4AA;
  X, Y, SX, V: Integer;
  Z: Extended;
begin
  ProgressProcCaller(0, PProc);

  try
    GetMem(SXA, SizeOf(Integer) * Dst.Width);
  except
    on EHeapException do Exit;
  end;

  try
    GetMem(LR, SizeOf(TInt4Array) * Dst.Width);
  except
    on EHeapException do
    begin
      FreeMem(SXA);
      Exit;
    end;
  end;

  try
    for X := 0 to Dst.Width - 1 do
    begin
      Z := X * (Src.Width - 1) / (Dst.Width - 1);
      SXA[X] := Trunc(Z);
      Z := Frac(Z) + 1;
      LR[X][0] := Trunc($10000 * (Z - 1) * (Z - 2) * (Z - 3) * (1 / -6) + 0.5);
      LR[X][1] := Trunc($10000 * (Z - 0) * (Z - 2) * (Z - 3) * (1 /  2) + 0.5);
      LR[X][2] := Trunc($10000 * (Z - 0) * (Z - 1) * (Z - 3) * (1 / -2) + 0.5);
      LR[X][3] := Trunc($10000 * (Z - 0) * (Z - 1) * (Z - 2) * (1 /  6) + 0.5);
    end;

    for Y := 0 to Dst.Height - 1 do
    begin
      SP := Src.ScanLine[Y];
      DP := Dst.ScanLine[Y];

      X := 0;
      SX := SXA[X];
      while SX < 1 do
      begin
        Z := Frac(X * (Src.Width - 1) / (Dst.Width - 1));
        DP[X].B := Trunc(SP[SX].B * (1 - Z) + SP[SX + 1].B * Z + 0.5);
        DP[X].G := Trunc(SP[SX].G * (1 - Z) + SP[SX + 1].G * Z + 0.5);
        DP[X].R := Trunc(SP[SX].R * (1 - Z) + SP[SX + 1].R * Z + 0.5);
        Inc(X);
        SX := SXA[X];
      end;

      while SX < Src.Width - 2 do
      begin
        V := $8000 + SP[SX - 1].B * LR[X][0] + SP[SX    ].B * LR[X][1] +
             SP[SX + 1].B * LR[X][2] + SP[SX + 2].B * LR[X][3];
        if V < 0 then V := 0
        else if V > $FF * $10000 then V := $FF * $10000;
        DP[X].B := V shr 16;

        V := $8000 + SP[SX - 1].G * LR[X][0] + SP[SX    ].G * LR[X][1] +
             SP[SX + 1].G * LR[X][2] + SP[SX + 2].G * LR[X][3];
        if V < 0 then V := 0
        else if V > $FF * $10000 then V := $FF * $10000;
        DP[X].G := V shr 16;

        V := $8000 + SP[SX - 1].R * LR[X][0] + SP[SX    ].R * LR[X][1] +
             SP[SX + 1].R * LR[X][2] + SP[SX + 2].R * LR[X][3];
        if V < 0 then V := 0
        else if V > $FF * $10000 then V := $FF * $10000;
        DP[X].R := V shr 16;

        Inc(X);
        SX := SXA[X];
      end;

      while SX < Src.Width - 1 do
      begin
        Z := Frac(X * (Src.Width - 1) / (Dst.Width - 1));
        DP[X].B := Trunc(SP[SX].B * (1 - Z) + SP[SX + 1].B * Z + 0.5);
        DP[X].G := Trunc(SP[SX].G * (1 - Z) + SP[SX + 1].G * Z + 0.5);
        DP[X].R := Trunc(SP[SX].R * (1 - Z) + SP[SX + 1].R * Z + 0.5);
        Inc(X);
        SX := SXA[X];
      end;

      DP[X] := SP[SX];
      Try
        ProgressProcCaller((100 * Y) div ((Dst.Height - 1) * 2), PProc);
      except
      end;
    end;
  finally
    FreeMem(LR);
    FreeMem(SXA);
  end;
end;

procedure VLI3(const Src, Dst: TBitmap; const PProc: TProgressProc);
var
  DP: PRGBColorArray;
  SP: array[0..3] of PRGBColorArray;
  LR: PInt4AA;
  X, Y, SY, V: Integer;
  Z: Extended;
begin
  ProgressProcCaller(50, PProc);
  try
    GetMem(LR, SizeOf(TInt4Array) * Dst.Height);
  except
    on EOutOfMemory do Exit;
  end;

  try
    for Y := 0 to Dst.Height - 1 do
    begin
      Z := Frac(Y * (Src.Height - 1) / (Dst.Height - 1)) + 1;
      LR[Y][0] := Trunc($10000 * (Z - 1) * (Z - 2) * (Z - 3) * (1 / -6) + 0.5);
      LR[Y][1] := Trunc($10000 * (Z - 0) * (Z - 2) * (Z - 3) * (1 /  2) + 0.5);
      LR[Y][2] := Trunc($10000 * (Z - 0) * (Z - 1) * (Z - 3) * (1 / -2) + 0.5);
      LR[Y][3] := Trunc($10000 * (Z - 0) * (Z - 1) * (Z - 2) * (1 /  6) + 0.5);
    end;

    for Y := 0 to Dst.Height - 1 do
    begin
      Z := Y * (Src.Height - 1) / (Dst.Height - 1);
      SY := Trunc(Z);
      DP := Dst.ScanLine[Y];

      if SY = Src.Height - 1 then
      begin
        SP[0] := Src.ScanLine[SY];

        for X := 0 to Dst.Width - 1 do
        begin
          DP[X] := SP[0][X];
        end;
      end
      else if (SY = 0) or (SY = Src.Height - 2) then
      begin
        SP[0] := Src.ScanLine[SY];
        SP[1] := Src.ScanLine[SY + 1];
        Z := Frac(Z);

        for X := 0 to Dst.Width - 1 do
        begin
          DP[X].B := Trunc(SP[0][X].B * (1 - Z) + SP[1][X].B * Z + 0.5);
          DP[X].G := Trunc(SP[0][X].G * (1 - Z) + SP[1][X].G * Z + 0.5);
          DP[X].R := Trunc(SP[0][X].R * (1 - Z) + SP[1][X].R * Z + 0.5);
        end;
      end
      else
      begin
        SP[0] := Src.ScanLine[SY - 1];
        SP[1] := Src.ScanLine[SY    ];
        SP[2] := Src.ScanLine[SY + 1];
        SP[3] := Src.ScanLine[SY + 2];

        for X := 0 to Dst.Width - 1 do
        begin
          V := $8000 + SP[0][X].B * LR[Y][0] + SP[1][X].B * LR[Y][1] +
               SP[2][X].B * LR[Y][2] + SP[3][X].B * LR[Y][3];
          if V < 0 then V := 0
          else if V > $FF * $10000 then V := $FF * $10000;
          DP[X].B := V shr 16;

          V := $8000 + SP[0][X].G * LR[Y][0] + SP[1][X].G * LR[Y][1] +
               SP[2][X].G * LR[Y][2] + SP[3][X].G * LR[Y][3];
          if V < 0 then V := 0
          else if V > $FF * $10000 then V := $FF * $10000;
          DP[X].G := V shr 16;

          V := $8000 + SP[0][X].R * LR[Y][0] + SP[1][X].R * LR[Y][1] +
               SP[2][X].R * LR[Y][2] + SP[3][X].R * LR[Y][3];
          if V < 0 then V := 0
          else if V > $FF * $10000 then V := $FF * $10000;
          DP[X].R := V shr 16;
        end;
      end;
      Try
        ProgressProcCaller(50 + (100 * Y) div ((Dst.Height - 1) * 2), PProc);
      except
      end;
    end;
  finally
    FreeMem(LR);
  end;
end;

procedure HAO(const Src, Dst: TBitmap; const PProc: TProgressProc);
var
  X, Y: Integer;
  I, DX, HDX, SX, XD: Integer;
  SXA, XDA: PIntArray;
  SP, DP: PRGBColorArray;
  B, G, R: Integer;
  Z: Extended;
begin
  ProgressProcCaller(0, PProc);
  try
    GetMem(SXA, SizeOf(Integer) * (Src.Width + 1));
  except
    on EOutOfMemory do Exit;
  end;

  try
    GetMem(XDA, SizeOf(Integer) * (Src.Width + 1));
  except
    on EOutOfMemory do
    begin
      FreeMem(SXA);
      Exit;
    end;
  end;


  try
    for X := 0 to Dst.Width do
    begin
      Z := X * Src.Width / Dst.Width;
      SXA[X] := Trunc(Z);
      XDA[X] := Trunc(Frac(Z) * $10000);
    end;

    DX := Trunc(Src.Width * $10000 / Dst.Width  + 0.5);
    HDX := (DX + 1) div 2;

    for Y := 0 to Dst.Height - 1 do
    begin
      SP := Src.ScanLine[Y];
      DP := Dst.ScanLine[Y];
      SX := 0;
      XD := $10000;
      for X := 0 to Dst.Width - 1 do
      begin
        B := 0;
        G := 0;
        R := 0;

        if XD <> 0 then
        begin
          Inc(B, SP[SX].B * XD);
          Inc(G, SP[SX].G * XD);
          Inc(R, SP[SX].R * XD);
        end;

        I := SX;
        SX := SXA[X + 1];

        for I := I + 1 to SX - 1 do
        begin
          Inc(B, SP[I].B shl 16);
          Inc(G, SP[I].G shl 16);
          Inc(R, SP[I].R shl 16);
        end;

        XD := XDA[X + 1];
        if XD <> 0 then
        begin
          Inc(B, SP[SX].B * XD);
          Inc(G, SP[SX].G * XD);
          Inc(R, SP[SX].R * XD);
        end;

        XD := $10000 - XD;

        DP[X].B := (B + HDX) div DX;
        DP[X].G := (G + HDX) div DX;
        DP[X].R := (R + HDX) div DX;
      end;
      Try
        ProgressProcCaller((100 * Y) div ((Dst.Height - 1) * 2), PProc);
      except
      end;
    end;
  finally
    FreeMem(XDA);
    FreeMem(SXA);
  end;
end;

procedure VAO(const Src, Dst: TBitmap; const PProc: TProgressProc);
var
  X, Y: Integer;
  DP, SP: PRGBColorArray;
  Z: Extended;
  I, DY, HDY, YD, SY: Integer;
  B, G, R: PIntArray;
begin
  ProgressProcCaller(50, PProc);

  try
    GetMem(B, SizeOf(Integer) * Src.Width);
  except
    on EOutOfMemory do Exit;
  end;

  try
    GetMem(G, SizeOf(Integer) * Src.Width);
  except
    on EOutOfMemory do
    begin
      FreeMem(B);
      Exit;
    end;
  end;

  try
    GetMem(R, SizeOf(Integer) * Src.Width);
  except
    on EOutOfMemory do
    begin
      FreeMem(G);
      FreeMem(B);
      Exit;
    end;
  end;

  try
    YD := $10000;
    SY := 0;
    SP := Src.ScanLine[SY];
    DY := Trunc(Src.Height * $10000 / Dst.Height  + 0.5);
    HDY := (DY + 1) div 2;
    for Y := 0 to Dst.Height - 1 do
    begin
      for X := 0 to Dst.Width - 1 do
      begin
        B[X] := 0;
        G[X] := 0;
        R[X] := 0;
      end;

      if YD <> 0 then
      begin
        for X := 0 to Dst.Width - 1 do
        begin
          Inc(B[X], SP[X].B * YD);
          Inc(G[X], SP[X].G * YD);
          Inc(R[X], SP[X].R * YD);
        end;
      end;

      I := SY;
      Z := (Y + 1) * Src.Height / Dst.Height;
      SY := Trunc(Z);
      for I := I + 1 to SY - 1 do
      begin
        SP := Src.ScanLine[I];
        for X := 0 to Dst.Width - 1 do
        begin
          Inc(B[X], SP[X].B shl 16);
          Inc(G[X], SP[X].G shl 16);
          Inc(R[X], SP[X].R shl 16);
        end;
      end;

      YD := Trunc(Frac(Z) * $10000);
      if Y <> Dst.Height - 1 then
      begin
        SP := Src.ScanLine[SY];
        if YD <> 0 then
        begin
          for X := 0 to Dst.Width - 1 do
          begin
            Inc(B[X], SP[X].B * YD);
            Inc(G[X], SP[X].G * YD);
            Inc(R[X], SP[X].R * YD);
          end;
        end;
      end;

      DP := Dst.ScanLine[Y];
      for X := 0 to Dst.Width - 1 do
      begin
        DP[X].B := (B[X] + HDY) div DY;
        DP[X].G := (G[X] + HDY) div DY;
        DP[X].R := (R[X] + HDY) div DY;
      end;

      YD := $10000 - YD;
      Try
        ProgressProcCaller(50 + (100 * Y) div ((Dst.Height - 1) * 2), PProc);
      except
      end;
    end;
  finally
    FreeMem(R);
    FreeMem(G);
    FreeMem(B);
  end;
end;


procedure Stretch(const Src: TBitmap; const Width, Height: Integer; const PProc: TProgressProc= nil);
var
  Dst: TBitmap;
begin
  // GPo 2005; sonst wird Palette auch ohne Scr.Assign vernichtet
  If (Src = nil) or
     ((Src.Width= Width)and(Src.Height= Height))then exit;

  if Src.PixelFormat <> pf24bit then
  begin
    Src.PixelFormat := pf24bit;
    Src.ReleasePalette;
  end;

  Dst := TBitmap.Create;
  try
    if (Src.Width <> Width)and(Width> 1)and(Src.Width>1) then
    begin
      Dst.Assign(Src);
      Dst.Width := Width;

      if Width > Src.Width then HLI3(Src, Dst, PProc)
      else HAO(Src, Dst, PProc);

      //Src.Assign(Dst);
      // GPo 2005, etwas schneller
      If Dst.HandleAllocated then
        Src.Handle:= Dst.ReleaseHandle;

    end;

    if (Src.Height <> Height)and(Height> 1)and(Src.Height>1) then
    begin
      Dst.Assign(Src);
      Dst.Height := Height;

      if Height > Src.Height then VLI3(Src, Dst, PProc)
      else VAO(Src, Dst, PProc);

      //Src.Assign(Dst);
      // GPo 2005, etwas schneller
      If Dst.HandleAllocated then
        Src.Handle:= Dst.ReleaseHandle;
    end;
  finally
    Dst.Free;
  end;
end;



// GPo 2005 ; wenn Height u. Width <> dann kuzfristig 1 Bitmap  mehr im Speicher
// sonst nur Source und Destination, und etwas schneller
{procedure Stretch(const Dst,Src: TBitmap; const Width,Height: Integer; const PProc: TProgressProc= nil);
var bmp: TBitmap;
begin
  If ((not Src.Empty) and (Src <> nil)and(Dst<> nil))and
     ((Src.Width<> Width)or(Src.Height<> Height))and((Src.Width>1)and(Src.Height>1))then
  begin
    if Src.PixelFormat <> pf24bit then
    begin
      Src.PixelFormat := pf24bit;
      Src.ReleasePalette;
    end;
    if Dst.PixelFormat <> pf24bit then
    begin
      Dst.PixelFormat := pf24bit;
      Dst.ReleasePalette;
    end;
    If (Src.Width <> Width)and(Src.Height <> Height) then
    begin
      bmp:= TBitmap.Create;
      bmp.PixelFormat:= pf24bit;
      Try
        //bmp.Assign(Src);  // paar ms lansamer
        bmp.Width:= Width;
        bmp.Height:= Src.Height;

        If Width > Src.Width then HLI3(Src, bmp, PProc)
        else HAO(Src, bmp, PProc);

        //dest.Assign(bmp);
        Dst.Height:= Height;
        Dst.Width:= bmp.Width;

        If Height > Src.Height then VLI3(bmp, dst, PProc)
        else VAO(bmp, dst, PProc);
      finally
        bmp.Free;
      end;
    end
    else if(Src.Width <> Width) then
    begin
      //Dst.Assign(Src);
      Dst.Height:= Src.Height;
      Dst.Width := Width;
      If Width > Src.Width then HLI3(Src, Dst, PProc)
      else HAO(Src, Dst, PProc);
    end
    else If Src.Height <> Height then
    begin
      //Dest.Assign(Src);
      Dst.Width:= Src.Width;
      Dst.Height:= Height;
      If Height > Src.Height then VLI3(Src, Dst, PProc)
      else VAO(Src, Dst, PProc);
    end;
  end                                                           // Dst immer füllen
  else If (not Src.Empty) and (Src <> nil)and (Dst<> nil)then Dst.Assign(Src);
end;}

end.

