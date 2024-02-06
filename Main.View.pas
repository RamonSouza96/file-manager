unit Main.View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation,
  FMX.Types;

type
  TFormMain = class(TForm)
    ListViewLista: TListView;
    BtnFim: TSpeedButton;
    ImgFolder: TImage;
    ImgFile: TImage;
    ImgChecked: TImage;
    ImgNotChecked: TImage;
    ImgPrior: TImage;
    ImgNext: TImage;
    lblDiretorio: TLabel;
    RectHeader: TRectangle;
    RectPath: TRectangle;
    Rectangle3: TRectangle;
    procedure FormShow(Sender: TObject);
    procedure ListViewListaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure BtnFimClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PopularListView(ADiretorio: string);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

uses FMX.DialogService,
     Androidapi.JNI.Os,
     Androidapi.JNI.JavaTypes,
     Androidapi.Helpers,
     DW.Permissions.Helpers,
     System.Permissions;

{ TForm1 }

procedure TFormMain.FormShow(Sender: TObject);
begin
  ImgFolder.Visible    := False;
  ImgFile.Visible      := False;
  ImgChecked.Visible   := False;
  ImgNotChecked.Visible:= False;
  ImgPrior.Visible     := False;
  ImgNext.Visible      := False;

  PermissionsService.RequestPermissions(['android.permission.READ_EXTERNAL_STORAGE', 'android.permission.WRITE_EXTERNAL_STORAGE'],
    procedure(const APermissions: TPermissionArray; const AGrantResults: TPermissionStatusArray)
    begin
      if AGrantResults.AreAllGranted then
        PopularListView('/storage/emulated/0');
    end
  );
end;

procedure TFormMain.PopularListView(ADiretorio: string);
var
  LPastas, LArquivos: TStringDynArray;
  LPasta, LArquivo: string;
  LListItem: TListViewItem;
begin
  // Limpar a ListView
  ListViewLista.Items.Clear;

  // Definir o diretório atual
  lblDiretorio.Text := ADiretorio;

  // Obter pastas e arquivos no diretório
  LPastas := TDirectory.GetDirectories(ADiretorio);
  LArquivos := TDirectory.GetFiles(ADiretorio);

  // Iniciar a atualização da ListView
  ListViewLista.BeginUpdate;

  // Adicionar item para voltar (exceto na raiz)
  LListItem := ListViewLista.Items.Add;
  if ADiretorio = '/storage/emulated/0' then
  begin
    LListItem.Data['Text2'] := 'Home';
    LListItem.Data['Text1'] := 'Pasta Raiz';
    LListItem.Data['Image3'] :=  ImgNext.Bitmap;
  end
  else
  begin
    LListItem.Data['Text2'] := 'Voltar';
    LListItem.Data['Text1'] := '..<< Voltar';
    LListItem.Data['Image3'] :=  ImgPrior.Bitmap;
  end;

  // Adicionar pastas
  for LPasta in LPastas do
  begin
    LListItem := ListViewLista.Items.Add;
    LListItem.Data['Text2'] := 'Pasta';
    LListItem.Data['Text1'] := ExtractFileName(LPasta);
    LListItem.Data['Image3'] := ImgFolder.Bitmap;
  end;

  // Adicionar arquivos
  for LArquivo in LArquivos do
  begin
    LListItem := ListViewLista.Items.Add;
    LListItem.Data['Text2'] := 'Arquivo';
    LListItem.Data['Text1'] := ExtractFileName(LArquivo);
    LListItem.Data['Image3'] := Imgfile.Bitmap;
    LListItem.Data['Image4'] := ImgNotChecked.Bitmap;
    LListItem.TagString := LArquivo;
  end;

  // Finalizar a atualização da ListView
  ListViewLista.EndUpdate;
end;

procedure TFormMain.ListViewListaItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
begin
  // Popula a ListView toda vez que é clicado em um registro
  if ListViewLista.Items[ListViewLista.ItemIndex].Data['Text2'].AsString = 'Pasta' then
  begin
    if TListView(Sender).Selected <> nil then
    begin
      PopularListView(lblDiretorio.Text + PathDelim + TAppearanceListViewItem(ListViewLista.Selected).Objects.FindObjectT<TListItemText>('Text1').Text);
    end;
  end
  else
  begin
    if ListViewLista.Items[ListViewLista.ItemIndex].Data['Text2'].AsString = 'Voltar' then
    begin
      if lblDiretorio.Text = '/storage/emulated/0' then // Se estiver na raiz
      begin
        ListViewLista.Items[ListViewLista.ItemIndex].Data['Text1'] := 'Home';
      end
      else
      begin
        PopularListView(copy(ExtractFilePath(lblDiretorio.Text), 0, Length(ExtractFilePath(lblDiretorio.Text)) - 1));
      end;
    end;
  end;

  // Marca caixinha de checkado e não checkado
  if (TListView(Sender).Selected <> nil) and (ItemObject is TListItemImage) then
  begin
    // Clique em uma imagem...
    if TListItemImage(ItemObject).Name = 'Image4' then
    begin
      // Ícone curtir / descurtir...
      if TListView(Sender).Selected.Tag = 0 then
      begin
        TListItemImage(ItemObject).Bitmap := ImgChecked.Bitmap;
        TListView(Sender).Selected.Tag := 1;
      end
      else
      begin
        TListItemImage(ItemObject).Bitmap := ImgNotChecked.Bitmap;
        TListView(Sender).Selected.Tag := 0;
      end;
    end;
  end;
end;

procedure TFormMain.BtnFimClick(Sender: TObject);
var
  I: Integer;
  LSelected: Boolean;
begin
  LSelected := False;

  for I := 0 to ListViewLista.ItemCount - 1 do
  begin
    if ListViewLista.Items.Item[I].Tag = 1 then
    begin
      ShowMessage(ListViewLista.Items.Item[I].TagString);
      LSelected := True;
    end;
  end;

  if not LSelected then
    ShowMessage('Nenhum arquivo checkado!!');
end;

end.
