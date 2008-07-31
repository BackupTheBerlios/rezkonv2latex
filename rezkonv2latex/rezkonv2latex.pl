#!/usr/bin/perl
#Script zum Umwandeln von RKS in LaTeX
#Version 0.2.0
use locale;
sub BEGIN {
    use strict 'refs';
    require 5.6.0;
}
use strict 'refs';
our $version = '0.1.1';
our $i = undef;
############### LaTeX Sonderzeichen ###############
sub LATEXSONDERZEICHEN {
    $i =~ s/\\/\\\\/g;
    $i =~ s/\$/\\\$/g;
    $i =~ s/#/\\#/g;
    $i =~ s/&/\\&/g;
    $i =~ s/%/\\%/g;
    $i =~ s/{/\\{/g;
    $i =~ s/}/\\}/g;
    $i =~ s/_/\\_/g;
    $i =~ s/\267//g;
    $i =~ s/\265/\$\\mu\$/g;
}#Ende LaTeX Sonderzeichen
################ Hauptprogramm ################
if (not defined @ARGV[0]) {#Anleitung zum Programm - Abbruch wenn kein Parameterangegeben
    print "\nPerl RezKonv2LaTeX.pl {1.Datei} [Weitere Dateien]\n                       ^^^^^^^\t\n  Dieses Programm benoetigt mindestens einen Dateinamen als Parameter\n\t\n  Am einfachsten ist es, wenn man sich in der RezKonvSuit verschiedene\n  Kochbuecher anlegt. Fuer jedes 'Kapitel' eines. Diese exportiert man dann\n  ueber Export -> gesammtest Kochbuch exportieren.\n  \n  Hat man diese in einem Verzeichnis, kopiert man diese Datei in dasselbige.\n  Das Programm wir ausgefuehrt, und als Parameter werden ihm die Dateinamen\n  mitgeben. Fuer jede Datei wird ein eigenes Verzeichnis angelegt, sowie die\n  dazugehoerige Importdatei.\n  \n  ***RezKonv2LaTeX Version $version***\n\n";
    print "  Es wird auch eine Datei KochbuchUmwandlung.bat erstellt. Wenn man diese\n  editiert muss man nicht die Komandozeile nutzen. Die Kochbuecher werden\n  einfach hinter den Dateinamen geschrieben, und die Datei wird ausgefuehrt.\n  Nun konvertiert das Programm die einzelnen Kochbuecher nach LaTeX.\n\nDruecke RETURN oder ENTER um dieses Fenster zu schliessen";
    my $rw = open(BATCH, 'KochbuchUmwandlung.bat');
		if (not defined $rw) {
    		open BATCH, '> KochbuchUmwandlung.bat';
    		print BATCH qq[RezKonv2LaTeX.exe "kochbuch1.rk" "kochbuch2.txt"\nREM Bitte schreiben schreiben Sie ihre Kochb\374cher die Sie aus der RKS\nREM exportiert haben in "" nach den Dateinamen. Diese Batchdatei k\366nnen\nREM sie dann nutzen um die Kochb\374cher in LaTeX umwandeln zu lassen.];
				}
		close BATCH;
		<STDIN>;
    exit();
}#Anleitung zum Programm - Abbruch wenn kein Parameterangegeben
#kochbuch.tex erstellen
  die "Fehler beim \366ffnen von 'kochbuch.tex': $!\n" unless open KOCHBUCH, '> kochbuch.tex'; #Haupt tex Datei anlegen
  print KOCHBUCH "\\documentclass[a5paper,10pt,titlepage,twoside,onecolumn]{scrartcl}\n%\\documentclass[a5paper,10pt,titlepage,twoside,onecolumn]{scrartcl}\n\\input{header}\n\\marginsize{2,5cm}{20mm}{2cm}{2cm} %R\344nder: links, rechts, oben, unten\n\n\n\\begin{document}\n\\begin{titlepage}\n  \\begin{center}\n    \\null\n    \\vfill\n    %\\LinienBox {\\huge Kochbuch} font {\\UB}  ecken 30 linien 0   \\\\\n    \\LinienBox {\\huge Kochbuch} font {\\UB}  ecken 124 linien 100   \\\\\n    \\vfill\n    {\\Large Letzte \304nderung, \\today}\\\\\n  \\end{center}\n\\end{titlepage}\n\\input{mktoc}";
