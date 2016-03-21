%{
#include  "proj2.h"
#include  <stdio.h>

  tree type_record, type_method, argtype, bractemp, type_tree; /* globals used to store treenode pointers */

%}

%token <intg>  PROGRAMnum IDnum SEMInum CLASSnum  DECLARATIONSnum  ENDDECLARATIONSnum
%token <intg>  COMMAnum EQUALnum LBRACEnum RBRACEnum LBRACnum RBRACnum LPARENnum RPARENnum VOIDnum
%token <intg>  INTnum METHODnum VALnum DOTnum ASSGNnum RETURNnum IFnum ELSEnum WHILEnum
%token <intg>  LTnum LEnum EQnum NEnum GEnum GTnum PLUSnum MINUSnum ORnum TIMESnum DIVIDEnum ANDnum
%token <intg>  NOTnum ICONSTnum SCONSTnum

%type  <tptr>  MethodDecl_List FieldDecl_List Formal_Parameter_List

%type  <tptr>  Formal_Parameter_rec Formal_Parameter_List Formal_Parameter Formal_Parameter_List_rec
%type  <tptr>  Statement StatementList StatementList_rec Formal_Parameter_rec ParameterList
%type  <tptr>  FieldDecl_Id ArrayInitializer_rec ArrayCreationExpression_rec ArrayExpression
%type  <tptr>  Field Field_rec Index Index_rec Term_Op Term_Op_rec SimpleExpression_Op SimpleExpression_Op_rec Type_rec

%type  <tptr>  Program ClassDecl_rec ClassDecl ClassBody MethodDecl_z1 MethodDecl_rec Decls
%type  <tptr>  FieldDecl_rec FieldDecl Tail FieldDecl_body VariableDeclId Bracket_rec1 Bracket_rec2
%type  <tptr>  VariableInitializer ArrayInitializer ArrayInitializer_body  ArrayCreationExpression
%type  <tptr>  ArrayCreationExpression_tail MethodDecl FormalParameterList_z1 FormalParameterList
%type  <tptr>  FormalParameterList_rec IDENTIFIER_rec Block Type Type_front 
%type  <tptr>  StatementList Statement_rec Statement AssignmentStatement MethodCallStatement
%type  <tptr>  MethodCallStatement_tail Expression_rec ReturnStatement IfStatement If_rec WhileStatement
%type  <tptr>  Expression Comp_op SimpleExpression Term Factor Expression_rec2
%type  <tptr>  UnsignedConstant Variable Variable_tail Variable_rec Variable_1 


%%/* yacc specification*/
Program         :      PROGRAMnum IDnum SEMInum ClassDecl_rec
                       {  
                         $$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2)); 
                         printtree($$, 0);
                       }
                ;
ClassDecl_rec   :      ClassDecl                       
                          {  $$ = MakeTree(ClassOp, NullExp(), $1); } 
                |      ClassDecl_rec ClassDecl
			  {  $$ = MakeTree(ClassOp, $1, $2); }
                ;
ClassDecl 	:	CLASSnum IDnum ClassBody
			{
				$$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2));
			} 
		;
ClassBody	:	LBRACEnum MethodDecl_List RBRACEnum
			{
				$$ = $2;
			}
		;
MethodDecl_List	:	MethodDecl_z1
			{
				$$ = $1;
			}
		|	MethodDecl_List MethodDecl
			{
				$$ = MakeTree(BodyOp, $1, $2);
			}
		;
MethodDecl_z1	:	/* Epsilon */
			{
				$$ = NullExp();
			}
		|	Decls
			{
				$$ = $1;
			}
		|	MethodDecl
			{
				$$ = MakeTree(BodyOp, NullExp(), $1);
			}
		|	Decls MethodDecl
			{
				$$ = MakeTree(BodyOp, $1, $2);
			}
		;
MethodDecl	:	METHODnum Type IDnum LPARENnum Formal_Parameter_List RPARENnum Block
			{
				tree headOp = MakeTree(HeadOp, MakeLeaf(IDNode, $3), $5);
				$$ = MakeTree(MethodOp, headOp, $7);
			}
		/* This is a way to handle void (Setting the global type pointer in the RHS semantic action) This is done rather than including 
		   Void as a type so that void cannot be used as the type for field declarations */
		|	METHODnum VOIDnum {type_tree = NullExp();} IDnum LPARENnum Formal_Parameter_List RPARENnum Block
			{
				tree headOp = MakeTree(HeadOp, MakeLeaf(IDNode, $4), $6);
				$$ = MakeTree(MethodOp, headOp, $8);
			}
		;
