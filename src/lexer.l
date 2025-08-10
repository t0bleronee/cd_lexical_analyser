%{
#include <cstdio>
#include <string>
using namespace std;

int lexical_error = 0;
int line_num = 1;    // Start at line 1
int col_num = 1;     // Start at column 1
// This macro runs before any action for a rule
#define YY_USER_ACTION \
    { \
        int i; \
        for (i = 0; yytext[i] != '\0'; i++) { \
            if (yytext[i] == '\n') { \
                line_num++; \
                col_num = 1; \
            } else { \
                col_num++; \
            } \
        } \
    }

%}

%option noyywrap


WHITESPACE  [ \t\r\n]+

MULTI_LINE_COMMENT   "/*"([^*]|\*+[^*/])*"\*/"
SINGLE_LINE_COMMENT   "//"[^\n]*

/* Common whitespace before and after # */
PP_PREFIX        ^[ \t]*#[ \t]*

/* Identifier for macro names */
PP_IDENTIFIER    [a-zA-Z_][a-zA-Z0-9_]*

/* Preprocessor categories */
PP_DEFINE        {PP_PREFIX}define[ \t]+{PP_IDENTIFIER}([ \t]+.*)?$
PP_UNDEF         {PP_PREFIX}undef[ \t]+{PP_IDENTIFIER}[ \t]*$
PP_IF            {PP_PREFIX}if[ \t]+.*$
PP_ELIF          {PP_PREFIX}elif[ \t]+.*$
PP_ELSE          {PP_PREFIX}else[ \t]*$
PP_ENDIF         {PP_PREFIX}endif[ \t]*$
PP_IFDEF         {PP_PREFIX}ifdef[ \t]+{PP_IDENTIFIER}[ \t]*$
PP_IFNDEF        {PP_PREFIX}ifndef[ \t]+{PP_IDENTIFIER}[ \t]*$
PP_ERROR         {PP_PREFIX}error[ \t]+.*$
PP_WARNING       {PP_PREFIX}warning[ \t]+.*$
PP_PRAGMA        {PP_PREFIX}pragma[ \t]+.*$
PP_INCLUDE       {PP_PREFIX}include[ \t]*([<"][^>"]+[>"])

STRING_LITERAL      \"([^\\\"\n]|(\\.))*\"
ESCAPE_HEX    \\x[0-9a-fA-F]+
ESCAPE_OCT    \\[0-7]{1,3}
ESCAPE_CHAR   \\[abfnrtv\'\"\\?] 
ESCAPE_UNICODE  \\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8}
CHAR_PREFIX    (u|U|L)?
CHAR_CONTENT  ({ESCAPE_HEX}|{ESCAPE_OCT}|{ESCAPE_CHAR}|{ESCAPE_UNICODE}|[^\\\'\n])
CHAR_LITERAL   {CHAR_PREFIX}\'({CHAR_CONTENT})\'


KEYWORD    (int|float|double|char|bool|void|short|long|signed|unsigned|if|else|switch|case|default|for|while|do|break|continue|return|goto|auto|static|class|struct|union|enum|template|typename|this|namespace|friend|virtual|override|explicit|inline|try|catch|throw|const|sizeof|typedef|typeid|new|delete|nullptr|constexpr|std|array|vector)

ALTERNATIVE_OPERATOR  (and|or|not|xor|bitand|bitor|compl|and_eq|or_eq|xor_eq|not_eq)

BOOL_LITERAL (true|false|TRUE|FALSE)

/* Identifiers: letter or underscore followed by letters, digits, or underscores */
IDENTIFIER  [a-zA-Z_][a-zA-Z0-9_]*


HEXADECIMAL_FLOAT_LITERAL  0[xX]([0-9a-fA-F]+\.[0-9a-fA-F]*|\.[0-9a-fA-F]+|[0-9a-fA-F]+)[pP][+-]?[0-9]+([fFlL])?


HEXADECIMAL_INT_LITERAL 0[xX][0-9a-fA-F]+((u|U)(ll|LL|l|L)?|(ll|LL|l|L)(u|U)?)?

OCTAL_INT_LITERAL 0[0-7]+((u|U)(ll|LL|l|L)?|(ll|LL|l|L)(u|U)?)?  

BINARY_INT_LITERAL 0[bB][01]+((u|U)(ll|LL|l|L)?|(ll|LL|l|L)(u|U)?)? 


/* Numbers: integers, floats (with optional decimal and exponent), and hex */
FLOAT_LITERAL          (((?:0|[1-9][0-9]*)\.[0-9]*([eE][+-]?[0-9]+)?)|((?:0|[1-9][0-9]*)?\.[0-9]+([eE][+-]?[0-9]+)?)|((0|[1-9][0-9]*)([eE][+-]?[0-9]+)))([lLfF])?
INTEGER_LITERAL        (0|([1-9][0-9]*))((u|U)(ll|LL|l|L)?|(ll|LL|l|L)(u|U)?)?

/* Operators: multi-character and single-character operators with proper alternation */
OPERATOR    (\+\+|--|\+=|-=|\/=|%=|<<=|>>=|==|!=|>=|<=|&&|\|\||<<|>>|&=|\|=|\^=|\+|-|\*|\/|%|>|<|=|&|\||\^|~|!|\?|:)

/* Punctuation: includes ..., ::, and . */
PUNCTUATION (\.\.\.|::|\.)

/* Delimiters: single characters like parentheses, brackets, braces, commas, semicolons */
DELIMITER   [()\[\]{},;]




%%
{WHITESPACE}    { /* Skip whitespace */ }
{MULTI_LINE_COMMENT} { printf("%s\tmulti line comment\n", yytext); }
{SINGLE_LINE_COMMENT} { printf("%s\tsingle line comment\n", yytext); }
{PP_DEFINE}      { printf("%s\tpreprocessor_define\n", yytext); }
{PP_UNDEF}       { printf("%s\tpreprocessor_undef\n", yytext); }
{PP_IF}          { printf("%s\tpreprocessor_if\n", yytext); }
{PP_ELIF}        { printf("%s\tpreprocessor_elif\n", yytext); }
{PP_ELSE}        { printf("%s\tpreprocessor_else\n", yytext); }
{PP_ENDIF}       { printf("%s\tpreprocessor_endif\n", yytext); }
{PP_IFDEF}       { printf("%s\tpreprocessor_ifdef\n", yytext); }
{PP_IFNDEF}      { printf("%s\tpreprocessor_ifndef\n", yytext); }
{PP_ERROR}       { printf("%s\tpreprocessor_error\n", yytext); }
{PP_WARNING}     { printf("%s\tpreprocessor_warning\n", yytext); }
{PP_PRAGMA}      { printf("%s\tpreprocessor_pragma\n", yytext); }
{PP_INCLUDE}     { printf("%s\tpreprocessor_include\n", yytext); }
{STRING_LITERAL}    { printf("%s\tstring_literal\n", yytext); }
{CHAR_LITERAL}      { printf("%s\tchar_literal\n", yytext); }
{ALTERNATIVE_OPERATOR} { printf("%s\toperator\n", yytext); }
{KEYWORD}       { printf("%s\tkeyword\n", yytext); }
{BOOL_LITERAL}      { printf("%s\tbool_literal\n", yytext); }
{HEXADECIMAL_FLOAT_LITERAL} {printf("%s\thexadecimal_float_literal\n", yytext); }
{HEXADECIMAL_INT_LITERAL} {printf("%s\thexadecimal_int_literal\n", yytext); }
{OCTAL_INT_LITERAL} {printf("%s\toctal_int_literal\n", yytext); }
{BINARY_INT_LITERAL} {printf("%s\tbinary_int_literal\n", yytext); }
{FLOAT_LITERAL}        { printf("%s\tFLOAT_LITERAL\n", yytext); }
{INTEGER_LITERAL}        { printf("%s\tINTEGER_LITERAL\n", yytext); }
{IDENTIFIER}    { printf("%s\tidentifier\n", yytext); }
{OPERATOR}      { printf("%s\toperator\n", yytext); }
{PUNCTUATION}   { printf("%s\tpunctuation\n", yytext); }
{DELIMITER}     { printf("%s\tdelimiter\n", yytext); }
. { 
    printf("%s\tUNKNOWN or lexical error at (%d,%d)\n", yytext, line_num, col_num); 
    lexical_error = 1; 
}

%%

int main() {
    yylex();
    if (lexical_error)
        fprintf(stderr, "One or more lexical errors detected.\n");
    return lexical_error;
}