#kochbuch.tex erstellen
print "$^O\n";
foreach my $datein (@ARGV) {#Parameter Abarbeiten
    my $rw = open(INFILE, $datein); #Datei zum Einlesen Öffnen
    if (not defined $rw) {
        print "Fehler beim \366ffnen der Datei '${datein}':\n$!\n";
        next;
    }
    print "Bearbeitung von '${datein}'\n";
    my $dirn = $datein;
#print "Verzeichniss erstellen\n";
    {#Parameter aufarbeiten - Verzeichnis erstellen
        chomp $dirn;
        $dirn =~ s/\..*$//;
        $dirn =~ tr/äÄöÖüÜ-/aAoOuU /;#Deutsch Umlaute umwandeln
        $dirn =~ s/(\w+)/\u\L$1\E/g;#Jeweils ersten Buchstaben groß s/(\w+)/\u\L$1/g;
        $dirn =~ s/ //g;#Leerzeichen entfernen
        $dirn =~ s/[^a-zA-Z_0-9]/_/g;#Sonderzeichen entfernen 
        my $permission = 0777;
        mkdir $dirn, $permission; # Verzeichnis erstellen
    }#Parameter aufarbeiten - Verzeichnis erstellen
#print "Verzeichniss erstellt\n";
    my(@datlist) = undef;
    while (defined($i = <INFILE>)) {#Datei verarbeiten/Rezepte aus Datei lesen7
#print "Datei verarbeiten/Rezepte aus Datei lesen\n";
        my(@rezept) = undef;
        if ($i =~ /^={5,}.*rezkonv/i) {#Erkennung des Rezeptbeginns/Rezept in Array einlesen
#print "Erkennung des Rezeptbeginns/Rezept in Array einlesen\n";
            #while (not $i =~ /^={5,}$/) {#Rezept Ende
	     while (not $i =~ /\A(={5,})\Z/) {#Rezept Ende
                $i = <INFILE>;
                chomp $i;
#print "Einlesen: !$i!\n";
                if (not $i =~ /\A(={5,})\Z/) {#!if Rezept Ende
                   # &LATEXSONDERZEICHEN;#LaTeX Sonderzeichen ersetzen
                    $i =~ s[\b(\d+)/(\d+)\b][\\frac{$1}{$2}]g;#x/y in \frac{x}{y} umwandeln
#print "Ausgewertet: $i";
                    push @rezept, $i;
                }#!if Rezept Ende
#if ($i =~/^={5,}$/){print"\n\n Ende erkannt\n\n";}
            }#Rezept Ende
#print "x Erkennung des Rezeptbeginns/Rezept in Array einlesen\n";
        }#Erkennung des Rezeptbeginns/Rezept in Array einlesen
        else {next};
        push @rezept, "enderezept\n";
        #Variablendefinition
#print "Variablendefinition\n";
        my(@kopf) = undef;
        my(@zutaten) = undef;
        my(@quelle) = undef;
        my(@erfasser) = undef;
        my(@zubereitung) = undef;
        my(@langertitel) = undef;
        my $titel;
        my $dateiname;
        my $zeiger = 1;
        my $langertitel = 0;
#print "x Variablendefinition\n";
        #Variablendefinition
        foreach my $x (@rezept) {#Rezept in seine Bestandteile Zerlegen
            if ($x =~ /enderezept/) {#Wenn das Ende erreicht ist aus der Schleife Aussteigen
                last;
            }#Wenn das Ende erreicht ist aus der Schleife Aussteigen
            if ($zeiger == 1) {#Kopf
#print "Kopf\n";
                if ($x =~ / *Titel:/) {#Titel Bearbeiten
                    chomp $x;
                    $dateiname = $x;
                    $x =~ s/ *Titel: //;
                    $dateiname =~ s/ {0,}Titel: //;
                    $dateiname =~ tr/äÄöÖüÜ-/aAoOuU /;#Deutsch Umlaute umwandeln
                    $dateiname =~ s/(\w+)/\u\L$1\E/g;#Jeweils ersten Buchstaben groß
                    $dateiname =~ s/ //g;#Leerzeichen entfernen
                    $dateiname =~ s/[^a-zA-Z0-9]//g;#Sonderzeichen entfernen
                    $dateiname .= '.tex';#Dateierweiterung anhängen
                    $titel = $x;
#print "    Titel: $titel\n";
#print "Dateiname: $dateiname\n\n";
                }#Titel Bearbeiten
                if ($x =~ / *Kategorien:/) {#Kategorien
                    chomp $x;
                    $x =~ s/ *Kategorien: //;
                    $x = '\\kategorien{' . $x . "}\n";
                    push @kopf, $x;
                }#Kategorien
                if ($x =~ / *Menge:/) {#Menge
                    chomp $x;
                    $x =~ s/ {0,}Menge: //;
                    $x = '\\menge{' . $x . "}\n";
                    push @kopf, $x;
                    push @zutaten, "\\begin{Zutatenliste}\n";
                    ++$zeiger;
                    next;
                }#Menge
#print "x Kopf\n";
            }#Kopf
            if ($zeiger == 2) {#Zutaten
#print "Zutaten\n";
                if ($x =~ /^Zutaten:/) {#Zutaten: nicht reinschreiben
                    next;
                }#Zutaten: nicht reinschreiben
                if ($x =~ /^$/) {#Leerzeilen Ignorieren
                    next;
                }#Leerzeilen Ignorieren
                $x =~ s/ {2};//;#Versuch das MM ; aus den Zutaten zu verbannen
                if (not $x =~ /quelle|source/i and $x =~ /^={3,}/i) {#Zutatenüberschrift
                    chomp $x;
                    $x =~ s/=*//g;#= Entfernen
                    $x =~ s/(\w+)/\u\L$1\E/g;#Jeweils ersten Buchstaben groß
                    $x =~ s/(\A *)|( *\Z)//g;#Leerzeichen Am Anfang und am Ende entfernen
                    $x = "\\end{Zutatenliste}\n\\zutatenueberschrift{$x}\n\\begin{Zutatenliste}\n";
                    push @zutaten, $x;
                    next;
                }#Zutatenüberschrift
###################################################################
#Quelle ist optional!!! Zutatenende muss anders realisiert werden.#
###################################################################
                if ($x =~ /quelle|source/i) {#Quellenbeginn/Zutatenende
                    push @zutaten, "\\end{Zutatenliste}\n";
                    ++$zeiger;
                    next;
                }#Quellenbeginn/Zutatenende
                if (not $x =~ /^ *-{1,} /) {#Wenn kein Zutatenumbruch - \item voransetzen
                    $x = '\\item ' . $x."\n";
                }#Wenn kein Zutatenumbruch - \item voransetzen
                push @zutaten, $x;
#print "x Zutaten\n";
            }#Zutaten
            if ($zeiger == 3) {#Quelle und Erfasser
#print "Quelle und Erfasser";
                if ($x =~ / {3,}-- /) {#Erfasser
                    $x =~ s/ *-- //;#Remove leading Spaces
                    push @erfasser, $x;
                    next;
                }#Erfasser
                if ($x =~ /^$/) {#Quellenende
                    $zeiger = 7;
                    next;
                }#Quellenende
                $x =~ s/ *//;#Remove leading Spaces
                push @quelle, $x;
                next;
#print "Quelle und Erfasser";
            }#Quelle und Erfasser
            if ($zeiger == 7) {#Überprüfung auf "Zubereitung:" am Zubereitungsbeginn
                if ($x =~ /^Zubereitung:/) {
                    $x = "";
                }
                $zeiger = 4;
            }#Überprüfung auf "Zubereitung:" am Zubereitungsbeginn
            if ($zeiger == 4) {#Zubereitung
                if ($x =~ /O-Titel/i) {#Langer Titel?
                    $zeiger = 5;
                    redo;
                }#Langer Titel?
                else {
###########################
#Erzwungener Zeilenumbruch#
###########################
                    if ($x =~ /^(:|\*|-)/) {#Erzwungener Zeilenumbruch - Lösung gehört verbessert!
                        chomp $x; #Entfernt \n am Zeilenende
                        #$x = "\n{\\footnotesize \\verb|" . $x . "|}\\\\\n";
                        #$x = "{\\verb|$x|}\\\\\n";
			$x = "\n" . $x; #Fügt eine neue Zeile vor dem String ein.
                    }#Erzwungener Zeilenumbruch - Lösung gehört verbessert!
                    push @zubereitung, $x."\n";
                }
            }#Zubereitung
            if ($zeiger == 5) {#Langer Titel/Kann evtl zu Problemen kommen wenn danach noch Metatags kommen
                $x =~ s/: *O-Titel *: *//i;
                $x =~ s/^: *> *: *//;
                $x =~ s/^: *> */ /;
                if (defined $x and $x =~ /.{3,}/) {
                    push @langertitel, $x;
                    $langertitel = 1;
                }
            }#Langer Titel/Kann evtl zu Problemen kommen wenn danach noch Metatags kommen
        }#Rezept in seine Bestandteile Zerlegen
        if (defined @langertitel and $langertitel == 1) {#Langen Titel verarbeiten
            my $langertitel;
            foreach my $x (@langertitel) {
                #chomp $x;
                $langertitel .= $x . ' ';
            }
            $langertitel =~ s/(^ *)|( *$)//g;
            chomp $langertitel;
            $dateiname = $langertitel;
            $dateiname =~ tr/äÄöÖüÜ-/aAoOuU /;#Deutsch Umlaute umwandeln
            $dateiname =~ s/(\w+)/\u\L$1\E/g;#Jeweils ersten Buchstaben groß
            $dateiname =~ s/ //g;#Leerzeichen entfernen
            $dateiname =~ s/[^a-zA-Z_0-9]/_/g;#Sonderzeichen entfernen
            $dateiname .= '.tex';#Dateierweiterung
            @langertitel = undef;
            $langertitel =~ s/(^ *)|( *$)//g;#leading and trailing space entfernen
            push @langertitel, $langertitel . "\n";
            $titel = $langertitel;#Titel erneuern
        }#Langen Titel verarbeiten
        $titel =~ s/"(.*?)"/"`$1"'/g;#Anführungszeichen bereinigen
        my $zutaten="";
        foreach my $x (@zutaten) {#Zutaten in EINEN String
            $zutaten .= $x;
        }#Zutaten in EINEN String
        $zutaten =~ s/\n *-{1,} */ /gms;#Zeilenumbruch bereinigen
        $zutaten =~ s/\\begin{Zutatenliste}\n\\end{Zutatenliste}//;
        $zutaten =~ s/"(.*?)"/"`$1"'/gms;#Anführungszeichen bereinigen
        my $zubereitung="";
        foreach my $x (@zubereitung) {#Zubereitung in EINEN String
            $zubereitung .= $x;
        }#Zubereitung in EINEN String
        $zubereitung =~ s/"(.*?)"/"`$1"'/gms;#Anführungszeichen bereinigen
        while ($zubereitung =~ /(\A\n)|(\n\Z)/gms){
        	  $zubereitung =~ s/(\A\n)|(\n\Z)//gms;#Versuch führende und folgende Leerzeilen zu Löschen
        }
        #$zubereitung =~ s/\n\Z//gms;#Versuch führende und folgende Leerzeilen zu Löschen
        {#alte Einzelrezeptdatei schließen, neue öffnen - Eintrag in Dateiliste
            close OUTFILE;
            my $Is_Unix;
            my $dateinamemp;
            $Is_Unix = !grep { $^O eq $_ } qw(VMS MSWin32 os2 dos MacOS NetWare beos vos);
            if (not $IsUnix) {$dateinamemp = "./$dirn/" . $dateiname}#Dateiname für Einzelrezept erzeugen
               else {$dateinamemp = ".\\$dirn\\" . $dateiname}#Dateiname für Einzelrezept erzeugen
#print "$dateinamemp";
            die "Fehler beim \366ffnen von '" . $dateiname . "': $!\n" unless open OUTFILE, '> ' . $dateinamemp; #Datei öffnen
            my $dateinamempoe = "$dirn/$dateiname";#Dateiname für Liste aufbereiten
            $dateinamempoe =~ s/\.tex//;#Dateiname für Liste aufbereiten
            push @datlist, '\\einfuegen{' . $dateinamempoe . "}\n";
        }#alte Einzelrezeptdatei schließen, neue öffnen - Eintrag in Dateiliste
        {#Schreiben des Rezeptes in die Ausgabedatei
            print OUTFILE '%' . $dateiname . "\n%Erstellt mit Hilfe von RezKonv2LaTeX by Bastian Hepp\n%Version " . $version . "\n";
            (my $tmptitel = $titel) =~ s/[^a-zA-Z]//g;#Alles auser Buchstaben aus dem Titel entfernen
            if ($tmptitel =~ /^[A-Z]+$/) {#Wenn nur Großbuchstaben vorkommen
                $titel =~ s/(\w+)/\u\L$1\E/g;#Jeweils ersten Buchstaben groß
            }#Wenn nur Großbuchstaben vorkommen
            my $quelle = "\\begin{KQuelle}\n\\quelle{";#Quellenenviroment beginnen/Quellentag hinzufügen
            foreach my $x (@quelle) {#@Quelle in einen String umwandeln
                if (not $x =~ /^$/) {#Leerzeilenerkennung
                    if (not $quelle =~ /quelle.$/) {#Nach quelle{ kein \\
                        $quelle .= "\\\\\n";
                    }#Nach quelle{ kein \\
                    chomp $x;
                    $quelle .= $x . '';
                }#Leerzeilenerkennung
            }#@Quelle in einen String umwandeln
            $quelle .= "}\n\n";#Quellentag hinzufügen
            my $erfasser = '\\erfasser{';#Erfassertag hinzufügen
            foreach my $x (@erfasser) {#@Erfasser in einen String umwandeln
                if (not $x =~ /^$/) {#Leerzeilenerkennung
                    if (not $erfasser =~ /erfasser.$/) {#Nach erfasser{ kein \\
                        $erfasser .= "\\\\\n";
                    }#Nach erfasser{ kein \\
                    chomp $x;
                    $erfasser .= $x . '';
                }#Leerzeilenerkennung
            }#@Erfasser in einen String umwandeln
            $erfasser .= "}\n\\end{KQuelle}\n";#Erfassertag hinzufügen/Quellenenviroment schließen
            #Ausgabe in Datei
            print OUTFILE "\\titel{$titel}\n";
            print OUTFILE @kopf;
            print OUTFILE $zutaten;
            print OUTFILE $quelle;
            print OUTFILE $erfasser;
            print OUTFILE "\\begin{zubereitung}\n$zubereitung\n\\end{zubereitung}";
        }#Schreiben des Rezeptes in die Ausgabedatei
    }#Datei verarbeiten/Rezepte aus Datei lesen
    @datlist = sort  @datlist;
    die "\nFehler beim \366ffnen von '" . $dirn . "':\n $!\n" unless open DATLIST, "> $dirn.tex";
    print DATLIST @datlist;
    print KOCHBUCH "\n\\part{$dirn}\n";
    print KOCHBUCH @datlist;
    close DATLIST;
    close INFILE;
    close OUTFILE;
    print "     *** abgeschlossen\n\n";
}#Parameter Abarbeiten
print KOCHBUCH "\\end{document}";
close KOCHBUCH;
my $rw = open(HEADERTEX, 'header.tex');
if (not defined $rw) {
    open HEADERTEX, '> header.tex';
    print HEADERTEX "\\usepackage{textcomp,tocloft,multicol,graphicx,anysize,microtype,ellipsis,fixltx2e,mparhack}\n\\usepackage[OT1]{fontenc}\n\\usepackage[latin9]{inputenc}\n\\usepackage[german,ngerman,english]{babel}\n%\\usepackage{pstricks,color}\n\\usepackage[pdftex,colorlinks,bookmarksnumbered,backref]{hyperref}\n\n\\newcommand{\\titel}[1]{\\section{#1}}\n\\newcommand{\\kategorien}[1]{Kategorien: #1\\\\}\n\\newcommand{\\menge}[1]{Menge: #1\\\\}\n\\newcommand{\\quelle}[1]{#1}\n\\newcommand{\\erfasser}[1]{#1}\n\\newcommand{\\zutatenueberschrift}[1]{\\begin{center}{\\textsc{#1}}\\end{center}}%\n\\newcommand{\\einfuegen}[1]{\\null\\vfill\\input{#1}}\n\n\\usepackage{umrand}                               %\n\\font\\UB=umrandb at 50pt                          %\n\\font\\f = umranda\n\\font\\F = umranda at 20pt\n\n\n\\renewcommand{\\frac}[2]{\$\\leavevmode\\kern.1em \\raise.5ex \\hbox{\\the\\scriptfont0 #1}\\kern-.1em/\\kern-.15em\\lower.25ex\\hbox{\\the\\scriptfont0 #2}\$}\n\n\\newcommand{\\tpfvo}[1]{\\unitlength #1pt%Das Pfundzeichen, Variabel\n    \\begin{picture}(9,10)(1,.5)\n        \\qbezier(2,8)(2,0)(4,0)\n        \\qbezier(7,8)(7,0)(4,0)\n        \\qbezier(7,8)(7,3)(7,2)\n        \\qbezier(7,2)(11,3)(6.7,4)\n        \\qbezier(6.7,4)(5,4)(2,4)\n        \\qbezier(2,4)(-2,5)(2,6)\n        \\qbezier(2,6)(3,6)(9,6)\n    \\end{picture}}\n    \n\\newcommand{\\tpfv}[1]{\\unitlength #1pt%Das Pfundzeichen, Variabel    \n    \\begin{picture}(9,10)(1,.5)\n        \\qbezier(2,8)(2,0)(4,0)\n        \\qbezier(7,8)(7,0)(4,0)\n        \\qbezier(7,8)(7,3)(7,1)\n        \\qbezier(7,1)(7.3,0)(8,0)\n        \\qbezier(8,0)(8.7,0)(9,1)\n        \\qbezier(9,1)(10,4)(6.7,4)\n        \\qbezier(6.7,4)(5,4)(2,4)\n        \\qbezier(2,4)(-2,5)(2,6)\n        \\qbezier(2,6)(3,6)(9,6)\n    \\end{picture}}    \n\\newcommand{\\tpf}[0]{\\tpfv{1.2}}%Feste gr\366\337e f\374r das Pfundzeichen\n\n%Kopf und Fu\337zeile\n\\usepackage{fancyhdr}\n\\pagestyle{fancy}\n\\renewcommand{\\sectionmark}[1]{}\n\\fancyhead{}\n\\setlength{\\headheight}{22pt}\n\\fancyhead[RE,LO]{}\n\\fancyhead[CE,CO]{}\n\\fancyhead[LE,RO]{\\rightmark}\n\\fancyfoot[RE,LO]{}\n\\fancyfoot[LE,RO]{\\thepage}\n\\fancyfoot[CE,CO]{} \\renewcommand{\\headrulewidth}{0.4pt}\n\\renewcommand{\\footrulewidth}{0.4pt}\n%Kopf und Fu\337zeile\n\n\\newcommand{\\Inh}{\\markboth{}{Inhaltsverzeichnis}}\n\n\\usepackage{pifont}\n\\AtBeginDocument{\\renewcommand{\\labelitemi}{\\ding{167}}}\n\\addto\\itemize{\\itemsep=-2mm}\n\\parindent0mm\n\\newlength{\\as}\n\\setlength{\\as}{2mm}\n\n\\newenvironment{Zutatenliste}{%\n  \\parindent0pt\n  %\\begin{parbox}\n  %\\begin{mbox}\n  \\begin{multicols}{2}\n  \\begin{itemize}\n  }{%\n  \\end{itemize}\n  \\end{multicols}\n  %\\end{mbox}\n  %\\end{parbox}\n  }\n\\newenvironment{zubereitung}{%\n  \\parindent0pt\n  \\parskip5pt\n  %\\vspace{-9mm}\n  %\\null\\hfill\\rule{10cm}{2pt}\\hfill\\null\n  \\begin{multicols}{2}\n  \\begin{mbox}\n  }{%\n  \\end{mbox}\n  \\end{multicols}  \n  }\n\\newenvironment{KQuelle}{\n  %\\rule{\\textwidth}{0.5pt}\n  %\\begin{multicols}{2}\n  \\begin{center}\n  }{\n  \\end{center}\n  %\\end{multicols}\n  %\\rule{\\textwidth}{0.5pt}\n  }";
}
close HEADERTEX;
#my $rw = open(MKTOK, 'mktoc.tex');
$rw = open(MKTOK, 'mktoc.tex');
if (not defined $rw) {
    open MKTOK, '> mktoc.tex';
    print MKTOK "\\addtocontents{toc}{\\protect\\Inh}\n\\cleardoublepage\n\\cftsecnumwidth=4ex\n\\renewcommand{\\cftdot}{\\ensuremath{\\cdot}}\n\\renewcommand{\\cftsecdotsep}{4}\n\\renewcommand{\\cftsecpresnum}{\\hfill} % note the double `l'\n\\renewcommand{\\cftsecaftersnum}{\\hspace*{0.5em}}\n\\addtolength{\\cftsecnumwidth}{0.5em}\n\\setlength{\\cftbeforesecskip}{0pt}\n\\pagestyle{fancy}\n\\markboth{}{Inhaltsverzeichnis}\n\\tableofcontents\n\\cleardoublepage\n\\markboth{}{}";
}
close MKTOK;
#my $rw = open(BATCH, 'erstelleKochbuch.bat');
$rw = open(BATCH, 'erstelleKochbuch.bat');
if (not defined $rw) {
    open BATCH, '> erstelleKochbuch.bat';
    print BATCH "\@echo off\ndel *.aux\ndel *.log\ndel *.ind\ndel *.idx\ndel *.toc\ndel *.out\ndel *.tmp\ndel *.ilg\ncls\necho erster LaTeX durchlauf\npdflatex -enable-installer -quiet kochbuch.tex\necho .\necho .\necho zweiter LaTeX durchlauf\npdflatex -quiet kochbuch.tex\ndel *.aux\ndel *.log\ndel *.ind\ndel *.idx\ndel *.toc\ndel *.out\ndel *.tmp\ndel *.ilg\nkochbuch.pdf";
}
close BATCH;


