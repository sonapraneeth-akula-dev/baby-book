% babybook.cls -- layout, palette and drawing blocks for the baby record book.
% Every fill-in block takes a JSON key (see babydata.sty); empty key => blank.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{babybook}[2026/01/01 Baby record book]
\LoadClass[11pt,a4paper,oneside]{book}
\RequirePackage[a4paper,margin=18mm,top=20mm,bottom=22mm]{geometry}
\RequirePackage[T1]{fontenc}
\RequirePackage{nunito}
\RequirePackage{tgpagella}
\renewcommand\familydefault{Nunito-TLF}
\RequirePackage[table]{xcolor}
\RequirePackage{fontawesome5}
\RequirePackage{graphicx,tabularx,array,colortbl}
\RequirePackage[most]{tcolorbox}
\RequirePackage{pgfplots}
\pgfplotsset{compat=1.18}
\usetikzlibrary{calc,positioning,shapes.geometric,shapes.callouts,decorations.pathmorphing}
\RequirePackage[hidelinks]{hyperref}
\pdfstringdefDisableCommands{\def\\{ }}
\RequirePackage{babydata}

\newcommand\headfont{\fontfamily{qpl}\selectfont\bfseries}
\newcommand\valuefont{\bfseries\color{ink}}   % how filled-in data looks
\newcommand\bbphotodir{photos/}                % photo file names in JSON are relative to this
\raggedbottom\setlength\parindent{0pt}
\AtBeginDocument{\color{ink}}

