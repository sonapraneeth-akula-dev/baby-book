% babybook.cls -- layout, palette and drawing blocks for the baby record book.
% Every fill-in block takes a JSON key (see babydata.sty); empty key => blank.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{babybook}[2026/01/01 Baby record book]
\newif\ifbb@twoside
\DeclareOption{twoside}{\bb@twosidetrue}
\DeclareOption{oneside}{\bb@twosidefalse}
\ProcessOptions\relax
\ifbb@twoside
  \LoadClass[11pt,a4paper,twoside,openany]{book}
  \RequirePackage[a4paper,inner=23mm,outer=13mm,top=20mm,bottom=22mm]{geometry}
\else
  \LoadClass[11pt,a4paper,oneside]{book}
  \RequirePackage[a4paper,margin=18mm,top=20mm,bottom=22mm]{geometry}
\fi
\RequirePackage{iftex,pdftexcmds}
\iftutex
  \RequirePackage{fontspec}
  \setmainfont{Nunito}[Extension=.otf,UprightFont=*-Regular,BoldFont=*-Bold,ItalicFont=*-Italic,BoldItalicFont=*-BoldItalic]
  \newfontfamily\displayfont{CormorantGaramond}[Extension=.ttf,UprightFont=*-Regular,BoldFont=*-Bold,ItalicFont=*-Italic,BoldItalicFont=*-BoldItalic]
  \providecommand\pdfstrcmp{\pdf@strcmp}
\else
  \RequirePackage[T1]{fontenc}
  \RequirePackage[lining,mainfont]{nunito}
  \newcommand\displayfont{\fontfamily{CormorantGaramond-TLF}\selectfont}
\fi
\RequirePackage{comfortaa}
\RequirePackage[table]{xcolor}
\RequirePackage{fontawesome5}
\RequirePackage{graphicx,tabularx,array,colortbl,multicol}
\RequirePackage[most]{tcolorbox}
\RequirePackage{pgfplots}
\pgfplotsset{compat=1.18}
\usetikzlibrary{calc,positioning,shapes.geometric,shapes.callouts,decorations.pathmorphing}
\RequirePackage[hidelinks]{hyperref}
\pdfstringdefDisableCommands{\def\\{ }\def\faStar{}\def\quad{ }\def\enspace{ }}
\RequirePackage{babydata}

\newcommand\headfont{\displayfont\bfseries}
\newcommand\valuefont{\comfortaa\fontsize{.94\dimexpr\f@size pt\relax}{\f@baselineskip}\selectfont\color{written}}
\newcommand\bbphotodir{photos/}                % photo file names in JSON are relative to this
\raggedbottom\setlength\parindent{0pt}

