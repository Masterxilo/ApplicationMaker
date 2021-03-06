(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* :Title: ApplicationMaker *) 
(* :Author: jmlopez *)
(* :Email: jmlopez.rod@gmail.com *)
(* :Summary: Package provides functions to create directory tree and to export
			 the application. *)
(* :Context: ApplicationMaker`ApplicationMaker` *)
(* :Package version: 1.0 *)
(* :History:  Version 1.0 July 09 2011
 fix as suggested by oca by Paul Frischknecht August 08 2016 *)
(* :Mathematica version: 8.0 for Mac OS X x86 (64-bit) (February 23, 2011) *)
(* :Discussion: The function NewApplication creates a directory tree at a
				specified location for a new application. The DeployApplication
				takes all the m files and documentation notebooks in the
				application and puts them in an specified location for 
				distribution. *)


BeginPackage["ApplicationMaker`ApplicationMaker`"];


Unprotect[NewApplication, BuildApplication, DeployApplication];
ClearAll[NewApplication, BuildApplication, DeployApplication];


(* :Usage Messages: *)


NewApplication::usage = 
"NewApplication[\!\(\*
StyleBox[\"appName\", \"TI\"]\)] creates a directory named \!\(\*
StyleBox[\"appName\", \"TI\"]\) in \!\(\*
StyleBox[\"$UserBaseDirectory\", \"Program\"]\)\!\(\*
StyleBox[\"/\", \"Program\"]\)\!\(\*
StyleBox[\"Applications\", \"Program\"]\)\!\(\*
StyleBox[\"/\", \"Program\"]\) and subdirectories required to make an application with documentation.";
BuildApplication::usage =
"BuildApplication[\!\(\*
StyleBox[\"appName\", \"TI\"]\)] creates the documentation files and the index for the documentation center.";
DeployApplication::usage =
"DeployApplication[\!\(\*
StyleBox[\"appName\", \"TI\"]\), \!\(\*
StyleBox[\"destDir\", \"TI\"]\)] copies the m files and documentation of your application into \!\(\*
StyleBox[\"destDir\", \"TI\"]\)";


(* :Error Messages: *)


NewApplication::argerr =
"String specifying the application name was expected.";
BuildApplication::argerr =
"String specifying the application name was expected.";
BuildApplication::nodir =
"There is no application `1` in `2`. To create a new application use NewApplication";
DeployApplication::argerr =
"Strings specifying the application name and the destination were expected.";
DeployApplication::nodir =
"There is no application `1` in `2`. To create a new application use NewApplication";


Begin["`Private`"];


NewApplication[args___] := (Message[NewApplication::argerr];$Failed)
MakeDirectory[root_, start_,main_, sub_] := Module[
{nm, ns, tmp},
nm = Position[main, start];
If[Length@nm != 0, nm=nm[[1,1]]];
If[Length@sub[[nm]] !=0,
Do[
tmp=If[StringLength[root]!=0,FileNameJoin[{root,start,sub[[nm,i]]}],FileNameJoin[{start,sub[[nm,i]]}]];
If[DirectoryQ[tmp], 
Print[Style["Existing Directory : ", "MSG", Gray],Style[tmp, "MSG", Bold]], 
CreateDirectory[tmp];
Print[Style["Directory Created  : ", "MSG", Blue],Style[tmp, "MSG", Bold]]
];
,{i,Length@sub[[nm]]}]
];
Do[
MakeDirectory[FileNameJoin[{root,start}], sub[[nm,i]], main, sub],
{i,Length@sub[[nm]]}
]
]
NewApplication[
appName_String, 
appDir_String:FileNameJoin[{ $UserBaseDirectory,"Applications"}]
]:= Module[
{appNameDir, main, sub},
appNameDir =  FileNameJoin[{appDir, appName}];
If[DirectoryQ[appNameDir],
Print[Style["Existing Directory : ", "MSG", Gray],Style[appNameDir, "MSG", Bold]],
CreateDirectory[appNameDir]; 
Print[Style["Directory Created  : ", "MSG", Blue],Style[appNameDir, "MSG", Bold]]
];
main = {appNameDir, "Documentation", "Kernel", "English", "ReferencePages"};
sub = {
{"Documentation", "Kernel"}, 
{"English"}, 
{}, 
{"Guides", "ReferencePages", "Tutorials"}, 
{"Symbols"}
};
MakeDirectory["", appNameDir, main, sub];
]


ChangeNotebookSettings[path_, index_,  header_, footer_]:= Module[{nb, newpath, winTitle},
nb=NotebookOpen[path];
winTitle =Options[nb, WindowTitle][[1]][[2]];
newpath = FileNameJoin[{DirectoryName[path], StringDrop[FileNameTake[path], 3]}];
NotebookSave[nb, newpath];
SetOptions[nb,
Saveable->False,
StyleDefinitions->FrontEnd`FileName[{"Wolfram"},"Reference.nb"],
DockedCells->FEPrivate`FrontEndResource["FEExpressions","HelpViewerToolbar"],
PageFooters->{
{None,None,None},
{Cell[TextData[{footer}],"PageFooter"],None,None}
},
PageHeaders->{
{None,None,None},{None,None,Cell[TextData[{Cell[TextData[{header}],"PageHeader"],Cell[TextData[{CounterBox["Page"]}],"PageNumber"]}],CellMargins->{{Inherited,-29},{Inherited,Inherited}}]}
},
WindowTitle-> winTitle
];
NotebookSave[nb];
NotebookClose[nb];
DocumentationSearch`AddDocumentationNotebook[index, newpath];
Return[StringDrop[FileBaseName[path],3]];
]


BuildApplication[args___] := (Message[BuildApplication::argerr];$Failed)
BuildApplication[
appName_String,
version_String: "0.0.1",
header_String: "", footer_String: "",
appDir_String: FileNameJoin[{ $UserBaseDirectory,"Applications"}]
] := Module[
{appNameDir, indexDir, tmpPath, files, pacFile, pkg, index, str},
appNameDir =  FileNameJoin[{appDir, appName}];
indexDir = FileNameJoin[{appNameDir,"Documentation", "English", "Index" }];
If[!DirectoryQ[appNameDir], Message[BuildApplication::nodir, appName, appDir]; Return[$Failed]];
If[FileNames[indexDir]!={},DeleteDirectory[indexDir,DeleteContents->True]];
index=DocumentationSearch`NewDocumentationNotebookIndexer[indexDir];
pacFile = OpenWrite[FileNameJoin[{appNameDir, "PacletInfo.m"}]];
WriteString[pacFile, "Paclet[
	Name -> \""<>appName<>"\",
	Version -> \""<>version<>"\",
	MathematicaVersion -> \"8+\",
	Extensions -> {
		{
			\"Kernel\",
			\"Context\" -> {\n"];
pkg = Map[FileBaseName, FileNames[appNameDir<>"/*.nb"]];
Do[
WriteString[pacFile, "\t\t\t\t\""<>appName<>"`"<>pkg[[i]]<>"`\",\n"];
,{i, Length@pkg-1}];
If[Length@pkg > 0,
WriteString[pacFile, "\t\t\t\t\""<>appName<>"`"<>pkg[[-1]]<>"`\"\n"]
];
WriteString[pacFile, "\t\t\t}
		},
		{
			\"Documentation\",
			Language -> \"English\",
			LinkBase -> \""<>appName<>"\",
			Resources -> {\n"];
(* :GUIDES: *)
files = FileNames[FileNameJoin[{appNameDir,"Documentation","English","Guides","___*"}]];
Do[
str = ChangeNotebookSettings[files[[i]], index, header, footer];
Print[
Style["Adding Guide : ", "MSG", Gray],
Style[StringDrop[ FileBaseName[files[[i]]],3], "MSG", Bold]
];
WriteString[pacFile, "\t\t\t\t\""<>FileNameJoin[{"Guides",str}]<>"\",\n"];
,{i, Length@files}];
(* :TUTORIALS: *)
files = FileNames[FileNameJoin[{appNameDir,"Documentation","English","Tutorials","___*"}]];
Do[
str = ChangeNotebookSettings[files[[i]], index, header, footer];
Print[
Style["Adding Tutorial : ", "MSG", Gray],
Style[StringDrop[ FileBaseName[files[[i]]],3], "MSG", Bold]
];
WriteString[pacFile, "\t\t\t\t\""<>FileNameJoin[{"Tutorials",str}]<>"\",\n"];
,{i, Length@files}];
(* :REFERENCES: *)
files = FileNames[FileNameJoin[
{appNameDir,"Documentation","English","ReferencePages","Symbols","___*"}
]];
Do[
str = ChangeNotebookSettings[files[[i]], index, header, footer];
Print[
Style["Adding Reference : ", "MSG", Gray],
Style[StringDrop[ FileBaseName[files[[i]]],3], "MSG", Bold]
];
WriteString[pacFile, "\t\t\t\t\""<>FileNameJoin[{"ReferencePages","Symbols",str}]<>"\",\n"];
,{i, Length@files-1}];
str = ChangeNotebookSettings[files[[-1]], index, header, footer];
Print[
Style["Adding Reference : ", "MSG", Gray],
Style[StringDrop[ FileBaseName[files[[-1]]],3], "MSG", Bold]
];
WriteString[pacFile, "\t\t\t\t\""<>FileNameJoin[{"ReferencePages","Symbols",str}]<>"\"\n"];
WriteString[pacFile, "\t\t\t}
		}
	}
]\n"];
Close[pacFile];
DocumentationSearch`CloseDocumentationNotebookIndexer[index];
PacletManager`RestartPacletManager[];
]


DeployApplication[args___] := (Message[DeployApplication::argerr];$Failed)
DeployApplication[
appName_String,
destDir_String,
appDir_String: FileNameJoin[{ $UserBaseDirectory,"Applications"}]
] := Module[
{appNameDir, files},
appNameDir =  FileNameJoin[{appDir, appName}];
If[!DirectoryQ[appNameDir], Message[BuildApplication::nodir, appName, appDir]; Return[$Failed]];
If[MatchQ[CopyDirectory[appNameDir, FileNameJoin[{destDir,appName}]], $Failed],Return[$Failed]];
DeleteFile[FileNames@FileNameJoin[{destDir,appName, "*.nb"}]];
DeleteFile[FileNames@FileNameJoin[{destDir,appName, "Documentation", "English", "ReferencePages","Symbols", "___*.nb"}]];
DeleteFile[FileNames@FileNameJoin[{destDir,appName, "Documentation", "English", "Guides", "___*.nb"}]];
DeleteFile[FileNames@FileNameJoin[{destDir,appName, "Documentation", "English", "Tutorials", "___*.nb"}]];
Print[
Style["The application ", "MSG"], 
Style[appName, "MSG", Bold], 
Style[" has been deployed to ", "MSG"], 
Style[FileNameJoin[{destDir,appName}], "MSG", Bold]
];
]


End[];


Protect[NewApplication, BuildApplication, DeployApplication];


EndPackage[];