/* This currently creates a tree that looks tree given in the notes */
/* TODO: Make a note in the README */
Type		:	IDnum Type_rec
			{
				$$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
			}
		|	INTnum Type_rec
			{
				$$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, $1), $2);
			}
		|	IDnum Type_rec DOTnum Type
			{
				tree typeTree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
				/* This code creates a tree that looks like the assignment pdf */			
				tree fieldTree = MakeTree(FieldOp, $4, NullExp());
				$$ = type_tree = MkRightC(fieldTree, typeTree); 
				/* This code creates a tree that looks like the example parser */
				//$$ = type_tree = MkRightC($4, typeTree);
			}
		|	INTnum Type_rec DOTnum Type
			{
				tree typeTree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, $1), $2);
				/* This code creates a tree that looks like the assignment pdf */
				tree fieldTree = MakeTree(FieldOp, $4, NullExp());
				$$ = type_tree = MkRightC(fieldTree, typeTree);
				/* This code creates a tree that looks like the example parser */
				//$$ = type_tree = MkRightC($4, typeTree);
			}
		;
Type_rec	:	/* Epsilon */
			{
				$$ = type_tree = NullExp();
			}
		|	LBRACnum RBRACnum
			{
				$$ = type_tree = MakeTree(IndexOp, NullExp(), NullExp());
			}
		|	Type_rec LBRACnum RBRACnum
			{
				$$ = type_tree = MakeTree(IndexOp, NullExp(), $1);
			}
		;
Formal_Parameter_List :	/* Epsilon */
			{
				$$ = MakeTree(SpecOp, NullExp(), type_tree);
			}
		|	Formal_Parameter_List_rec
			{
				$$ = MakeTree(SpecOp, $1, type_tree);
			}
		;
Formal_Parameter_List_rec:	Formal_Parameter
			{
				$$ = $1;
			}
		|	Formal_Parameter SEMInum Formal_Parameter_List_rec
			{
				$$ = MkRightC($3, $1);
			}
		;	
Formal_Parameter:	VALnum INTnum Formal_Parameter_rec
			{
				$$ = MakeVal($3);
			}		
		|	INTnum Formal_Parameter_rec
			{
				$$ = $2;
			}
		;
Formal_Parameter_rec:	IDnum 	
			{
				tree idTree = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0));
				$$ = MakeTree(RArgTypeOp, idTree, NullExp());
			}
		|	IDnum COMMAnum Formal_Parameter_rec
			{
				tree idTree = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0));
				tree formalParameter = MakeTree(RArgTypeOp, idTree, NullExp());
				$$ = MkRightC($3, formalParameter);
			}
		;
Block		:	StatementList
			{
				$$ = MakeTree(BodyOp, NullExp(), $1);
			}
		|	Decls StatementList
			{
				$$ = MakeTree(BodyOp, $1, $2);
			}
		;
StatementList	:	LBRACEnum StatementList_rec RBRACEnum
			{
				$$ = $2;
			}
		;
StatementList_rec:	Statement
			{	
				$$ = MakeTree(StmtOp, NullExp(), $1);
			}
		|	StatementList_rec SEMInum Statement
			{	
				if ($3 == NullExp()) {
					$$ = $1;
				} else { 
					$$ = MakeTree(StmtOp, $1, $3);
				}
			}
		;
Statement	:	/* Epsilon */
			{
				$$ = NullExp();
			}	
		|	AssignmentStatement
			{
				$$ = $1;
			}
		|	MethodCallStatement
			{
				$$ = $1;
			}
		|	ReturnStatement
			{
				$$ = $1;
			}
		|	IfStatement 
			{
				$$ = $1;
			}
		|	WhileStatement 
			{
				$$ = $1;
			}
		;
Decls		:	DECLARATIONSnum FieldDecl_List ENDDECLARATIONSnum
			{
				$$ = $2;
			}  
		;
/* TODO: Make a note of this in the README */
FieldDecl_List	/* This Epsilon rule makes a dummy node of there are no Decls like the trees in the assignment */
		:	/* Epsilon */
			{
				$$ = NullExp();
			}
		/* This Epsilon rule makes a body node with two dummy nodes like the example parser 
		: 	Epsilon 	
			{
				$$ = MakeTree(BodyOp, NullExp(), NullExp());
			} */
		|	FieldDecl
			{
				$$ = MakeTree(BodyOp, NullExp(), $1);
			}
		|	FieldDecl_List FieldDecl
			{
				$$ = MakeTree(BodyOp, $1, $2);
			}
		;
