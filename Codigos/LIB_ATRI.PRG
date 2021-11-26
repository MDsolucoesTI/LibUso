/*
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 \ Empresa.: Denny Paulista Azevedo Filho
 \ Programa: LIB_ATRI.PRG
 \ Data....: 10-12-96
 \ Sistema.: Libera��o de Uso de Softwares
 \ Funcao..: Gerenciador do chaves de liberacao
 \ Analista: Denny Paulista Azevedo Filho
 \ Criacao.: GAS-Pro v3.0 
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/

#include "libuso.ch"    // inicializa constantes manifestas


/*
   A adicao das  definicoes dos campos (mascara, titulo, cmd esp, when/defa,
   critica, ajuda) dentro do vetor sistema e' feita atraves da funcao AADD(),
   isto previne erro "memory overbooked" do CA-Clipper, durante a compilacao,
   devido a linha ser muito extensa
*/

sistema[01]={;
            "MILENIUM",;                                    // opcao do menu
            "MILENIUM",;                                    // titulo do sistema
            {"empresa1"},;                                  // chaves do arquivo
            {"Por Empresa"},;                               // titulo dos indices para consulta
            {"01"},;                                        // ordem campos chaves
            "CLIENTES",;                                    // nome do DBF
            {"CLIENTE1"},;                                  // nomes dos NTX
            {"SENHAMIL"},;                                  // nome dos dbf's relacionados
            {},;                                            // campos de relacionamento
            {2,1,1,3,22,76},;                               // num telas/tela atual/coordenadas
            {3,.t.},;                                       // nivel acesso/tp chave
            {},;                                            // campos do arquivo
            {};                                             // formula mostradas
           }

AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "",;
     /* titulo        */    "Nome do Hotel",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(empresa1)~Necess�rio informar o nome da empresa",;
     /* help do campo */    "Informe o Nome do Hotel";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@R 99.999.999/9999-99",;
     /* titulo        */    "CGC",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!empty(cgc1).And.VCGC(CGC1)~CGC n�o aceit�vel",;
     /* help do campo */    "Informe o n�mero do CGC";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@R 999.999.999.999",;
     /* titulo        */    "Inscri��o Estadual",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o numero da Inscri��o Estadual";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "",;
     /* titulo        */    "Endere�o",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(ender1)~Necess�rio informar o endere�o da empresa",;
     /* help do campo */    "Informe o Endere�o da empresa";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "99999",;
     /* titulo        */    "N�mero",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(numero1)~Necess�rio informar o n�mero do endere�o",;
     /* help do campo */    "Informe o n�mero do endere�o da empresa";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "",;
     /* titulo        */    "Bairro",;
     /* cmd especial  */    "",;
     /* default       */    "[Centro]",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(bairro1)~Necess�rio informar bairro",;
     /* help do campo */    "Informe o nome do Bairro";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "",;
     /* titulo        */    "Cidade",;
     /* cmd especial  */    "",;
     /* default       */    "[Taubat�]",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(cidade1)~Necess�rio informar a cidade",;
     /* help do campo */    "Informe o nome da Cidade";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Unidade Federativa",;
     /* cmd especial  */    "",;
     /* default       */    "[SP]",;
     /* pre-validacao */    "",;
     /* validacao     */    "!Empty(uf1)~Unidade da Federa��o inv�lida",;
     /* help do campo */    "Informe a Unidade Federetiva";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "",;
     /* titulo        */    "Pais",;
     /* cmd especial  */    "",;
     /* default       */    "[Brasil]",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(pais1)~Necess�rio informar o Pa�s",;
     /* help do campo */    "Informe o Pa�s sede da empresa";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@R 99999-999",;
     /* titulo        */    "CEP",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(cep1)~Necess�rio informar CEP",;
     /* help do campo */    "Informe o CEP da Cidade";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@R (!999)!!99-9999",;
     /* titulo        */    "Telefone",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(tele1)~Necess�rio informar o telefone da empresa",;
     /* help do campo */    "Informe o telefone da empresa";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@R (!999)!!99-9999",;
     /* titulo        */    "Fax",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o N�mero do Fax da empresa|se houver";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "",;
     /* titulo        */    "Telex",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o Telex da empresa|se houver";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Recep��o",;
     /* cmd especial  */    "MTAB([SIM|N�O],[RECEP��O])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "recepcao $ [SN]~RECEP��O n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo recep��o esteja|liberado caso contr�rio informe N";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Reserva",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Reserva])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "reserva $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo de Reserva esteja|liberado e N caso n�o|esteja|F8 Tabela Pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Retaguarda",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Retaguarda])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "retaguarda $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo de Retaguarda esteja|liberado e N caso n�o esteja|F8 tabela pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Restaurante",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Restaurante])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "restaurant $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo de Restaurante esteja|liberado e N caso n�o esteja|F8 tabela Pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Estoque",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Estoque])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "estoque $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo de Estoque esteja|liberado e N caso n�o esteja|F8 tabela Pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Financeiro",;
     /* cmd especial  */    "MTAB([SIM|N�O],[FINANCEIRO])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "financeiro $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo Financeiro esteja|liberado e N caso n�o esteja|F8 Tabela Pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Or�amento",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Or�amento])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "orcamen $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo de Planejamento Or�ament�rio esteja|liberado e N caso n�o esteja|F8 tabela pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Ve�culo",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Ve�culo])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "veiculo $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo Ve�culo esteja|liberado e N caso n�o esteja|F8 tabela pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@!",;
     /* titulo        */    "Marina",;
     /* cmd especial  */    "MTAB([SIM|N�O],[Marina])",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "marina $ [SN]~Op��o n�o aceit�vel",;
     /* help do campo */    "Informe S caso o m�dulo Marina esteja|liberado e N caso n�o esteja|F8 tabela pick";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@D",;
     /* titulo        */    "Data In�cio de Contrato",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(dtinicont)~Necess�rio informar a|Data de In�cio do Contrato",;
     /* help do campo */    "Informe a data inicial do Contrato";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@D",;
     /* titulo        */    "Data final Contrato",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(dtfimcont)~Necess�rio informar a|Data do Final do Contrato",;
     /* help do campo */    "Informe a Data de t�rmino do Contrato";
                         };
)
AADD(sistema[01,O_CAMPO],{;            // CLIENTES
     /* mascara       */    "@S35",;
     /* titulo        */    "Observa��o",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe uma observa��o|se houver";
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Recep��o
     /* form mostrar  */    "LEFT(TRAN(If(recepcao=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    15,;
     /* col da formula*/    22;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Reserva
     /* form mostrar  */    "LEFT(TRAN(if(reserva=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    15,;
     /* col da formula*/    45;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Restaurante
     /* form mostrar  */    "LEFT(TRAN(if(restaurant=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    17,;
     /* col da formula*/    22;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Estoque
     /* form mostrar  */    "LEFT(TRAN(if(estoque=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    17,;
     /* col da formula*/    45;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Retaguarda
     /* form mostrar  */    "LEFT(TRAN(if(retaguarda=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    15,;
     /* col da formula*/    68;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Financeiro
     /* form mostrar  */    "LEFT(TRAN(if(financeiro=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    17,;
     /* col da formula*/    68;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - or�ament�rio
     /* form mostrar  */    "LEFT(TRAN(if(orcamen=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    19,;
     /* col da formula*/    22;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Ve�culo
     /* form mostrar  */    "LEFT(TRAN(if(veiculo=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    19,;
     /* col da formula*/    45;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Marina
     /* form mostrar  */    "LEFT(TRAN(if(marina=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    19,;
     /* col da formula*/    68;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Lan�amento
     /* form mostrar  */    "LEFT(TRAN(if(lancmov=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    0,;
     /* col da formula*/    0;
                         };
)
AADD(sistema[01,O_FORMULA],{;          // CLIENTES - Baixa
     /* form mostrar  */    "LEFT(TRAN(If(baixpag=[S],[im],[�o]),[]),02)",;
     /* lin da formula*/    0,;
     /* col da formula*/    0;
                         };
)

sistema[02]={;
            "Senha MILENIUM v2.0",;                         // opcao do menu
            "Senha MILENIUM v2.0",;                         // titulo do sistema
            {"empresa1+palavra"},;                          // chaves do arquivo
            {"Por Empresa+Senha"},;                         // titulo dos indices para consulta
            {"0102"},;                                      // ordem campos chaves
            "SENHAMIL",;                                    // nome do DBF
            {"SENHAMI1"},;                                  // nomes dos NTX
            {},;                                            // nome dos dbf's relacionados
            {"CLIENTES->empresa1"},;                        // campos de relacionamento
            {1,1,15,17,20,60},;                             // num telas/tela atual/coordenadas
            {3,.f.},;                                       // nivel acesso/tp chave
            {},;                                            // campos do arquivo
            {};                                             // formula mostradas
           }

