unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ExtCtrls, Types, PlayerAI;

type

  { TMainView }

  TMainView = class(TForm)
    Button1:       TButton;
    GameGrid:      TDrawGrid;
    Edit1:         TEdit;
    Edit2:         TEdit;
    RadioGroup1:   TRadioGroup;
    turnPlayer1:   TShape;
    StaticText1:   TStaticText;
    StaticText2:   TStaticText;
    turnPlayer2:   TShape;
    procedure Button1Click(Sender: TObject);
    procedure GameGridClick(Sender: TObject);
    procedure GameGridDrawCell(Sender: TObject; aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
  private
    FCpuPlayer:          TPlayer;
    FPlayer1StateColors: array [0..4] of TColor;
    FPlayer2StateColors: array [0..4] of TColor;
    FTurn:               byte;
    FGameTableModel:     TGameTableModel;
    function gameIsRunning: boolean;
    procedure resetTable;
    procedure nextTurn;
    function checkGameEnd: boolean;
    function countFreeCells: byte;
    function checkDiagonal(inverse: boolean = False): boolean;
    function checkRow(rowNum: byte): boolean;
    function checkColumn(columnNum: byte): boolean;
    function secondPlayerIsCpu: boolean;
    procedure cpuPlay;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainView: TMainView;

implementation

const
  TurnGameStop = 0;
  TurnGamePayer1 = 1;
  TurnGamePayer2 = 2;
  TurnWinnerPlayer = 3;
  TurnLoserPlayer = 4;

{$R *.lfm}

{ TMainView }

procedure TMainView.GameGridDrawCell(Sender: TObject; aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
begin
  with TCustomGrid(Sender) do
  begin
    case FGameTableModel[aCol, aRow] of
      0:
      begin
        canvas.Brush.Color := clSkyBlue;
      end;
      1:
      begin
        canvas.Brush.Color := clCream;
      end;
      2:
      begin
        canvas.Brush.Color := clMoneyGreen;
      end;
    end;
    canvas.FillRect(aRect);
  end;
end;

function TMainView.gameIsRunning: boolean;
begin
  Result := FTurn in [TurnGamePayer1, TurnGamePayer2];
end;

procedure TMainView.resetTable;
begin
  FillByte(FGameTableModel, 3 * 3, 0);
  GameGrid.Invalidate;
end;

procedure TMainView.nextTurn;
begin
  if not self.checkGameEnd then
  begin
    if FTurn = TurnGamePayer1 then
      FTurn        := TurnGamePayer2
    else
      FTurn        := TurnGamePayer1;
    turnPlayer1.Brush.Color := FPlayer1StateColors[FTurn];
    turnPlayer2.Brush.Color := FPlayer2StateColors[FTurn];
    turnPlayer1.Paint;
    turnPlayer2.Paint;
    if (FTurn = TurnGamePayer2) and secondPlayerIsCpu then
    begin
      cpuPlay;
    end;
  end;
end;

function TMainView.checkGameEnd: boolean;
begin
  Result := False;
  if checkDiagonal or checkDiagonal(True) or checkRow(0) or checkRow(1) or checkRow(2) or checkColumn(0) or checkColumn(1) or checkColumn(2) then
  begin
    Result := True;
  end;
  if Result then
  begin
    if FTurn = TurnGamePayer1 then
    begin
      turnPlayer1.Brush.Color := FPlayer1StateColors[TurnWinnerPlayer];
      turnPlayer2.Brush.Color := FPlayer2StateColors[TurnLoserPlayer];
      turnPlayer1.Paint;
      turnPlayer2.Paint;
      FTurn := TurnWinnerPlayer;
    end
    else
    if FTurn = TurnGamePayer2 then
    begin
      turnPlayer1.Brush.Color := FPlayer1StateColors[TurnLoserPlayer];
      turnPlayer2.Brush.Color := FPlayer2StateColors[TurnWinnerPlayer];
      turnPlayer1.Paint;
      turnPlayer2.Paint;
      FTurn := TurnWinnerPlayer;
    end;
  end
  else
  if countFreeCells = 0 then
  begin
    Result         := True;
    FTurn          := TurnGameStop;
    turnPlayer1.Brush.Color := FPlayer1StateColors[TurnGameStop];
    turnPlayer2.Brush.Color := FPlayer2StateColors[TurnGameStop];
    turnPlayer1.Paint;
    turnPlayer2.Paint;
  end;
end;

function TMainView.countFreeCells: byte;
var
  x, y: byte;
begin
  Result := 0;
  for  x := 0 to 2 do
    for y := 0 to 2 do
    begin
      if FGameTableModel[x, y] = 0 then
        Inc(Result);
    end;
end;

function TMainView.checkDiagonal(inverse: boolean): boolean;
begin
  if inverse then
  begin
    Result :=
      (FGameTableModel[2, 0] <> TurnGameStop) and (FGameTableModel[2, 0] = FGameTableModel[1, 1]) and (FGameTableModel[2, 0] = FGameTableModel[0, 2]);
  end
  else
    Result :=
      (FGameTableModel[0, 0] <> TurnGameStop) and (FGameTableModel[0, 0] = FGameTableModel[1, 1]) and (FGameTableModel[0, 0] = FGameTableModel[2, 2]);
end;

function TMainView.checkRow(rowNum: byte): boolean;
begin
  Result :=
    (FGameTableModel[0, rowNum] <> TurnGameStop) and (FGameTableModel[0, rowNum] = FGameTableModel[1, rowNum]) and (FGameTableModel[0, rowNum] = FGameTableModel[2, rowNum]);
end;

function TMainView.checkColumn(columnNum: byte): boolean;
begin
  Result :=
    (FGameTableModel[columnNum, 0] <> TurnGameStop) and (FGameTableModel[columnNum, 0] = FGameTableModel[columnNum, 1]) and (FGameTableModel[columnNum, 0] = FGameTableModel[columnNum, 2]);
end;

function TMainView.secondPlayerIsCpu: boolean;
begin
  Result := RadioGroup1.ItemIndex = 0;
end;

procedure TMainView.cpuPlay;
begin
  FCpuPlayer.play(FGameTableModel);
  nextTurn;
end;

procedure TMainView.GameGridClick(Sender: TObject);
var
  aRow: longint = 0;
  aCol: longint = 0;
  mousepoint: TPoint;
begin
  if gameIsRunning then
  begin
    mousepoint := TDrawGrid(Sender).ScreenToClient(Mouse.CursorPos);
    TDrawGrid(Sender).MouseToCell(mousepoint.x, mousepoint.y, aCol, aRow);
    if FGameTableModel[aCol, aRow] = 0 then
    begin
      FGameTableModel[aCol, aRow] := FTurn;
      TDrawGrid(Sender).Invalidate;
      nextTurn;
    end;
  end;
end;

procedure TMainView.Button1Click(Sender: TObject);
begin
  resetTable;
  GameGrid.Invalidate;
  FTurn := TurnGameStop;
  nextTurn;
end;

constructor TMainView.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FillByte(FGameTableModel, 3 * 3, TurnGameStop);
  FTurn := TurnGameStop;
  Edit1.Text := 'Giocatore 1';
  Edit2.Text := 'Giocatore 2';
  FPlayer1StateColors[0] := clSilver;
  FPlayer1StateColors[1] := clLime;
  FPlayer1StateColors[2] := clRed;
  FPlayer1StateColors[3] := clYellow;
  FPlayer1StateColors[4] := clMaroon;

  FPlayer2StateColors[0] := clSilver;
  FPlayer2StateColors[1] := clRed;
  FPlayer2StateColors[2] := clLime;
  FPlayer2StateColors[3] := clYellow;
  FPlayer2StateColors[4] := clMaroon;

  FCpuPlayer := TRandomPlayer.Create;
end;

destructor TMainView.Destroy;
begin
  FreeAndNil(FCpuPlayer);
  inherited Destroy;
end;

end.
