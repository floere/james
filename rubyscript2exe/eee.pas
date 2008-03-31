program eee;

{$mode DELPHI}

{$IFDEF WIN32}
  {$R eee.res}
{$ENDIF}

uses

  SysUtils, Dos, GZio, StrUtils;

const

  {$IFDEF WIN32}
    slash	= '\';
  {$ELSE}
    slash	= '/';
  {$ENDIF}

type

  header =	record
		  klasse	: string[1];
		  tekst		: string[255];
		  datalength	: longint;
		end;

  tail =	record
		  eeeexe	: string[255];
		  appname	: string[255];
		  tempdir	: string[255];
		  gzlength	: longint;
		  who		: string[255];
		  number	: longint;
		end;

var
  temp		: string[255];
  orgdir	: string[255];
  tempdir	: string[255];
  workdir1	: string[255];
  workdir2	: string[255];
  workfile	: string[255];
  me		: string[255];
  ownfile	: file of byte;
  eeefile	: Text;
  klasse	: string[1];
  tekst1	: string[255];
  tekst2	: string;
  workdirnumber	: string[255];
  h		: header;
  t		: tail;
  teller	: longint;
  parms		: string;
  quotedparms	: string;
  parmslist	: string;
  justextract	: boolean;
  list		: boolean;
  info		: boolean;
  appname	: string;
  returncode	: integer;

  {$IFDEF WIN32}
  {$ELSE}
    currentdir	: string[255];
  {$ENDIF}

{**********************************************************************}

{$IFDEF WIN32}
  function GetShortPathNameA(LongName, ShortName: Pchar; ccbuffer: Dword): Dword; stdcall external 'kernel32.dll' name 'GetShortPathNameA';
  function MessageBox(p1: longint; p2, p3: pChar; p4: longint): longint; stdcall; external 'user32.dll' name 'MessageBoxA';
{$ENDIF}

{**********************************************************************}

procedure message(msg: string);

{$IFDEF WIN32}
var
  appname2	: string;
{$ENDIF}

begin

  {$IFDEF WIN32}
    if IsConsole then begin
      writeln(appname + ': ' + msg);
    end
    else begin
      msg	:= msg + #0;
      appname2	:= appname + #0;

      MessageBox(0, @msg[1], @appname2[1], 0);
    end;
  {$ELSE}
    writeln(appname + ': ' + msg);
  {$ENDIF}

end;

{**********************************************************************}

procedure error(msg: string);

begin

  message(msg);

  // ??? Possible loop ??? recursivedelete(tempdir);

  halt(8);

end;

{**********************************************************************}

function getshortpathname(dir: String): String;

{$IFDEF WIN32}
  var
    longname	: string;
    shortname	: string;
    l		: longint;
{$ENDIF}

begin

  {$IFDEF WIN32}
    longname	:= dir + #0;
    shortname	:= '';

    for teller := 1 to 255 do begin
      shortname := shortname + ' ';	// This is stupid...
    end;

    l	:= GetShortPathNameA(@longname[1], @shortname[1], length(shortname));

    if (l > 0) then begin
      dir	:= AnsiMidStr(shortname, 1, l);
    end;
  {$ENDIF}

  getshortpathname	:= dir;

end;

{**********************************************************************}

procedure getdir2(drivenr: byte; var dir: string[255]);

begin

  {$IFDEF WIN32}
    getdir(drivenr, dir);
  {$ELSE}	// Foutje indien bovenliggende dirs niet benaderbaar zijn.
    if (currentdir = '') then begin
      currentdir	:= getshortpathname(getenv('EEE_DIR'));
      if (currentdir = '') then begin
        currentdir	:= getshortpathname(getenv('PWD'));
      end;
    end;

    dir	:= currentdir;
  {$ENDIF}

end;

{**********************************************************************}

procedure chdir2(dir: string[255]; continueonfailure: boolean);

