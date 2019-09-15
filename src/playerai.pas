unit PlayerAI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TGameTableModel = array[0..2, 0..2] of byte;

  { TPlayer }

  TPlayer = class
  public
    procedure play(var table: TGameTableModel); virtual; abstract;
  end;

  { TRandomPlayer }

  TRandomPlayer = class(TPlayer)
  public
    procedure play(var table: TGameTableModel); override;
  end;

  { TMinMaxPalyer }

  TMinMaxPalyer = class(TPlayer)
  public
    procedure play(var table: TGameTableModel); override;
  end;


implementation

uses
  fgl;

type
  TListOfPoint = specialize TFPGList<TPoint>;

  { TListOfPointHelper }

  TListOfPointHelper = class helper for TListOfPoint
    function isPresent(x, y: byte): boolean;
  end;

{ TMinMaxPalyer }

procedure TMinMaxPalyer.play(var table: TGameTableModel);
begin

end;

{ TListOfPointHelper }

function TListOfPointHelper.isPresent(x, y: byte): boolean;
var
  p: TPoint;
begin
  Result := False;
  for p in self do
  begin
    if (p.x = x) and (p.y = y) then
    begin
      exit(True);
    end;
  end;
end;

{ TRandomPlayer }

procedure TRandomPlayer.play(var table: TGameTableModel);
var
  idx: integer;
  Pt: TPoint;
  listOfPoint: TListOfPoint = nil;
begin
  listOfPoint := TListOfPoint.Create;
  for idx := 0 to 8 do
  begin
    case idx of
      0: if (table[0, 0] = 0) then
          listOfPoint.Add(point(0, 0));
      1: if (table[1, 0] = 0) then
          listOfPoint.Add(point(1, 0));
      2: if (table[2, 0] = 0) then
          listOfPoint.Add(point(2, 0));
      3: if (table[0, 1] = 0) then
          listOfPoint.Add(point(0, 1));
      4: if (table[1, 1] = 0) then
          listOfPoint.Add(point(1, 1));
      5: if (table[2, 1] = 0) then
          listOfPoint.Add(point(2, 1));
      6: if (table[0, 2] = 0) then
          listOfPoint.Add(point(0, 2));
      7: if (table[1, 2] = 0) then
          listOfPoint.Add(point(1, 2));
      8: if (table[1, 2] = 0) then
          listOfPoint.Add(point(2, 2));
    end;
  end;
  idx := random(listOfPoint.Count);
  pt  := listOfPoint[idx];
  table[pt.x, pt.y] := 2;
  FreeAndNil(listOfPoint);
end;

initialization

  Randomize;

end.
