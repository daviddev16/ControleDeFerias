unit uCustomSeletorCores;

interface

uses
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TCustomSeletorCores = class(TGroupBox)
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy(); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('CustomSeletorCores', [TCustomSeletorCores]);
end;

constructor TCustomSeletorCores.Create(AOwner: TComponent);
var
  ComboxBox : TComboBox;
begin
  inherited Create(AOwner);
  ComboxBox := TComboBox.Create(Self);
  ComboxBox.SetSubComponent(True);
  ComboxBox.Parent := Self;
end;

destructor TCustomSeletorCores.Destroy();
begin
  inherited;
end;

end.