begin

  {$I-}

  {$IFDEF WIN32}
    chdir(dir);
  {$ELSE}	// Foutje indien bovenliggende dirs niet benaderbaar zijn.
    if not (AnsiStartsStr('/', dir)) then begin
      dir	:= currentdir + '/' + dir;
    end;

    currentdir	:= dir;

    chdir(dir);
  {$ENDIF}

  if (ioresult <> 0) then begin
    message('Couldn''t change directory: "' + dir + '"');

    if (not continueonfailure) then begin
      halt(8);
    end;
  end;

  {$I+}

end;

{**********************************************************************}

procedure recursivedelete(var path: string[255]);

var
  f		: file;
  sr		: searchrec;
  dir		: string[255];
  attr		: word;

begin

  getdir2(0, dir);

  {$I-}
    chdir2(path, true);
  {$I+}

  if (ioresult = 0) then begin
    {$IFDEF WIN32}
      findfirst('*.*', anyfile or directory, sr);
    {$ELSE}
      findfirst('*', anyfile or directory, sr);
    {$ENDIF}
    while (doserror = 0) do begin
      assign(f, sr.name);		// Foutje in 1.9.2 ???
      getfattr(f, attr);		// Foutje in 1.9.2 ???

      if (attr and directory > 0) then begin
        if ((not (sr.name = '.')) and (not (sr.name = '..'))) then begin
          recursivedelete(sr.name);
        end;
      end
      else begin

        {$I-}
          assign(f, sr.name);
          erase(f);			if (ioresult <> 0) then;
        {$I+}

      end;

      findnext(sr);
    end;
    findclose(sr);

    chdir2(dir, false);

    {$I-}
      rmdir(path + slash);		if (ioresult <> 0) then;
    {$I+}
  end;

end;

{**********************************************************************}

procedure blockeat(var infile: file; inlength: longint);

var
  b	: array[0..99999] of byte;
  l	: longint;
  c	: longint;

begin

  c		:= inlength div sizeof(b);

  while (c >= 0) do begin
    if (c = 0)	then l := inlength-(inlength div sizeof(b))*sizeof(b)
		else l := sizeof(b);

    {$I-}
      blockread(infile, b, l);		if (ioresult <> 0) then error('Couldn''t read file (BLOCKEAT).');
    {$I+}

    dec(c);
  end;

end;

{**********************************************************************}

procedure blockeatfromgz(var zfile: gzFile; inlength: longint);

var
  b	: array[0..99999] of byte;
  l	: longint;
  c	: longint;

begin

  c		:= inlength div sizeof(b);

  while (c >= 0) do begin
    if (c = 0)	then l := inlength-(inlength div sizeof(b))*sizeof(b)
		else l := sizeof(b);

    {$I-}
      gzread(zfile, addr(b), l);		if (ioresult <> 0) then error('Couldn''t read file (BLOCKEATFROMGZ).');
    {$I+}

    dec(c);
  end;

end;

{**********************************************************************}

procedure blockcopy(var infile: file; var outfile: file; inlength: longint);

var
  b	: array[0..99999] of byte;
  l	: longint;
  c	: longint;
  n	: longint;

begin

  c		:= inlength div sizeof(b);

  while (c >= 0) do begin
    if (c = 0)	then l := inlength-(inlength div sizeof(b))*sizeof(b)
		else l := sizeof(b);

    {$I-}
      blockread(infile, b, l, n);		if (ioresult <> 0) then error('Couldn''t read file (BLOCKCOPY).');
      blockwrite(outfile, b, n);		if (ioresult <> 0) then error('Couldn''t write file (BLOCKCOPY).');
    {$I+}

    dec(c);
  end;

end;

{**********************************************************************}

procedure blockcopytogz(var infile: file; var zfile: gzFile; inlength: longint);

var
  b	: array[0..99999] of byte;
  l	: longint;
  c	: longint;
  n	: longint;

begin

  c		:= inlength div sizeof(b);

  while (c >= 0) do begin
    if (c = 0)	then l := inlength-(inlength div sizeof(b))*sizeof(b)
		else l := sizeof(b);

    {$I-}
      blockread(infile, b, l, n);		if (ioresult <> 0) then error('Couldn''t read file (BLOCKCOPYTOGZ).');
      gzwrite(zfile, addr(b), n);		if (ioresult <> 0) then error('Couldn''t write file (BLOCKCOPYTOGZ).');
    {$I+}

    dec(c);
  end;