FieldDecl	:	Type FieldDecl_rec SEMInum
			{
				$$ = $2;
			}
		;
FieldDecl_rec	:	FieldDecl_Id
			{
				$$ = MakeTree(DeclOp, NullExp(), $1);
			}
		|	FieldDecl_rec COMMAnum FieldDecl_Id
			{
				$$ = MakeTree(DeclOp, $1, $3);
			}
		;
FieldDecl_Id	:	VariableDeclId
			{
				tree commaTree = MakeTree(CommaOp, type_tree, NullExp());
				$$ = MakeTree(CommaOp, $1, commaTree);
			}
		|	VariableDeclId EQUALnum VariableInitializer
			{
				tree commaTree = MakeTree(CommaOp, type_tree, $3);
				$$ = MakeTree(CommaOp, $1, commaTree);
			}
		;
VariableDeclId	:	IDnum
			{
				$$ = MakeLeaf(IDNode, $1);
			}
		|	IDnum BracketLoop
			{
				$$ = MakeLeaf(IDNode, $1);
			}
		;
BracketLoop	:	LBRACnum RBRACnum
		|	BracketLoop LBRACnum RBRACnum
		;
VariableInitializer:	Expression
			{
				$$ = $1;
			}
		|	ArrayInitializer
			{
				$$ = $1;
			}
		|	ArrayCreationExpression
			{
				$$ = $1;
			}		
		;
ArrayInitializer:	LBRACEnum ArrayInitializer_rec RBRACEnum
			{
				$$ = MakeTree(ArrayTypeOp, $2, type_tree);
			}
		;
ArrayInitializer_rec:	Expression
			{
				$$ = MakeTree(CommaOp, NullExp(), $1);
			}
		|	ArrayInitializer_rec COMMAnum Expression
			{
				$$ = MakeTree(CommaOp, $1, $3);
			}
		;
ArrayCreationExpression:INTnum ArrayCreationExpression_rec
			{
				$$ = MakeTree(ArrayTypeOp, $2, type_tree);
			}
		;
ArrayCreationExpression_rec:ArrayExpression
			{
				$$ = MakeTree(BoundOp, NullExp(), $1);
			}
		|	ArrayCreationExpression_rec ArrayExpression
			{
				$$ = MakeTree(BoundOp, $1, $2);
			}
		;
ArrayExpression	:	LBRACnum Expression RBRACnum
			{
				$$ = $2;
			}
		;
AssignmentStatement:	Variable ASSGNnum Expression
			{
				tree assignOp = MakeTree(AssignOp, NullExp(), $1);
				$$ = MakeTree(AssignOp, assignOp, $3);
			}
		;
MethodCallStatement:	Variable LPARENnum ParameterList RPARENnum
			{
				$$ = MakeTree(RoutineCallOp, $1, $3);
			}
		;
ParameterList	:	/* Epsilon */
			{
				$$ = NullExp();
			}
		|	Expression
			{
				$$ = MakeTree(CommaOp, $1, NullExp());
			}
		|	Expression COMMAnum ParameterList
			{
				$$ = MakeTree(CommaOp, $1, $3);
			}
		;
ReturnStatement	:	RETURNnum
			{
				$$ = MakeTree(ReturnOp, NullExp(), NullExp());
			}
		|	RETURNnum Expression
			{
				$$ = MakeTree(ReturnOp, $2, NullExp());
			}
		;
IfStatement	:	IFnum Expression StatementList
			{
				tree commaTree = MakeTree(CommaOp, $2, $3);
				$$ = MakeTree(IfElseOp, NullExp(), commaTree);
			}
		|	IFnum Expression StatementList ELSEnum StatementList
			{
				tree commaTree = MakeTree(CommaOp, $2, $3);
				tree ifTree = MakeTree(IfElseOp, NullExp(), commaTree);
				$$ = MakeTree(IfElseOp, ifTree, $5);	
			}
		;
WhileStatement	:	WHILEnum Expression StatementList
			{
				$$ = MakeTree(LoopOp, $2, $3);
			}
		;