AADD(sistema[02,O_CAMPO],{;            // SENHAMIL
     /* mascara       */    "",;
     /* titulo        */    "Nome do Hotel",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "I",;
     /* help do campo */    "";
                         };
)
AADD(sistema[02,O_CAMPO],{;            // SENHAMIL
     /* mascara       */    "@!",;
     /* titulo        */    "Palavra",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "senha([Clientes])",;
     /* validacao     */    "",;
     /* help do campo */    "Informe a Senha deste per�odo";
                         };
)
AADD(sistema[02,O_CAMPO],{;            // SENHAMIL
     /* mascara       */    "!",;
     /* titulo        */    "Flag",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "I",;
     /* help do campo */    "";
                         };
)


sistema[03]={;
            "TRITON",;                                      // opcao do menu
            "TRITON",;                                      // titulo do sistema
            {"empresa"},;                                   // chaves do arquivo
            {"por Empresa"},;                               // titulo dos indices para consulta
            {"01"},;                                        // ordem campos chaves
            "TRICLI",;                                      // nome do DBF
            {"TRICLI1"},;                                   // nomes dos NTX
            {"SETRITON"},;                                  // nome dos dbf's relacionados
            {},;                                            // campos de relacionamento
            {2,1,4,4,16,77},;                               // num telas/tela atual/coordenadas
            {3,.t.},;                                       // nivel acesso/tp chave
            {},;                                            // campos do arquivo
            {};                                             // formula mostradas
           }

AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "",;
     /* titulo        */    "Nome",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(empresa)~Necess�rio informar a Empresa",;
     /* help do campo */    "Informar o nome da Empresa";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@R 99.999.999/9999-99",;
     /* titulo        */    "CGC",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "VCGC(cgc1)~CGC n�o aceit�vel",;
     /* help do campo */    "Informe o cadastro geral de contribuinte";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@R 999.999",;
     /* titulo        */    "CRECI",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o numero do CRECI";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "",;
     /* titulo        */    "Endere�o",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(ender1)~Necess�rio informar ENDERE�O",;
     /* help do campo */    "Informe o endere�o da Empresa";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "99999",;
     /* titulo        */    "N�mero",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "numero1>0~N�MERO n�o aceit�vel",;
     /* help do campo */    "Informe o n�mero da residencia ou pr�dio";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@R 99999-999",;
     /* titulo        */    "CEP",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(cep1)~Necess�rio informar CEP",;
     /* help do campo */    "Entre com o CEP relativo ao endere�o";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "",;
     /* titulo        */    "Complemento",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o complemento do endere�o|bloco, quadra, etc|se houver";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "",;
     /* titulo        */    "Bairro",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o bairro do endere�o";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "",;
     /* titulo        */    "Cidade",;
     /* cmd especial  */    "",;
     /* default       */    "[Taubat�]",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe a Cidade do endere�o";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "!!",;
     /* titulo        */    "UF",;
     /* cmd especial  */    "",;
     /* default       */    "[SP]",;
     /* pre-validacao */    "",;
     /* validacao     */    "VUF(uf1)~UNIDADE DA FEDERA��O inv�lida",;
     /* help do campo */    "Informe a sigla da unidade da federa��o";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@R (!999)!99-9999",;
     /* titulo        */    "Telefone",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o telefone";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@R (!999)!99-9999",;
     /* titulo        */    "Fax",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o n�mero do Fax";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@D",;
     /* titulo        */    "Data Inicial",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(dtinicont)~Necess�rio informar DATA INICIAL",;
     /* help do campo */    "Informe a data inicial do contrato";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@D",;
     /* titulo        */    "Data Final",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPT(dtfimcont)~Necess�rio informar DATA FINAL",;
     /* help do campo */    "Informe a data final do contrato";
                         };
)
AADD(sistema[03,O_CAMPO],{;            // TRICLI
     /* mascara       */    "@S35",;
     /* titulo        */    "Observa��o",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    "Informe uma Observa��o|se houver";
                         };
)


