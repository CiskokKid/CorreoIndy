unit correopop;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  IdPOP3, IdMessage,  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdText, IdMessageParts ,IdAttachment;

type
  TfCorreoPop = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Memo1: TMemo;
    Panel3: TPanel;
    Panel4: TPanel;
    ProgressBar1: TProgressBar;

    procedure Button1Click(Sender: TObject);
    procedure LeerCorreo( sServidor, sUsuario, sClave: String );
    procedure ProcesarMensaje(mensaje:TIdMessage );
    function CaseString (const s: string; ci, p: Boolean; const x: array of string): Integer;
    function striposCI (const s1, s2: string; pos, max: Integer): Integer;
    function stripos (const s1, s2: string; pos, max: Integer): Integer;
    function GetBody (mail: TIdMessage; var html: Boolean): string;

  private
  var
    CarpetaDestino:string;
    { Private declarations }
  public
    { Public declarations }
  end;
var
  fCorreoPop: TfCorreoPop;

implementation

{$R *.dfm}




procedure TfCorreoPop.LeerCorreo( sServidor, sUsuario, sClave: String );
var
  POP3      : TIdPOP3;
  Mensaje   : TIdMessage;
  i         : Integer;
begin
  // creamos el objeto POP3
  POP3          := TIdPOP3.Create( nil );
  POP3.Host     := sServidor;
  POP3.Username := sUsuario;
  POP3.Password := sClave;
  POP3.Port     := 110;
  // conectamos con el servidor de correo
  try
    POP3.Connect;
  except
  begin
    raise Exception.Create( 'Error al conectar con el servidor.' );
    abort;
  end;
  end;

  progressbar1.Min:=0;
  progressbar1.Max:=POP3.CheckMessages;
  memo1.Clear;
  Mensaje := TIdMessage.Create( nil );   // creamos el mensaje, en este objeto se meteran cada uno de los correos


  for i := 1 to POP3.CheckMessages do    // se recorren la lista de correos
  begin
    progressbar1.Position:=i;            // actualizar barra de estado
    Mensaje.Clear;                       // limpiar el objeto mensaje
    POP3.Retrieve( i, Mensaje );         // leer el mensaje i
    ProcesarMensaje(mensaje)             // procesar el mensaje
  end;
  POP3.Disconnect();           // cerrar conexion servidor de correo
  FreeAndNil( Mensaje );
  FreeAndNil( POP3    );
end;

procedure TfCorreoPop.ProcesarMensaje(mensaje: TIdMessage);
var
  archivo   : string;
  extension : string;
  j ,k      : Integer;
  id        : integer;
  cuerpo    : string;
  html      : boolean;
begin
       cuerpo:= GetBody (mensaje, html);                                       // obtener el cuerpor del correo (solo se pone en el campo memo)
       memo1.Lines.Add(cuerpo);
       for j := 0 to mensaje.MessageParts.Count-1 do                            // recorrer el mensaje parte por parte
       begin                                                                        //-----004
          if mensaje.MessageParts[j] is TIdAttachment then                                           // si la parte es un anexo
          begin                                                                       //------03
            with TIdAttachment(mensaje.MessageParts[j]) do
            begin                                                                      //------02
              archivo := IncludeTrailingPathDelimiter(CarpetaDestino) + ExtractFileName(FileName);
              archivo := StringReplace( archivo, ' ', '', [rfReplaceAll]) ;             // quitar espacios
              extension:= uppercase(ExtractFileExt(archivo));
              if (extension ='.PDF') or (extension ='.XML')  then                       // solo descargar pdf y xml
              begin                                                                     // -----01.01
                if not FileExists(archivo) then
                begin                                                                   //-----01
                  memo1.lines.add(  Mensaje.Subject + '-->' + archivo);
                  SaveToFile(archivo);
                end;                                                                     //-----01
              end;                                                                      // -----01.01
            end;                                                                      //------02
          end;                                                                      //------03
       end;                                                                       //-----004
end;



procedure TfCorreoPop.Button1Click(Sender: TObject);
begin
   memo1.Clear;
   CarpetaDestino:='c:\correosX\';
   If not DirectoryExists(CarpetaDestino) then CreateDir(CarpetaDestino) ;

   // poner el servidor de correo entrante   , la cuenta    y la contraseña
   LeerCorreo('pop.SevidordeCorreo.com', 'cuenta@dominio.com', 'contraseña' );