end;

{**********************************************************************}

procedure blockcopyfromgz(var zfile: gzFile; var outfile: file; inlength: longint);

var
  b	: array[0..99999] of byte;
  l	: longint;
  c	: longint;
  n	: longint;

begin

  c		:= inlength div sizeof(b);

  while (c >= 0) do begin
    if (c = 0)	then l := inlength-(inlength div sizeof(b))*sizeof(b)
		else l := sizeof(b);

    {$I-}
      n	:= gzread(zfile, addr(b), l);		if (ioresult <> 0) then error('Couldn''t read file (BLOCKCOPYFROMGZ).');
      blockwrite(outfile, b, n);		if (ioresult <> 0) then error('Couldn''t write file (BLOCKCOPYFROMGZ).');
    {$I+}

    dec(c);
  end;

end;

{**********************************************************************}

procedure pakin_f(var zfile: gzFile; klasse: string[1]; tekst: string[255]; entry: string[255]; var t: tail);

var
  infile	: file of byte;
  h		: header;

begin

  h.klasse	:= klasse;
  h.tekst	:= tekst;

  {$I-}
    assign(infile, entry);
    reset(infile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + entry + '"');
    h.datalength	:= filesize(infile);
    gzwrite(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t write file (GZFILE).');
  {$I+}
  blockcopytogz(infile, zfile, h.datalength);
  close(infile);

  t.number	:= t.number + 1;

end;

{**********************************************************************}

procedure pakin_d(var zfile: gzFile; klasse: string[1]; tekst: string[255]; entry: string[255]; var t: tail);

var
  h		: header;

begin

  entry		:= entry;

  h.klasse	:= klasse;
  h.tekst	:= tekst;
  h.datalength	:= 0;

  {$I-}
    gzwrite(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t write file (GZFILE).');
  {$I+}

  t.number	:= t.number + 1;

end;

{**********************************************************************}

procedure pakin_r(var zfile: gzFile; klasse: string[1]; tekst: string[255]; entry: string[255]; var t: tail);

var
  f		: file;
  sr		: searchrec;
  dir		: string[255];
  attr		: word;

begin

  klasse	:= klasse;

  pakin_d(zfile, 'd', tekst, entry, t);

  getdir2(0, dir);
  chdir2(entry, false);

  {$IFDEF WIN32}
    findfirst('*.*', anyfile or directory, sr);
  {$ELSE}
    findfirst('*', anyfile or directory, sr);
  {$ENDIF}
  while (doserror = 0) do begin
    assign(f, sr.name);		// Foutje in 1.9.2 ???
    getfattr(f, attr);		// Foutje in 1.9.2 ???

    if (attr and directory > 0) then begin
      if ((not (sr.name = '.')) and (not (sr.name = '..'))) then begin
        pakin_r(zfile, 'r', tekst + slash + sr.name, sr.name, t);
      end;
    end
    else begin
      pakin_f(zfile, 'f', tekst + slash + sr.name, sr.name, t);
    end;

    findnext(sr);
  end;
  findclose(sr);

  chdir2(dir, false);

end;

{**********************************************************************}

procedure pakin_c(var zfile: gzFile; klasse: string[1]; tekst: string[255]; entry: string[255]; var t: tail);

var
  h		: header;

begin

  entry		:= entry;

  h.klasse	:= klasse;
  h.tekst	:= tekst;
  h.datalength	:= 0;

  {$I-}
    gzwrite(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t write file (GZFILE).');
  {$I+}

  t.number	:= t.number + 1;

end;

{**********************************************************************}

procedure pakin_t(var zfile: gzFile; klasse: string[1]; tekst: string[255]; entry: string[255]; var t: tail);

var
  h		: header;

begin

  entry		:= entry;

  h.klasse	:= klasse;
  h.tekst	:= tekst;
  h.datalength	:= 0;

  {$I-}
    gzwrite(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t write file (GZFILE).');
  {$I+}

  t.number	:= t.number + 1;

end;

{**********************************************************************}

procedure pakin_i(var zfile: gzFile; klasse: string[1]; tekst: string[255]; entry: string[255]; var t: tail);

var
  h		: header;

begin

  entry		:= entry;

  h.klasse	:= klasse;
  h.tekst	:= tekst;
  h.datalength	:= 0;

  {$I-}
    gzwrite(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t write file (GZFILE).');
  {$I+}

  t.number	:= t.number + 1;

end;

{**********************************************************************}

procedure pakin;

var
  zfile		: gzFile;
  infile	: file of byte;
  outfile	: file of byte;
  s		: string;
  i		: longint;
  eeeexe	: string[255];

  {$IFDEF WIN32}
  {$ELSE}
    c		: string;
    p		: string;
  {$ENDIF}

begin

  {$I-}
    assign(eeefile, paramstr(1));
    reset(eeefile);		if (ioresult <> 0) then error('Couldn''t open: "' + paramstr(1) + '"');
  {$I+}

  if (getenv('EEE_EXE') <> '') then begin
    eeeexe	:= getshortpathname(getenv('EEE_EXE'));
  end
  else begin
    eeeexe	:= paramstr(0);
  end;

  appname	:= paramstr(2);

  s		:= slash;
  i		:= posex(s, appname);
  while (i > 0) do begin
    appname	:= AnsiMidStr(appname, i+length(s), length(appname)-(i+length(s))+1);
    i		:= posex(s, appname);
  end;

  t.eeeexe	:= eeeexe;
  t.appname	:= appname;
  t.tempdir	:= getenv('EEE_TEMPDIR');
  t.number	:= 0;
  t.who		:= me;

  s		:= slash;
  i		:= posex(s, t.eeeexe);
  while (i > 0) do begin
    t.eeeexe	:= AnsiMidStr(t.eeeexe, i+length(s), length(t.eeeexe)-(i+length(s))+1);
    i		:= posex(s, t.eeeexe);
  end;

  {$I-}
    zfile	:= gzopen(workfile, 'w');		if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}

  repeat
    readln(eeefile, s);

    if (not (s = '') and not (AnsiStartsStr('#', s))) then begin
      klasse	:= AnsiMidStr(s, 1, 1);
      tekst1	:= AnsiMidStr(s, 3, length(s)-2);

      case klasse[1] of
        'f': pakin_f(zfile, klasse, tekst1, tekst1, t);
        'd': pakin_d(zfile, klasse, tekst1, tekst1, t);
        'r': pakin_r(zfile, klasse, tekst1, tekst1, t);
        'c': pakin_c(zfile, klasse, tekst1, tekst1, t);
        't': pakin_t(zfile, klasse, tekst1, tekst1, t);
        'i': pakin_i(zfile, klasse, tekst1, tekst1, t);
      end;
    end;
  until eof(eeefile);

  gzclose(zfile);

  close(eeefile);

  {$I-}
    assign(outfile, paramstr(2));
    rewrite(outfile, 1);			if (ioresult <> 0) then error('Couldn''t open: "' + paramstr(2) + '"');
  {$I+}

  {$I-}
    assign(infile, eeeexe);
    reset(infile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + eeeexe + '"');
  {$I+}
  blockcopy(infile, outfile, filesize(infile));
  close(infile);

  {$I-}
    assign(infile, workfile);
    reset(infile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}
  blockcopy(infile, outfile, filesize(infile));
  t.gzlength	:= filesize(infile);
  close(infile);

  {$I-}
    blockwrite(outfile, t, sizeof(t));		if (ioresult <> 0) then error('Couldn''t write: "' + paramstr(2) + '"');
  {$I+}

  close(outfile);

  {$IFDEF WIN32}
  {$ELSE}
    c	:= '/bin/sh';
    p	:= '-c "chmod +x ' + paramstr(2);
    executeprocess(c, p);
  {$ENDIF}

end;

{**********************************************************************}

procedure pakuit_f(var zfile: gzFile; var outfile: file; tekst: string; var h: header);

begin

  {$I-}
    assign(outfile, tempdir + slash + tekst);
    rewrite(outfile, 1);		if (ioresult <> 0) then error('Couldn''t open: "' + tempdir + slash + tekst + '"');
  {$I+}

  blockcopyfromgz(zfile, outfile, h.datalength);

  close(outfile);

end;

{**********************************************************************}

procedure pakuit_d(var zfile: gzFile; var outfile: file; tekst: string; var h: header);

begin

  zfile		:= zfile;
  outfile	:= outfile;
  h		:= h;

  mkdir(tempdir + slash + tekst);

end;

{**********************************************************************}

procedure pakuit_c(var zfile: gzFile; var outfile: file; tekst: string; var h: header);

var
  c		: string;
  p		: string;

  {$IFDEF WIN32}
    i		: longint;
  {$ELSE}
  {$ENDIF}

begin

  zfile		:= zfile;
  outfile	:= outfile;
  h		:= h;

  {$IFDEF WIN32}
    i	:= posex(' ', tekst);
    if (i = 0) then begin
      c	:= tekst;
      p	:= '';
    end
    else begin
      c	:= AnsiMidStr(tekst, 1, i-1);
      p	:= AnsiMidStr(tekst, i+1, length(tekst)-i);
    end;
  {$ELSE}
    c	:= '/bin/sh';
    p	:= '-c "' + tekst + '"';
  {$ENDIF}

  returncode	:= executeprocess(c, p);

end;

{**********************************************************************}

procedure pakuit_t(var zfile: gzFile; var outfile: file; tekst: string; var h: header);

var
  c		: string;
  p		: string;
  dir		: string[255];

  {$IFDEF WIN32}
    i		: longint;
  {$ENDIF}

begin

  zfile		:= zfile;
  outfile	:= outfile;
  h		:= h;

  {$IFDEF WIN32}
    i	:= posex(' ', tekst);
    if (i = 0) then begin
      c	:= tekst;
      p	:= '';
    end
    else begin
      c	:= AnsiMidStr(tekst, 1, i-1);
      p	:= AnsiMidStr(tekst, i+1, length(tekst)-i);
    end;
  {$ELSE}
    c	:= '/bin/sh';
    p	:= '-c "' + tekst + '"';
  {$ENDIF}

  getdir2(0, dir);
  chdir2(tempdir, false);
    returncode	:= executeprocess(c, p);
  chdir2(dir, false);

end;

{**********************************************************************}

procedure pakuit_i(var zfile: gzFile; var outfile: file; tekst: string; var h: header);

var
  infofile	: Text;

begin

  {$I-}
    assign(infofile, tempdir + slash + tekst);
    rewrite(infofile);		if (ioresult <> 0) then error('Couldn''t open: "' + tempdir + slash + tekst + '"');
  {$I+}

  writeln(infofile, 'EEE_APPEXE='	+ paramstr(0));
  writeln(infofile, 'EEE_EEEEXE='	+ t.eeeexe);
  writeln(infofile, 'EEE_TEMPDIR='	+ tempdir);
  writeln(infofile, 'EEE_PARMS='	+ parms);
  writeln(infofile, 'EEE_QUOTEDPARMS='	+ quotedparms);
  writeln(infofile, 'EEE_PARMSLIST='	+ parmslist);

  close(infofile);

end;

{**********************************************************************}

procedure pakuit;

var
  zfile		: gzFile;
  infile	: file of byte;
  outfile	: file of byte;
  i		: longint;
  n		: longint;

begin

  {$I-}
    assign(infile, paramstr(0));
    reset(infile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + paramstr(0) + '"');
  {$I+}

  blockeat(infile, filesize(infile)-t.gzlength-sizeof(t));

  {$I-}
    assign(outfile, workfile);
    rewrite(outfile, 1);			if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}
  blockcopy(infile, outfile, t.gzlength);
  close(outfile);

  close(infile);

  {$I-}
    zfile	:= gzopen(workfile, 'r');	if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}

  for i := 1 to t.number do begin
    {$I-}
      n	:= gzread(zfile, addr(h), sizeof(h));	if (ioresult <> 0) then error('Couldn''t read: "' + workfile + '"');
    {$I+}

    if (n <> sizeof(h)) then error('Couldn''t read: "' + workfile + '"');

    klasse	:= h.klasse;
    tekst2	:= h.tekst;

    tekst2	:= AnsiReplaceStr(tekst2, '%parms%', parms);
    tekst2	:= AnsiReplaceStr(tekst2, '%quotedparms%', quotedparms);
    tekst2	:= AnsiReplaceStr(tekst2, '%parmslist%', parmslist);
    tekst2	:= AnsiReplaceStr(tekst2, '%orgdir%', orgdir);
    tekst2	:= AnsiReplaceStr(tekst2, '%tempdir%', tempdir);
    tekst2	:= AnsiReplaceStr(tekst2, '%tempdir1%', workdir1);
    tekst2	:= AnsiReplaceStr(tekst2, '%tempdir2%', workdir2);

    case klasse[1] of
      'f': pakuit_f(zfile, outfile, tekst2, h);
      'd': pakuit_d(zfile, outfile, tekst2, h);
      'c': pakuit_c(zfile, outfile, tekst2, h);
      't': pakuit_t(zfile, outfile, tekst2, h);
      'i': pakuit_i(zfile, outfile, tekst2, h);
    end;
  end;

  gzclose(zfile);

end;

{**********************************************************************}

procedure pakhieruit;

var
  zfile		: gzFile;
  infile	: file of byte;
  outfile	: file of byte;
  i		: longint;

  {$IFDEF WIN32}
  {$ELSE}
    c		: string;
    p		: string;
  {$ENDIF}

begin

  {$I-}
    assign(infile, paramstr(0));
    reset(infile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + paramstr(0) + '"');
  {$I+}

  {$I-}
    assign(outfile, t.eeeexe);
    rewrite(outfile);				if (ioresult <> 0) then error('Couldn''t open: "' + t.eeeexe + '"');
  {$I+}
  blockcopy(infile, outfile, filesize(infile)-t.gzlength-sizeof(t));
  close(outfile);

  {$IFDEF WIN32}
  {$ELSE}
    c	:= '/bin/sh';
    p	:= '-c "chmod +x ' + t.eeeexe;
    executeprocess(c, p);
  {$ENDIF}

  {$I-}
    assign(outfile, workfile);
    rewrite(outfile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}
  blockcopy(infile, outfile, t.gzlength);
  close(outfile);

  close(infile);

  {$I-}
    zfile	:= gzopen(workfile, 'r');		if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}

  {$I-}
    assign(eeefile, 'app.eee');
    rewrite(eeefile);				if (ioresult <> 0) then error('Couldn''t open file (app.eee).');
  {$I+}

  for i := 1 to t.number do begin
    {$I-}
      gzread(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t read: "' + workfile + '"');
    {$I+}

    writeln(eeefile, h.klasse, ' ', h.tekst);

    if (h.klasse = 'f') then begin
      {$I-}
        assign(outfile, h.tekst);
        rewrite(outfile, 1);			if (ioresult <> 0) then error('Couldn''t open: "' + h.tekst + '"');
      {$I+}

      blockcopyfromgz(zfile, outfile, h.datalength);

      close(outfile);
    end;

    if (h.klasse = 'd') then begin
      {$I-}
        mkdir(h.tekst);				if (ioresult = 0) then;
      {$I+}
    end;
  end;

  close(eeefile);

  gzclose(zfile);

end;

{**********************************************************************}

procedure tooninhoud;

var
  zfile		: gzFile;
  infile	: file of byte;
  outfile	: file of byte;
  i		: longint;

begin

  {$I-}
    assign(infile, paramstr(0));
    reset(infile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + paramstr(0) + '"');
  {$I+}

  blockeat(infile, filesize(infile)-t.gzlength-sizeof(t));

  {$I-}
    assign(outfile, workfile);
    rewrite(outfile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}
  blockcopy(infile, outfile, t.gzlength);
  close(outfile);

  close(infile);

  {$I-}
    zfile	:= gzopen(workfile, 'r');		if (ioresult <> 0) then error('Couldn''t open: "' + workfile + '"');
  {$I+}

  for i := 1 to t.number do begin
    {$I-}
      gzread(zfile, addr(h), sizeof(h));		if (ioresult <> 0) then error('Couldn''t read: "' + workfile + '"');
    {$I+}

    if (h.klasse = 'f') then begin
      writeln(h.klasse, ' ', h.tekst, ' (', h.datalength, ')');
      blockeatfromgz(zfile, h.datalength);
    end
    else begin
      writeln(h.klasse, ' ', h.tekst);
    end;

  end;

  gzclose(zfile);

end;

{**********************************************************************}

procedure tooninfo;

begin

  writeln('APPNAME           : ', t.appname);
  writeln('NUMBER OF ITEMS   : ', t.number);
  writeln('LENGTH OF GZ-FILE : ', t.gzlength);
  writeln('EEEEXE            : ', t.eeeexe);
  writeln('TEMPDIR           : ', t.tempdir);

end;

{**********************************************************************}

begin

  randomize;
  filemode	:= 0;

  {$IFDEF WIN32}
  {$ELSE}
    currentdir	:= '';
  {$ENDIF}

  me		:= 'EEE: Dit is mijn herkennigsstring voor het herkennen van pakin of pakuit mode.';

  justextract	:= false;
  list		:= false;
  info		:= false;

  appname	:= 'EEE';
  returncode	:= 0;

  parms		:= '';
  quotedparms	:= '';
  parmslist	:= '';
  for teller := 1 to paramcount do begin
    if (paramstr(teller) = '--eee-justextract') then begin
      justextract	:= true;
    end;

    if (paramstr(teller) = '--eee-list') then begin
      list		:= true;
    end;

    if (paramstr(teller) = '--eee-info') then begin
      info		:= true;
    end;

    if ((parms = '') and (quotedparms = '') and (parmslist = '')) then begin
      parms		:= paramstr(teller);
      quotedparms	:= '''' + paramstr(teller) + '''';
      parmslist		:= paramstr(teller) + #0;
    end
    else begin
      parms		:= parms + ' ' + paramstr(teller);
      quotedparms	:= quotedparms + ' ''' + paramstr(teller) + '''';
      parmslist		:= parmslist + paramstr(teller) + #0;
    end;
  end;

  {$I-}
    assign(ownfile, paramstr(0));
    reset(ownfile, 1);				if (ioresult <> 0) then error('Couldn''t open: "' + paramstr(0) + '"');
    blockeat(ownfile, filesize(ownfile)-sizeof(t));
    blockread(ownfile, t, sizeof(t));		if (ioresult <> 0) then error('Couldn''t read: "' + paramstr(0) + '"');
  {$I+}
  close(ownfile);

  if (t.who = me) then begin
    appname	:= t.appname;
  end;

  temp	:= getshortpathname(getenv('TEMP'));
  if (temp = '') then begin
    temp	:= '/tmp'
  end;

  getdir2(0, orgdir);
  chdir2(temp, false);
    {$I-}
      if ((t.tempdir <> '') and (t.who = me)) then begin
        tempdir	:= t.tempdir;
        mkdir(tempdir);				if (ioresult <> 0) then error('Couldn''t create directory: "' + temp + slash + tempdir + '"');
      end
      else begin
        workdirnumber	:= '';
        teller		:= 1;
        repeat
          inc(teller);
          str(teller, workdirnumber);
          tempdir	:= 'eee.' + appname + '.' + workdirnumber;
          mkdir(tempdir);
        until (ioresult = 0);
      end;
    {$I+}
  chdir2(orgdir, false);

  tempdir	:= temp + slash + tempdir;
  workfile	:= tempdir + slash + 'eee.gz';
  workdir1	:= AnsiReplaceStr(tempdir, '\', '/');
  workdir2	:= AnsiReplaceStr(tempdir, '/', '\');

  if (posex('eeew', lowercase(t.eeeexe)) > 0) then begin
    list	:= false;
    info	:= false;
  end;

  if (t.who <> me) then begin
    pakin;
  end
  else begin
    if (justextract) then begin
      pakhieruit;
    end
    else begin
      if (list) then begin
        tooninhoud;
      end
      else begin
        if (info) then begin
          tooninfo;
        end
        else begin
          pakuit;
        end;
      end;
    end;
  end;

  recursivedelete(tempdir);

  halt(returncode);

end.