% ---------- heirloom botanical palette ----------
\definecolor{cream}{HTML}{FBF8F3}
\definecolor{ink}{HTML}{363842}
\definecolor{written}{HTML}{2B4162}
\definecolor{blush}{HTML}{F5E2E6}  \definecolor{rose}{HTML}{C4687B}
\definecolor{mint}{HTML}{E1EFEA}   \definecolor{sea}{HTML}{488573}
\definecolor{sky}{HTML}{E2ECF5}    \definecolor{ocean}{HTML}{4B759E}
\definecolor{lav}{HTML}{EAE3F2}    \definecolor{plum}{HTML}{7E6299}
\definecolor{peach}{HTML}{F8E6DC}  \definecolor{coral}{HTML}{D27B55}
\definecolor{butter}{HTML}{F6EDD4} \definecolor{honey}{HTML}{C49538}
\newcommand\settheme[2]{\colorlet{theme}{#1}\colorlet{themelight}{#2}}
\newcommand\setrunning[1]{\gdef\bb@running{#1}}
\newif\ifbb@partpage
\settheme{rose}{blush}\setrunning{}
\def\grandpaname{Grandpa}\def\handname{hand}
\AtBeginDocument{\pagecolor{cream}\color{ink}}

% ---------- archival page border, subtle corner washes, running header & diamond folio ----------
\pagestyle{empty}
\AddToHook{shipout/background}{\ifnum\value{page}>1\ifbb@partpage\global\bb@partpagefalse\else
  \put(0,0){\begin{tikzpicture}[overlay,x=1mm,y=1mm]
    \fill[themelight,opacity=.30] (0,0) circle (24);
    \fill[themelight,opacity=.26] (210,-297) circle (26);
    \draw[theme!28,line width=.45pt] (9.5,-9.5) rectangle (200.5,-287.5);
    \draw[honey!34,line width=.3pt] (11,-11) rectangle (199,-286);
    \foreach \cx/\cy in {9.5/-9.5, 200.5/-9.5, 9.5/-287.5, 200.5/-287.5}
      \node[diamond,fill=honey!75!theme,inner sep=1.1pt] at (\cx,\cy) {};
    \ifx\bb@running\empty\else
      \node[fill=cream,inner xsep=3mm,inner ysep=.5mm,font=\displayfont\itshape\footnotesize,text=theme!80!black]
        at (105,-9.5) {{\def\\{ }\bb@running}};
    \fi
    \node[fill=cream,inner xsep=2.5mm,inner ysep=.6mm] at (105,-287.5)
      {\color{honey!80!theme}\tiny$\bullet$\enspace{\displayfont\bfseries\small\color{theme!85!black}\thepage}\enspace$\bullet$};
  \end{tikzpicture}}\fi\fi}

% ---------- building blocks ----------
% editorial page title lockup (also a TOC entry unless starred: \pagetitle*[icon]{title})
\NewDocumentCommand\pagetitle{s O{\faStar} m}{\clearpage\phantomsection
  \IfBooleanF{#1}{\addcontentsline{toc}{section}{#3}}%
  \begin{center}\begin{tikzpicture}
    \node[circle,fill=themelight!85,draw=theme!50,line width=.5pt,minimum size=6.8mm,
          inner sep=0pt,text=theme,font=\footnotesize] (ic) at (0,0) {#2};
    \draw[theme!38,line width=.45pt] (-30mm,0) -- (ic.west) (ic.east) -- (30mm,0);
    \fill[honey!80!theme] (-30mm,0) circle (.9pt) (30mm,0) circle (.9pt);
    \node[below=.9mm of ic,font=\headfont\fontsize{20}{22}\selectfont,text=ink] (t) {\strut #3};
    \draw[theme!42,line width=.5pt] ($(t.south)+(-18mm,-1.3mm)$) -- ($(t.south)+(-2.2mm,-1.3mm)$)
      ($(t.south)+(2.2mm,-1.3mm)$) -- ($(t.south)+(18mm,-1.3mm)$);
    \node[diamond,fill=honey!85!theme,inner sep=1pt] at ($(t.south)+(0,-1.3mm)$) {};
  \end{tikzpicture}\end{center}\vspace{-3.6mm}}
\newcommand\bookcontents{{\setlength\columnsep{8mm}\parskip=0pt
  \renewcommand*\l@chapter[2]{\par\vspace{2.2mm}{\noindent\color{theme!85!black}\headfont\normalsize ##1\hfill ##2}\par\vspace{.6mm}}%
  \renewcommand*\l@section[2]{{\footnotesize\@dottedtocline{1}{2.5mm}{5mm}{##1}{##2}}}%
  \begin{multicols}{2}\@starttoc{toc}\end{multicols}}}

% stationery dotted leader & fill-in fields: \field[width]{label}{key}
\newcommand\bbrule{\leavevmode\leaders\hbox to 1.6mm{\hss\textcolor{theme!50}{.}\hss}\hfill\kern0pt}
\newcommand\field[3][\linewidth]{\bbget\bb@fv{#3}%
  \begin{minipage}[b]{#1}\raggedright\strut\if\relax\detokenize{#2}\relax\else{\color{theme!85!black}\small\bfseries #2}\ \fi
  \ifx\bb@fv\empty\else{\valuefont\bb@fv}\ \fi\bbrule\end{minipage}}
\newcommand\fields[4]{\field[.485\linewidth]{#1}{#2}\hfill\field[.485\linewidth]{#3}{#4}\par\vspace{2.2mm}}
\newcommand\fieldor[3]{\bbget\bb@fv{#2}%
  \begin{minipage}[b]{\linewidth}\raggedright\strut{\color{theme!85!black}\small\bfseries #1}\ %
  \ifx\bb@fv\empty #3\else{\valuefont\bb@fv}\ \fi\bbrule\end{minipage}}
\newcommand\blankline{\ifbbdata\else\par\vspace{2.2mm}\noindent\strut\bbrule\par\fi}
\newcommand\iconfield[3]{\noindent\makebox[6mm][l]{\color{theme}#1}\field[\dimexpr\linewidth-6mm\relax]{#2}{#3}}

% n dotted writing lines with the key's text written on them (grows if the text is longer)
\newcommand\writelines[2]{\par\noindent\bbget\bb@wv{#2}\begin{tikzpicture}
  \path (0,0) rectangle (\linewidth,-#1*8mm-1mm);
  \def\bb@nl{#1}%
  \ifx\bb@wv\empty\else
    \node[anchor=north west,inner sep=0,text width=\linewidth,align=left] (bbt) at (0,-.9mm)
      {\valuefont\fontsize{\f@size}{8mm}\selectfont\strut\bb@wv\strut\par};
    \pgfpointanchor{bbt}{south}\dimen@=-\pgf@y\advance\dimen@-.9mm
    \pgfmathtruncatemacro\bb@nl{max(#1,round(\dimen@/8mm))}%
  \fi
  \foreach \i in {1,...,\bb@nl} \draw[theme!48,densely dotted,line width=.55pt] (0,-\i*8mm) -- (\linewidth,-\i*8mm);
  \end{tikzpicture}\par}

% photos: gallery-mat frame with corner photo-mount ticks when empty
\newcommand\bb@ifphoto[3]{\bbgetraw\bb@p{#1}\ifx\bb@p\empty\expandafter\@secondoftwo\else
  \expandafter\bb@iffile\fi{#2}{#3}}
\newcommand\bb@iffile[2]{\IfFileExists{\bbphotodir\bb@p}{#1}
  {\ClassWarning{babybook}{Photo '\bbphotodir\bb@p' not found}#2}}
% image scaled to cover w x h (caller clips)
\newcommand\bb@cover[2]{\sbox\z@{\includegraphics[width=#1]{\bbphotodir\bb@p}}%
  \ifdim\ht\z@<#2\relax\includegraphics[height=#2]{\bbphotodir\bb@p}\else\usebox\z@\fi}
% \photoor{key}{w}{h}{fallback}: photo fitted into w x h, else fallback
\newcommand\photoor[4]{\bb@ifphoto{#1}{\includegraphics[width=#2,height=#3,keepaspectratio]{\bbphotodir\bb@p}}{#4}}
% gallery-matted photo frame: \photobox{key}{width}{height}{caption}
\newcommand\photobox[4]{\begin{tikzpicture}
  \coordinate (c) at ($(0,0)!.5!(#2,#3)$);
  \filldraw[fill=white,draw=theme!45,line width=.6pt,rounded corners=4pt] (.5pt,.5pt) rectangle ({#2-.5pt},{#3-.5pt});
  \bb@ifphoto{#1}{%
    \begin{scope}\clip[rounded corners=2.5pt] (2mm,2mm) rectangle ({#2-2mm},{#3-2mm});
      \node[inner sep=0] at (c) {\bb@cover{\dimexpr#2-4mm\relax}{\dimexpr#3-4mm\relax}};\end{scope}
    \draw[theme!25,line width=.35pt,rounded corners=2.5pt] (2mm,2mm) rectangle ({#2-2mm},{#3-2mm});}
   {\fill[themelight!26,rounded corners=2pt] (2.2mm,2.2mm) rectangle ({#2-2.2mm},{#3-2.2mm});
    \coordinate (mbl) at (3.5mm,3.5mm); \coordinate (mtr) at ({#2-3.5mm},{#3-3.5mm});
    \draw[honey!75!theme,line width=.65pt]
      ($(mbl)+(0,3mm)$) -- (mbl) -- ($(mbl)+(3mm,0)$)
      ($(mbl -| mtr)+(0,3mm)$) -- (mbl -| mtr) -- ($(mbl -| mtr)+(-3mm,0)$)
      ($(mbl |- mtr)+(0,-3mm)$) -- (mbl |- mtr) -- ($(mbl |- mtr)+(3mm,0)$)
      ($(mtr)+(0,-3mm)$) -- (mtr) -- ($(mtr)+(-3mm,0)$);
    \node[text=theme!42,font=\LARGE] at (c) {\faCamera};}
  \node[below,font=\displayfont\itshape\normalsize,text=ink!85] at ($(0,0)!.5!(#2,0)$) {\strut #4};
  \end{tikzpicture}}

% heirloom card with soft tinted header & subtle shadow
\tcbset{accent/.style={colframe=#1!52,colbacktitle=#1!20,coltitle=#1!78!black,titlerule style={#1!32}}}
\newtcolorbox{card}[2][]{enhanced,colback=white,colframe=theme!48,boxrule=.6pt,arc=2.5mm,
  fonttitle=\headfont\large,coltitle=theme!80!black,colbacktitle=themelight!70,
  titlerule=.45pt,titlerule style={theme!32},toptitle=1.4mm,bottomtitle=1.2mm,lefttitle=3.5mm,
  top=2.8mm,bottom=2.5mm,left=3.5mm,right=3.5mm,
  fuzzy shadow={.55mm}{-.55mm}{0mm}{.1mm}{ink!7},title={\strut #2},#1}
% \notecard[opts]{title}{lines}{key}
\newcommand\notecard[4][]{\begin{card}[#1]{#2}\vspace{-2.5mm}\writelines{#3}{#4}\end{card}}

% raster tiles (plain boxes inside tcbraster)
\newcommand\tile[1]{\begin{tcolorbox}#1\end{tcolorbox}}
% icon tile for rasters: {icon}{label}{content}
\newcommand\icontile[3]{\tile{\centering
  \tikz\node[circle,fill=themelight!75,draw=theme!35,line width=.4pt,minimum size=7.6mm,inner sep=0pt,text=theme,font=\normalsize]{#1};\par\vspace{1mm}
  {\headfont\large\color{ink} #2}\par\raggedright\vspace{2.2mm}#3\par}}
\tcbset{tiles/.style={enhanced,raster equal height,colback=white,colframe=theme!42,arc=2.5mm,boxrule=.55pt,
  fuzzy shadow={.5mm}{-.5mm}{0mm}{.1mm}{ink!6},raster column skip=3mm,raster row skip=3mm}}
\newcommand\chk{{\color{theme!75}\faSquare[regular]}\ }
\newcommand\chkyes{{\color{theme}\faCheckSquare}\ }

% arched bookplate section divider page: {n}{title}{subtitle}{theme}{light}{icons}
\newcommand\bookpart[6]{\clearpage\global\bb@partpagetrue\settheme{#4}{#5}\setrunning{#2}%
  \phantomsection{\let\\\space\addcontentsline{toc}{chapter}{#1\quad #2}}%
  \begin{tikzpicture}[remember picture,overlay]
    \fill[themelight!72!cream] (current page.south west) rectangle (current page.north east);
    \draw[theme!40,line width=.6pt] ($(current page.south west)+(12mm,12mm)$) rectangle ($(current page.north east)+(-12mm,-12mm)$);
    \draw[honey!55,line width=.35pt] ($(current page.south west)+(14mm,14mm)$) rectangle ($(current page.north east)+(-14mm,-14mm)$);
    \foreach \p/\dx/\dy in {south west/12mm/12mm, south east/-12mm/12mm, north west/12mm/-12mm, north east/-12mm/-12mm}
      \node[diamond,fill=honey!80!theme,inner sep=1.4pt] at ($(current page.\p)+(\dx,\dy)$) {};
    \path[fill=cream,draw=theme!60,line width=.8pt]
      ($(current page.center)+(-6.6cm,-9.4cm)$) -- ($(current page.center)+(-6.6cm,3.4cm)$)
      arc (180:0:6.6cm) -- ($(current page.center)+(6.6cm,-9.4cm)$) -- cycle;
    \path[draw=honey!55,line width=.4pt]
      ($(current page.center)+(-6.3cm,-9.1cm)$) -- ($(current page.center)+(-6.3cm,3.4cm)$)
      arc (180:0:6.3cm) -- ($(current page.center)+(6.3cm,-9.1cm)$) -- cycle;
    \node[circle,fill=themelight!85,draw=theme!65,line width=.7pt,minimum size=2.3cm,
          font=\headfont\fontsize{34}{34}\selectfont,text=theme!85!black] (n) at ($(current page.center)+(0,5.6cm)$) {#1};
    \draw[honey!70,line width=.4pt] (n) circle (1.02cm);
    \node[font=\headfont\fontsize{34}{39}\selectfont,text=ink,below=11mm of n,align=center,text width=11.8cm] (t) {#2};
    \draw[theme!45,line width=.6pt] ($(t.south)+(-2.6cm,-4mm)$) -- ($(t.south)+(-3.5mm,-4mm)$)
      ($(t.south)+(3.5mm,-4mm)$) -- ($(t.south)+(2.6cm,-4mm)$);
    \node[diamond,fill=honey!85!theme,inner sep=1.5pt] (d) at ($(t.south)+(0,-4mm)$) {};
    \node[font=\displayfont\itshape\fontsize{15}{20}\selectfont,text=ink!85,below=6mm of d,align=center,text width=10.8cm] (s) {#3};
    \node[below=14mm of s,text=theme!75,font=\fontsize{22}{22}\selectfont] {#6};
  \end{tikzpicture}\clearpage}

% round portrait (photo if given): \portrait[size]{node}{x,y}{colour}{icon}{photo key}
\newcommand\portrait[6][2.2cm]{\bb@ifphoto{#6}
  {\node[circle,draw=#4,line width=1.4pt,minimum size=#1,inner sep=0,path picture={\node at
     (path picture bounding box.center) {\bb@cover{#1}{#1}};}] (#2) at (#3) {};}
  {\node[circle,draw=#4,line width=1.4pt,fill=#4!12,minimum size=#1,text=#4] (#2) at (#3) {#5};}}
% family tree member: \member[size]{node}{x,y}{colour}{icon}{role}{person key}
\newcommand\member[7][2.2cm]{\portrait[#1]{#2}{#3}{#4}{#5}{#7.photo}%
  \node[below=.6mm of #2,font=\ifdim#1<1.8cm\scriptsize\else\footnotesize\fi\bfseries,text=#4,align=center] (#2-l) {#6};
  \pgfmathsetlengthmacro\bb@mw{max(1.85cm,.92*#1)}%
  \draw[#4!55] ($(#2-l.south)+(-.5*\bb@mw,-.45)$) -- ++(\bb@mw,0);
  \node[above,inner sep=1pt,font=\ifdim#1<2cm\scriptsize\else\footnotesize\fi]
    at ($(#2-l.south)+(0,-.45)$) {\bbv{#7.name}};}
\newcommand\couple[3]{\draw[#3,line width=1.2pt] (#1) -- (#2)
  coordinate[midway] (#1#2) node[midway,fill=white,inner sep=1pt,text=rose]{\small\faHeart};}

% simple pregnant-mama silhouette pic
\tikzset{pics/mama/.style={code={
  \fill[#1] (0,2.45) circle (.3);
  \fill[#1] (-.28,2.05) to[out=-100,in=90] (-.38,1.1) to[out=-90,in=90] (-.42,0)
    -- (.3,0) to[out=90,in=-80] (.28,.7) to[out=10,in=-90] (.78,1.12)
    to[out=90,in=-20] (.3,1.62) to[out=90,in=-80] (.28,2.05) -- cycle;}}}
% footprint guide pic
\tikzset{pics/foot/.style={code={
  \draw[#1,line width=1pt,dashed] (0,0) ellipse (1.25 and 2.4);
  \foreach \x/\y/\r in {-.75/2.75/.42, -.05/3.05/.33, .5/2.95/.28, .92/2.65/.24, 1.2/2.25/.2}
    \draw[#1,line width=1pt,dashed] (\x,\y) circle (\r);}}}

% themed table: \datatable{stretch}{colspec}{header cells}  (body = \rows)
\newcolumntype{P}[1]{>{\raggedright\arraybackslash}p{#1}}% ragged cells (narrow columns look odd justified)
\newcolumntype{Y}{>{\raggedright\arraybackslash}X}
\newcommand\datatable[3]{{\renewcommand\arraystretch{#1}\arrayrulecolor{theme!32}\rowcolors{2}{themelight!26}{white}%
  \begin{tabularx}{\linewidth}{#2}\hline\rowcolor{themelight!85}#3\\\hline\rows\end{tabularx}}}
\newcommand\thd[1]{\leavevmode\color{theme!80!black}\small\bfseries #1}
\endinput