#To Do:
#-Algorythmus (: - *) prüfen - Fehler aufgetreten
#-Algorythmus (: - *) verbessern dass er nur über EINEN String läuft?
#-Mehrere * - untereinander als Liste
#   \\ vor \n einfügen wenn ein Schlüssel folgt
#-Erkennung von weiteren Metatags
#-Quelle ist optional. Zutatenbeginn erkennen wenn keine Quelle vorhanden ist.


#Done 0.0.2
#+Dateisplitting
#+Zutatenumbrüche entfernen
#+Dateiliste generieren
#+auf : - * in der Zubereitung prüfen und als Typewriter setzen

#Done 0.0.3
#+Dateiliste sortieren
#+\item vor Zutat schreiben
#+Input Name entgegennehmen und Verzeichnis mit diesem Namen anlegen

#Done 0.0.4
#+Brüche in \frac{}{} umwandeln
#+Titel auf Uppercase überprüfen, wenn Upercase Kapitälchen bilden

#Done 0.0.5
#+ Bug bei Dateiliste behoben
#+ Bug \item ausgelassen behoben
#+ Bug \begin{Zutatenliste}\n\end{Zutatenliste} behoben
#+ " Problem 'unsauber' gefixd
#+\vfill vor \input

#Done 0.0.6
#+ " Problem *sauber* gelöst
#+\input durch \einfuegen ersetzt