% ---------- palette ----------
\definecolor{ink}{HTML}{293C3A}   \definecolor{paper}{HTML}{FCFAF5}
\definecolor{blush}{HTML}{F3E5DF} \definecolor{rose}{HTML}{AC5F58}
\definecolor{mint}{HTML}{E3EDE4}  \definecolor{sea}{HTML}{427765}
\definecolor{sky}{HTML}{E2ECEC}   \definecolor{ocean}{HTML}{406F78}
\definecolor{lav}{HTML}{EEE8EF}   \definecolor{plum}{HTML}{795F80}
\definecolor{peach}{HTML}{F8E8DA} \definecolor{coral}{HTML}{BF704D}
\definecolor{butter}{HTML}{F8EDCE}\definecolor{honey}{HTML}{AD813E}
\newcommand\settheme[2]{\colorlet{theme}{#1}\colorlet{themelight}{#2}}
\settheme{rose}{blush}
\def\grandpaname{Grandpa}\def\handname{hand}

% ---------- warm paper and restrained page furniture ----------
\pagestyle{empty}
\AddToHook{shipout/background}{\put(0,0){\begin{tikzpicture}[overlay,x=1mm,y=1mm]
  \fill[paper] (0,0) rectangle (210,-297);
  \ifnum\value{page}>1
    \fill[theme] (18,-11) rectangle (27,-12);
    \draw[theme!35,line width=.5pt] (30,-11.5) -- (192,-11.5);
    \draw[theme!35,line width=.5pt] (18,-282) -- (192,-282);
    \node[anchor=east,text=theme,font=\headfont\small] at (191,-287) {\thepage};
  \fi
\end{tikzpicture}}}

% ---------- building blocks ----------
% page title (also a TOC entry)
\newcommand\pagetitle[2][\faStar]{\clearpage\phantomsection
  \addcontentsline{toc}{section}{#2}%
  \noindent\begin{minipage}[c]{12mm}\centering\color{theme}\large #1\end{minipage}%
  \hspace{3mm}\begin{minipage}[c]{\dimexpr\linewidth-15mm\relax}
    {\headfont\LARGE\color{ink}#2}
  \end{minipage}\par\vspace{2mm}
  {\color{theme}\rule{\linewidth}{1pt}}\par\vspace{4mm}}
\newcommand\bookcontents{\@starttoc{toc}}

% label + value + fill-in line: \field[width]{label}{key}
\newcommand\field[3][\linewidth]{\bbget\bb@fv{#3}%
  \begin{minipage}[b]{#1}\raggedright\strut{\color{theme}\bfseries #2}\ %
  \ifx\bb@fv\empty\else{\valuefont\bb@fv}\ \fi{\color{theme!35}\hrulefill}\end{minipage}}
\newcommand\fields[4]{\field[.485\linewidth]{#1}{#2}\hfill\field[.485\linewidth]{#3}{#4}\par\vspace{2.2mm}}

% n ruled writing lines with the key's text written on them (grows if the text is longer)
\newcommand\writelines[2]{\par\noindent\bbget\bb@wv{#2}\begin{tikzpicture}
  \path (0,0) rectangle (\linewidth,-#1*8mm-1mm);
  \def\bb@nl{#1}%
  \ifx\bb@wv\empty\else
    \node[anchor=north west,inner sep=0,text width=\linewidth,align=left] (bbt) at (0,-1.7mm)
      {\valuefont\fontsize{\f@size}{8mm}\selectfont\strut\bb@wv\strut\par};
    \pgfpointanchor{bbt}{south}\dimen@=-\pgf@y\advance\dimen@-1.7mm
    \pgfmathtruncatemacro\bb@nl{max(#1,round(\dimen@/8mm))}%
  \fi
  \foreach \i in {1,...,\bb@nl} \draw[theme!30] (0,-\i*8mm) -- (\linewidth,-\i*8mm);
  \end{tikzpicture}\par}

% photos: JSON holds a file name inside \bbphotodir
\newcommand\bb@ifphoto[3]{\bbgetraw\bb@p{#1}\ifx\bb@p\empty\expandafter\@secondoftwo\else
  \expandafter\bb@iffile\fi{#2}{#3}}
\newcommand\bb@iffile[2]{\IfFileExists{\bbphotodir\bb@p}{#1}
  {\ClassWarning{babybook}{Photo '\bbphotodir\bb@p' not found}#2}}
% image scaled to cover w x h (caller clips)
\newcommand\bb@cover[2]{\sbox\z@{\includegraphics[width=#1]{\bbphotodir\bb@p}}%
  \ifdim\ht\z@<#2\relax\includegraphics[height=#2]{\bbphotodir\bb@p}\else\usebox\z@\fi}
% \photoor{key}{w}{h}{fallback}: photo fitted into w x h, else fallback
\newcommand\photoor[4]{\bb@ifphoto{#1}{\includegraphics[width=#2,height=#3,keepaspectratio]{\bbphotodir\bb@p}}{#4}}
% photo frame: \photobox{key}{width}{height}{caption}
\newcommand\photobox[4]{\begin{tikzpicture}
  \coordinate (c) at ($(0,0)!.5!(#2,#3)$);
  \bb@ifphoto{#1}{%
    \begin{scope}\clip[rounded corners=2pt] (0,0) rectangle (#2,#3);
      \node[inner sep=0] at (c) {\bb@cover{#2}{#3}};\end{scope}
    \draw[theme!65,line width=.8pt,rounded corners=2pt] (0,0) rectangle (#2,#3);}
   {\draw[theme!65,dashed,line width=.8pt,rounded corners=2pt,fill=themelight!35] (0,0) rectangle (#2,#3);
    \node[text=theme!60,font=\Huge] at (c) {\faCamera};}
  \node[below,font=\footnotesize\bfseries,text=theme] at ($(0,0)!.5!(#2,0)$) {#4};
  \end{tikzpicture}}

% lightly framed cards with a section marker
\newtcolorbox{card}[2][]{enhanced,colback=white,colframe=theme!45,boxrule=.65pt,arc=1.5mm,
  borderline west={2pt}{0pt}{theme},fonttitle=\headfont\large,coltitle=ink,colbacktitle=white,
  attach boxed title to top left={xshift=4mm,yshift=-2.5mm},
  boxed title style={arc=0pt,boxrule=0pt,colback=white},top=6mm,title={#2},#1}
% \notecard[opts]{title}{lines}{key}
\newcommand\notecard[4][]{\begin{card}[#1]{#2}\vspace{-3mm}\writelines{#3}{#4}\end{card}}

% raster tiles (plain boxes inside tcbraster)
\newcommand\tile[1]{\begin{tcolorbox}#1\end{tcolorbox}}
% icon tile for rasters: {icon}{label}{content}
\newcommand\icontile[3]{\tile{\centering{\color{theme}\huge #1}\par\smallskip
  {\headfont #2}\par\raggedright\vspace{3mm}#3\par}}
\tcbset{tiles/.style={raster equal height,colback=themelight!18,colframe=theme!40,arc=1.5mm,boxrule=.65pt,
  raster column skip=3mm,raster row skip=3mm}}
\newcommand\chk{{\color{theme}\faSquare[regular]}\ }
\newcommand\chkyes{{\color{theme}\faCheckSquare}\ }

% section divider page: {n}{title}{subtitle}{theme}{light}{icons}
\newcommand\bookpart[6]{\clearpage\settheme{#4}{#5}%
  \phantomsection{\let\\\space\addcontentsline{toc}{chapter}{#1\quad #2}}%
  \begin{tikzpicture}[remember picture,overlay]
    \fill[themelight] (current page.south west) rectangle (current page.north east);
    \fill[theme] (current page.south west) rectangle ($(current page.north west)+(1.5cm,0)$);
    \draw[theme!35,line width=1pt] ($(current page.north west)+(4cm,-5cm)$) --
      ($(current page.north east)+(-2cm,-5cm)$);
    \draw[theme!35,line width=1pt] ($(current page.north east)+(-1cm,-2cm)$) circle (3cm);
    \draw[theme!35,line width=1pt] ($(current page.north east)+(-1cm,-2cm)$) circle (2.2cm);
    \node[anchor=west,font=\small\bfseries,text=theme] at
      ($(current page.north west)+(4cm,-4cm)$) {A CHAPTER OF OUR STORY};
    \node[anchor=west,font=\headfont\fontsize{88}{92}\selectfont,text=theme] at
      ($(current page.north west)+(3.8cm,-9cm)$) {#1};
    \node[anchor=north west,font=\headfont\fontsize{37}{44}\selectfont,text=ink,
      align=left,text width=14cm] (t) at ($(current page.north west)+(4cm,-12.6cm)$) {#2};
    \node[anchor=north west,font=\Large\itshape,text=ink,align=left,text width=12cm]
      at ($(t.south west)+(0,-8mm)$) {#3};
    \node[anchor=west,text=theme,font=\fontsize{31}{31}\selectfont] at
      ($(current page.south west)+(4cm,4cm)$) {#6};
  \end{tikzpicture}\clearpage}

% round portrait (photo if given): \portrait[size]{node}{x,y}{colour}{icon}{photo key}
\newcommand\portrait[6][2.2cm]{\bb@ifphoto{#6}
  {\node[circle,draw=#4,line width=1.4pt,minimum size=#1,inner sep=0,path picture={\node at
     (path picture bounding box.center) {\bb@cover{#1}{#1}};}] (#2) at (#3) {};}
  {\node[circle,draw=#4,line width=1.4pt,fill=#4!12,minimum size=#1,text=#4] (#2) at (#3) {#5};}}
% family tree member: \member[size]{node}{x,y}{colour}{icon}{role}{person key}
\newcommand\member[7][2.2cm]{\portrait[#1]{#2}{#3}{#4}{#5}{#7.photo}%
  \node[below=.6mm of #2,font=\footnotesize\bfseries,text=#4,align=center] (#2-l) {#6};
  \draw[#4!55] ($(#2-l.south)+(-.45*#1,-.45)$) -- ++(.9*#1,0);
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
\newcommand\datatable[3]{{\renewcommand\arraystretch{#1}\arrayrulecolor{theme!50}\rowcolors{2}{themelight!40}{white}%
  \begin{tabularx}{\linewidth}{#2}\hline\rowcolor{theme}#3\\\hline\rows\end{tabularx}}}
\newcommand\thd[1]{\leavevmode\color{white}\bfseries #1}
\endinput
