unit uFrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.StdCtrls, FMX.Controls.Presentation,System.Permissions,


  System.IOUtils, System.ImageList, FMX.ImgList, FMX.Objects;

type
  TFrmMain = class(TForm)
    lvLista: TListView;
    TmrPermission: TTimer;
    BtnFim: TSpeedButton;
    ImgFolder: TImage;
    ImgFile: TImage;
    ImgChecked: TImage;
    ImgNotChecked: TImage;
    ImgPrior: TImage;
    ImgNext: TImage;
    lblDiretorio: TLabel;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    procedure FormShow(Sender: TObject);
    procedure lvListaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure TmrPermissionTimer(Sender: TObject);
    procedure BtnFimClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PopularLv(pDiretorio: String);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

uses FMX.DialogService,Androidapi.JNI.Os,Androidapi.JNI.JavaTypes,Androidapi.Helpers;

{ TForm1 }

procedure TFrmMain.FormShow(Sender: TObject);
begin
ImgFolder.Visible:=false;
ImgFile.Visible:=false;
ImgChecked.Visible:=false;
ImgNotChecked.Visible:=false;
ImgPrior.Visible:=false;
ImgNext.Visible:=false;
TmrPermission.Enabled:=true;
end;

procedure TFrmMain.PopularLv(pDiretorio: String);
var
  pastas, arquivos: TStringDynArray;
  pasta, arquivo: string;
  lstItem: TListViewItem;
begin
    //Procedure Responsavel por popular pastas e arquivos
    lvLista.Items.Clear;
    lblDiretorio.Text:=EmptyStr;
    lblDiretorio.Text := pDiretorio;

    pastas := TDirectory.GetDirectories(pDiretorio);
    arquivos := TDirectory.GetFiles(pDiretorio);

    lvLista.BeginUpdate;

    lstItem := lvLista.Items.Add;
    lstItem.Data['Text2'] := 'voltar';
    lstItem.Data['Text1'] := '..<< Voltar';
    lstItem.Data['Image3'] :=  ImgPrior.Bitmap;

    for pasta in pastas do
    begin
      //Carrega as Pastas
      lstItem := lvLista.Items.Add;
      lstItem.Data['Text2'] := 'pasta';
      lstItem.Data['Text1'] := Copy(pasta, Length(ExtractFilePath(pasta))+1, Length(pasta));
      lstItem.Data['Image3'] :=  ImgFolder.Bitmap;
    end;

    for arquivo in arquivos do
    begin
      //Carrega os Arquivos
      lstItem := lvLista.Items.Add;
      lstItem.Data['Text2'] := 'arquivo';
      lstItem.Data['Text1'] := ExtractFileName(arquivo);
      lstItem.Data['Image3'] :=  Imgfile.Bitmap;
      lstItem.Data['Image4'] :=  ImgNotChecked.Bitmap;

    end;

    lvLista.EndUpdate;

end;

procedure TFrmMain.lvListaItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
begin


    //Popula a ListView Toda vez que e clicado em um registro

  if lvLista.Items[lvLista.ItemIndex].Data['Text2'].AsString = 'pasta' then
  begin
   if TListView(Sender).Selected <> nil then
    begin
      PopularLv(lblDiretorio.Text+PathDelim+TAppearanceListViewItem(lvLista.Selected).Objects.FindObjectT<TListItemText>('Text1').Text);
    end;
  end
  else
  begin

    if lvLista.Items[lvLista.ItemIndex].Data['Text2'].AsString = 'voltar' then
    begin

      if lblDiretorio.text = '/storage/emulated/0' then //S� estiver na raiz
      begin

      end
      else
      begin
        PopularLv(copy(ExtractFilePath(lblDiretorio.text), 0,Length(ExtractFilePath(lblDiretorio.text))-1));
      end;

    end;

  end;

  //Marca caixinha de checkadoe n�o checkado
   if TListView(sender).Selected <> nil then
        begin
                // clique em uma imagem...
                if ItemObject is TListItemImage then
                begin
                        // icone curtir / descurtir...
                        if TListItemImage(ItemObject).Name = 'Image4' then
                        begin
                                if TListItemImage(ItemObject).TagFloat = 0 then
                                begin
                                        TListItemImage(ItemObject).Bitmap := ImgChecked.Bitmap;
                                        TListItemImage(ItemObject).TagFloat := 1;

                                end
                                else
                                begin
                                        TListItemImage(ItemObject).Bitmap := ImgNotChecked.Bitmap;
                                        TListItemImage(ItemObject).TagFloat := 0;

                                end;

                        end;


                end;
        end;


end;

procedure TFrmMain.BtnFimClick(Sender: TObject);
var
vText:string;
begin
vText := TAppearanceListViewItem(lvLista.Selected).Objects.FindObjectT<TListItemText>('Text1').Text;
ShowMessage(lblDiretorio.Text+PathDelim+vText);
end;

procedure TFrmMain.TmrPermissionTimer(Sender: TObject);
begin
// solicita permiss�o

     PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE)],
        procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
        begin
          PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE)],
          procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
          begin
            PopularLv('/storage/emulated/0');
          end);

        end);
          TmrPermission.Enabled:=false;
end;

end.