#Done 0.0.7
#+Umgehung eines Fehlers bei : - *

#Done 0.0.8
#+Quelle überarbeiten, dass diese auch 2 Spaltig gesetzt werden kann
#+anstelle mehrerer tex input dateien in eine haupt tex datei schreiben
#+Komplette Überarbeitung und Komentierung des Quellcodes

#Done 0.1.0
#+Es wird überprüft, ob header.tex und mktok.tex existieren, wenn dies nicht der Fall ist werden sie erzeugt.
#+Batch zum erstellen des Kochbuchs mit LaTeX wird erzeugt

#Done 0.2.0
#+Code komplett überarbeitet
#+Linux unterstützung

#Bugs die auftreten könnten
#-weitere Sonderzeichen in Rezepten
#-Wenn der überlanger Titel nicht das letzte Metatag ist könnte es probleme geben

#Anmerkung
# Die Ausgabe für die Dateien habe ich dadurch erreicht, dass ich das Grundgerüst der Perl Befehle
# in eine Datei kb geschrieben habe. Die auszugebende Datei war dann einfach so dort gestanden wie
# sie auch in der Tex Datei steht. Von einer Printanweisung und Anführungszeichen eingeschlossen.
# Nun hab ich einfach die Befehlszeile "perl -MO=Deparse kb >kb.pl" ausgeführt, und der Perldebugger
# hat mir den langen Text in einen Einzeiler verwandelt. So bleibt das Script meiner Meinung nach
# einfacher lesbar.

#Zeiger
# 1 Kopf
# 2 Zutaten
# 3 Quelle und Erfasser
# 4 Zubereitung
# 5 langer Titel
# 7 Überprüfung auf "Zubereitung:" am Zubereitungsbeginn
#
#To do
#11 - Erste Position im Absatz/Zeilen -> Liste
#12 * Erste Position im Absatz/Zeilen -> Liste

#Arbeitsweise des Programms
#--------------------------
# Zuerst werden die Dateien sequentiell eingelesen.
# Ein Rezept wird in ein Array eingelesen, wobei LaTeX Sonderzeichen schon Maskiert werden.
# Das Array wird auch Sequentiell abgearbeitet, wobei in einer Variable die Position im
#  Rezept (Kopf, Quelle...) festgehalten wird.
# Durch If-Anweisungen wird nur diesr Block verarbeitet.
# Die einzelnen Rezeptblöcke werden bei der Abarbeitung in einzelne Arrays geschrieben,
#  dass man diese später auch neu positionieren kann.