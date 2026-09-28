% babybook.cls -- layout, palette and drawing blocks for the baby record book.
% Every fill-in block takes a JSON key (see babydata.sty); empty key => blank.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{babybook}[2026/01/01 Baby record book]
\LoadClass[11pt,a4paper,oneside]{book}
\RequirePackage[a4paper,margin=18mm,top=20mm,bottom=22mm]{geometry}
\RequirePackage[T1]{fontenc}
\RequirePackage{nunito}
\RequirePackage{comfortaa}
\renewcommand\familydefault{\sfdefault}
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

\newcommand\headfont{\comfortaa\bfseries}
\newcommand\valuefont{\comfortaa\color{ink}}   % how filled-in data looks
\newcommand\bbphotodir{photos/}                % photo file names in JSON are relative to this
\raggedbottom\setlength\parindent{0pt}
\AtBeginDocument{\color{ink}}

% ---------- palette ----------
\definecolor{ink}{HTML}{4A4A5A}
\definecolor{blush}{HTML}{FAD4DC}  \definecolor{rose}{HTML}{E0839A}
\definecolor{mint}{HTML}{CBEBDD}   \definecolor{sea}{HTML}{4FA88C}
\definecolor{sky}{HTML}{D3E5F7}    \definecolor{ocean}{HTML}{5B8FC9}
\definecolor{lav}{HTML}{E4D9F4}    \definecolor{plum}{HTML}{9577C2}
\definecolor{peach}{HTML}{FFE0C7}  \definecolor{coral}{HTML}{EE9464}
\definecolor{butter}{HTML}{FFF3C4} \definecolor{honey}{HTML}{E8B53C}
\newcommand\settheme[2]{\colorlet{theme}{#1}\colorlet{themelight}{#2}}
\settheme{rose}{blush}
\def\grandpaname{Grandpa}\def\handname{hand}

% ---------- page background: soft blobs, stars, heart page number ----------
\pagestyle{empty}
\AddToHook{shipout/background}{\ifnum\value{page}>1
  \put(0,0){\begin{tikzpicture}[overlay,x=1mm,y=1mm]
    \fill[themelight,opacity=.55] (0,0) circle (28);
    \fill[themelight,opacity=.35] (22,-6) circle (12);
    \fill[themelight,opacity=.55] (210,-297) circle (32);
    \fill[themelight,opacity=.35] (186,-291) circle (13);
    \foreach \x/\y/\s in {196/-10/1.6, 203/-22/1, 8/-285/1.4, 18/-291/.9}
      \node[text=theme!45,scale=\s] at (\x,\y) {\faStar};
    \node[text=theme,scale=2.1] at (105,-284) {\faHeart};
    \node[text=white,font=\scriptsize\bfseries] at (105,-284.3) {\thepage};
  \end{tikzpicture}}\fi}

% ---------- building blocks ----------
% page title ribbon (also a TOC entry)
\newcommand\pagetitle[2][\faStar]{\clearpage\phantomsection
  \addcontentsline{toc}{section}{#2}%
  \begin{center}\begin{tikzpicture}
    \node[fill=theme,text=white,rounded corners=14pt,inner xsep=18pt,inner ysep=9pt,
          font=\headfont\LARGE] (t) {#1\enspace #2};
    \node[text=theme!50,left=3mm of t] {\faHeart};
    \node[text=theme!50,right=3mm of t] {\faHeart};
  \end{tikzpicture}\end{center}\vspace{-2mm}}
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
    \begin{scope}\clip[rounded corners=8pt] (0,0) rectangle (#2,#3);
      \node[inner sep=0] at (c) {\bb@cover{#2}{#3}};\end{scope}
    \draw[theme,line width=1pt,rounded corners=8pt] (0,0) rectangle (#2,#3);}
   {\draw[theme,dashed,line width=1pt,rounded corners=8pt,fill=themelight!30] (0,0) rectangle (#2,#3);
    \node[text=theme!55,font=\Huge] at (c) {\faCamera};}
  \node[below,font=\small\itshape,text=ink] at ($(0,0)!.5!(#2,0)$) {#4};
  \end{tikzpicture}}

% rounded card with boxed title
\newtcolorbox{card}[2][]{enhanced,colback=white,colframe=theme,boxrule=.9pt,arc=4mm,
  fonttitle=\headfont\large,coltitle=white,colbacktitle=theme,
  attach boxed title to top left={xshift=4mm,yshift=-3mm},
  boxed title style={arc=3mm,boxrule=0pt},top=5mm,title={#2},#1}
% \notecard[opts]{title}{lines}{key}
\newcommand\notecard[4][]{\begin{card}[#1]{#2}\vspace{-3mm}\writelines{#3}{#4}\end{card}}

% raster tiles (plain boxes inside tcbraster)
\newcommand\tile[1]{\begin{tcolorbox}#1\end{tcolorbox}}
% icon tile for rasters: {icon}{label}{content}
\newcommand\icontile[3]{\tile{\centering{\color{theme}\huge #1}\par\smallskip
  {\headfont #2}\par\raggedright\vspace{3mm}#3\par}}
\tcbset{tiles/.style={raster equal height,colback=white,colframe=theme!70,arc=3mm,boxrule=.8pt,
  raster column skip=3mm,raster row skip=3mm}}
\newcommand\chk{{\color{theme}\faSquare[regular]}\ }
\newcommand\chkyes{{\color{theme}\faCheckSquare}\ }

% section divider page: {n}{title}{subtitle}{theme}{light}{icons}
\newcommand\bookpart[6]{\clearpage\settheme{#4}{#5}%
  \phantomsection{\let\\\space\addcontentsline{toc}{chapter}{#1\quad #2}}%
  \begin{tikzpicture}[remember picture,overlay]
    \fill[themelight] (current page.south west) rectangle (current page.north east);
    \foreach \x/\y/\r in {.15/.85/3, .85/.78/2, .2/.2/2.5, .8/.15/3.5, .5/.95/1.2}
      \fill[white,opacity=.5] ($(current page.south west)+(\x*21cm,\y*29.7cm)$) circle (\r);
    \node[circle,fill=theme,text=white,minimum size=3.2cm,font=\headfont\fontsize{60}{60}\selectfont]
      (n) at ($(current page.center)+(0,5.5)$) {#1};
    \node[font=\headfont\fontsize{36}{40}\selectfont,text=theme,below=10mm of n,align=center] (t) {#2};
    \node[font=\Large\itshape,text=ink,below=5mm of t,align=center,text width=14cm] (s) {#3};
    \node[below=14mm of s,text=theme,font=\fontsize{44}{44}\selectfont] {#6};
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