Expression	:	SimpleExpression
			{
				$$ = $1;
			}
		|	SimpleExpression LTnum SimpleExpression
			{
				$$ = MakeTree(LTOp, $1, $3);
			}
		|	SimpleExpression LEnum SimpleExpression
			{
				$$ = MakeTree(LEOp, $1, $3);
			}
		|	SimpleExpression EQnum SimpleExpression
			{
				$$ = MakeTree(EQOp, $1, $3);
			}
		|	SimpleExpression NEnum SimpleExpression
			{
				$$ = MakeTree(NEOp, $1, $3);
			}
		|	SimpleExpression GEnum SimpleExpression
			{
				$$ = MakeTree(GEOp, $1, $3);
			}
		|	SimpleExpression GTnum SimpleExpression
			{
				$$ = MakeTree(GTOp, $1, $3);
			}
		;
Factor		:	UnsignedConstant
			{
				$$ = $1;
			}
		|	Variable
			{
				$$ = $1;
			}
		|	MethodCallStatement
			{
				$$ = $1;
			}
		|	LPARENnum Expression RPARENnum
			{
				$$ = $2;
			}
		|	NOTnum Factor
			{
				$$ = MakeTree(NotOp, $2, NullExp());
			}
		;
UnsignedConstant:	ICONSTnum
			{
				$$ = MakeLeaf(NUMNode, $1);
			}
		|	SCONSTnum
			{
				$$ = MakeLeaf(STRINGNode, $1);
			}
		;
SimpleExpression:	Term SimpleExpression_Op_rec
			{
				if ($2 == NullExp()) {
					$$ = $1;
				} else {
					$$ = MkLeftC($1, $2);
				}
			}
		|	PLUSnum Term SimpleExpression_Op_rec
			{
				if ($3 == NullExp()) {
					$$ = $2;
				} else {
					$$ = MkLeftC($2, $3);
				}
			}
		|	MINUSnum Term SimpleExpression_Op_rec
			{
				tree neg = MakeTree(UnaryNegOp, $2, NullExp());
				if ($3 == NullExp()) {
					$$ = neg;
				} else {
					$$ = MkLeftC(neg, $3);
				}
			}
		;
SimpleExpression_Op_rec:/* Epsilon */
			{
				$$ = NullExp();
			}
		|	SimpleExpression_Op SimpleExpression_Op_rec
			{
				if ($2 == NullExp()) {
					$$ = $1;
				} else {
					$$ = MkLeftC($1, $2);
				}
			}	
		;
SimpleExpression_Op:	PLUSnum Term
			{
				$$ = MakeTree(AddOp, NullExp(), $2);
			}
		|	MINUSnum Term
			{
				$$ = MakeTree(SubOp, NullExp(), $2);
			}
		|	ORnum Term
			{
				$$ = MakeTree(OrOp, NullExp(), $2);
			}
		;
Term		:	Factor Term_Op_rec
			{
				if ($2 == NullExp()) {
					$$ = $1;
				} else {
					$$ = MkLeftC($1, $2);
				}
			}
		;
Term_Op_rec	:	/* Epsilon */
			{
				$$ = NullExp();
			}
		|	Term_Op Term_Op_rec
			{
				if ($2 == NullExp()) {
					$$ = $1;
				} else {
					$$ = MkLeftC($1, $2);
				}
			}
		;
Term_Op		:	TIMESnum Factor
			{
				$$ = MakeTree(MultOp, NullExp(), $2);
			}
		|	DIVIDEnum Factor
			{
				$$ = MakeTree(DivOp, NullExp(), $2);
			}
		|	ANDnum Factor
			{
				$$ = MakeTree(AndOp, NullExp(), $2);
			}
		;
Variable	:	IDnum Variable_rec
			{
				$$ = MakeTree(VarOp, MakeLeaf(IDNode, $1), $2);
			}
		;	
Variable_rec	:	/* Epsilon */
			{
				$$ = NullExp();
			}
		|	Index Variable_rec
			{
				$$ = MakeTree(SelectOp, $1, $2);
			}
		|	Field Variable_rec
			{
				$$ = MakeTree(SelectOp, $1, $2);
			}
		;
Field		:	DOTnum IDnum
			{
				$$ = MakeTree(FieldOp, MakeLeaf(IDNode, $2), NullExp());
			}
		;
Index		:	LBRACnum Index_rec RBRACnum
			{
				$$ = $2;
			}
		;
Index_rec	:	Expression
			{
				$$ = MakeTree(IndexOp, $1, NullExp());
			}
		|	Expression COMMAnum Index_rec
			{
				$$ = MakeTree(IndexOp, $1, $3);
			}
		;
%%

int yycolumn, yyline;

FILE *treelst;

main()
{
  treelst = stdout;
  yyparse();
}

yyerror(char *str)
{
  printf("yyerror: %s at line %d\n", str, yyline);
}

#include "lex.yy.c"

