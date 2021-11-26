/*
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 \ Empresa.: Denny Paulista Azevedo Filho
 \ Programa: LIB_ESTR.PRG
 \ Data....: 10-12-96
 \ Sistema.: Libera��o de Uso de Softwares
 \ Funcao..: Gerenciador do chaves de liberacao
 \ Analista: Denny Paulista Azevedo Filho
 \ Criacao.: GAS-Pro v3.0 
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/

#include "libuso.ch"    // inicializa constantes manifestas

PROC CLI_estr     // estrutura do arquivo CLIENTES
DBCREATE(dbf,{;
               {"empresa1"  ,"C", 35, 0},; // 
               {"cgc1"      ,"C", 14, 0},; // @R 99.999.999/9999-99
               {"inscr1"    ,"C", 12, 0},; // @R 999.999.999.999
               {"ender1"    ,"C", 35, 0},; // 
               {"numero1"   ,"C",  5, 0},; // 99999
               {"bairro1"   ,"C", 18, 0},; // 
               {"cidade1"   ,"C", 20, 0},; // 
               {"uf1"       ,"C",  2, 0},; // @!
               {"pais1"     ,"C", 15, 0},; // 
               {"cep1"      ,"C",  8, 0},; // @R 99999-999
               {"tele1"     ,"C", 12, 0},; // @R (!999)!!99-9999
               {"fax1"      ,"C", 12, 0},; // @R (!999)!!99-9999
               {"tex1"      ,"C", 15, 0},; // 
               {"recepcao"  ,"C",  1, 0},; // @!
               {"reserva"   ,"C",  1, 0},; // @!
               {"retaguarda","C",  1, 0},; // @!
               {"restaurant","C",  1, 0},; // @!
               {"estoque"   ,"C",  1, 0},; // @!
               {"financeiro","C",  1, 0},; // @!
               {"orcamen"   ,"C",  1, 0},; // @!
               {"veiculo"   ,"C",  1, 0},; // @!
               {"marina"    ,"C",  1, 0},; // @!
               {"dtinicont" ,"D",  8, 0},; // @D
               {"dtfimcont" ,"D",  8, 0},; // @D
               {"obs"       ,"M", 10, 0};  // @S35
             };
)
RETU

PROC SEN_estr     // estrutura do arquivo SENHAMIL
DBCREATE(dbf,{;
               {"empresa1"  ,"C", 35, 0},; // 
               {"palavra"   ,"C", 20, 0},; // @!
               {"flag_excl" ,"C",  1, 0};  // !
             };
)
RETU

PROC TRI_estr     // estrutura do arquivo TRICLI
DBCREATE(dbf,{;
               {"empresa"   ,"C", 35, 0},; // 
               {"cgc1"      ,"C", 14, 0},; // @R 99.999.999/9999-99
               {"creci"     ,"C",  6, 0},; // @R 999.999
               {"ender1"    ,"C", 35, 0},; // 
               {"numero1"   ,"N",  5, 0},; // 99999
               {"cep1"      ,"C",  8, 0},; // @R 99999-999
               {"compl1"    ,"C", 15, 0},; // 
               {"bairro1"   ,"C", 20, 0},; // 
               {"cidade1"   ,"C", 20, 0},; // 
               {"uf1"       ,"C",  2, 0},; // !!
               {"tele1"     ,"C", 11, 0},; // @R (!999)!99-9999
               {"fax1"      ,"C", 11, 0},; // @R (!999)!99-9999
               {"dtinicont" ,"D",  8, 0},; // @D
               {"dtfimcont" ,"D",  8, 0},; // @D
               {"obs"       ,"M", 10, 0};  // @S35
             };
)
RETU

PROC SET_estr     // estrutura do arquivo SETRITON
DBCREATE(dbf,{;
               {"empresa"   ,"C", 35, 0},; // 
               {"palavra"   ,"C", 20, 0},; // @!
               {"flag_excl" ,"C",  1, 0};  // !
             };
)
RETU

* \\ Final de LIB_ESTR.PRG