sistema[04]={;
            "Senha - TRITON",;                              // opcao do menu
            "Senha - TRITON",;                              // titulo do sistema
            {"empresa+palavra"},;                           // chaves do arquivo
            {"por Empresa+Senha"},;                         // titulo dos indices para consulta
            {"0102"},;                                      // ordem campos chaves
            "SETRITON",;                                    // nome do DBF
            {"SETRITO1"},;                                  // nomes dos NTX
            {},;                                            // nome dos dbf's relacionados
            {"TRICLI->empresa"},;                           // campos de relacionamento
            {1,1,8,18,14,61},;                              // num telas/tela atual/coordenadas
            {3,.f.},;                                       // nivel acesso/tp chave
            {},;                                            // campos do arquivo
            {};                                             // formula mostradas
           }

AADD(sistema[04,O_CAMPO],{;            // SETRITON
     /* mascara       */    "",;
     /* titulo        */    "Nome",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "I",;
     /* help do campo */    "";
                         };
)
AADD(sistema[04,O_CAMPO],{;            // SETRITON
     /* mascara       */    "@!",;
     /* titulo        */    "Senha",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "SenhaTri([TriCli])",;
     /* validacao     */    "",;
     /* help do campo */    "Informe o senha de libera��o para o Sistema";
                         };
)
AADD(sistema[04,O_CAMPO],{;            // SETRITON
     /* mascara       */    "!",;
     /* titulo        */    "Flag",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "I",;
     /* help do campo */    "";
                         };
)


sistema[05]={;
            "Senhas",;                                      // opcao do menu
            "Usu�rios do sistema",;                         // titulo do sistema
            {"pass"},;                                      // chaves do arquivo
            {""},;                                          // titulo dos indices para consulta
            {"02"},;                                        // ordem dos campos chvs
            "LIBPW",;                                       // nome do DBF
            {ntxpw},;                                       // nome do NTX
            {},;                                            // nome dos DBF relacionados
            {},;                                            // campos de relacionamento
            {1,1,11,19,17,51},;                             // qde telas, tela atual, coordenadas
            {3,.t.},;                                       // nivel acesso/tp chave
            {},; // campos  { mascara, titulo, when, critica }
            {}; // fromula { mascara, titulo, formula, linha, coluna }
           }

msg="DIGITE INICIAIS DAS ROTINAS CERCEADAS AO USU�RIO|"+;
    "P. Procura    F. Filtragem    D. Digita��o     �|"+;
    "M. Modifica   E. Exclui       R. Recupera      �|"+;
    "V. V� global  N. Nova coluna  A. Apaga coluna  �|"+;
    "I. Imprime    O. Ordena       Q. Quantifica    �|"+;
    "L. Localiza   G. Global       C. Congela Colunas|"+;
    "T. Tamanho    J. nova Janela �X. eXporta       �|"+;
    "Z. totaliZa                                    �|"
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "",;
     /* titulo        */    "Pass",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "I",;
     /* help do campo */    "";
                         };
)
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "@!",;
     /* titulo        */    "Usu�rio",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "!EMPTY(nome)~Necess�rio informar NOME",;
     /* help do campo */    "";
                         };
)
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "9",;
     /* titulo        */    "Nivel",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "MTAB([1. Opera��o �|2. Manuten��o|3. Ger�ncia �],[N�VEL DE ACESSO])",;
     /* validacao     */    "nace$[123]~N�VEL DE ACESSO inv�lido",;
     /* help do campo */    "";
                         };
)
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "@A@!",;
     /* titulo        */    "MILENIUM",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    msg;
                         };
)
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "@A@!",;
     /* titulo        */    "Senha MILENIUM v2.0",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    msg;
                         };
)
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "@A@!",;
     /* titulo        */    "TRITON",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    msg;
                         };
)
AADD(sistema[05,O_CAMPO],{;            // SENHAS
     /* mascara       */    "@A@!",;
     /* titulo        */    "Senha - TRITON",;
     /* cmd especial  */    "",;
     /* default       */    "",;
     /* pre-validacao */    "",;
     /* validacao     */    "",;
     /* help do campo */    msg;
                         };
)

* \\ Final de LIB_ATRI.PRG