end;






//  la lectura de cuerpo del mensaje esta tomada de
//  http://www.delphigroups.info/2/4a/186159.html
function  TfCorreoPop.GetBody (mail: TIdMessage; var html: Boolean): string;
// Returns the body of a mail in one string
// html = True if the body is text/html format.
 function GetMimeBody (const ctyp: string): string;
 // Returns the body of a MIME-coded mail
 var i: Integer;
     x: TidText;
 begin
  Result:= '';
  for i:= 0 to Pred (mail.MessageParts.Count) do begin
   if (mail.MessageParts.Items[i] is TIdText) then begin
    x:= mail.MessageParts.Items[i] as TIdText;
    if striposCI (ctyp, x.ContentType, 0, -1) > 0 then begin
     Result:= x.Body.Text;
     Exit;
    end; // Pos
   end; // if mail.MessagePart
  end; // for
 end;
begin
 Result:= '';
 html:= False;
 case CaseString (mail.ContentType, True, True, ['multipart/', 'text/html']) of
  0:   begin // should have a MIME-coded body
        Result:= GetMimeBody ('text/html');  html:= True;
        if Result = '' then begin // maybe plain text?
         Result:= GetMimeBody ('text/plain'); html:= False;
         if Result = '' then begin // maybe xml?
          Result:= GetMimeBody ('text/xml'); html:= False;
         end;
        end;
       end;
  1:   begin // text/html body
        Result:= mail.Body.Text;
        html:= True;
       end;
  else begin // Normal text/plain body, no html
        Result:= mail.Body.Text;
        html:= False;
       end;
 end; // case
end;

// The function use two from my own functions, that replaces the old "Pos" function and realize a kind of "case string of"

function TfCorreoPop.stripos (const s1, s2: string; pos, max: Integer): Integer;
// This function searchs string s1 in s2 and returns the position of it,
// like the old Pos does. In addition, you can define a start position
// and a maximum length for to search.
var s, l1, l2, j: Integer;
begin
 Result:= -1;
 l1:= Length (s1);
 l2:= Length (s2);
 if max <= 0 then  max:= l2;
 if pos <= 0 then  pos:= 0;
 if (l1 <= 0) or (pos > max) then  Exit;
 for s:= pos to (max - l1) do begin
  for j:= 1 to l2 do begin
   if (s1[j] <> s2[s+j]) then  BREAK;
   if (j = l1) then begin  Result:= s+1;  EXIT;  end;
  end;
 end;
end;

function TfCorreoPop.striposCI (const s1, s2: string; pos, max: Integer): Integer;
// Like stripos but Case-Insensitive
begin
 Result:= stripos (AnsiUpperCase(s1), AnsiUpperCase(s2), pos, max);
end;
function TfCorreoPop.CaseString (const s: string; ci, p: Boolean;
                     const x: array of string): Integer;
// implements a kind of "case string of", for use in case statements
// help avoiding large "if then else i then else if" chains with stings
// s = the string to search
// ci = when true then case insensitive
// p = when false then s must exactly in x otherwise Pos is used
// x = Array of strings that searched for s
// returns the position of s in the array x
var i: Integer;
    s1, s2: string;
begin
 Result:= -1;
 if ci then s1:= AnsiUpperCase(s) else s1:= s;
 for i:= Low (x) to High (x) do begin
  if ci then s2:= AnsiUpperCase(x[i]) else s2:= x[i];
  if p then begin
   if Pos (s2, s1) > 0 then begin  Result:= i;  Exit;  end;
  end else begin
   if s1 = s2 then begin  Result:= i;  Exit;  end;
  end;
 end;
end;


end.
  {

  documentacion :

  site http //ww2.indyproject.org attachments

  https://www.indyproject.org/2021/02/10/links-to-old-indy-website-pages-are-currently-broken/

  https://web.archive.org/web/20200926104554/http://ww2.indyproject.org/Support.en.aspx
  https://web.archive.org/web/20200630040642/http://ww2.indyproject.org/Sockets/Docs/Articles.EN.aspx
  https://web.archive.org/web/20201027203326/https://www.atozed.com/forums/forum-9-page-5.html

  http://e-iter.net/Knowledge/Indy9/
  http://e-iter.net/Knowledge/Indy9/content.html

 }

