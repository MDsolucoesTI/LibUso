/*
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 \ Empresa.: Denny Paulista Azevedo Filho
 \ Programa: LIB_FUNC.PRG
 \ Data....: 10-12-96
 \ Sistema.: Libera��o de Uso de Softwares
 \ Funcao..: Gerenciador do chaves de liberacao
 \ Analista: Denny Paulista Azevedo Filho
 \ Criacao.: GAS-Pro v3.0 
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/

#include "libuso.ch"    // inicializa constantes manifestas

/*
   Sintaxe: CANC()
   Funcao.: Cancela impressao de relat�rio ou consulta
   Retorna: .t. se confirmou o cancelamento.
*/
FUNC CANC()
LOCAL ii, msg, defa_dev
PRIV cod_sos:=1
defa_dev=SET(_SET_DEVICE,"SCREEN")   // direciona para video para mensagem
ALERTA()                             // beep, beep, beep
msg="Cancelar o relat�rio|Prosseguir a impress�o"
ii=DBOX(msg,,,E_MENU,,"EMISS�O SUSPENSA")
SET(_SET_DEVICE,defa_dev)            // redireciona para impressora ou arquivo
RETU ii=1

/*
   Sintaxe: ROLATELA()
   Funcao.: Ajusta flag e prepara rolamento de tela
   Retorna: NIL
*/
FUNC ROLATELA()
LOCAL t_atual:=SAVESCREEN(l_s,c_s,l_i,c_i)
PRIV  tela_fundo:=tela_fundo
IF rola_t                                              // rolar a tela...
   DISPBEGIN()                                         // inicia montagem da tela
   RESTSCREEN(0,0,MAXROW(),79,tela_fundo)              // restaura pano de fundo
   IMPRELA()                                           // imprime DBFs relacionados
   tela_fundo=SAVESCREEN(0,0,MAXROW(),79)              // exceto o atual
   CAIXA(mold,l_s,c_s,l_i,c_i)                         // salva novo pano de fundo e
   RESTSCREEN(l_s,c_s,l_i,c_i,t_atual)                 // restaura a tela do DBF atual
   DISPEND()                                           // reapresenta tela
   MUDA_PJ(@l_s,@c_s,@l_i,@c_i,tela_fundo,tem_borda)   // muda posicao da janela
   PUBL &vr_memo.:=STR(l_s,2)+STR(c_s,2)               // salva novas coordenadas da
   SAVE TO (arqconf) ALL LIKE drv*                     // janela em disco
   REST FROM (arqconf) ADDI
ELSE                                                   // seta flag e abandona get pendente
   rola_t=.t.
   KEYB CHR(K_ESC)                                     // forca ESC
ENDI
RETU NIL

/*
   Sintaxe: PEGAPAI( <ExpN> )
   Funcao.: Capta o numero da subscricao do arquivo "pai de todos"
              ExpN = subscricao do arquivo relacionado
   Retorna: subscricao do "pai de todos"
*/
FUNC PEGAPAI(op_)
LOCAL ii
DO WHIL .t.
   IF LEN(sistema[op_,O_CPRELA])>0             // tem campo de ligacao com o pai?
      ii=sistema[op_,O_CPRELA,1]               // extrai o nome do arquivo da ligacao
      op_=EVAL(qualsis,LEFT(ii,AT("->",ii)-1)) // e acha a sua subscricao
      LOOP                                     // repete operacao para ver se o pai
   ENDI                                        // tambem e' filho
   EXIT
ENDD
RETU op_                                       // retorna susbcricao do pai de todos

/*
   Sintaxe: MENURELA( <ExpN> )
   Funcao.: Monta string com titulos de arquivos relacionados
              ExpN = subscricao do arquivo no vetor "sistema"
   Retorna: String
*/
FUNC MENURELA(op_)
LOCAL i, ii, menu
menu=IF(op_!=op_sis,"|"+sistema[op_,O_MENU],"")       // se o DBF e' dif do atual
FOR i=1 TO LEN(sistema[op_,O_DBRELA])                 // pega todos os DBF relacionados
   ii=EVAL(qualsis,sistema[op_,O_DBRELA,i])           // pega sua subscricao no vetor sistema
   IF LEN(sistema[ii,O_DBRELA])>0                     // se o DBF da relacao tem suas proprias
      menu=menu+MENURELA(ii)                          // relacoes chama a funcao recursivamente
   ELSE                                               // se DBF relacionado nao tem relacao
      IF ii!=op_sis                                   // e nao e' o DBF atual
         menu+="|"+sistema[ii,O_MENU]                 // entao monta string
      ENDI
   ENDI
NEXT
RETU menu                                             // retorna string dos nomes do DBFs

/*
   Sintaxe: QUALRELA( <ExpN1> <,ExpN2> <,ExpN3> )
   Funcao.: Pega subscricao do enesimo arquivo da relacao
              ExpN1 = subscricao do arquivo atual
              ExpN2 = enesimo arquivo da relacao
              ExpN3 = valor temporario que contera' a qde de arquivos
                      da relacao. Passar sempre 0.
   Retorna: Subscricao encontrada
*/
FUNC QUALRELA(op_,op_esc,qt_op)
LOCAL i, ii, menu:=0
IF op_!=op_sis                                       // se nao for o DBF atual, soma
   qt_op++                                           // 1 na qde de DBFs relacionados
   IF op_esc=qt_op                                   // e' o enesimo arquivo da relacao
      menu=op_                                       // prepara p/ retornar sua subscricao
   ENDI
ENDI
IF menu=0                                            // ainda nao achou o enesimo arquivo
   FOR i=1 TO LEN(sistema[op_,O_DBRELA])             // pega todos os DBF da relacao
      ii=EVAL(qualsis,sistema[op_,O_DBRELA,i])       // pega sua subscricao no vetor sistema
      IF LEN(sistema[ii,O_DBRELA])>0                 // se o DBF da relacao tem suas proprias
         menu=QUALRELA(ii,op_esc,@qt_op)             // relacoes chama a funcao recursivamente
         IF menu>0                                   // se achou o enesimo,
            EXIT                                     // cai fora
         ENDI
      ELSE                                           // se DBF relacionado nao tem relacao
         IF ii!=op_sis                               // e nao e' o DBF atual
            IF ++qt_op=op_esc                        // entao soma qde de DBFs da relacao
               menu=ii                               // e verifica se e' o enesimo
               EXIT                                  // se for, cai fora
            ENDI
         ENDI
      ENDI
   NEXT
ENDI
RETU menu                                            // retorna o enesimo DBF da relacao

/*
   Sintaxe: TP_SAIDA( <N1> <,N2> <,L> )
   Funcao.: Permite a escolha das diversas configuracoes da impressora
              N1,N2 = coordenada linha/coluna superior do menu
               ExpL = se .t. deixa escolher saida para arquivo/video
   Retorna: o tipo de saida escolhido
*/
FUNC TP_SAIDA(l_tp,c_tp,arq_vid)
LOCA ar_, i:=1
tps:=IF(TYPE("tps")="N",tps,1)
ar_=SELECT()                   // salva area atual e
SELE 0                         // vai p/ uma area vazia

#ifdef COM_REDE
   IF ! USEARQ(arq_prn,.f.,20,1,.f.)
      RETU tps                 // falhou abertura, retorna
   ENDI
#else
   USE (arq_prn)               // abre arquivo de configuracoes
#endi

msg=""                         // variavel que contera as configuracoes
DO WHIL !EOF()                 // le todo o arquivo
   msg+="|"+ALLTRIM(marca)+;   // e vai montando a variavel
        " em "+porta           // para o menu de tipos de saidas
   IF drvporta=porta .AND.;    // pega impressora configurada
      drvmarca=ALLTRIM(marca)  // para o default do menu
      i=RECNO()
   ENDI
   SKIP
ENDD
msg=SUBS(msg,2)                // retira o primeiro "|"
IF arq_vid                     // se pode enviar para arq/video
   msg+="|Arquivo/Video"       // acrescenta esta opcao
END IF
i=DBOX(msg,l_tp,c_tp,E_MENU,,,,,i)
IF i>0                         // escolheu um tipo...
   tps=IF(i<=RECC(),1,2)       // ajusta tps: 1-impressora, 2=arquivo
   IF tps=1
      drvprn=i                 // ajusta default da configuracao atual
      GO drvprn                // reinicializa as variaveis de impressao
      FOR i=1 TO FCOU()        // de acordo com configuracao escolhida
         msg=FIEL(i)
         drv&msg.=ALLTRIM(FIELDGET(i))
      NEXT
      SAVE TO (arqconf) ALL LIKE drv*       // salva mo disco configuracao escolhida
   ENDI
ENDI
USE                            // fecha o arq de conf de prn
SELE (ar_)                     // volta para area anterior
RETU tps

/*
   Sintaxe: TRANSCAMPO( <ExpL> <,ExpC> [,ExpN] )
   Funcao.: Adapta campo para pesquisa segundo seu tipo
             ExpL = se .t. monta expressao com conteudo do campo, caso
                    contrario, monta expressao com o nome do campo
             ExpC = nome do campo para adaptacao
             ExpN = numero do campo dentro da estrutura do DBF
   Retorna: String convertida
*/
FUNC TRANSCAMPO(conteudo_,chv_,indcp_)
LOCAL tp_cp:=VALTYPE(&chv_.), cp_, estr_dbf:=DBSTRUCT()
IF conteudo_
   IF tp_cp="D"
      cp_=DTOS(&chv_.)
   ELSEIF tp_cp="N"
      IF indcp_=NIL
         cp_=STR(&chv_.)
      ELSE
         cp_=STR(&chv_.,estr_dbf[indcp_,3],estr_dbf[indcp_,4])
      ENDI
   ELSE
      cp_=&chv_.
   ENDI
ELSE
   IF tp_cp="D"
      cp_="DTOS("+chv_+")"
   ELSEIF tp_cp="N"
      IF indcp_=NIL
         cp_="STR("+chv_+")"
      ELSE
         cp_="STR("+chv_+","+LPAD(estr_dbf[indcp_,3],2,"0")+","+LPAD(estr_dbf[indcp_,4],2,"0")+")"
      ENDI
   ELSE
      cp_=chv_
   ENDI
ENDI
RETU cp_

/*
   Sintaxe: ARQGER()
   Funcao.: recebe nome do arquivo
   Retorna: String (nome do arquivo)
*/
FUNC ARQGER()
LOCAL defa_:=drvdbf+"TMP"+ide_maq, t_l, t_r
t_l=SETKEY(K_LEFT,NIL)                         // desabilita seta -> e <-
t_r=SETKEY(K_RIGHT,NIL)
KEYB CHR(K_END)                                   // cursor no final do drive sugerido
arq_=DBOX("Nome do arquivo",,,,,"ARQUIVO EM DISCO",PADR(defa_,30),"@!")
arq_=TRIM(arq_)
SETKEY(K_LEFT,t_l)                             // reabilita setas cursoras
SETKEY(K_RIGHT,t_r)
RETU IF(LEN(SUBS(arq_,RAT("\",arq_)+1))<1.OR.; // nome do arquivo sem dir ou
     LASTKEY()=K_ESC,"",arq_)                  // ou cancelou

/*
   Sintaxe: PREPIMP( [msgt] )
   Funcao.: Apresenta mensagem para preparo da impressora
            msgt=titulo para menu
   Retorna: .t. se pronta
*/
FUNC PREPIMP(msgt)
PRIV cod_sos:=29
msgt=IF(msgt=NIL,"ATEN��O, "+usuario,msgt)
ALERTA(3)
op_=1
DO WHILE op_=1
   msg="Impressora pronta|Cancelar opera��o"
   op_=DBOX(msg,,,E_MENU,,msgt)                 // solicita preparo da impressora
   IF LEFT(drvporta,3)="LPT".AND.op_=1
      IF !IMPOK(VAL(SUBS(drvporta,4,1)))        // porta paralela podemos testar
         ALERTA(4)
         DBOX("Impressora n�o pronta!",,,,,"ATEN��O, "+usuario)
         LOOP                                   // fora de linha, ficamos por aqui
      ENDI
   ENDI
   EXIT                                         // s'imbora
ENDD
RETU (op_=1)                                    // retorna .T. se pronta

/*
   Sintaxe: CONFINCL()
   Funcao.: Apresenta mensagem para confirmar a inclusao
   Retorna: .t. se inclusao ok
*/
FUNC CONFINCL()
PRIV cod_sos:=1
ALERTA(2)
op_=1
msg="Efetuar inclus�o|Corrigir digita��o"
op_=DBOX(msg,l_i-1,c_i-10,E_MENU,,"ATEN��O, "+usuario) // solicita confirmacao
RETU (op_=1)     // retorna .T. se quer incluir

/*
   Sintaxe: CONFEXCL()
   Funcao.: Apresenta mensagem para confirmacao da exclusao e
            verifica se o reg pode ser excluido
   Retorna: .t. se ok
*/
FUNC CONFEXCL()
LOCAL op_:=1
PRIV cod_sos:=1
IF drvexcl                                          // se conf de exclusao
   ALERTA(1)                                        // esta ligada, vamos
   cod_sos=1                                        // pedir confirmacao
   msg=IF(LEN(sistema[op_sis,O_DBRELA])>0,"|(INCLUSIVE RELACIONADOS)","")
   msg="EXCLUIR"+msg
   op_=DBOX("Sim|N�o",17,,E_MENU,,msg)
ENDI
RETU op_=1

/*
   Sintaxe: ROLAPOP( <ExpN> )
   Funcao.: Efetua a rolagem do menu pop-down
   Retorna: NIL
*/
FUNC ROLAPOP(q_t)
IF q_t=NIL                 // se nao tem parametro desabilita setas da
   SETKEY(K_LEFT,NIL)      // esquerda/direita, caso contrario, liga as
   SETKEY(K_RIGHT,NIL)     // teclas com a qde de ESC, SETA e ENTER
ELSE                       // nesessarios para rolar a janela na horizontal
   SETKEY(K_LEFT,{||KEYBUFF(REPL(CHR(K_ESC),q_t)+CHR(K_LEFT)+CHR(K_ENTER))})
   SETKEY(K_RIGHT,{||KEYBUFF(REPL(CHR(K_ESC),q_t)+CHR(K_RIGHT)+CHR(K_ENTER))})
ENDI
RETU NIL

/*
   Sintaxe: PEGADIR( <ExpL> )
   Funcao.: Pega novo diret�rio de trabalho para a aplica��o
              ExpL = se .f., so pega diretorios de dados e de indices
                     se .t. recebe o diret�rio do ERROS.DBF tambem
   Retorna: .t. se nao foi cancelado
*/
FUNC PEGADIR(pri_vez)
LOCAL cn,drv_dbf:=drvdbf,drv_ntx:=drvntx,drv_err:=drverr,defa:=QUALDIR(),t,i,;
      msgt:="DIRET�RIOS DE TRABALHO",msg,ado_,aio_,add_,aid_
cn=.f.

#ifdef COM_PROTECAO
   IF !pri_vez                                       // se veio do apoio
      EVAL(protdbf,.f.)                              // protege DBFs
   ENDI
#endi

DO WHIL !cn
   msg="Arquivo de dados"
   drvdbf=DBOX(msg,,,,,msgt,PADR(drvdbf,23),"@!")    // diretorio dos DBF
   IF LASTKEY()=K_ESC                                // cancelou
      cn=.t.
      LOOP
   ENDI
   drvdbf=ALLTRIM(drvdbf)                            // tira espacos
   drvdbf=IF(RIGHT(drvdbf,1)!="\".AND.;              // diretorio tem que
          LEN(drvdbf)>0,drvdbf+"\",drvdbf)           // terminar com barra (\)
   IF !criadrv(drvdbf)                               // verifica/cria diretorio
      LOOP                                           // desistiu de criar
   ENDI
   msg+=": "+drvdbf                                  // diretorio dos NTX
   drvntx=DBOX(msg+"|*|Arquivos de �ndices",,,,,msgt,PADR(drvntx,23),"@!")
   IF LASTKEY()=K_ESC                                // se cancelou,
      LOOP                                           // volta a pedir dir DBF
   ENDI
   drvntx=ALLTRIM(drvntx)                            // tira espacos
   drvntx=IF(RIGHT(drvntx,1)!="\".AND.;              // diretorio tem que
          LEN(drvntx)>0,drvntx+"\",drvntx)           // terminar com barra (\)
   IF !criadrv(drvntx)                               // verifica/cria diretorio
      LOOP                                           // desistiu de criar
   ENDI
   msg+="|Arquivo de �ndices: "+drvntx
   IF pri_vez                                        // recebe diretorio do ERROS.DBF
      PADR(drverr,23)
      drverr=DBOX(msg+"|*|Arquivos de apoio � aplica��o:",,,,,msgt,PADR(drverr,23),"@!")
      IF LASTKEY()=K_ESC                             // se cancelou,
         LOOP                                        // volta a pedir dir DBF
      ENDI
      drverr=ALLTRIM(drverr)                         // tira espacos
      drverr=IF(RIGHT(drverr,1)!="\".AND.;           // diretorio tem que
             LEN(drverr)>0,drverr+"\",drverr)        // terminar com barra (\)
      IF !criadrv(drverr)                            // verifica/cria diretorio
         LOOP                                        // desistiu de criar
      ENDI
      msg+="|Arquivos de apoio: "+drverr
   ENDI
   msg=msgt+"|*|"+msg
   ALERTA(1)
   op_=DBOX("Prosseguir|Corrigir",,,E_MENU,,msg)     // confirma as informacoes
   IF op_=1                                          // se tudo certo,
      EXIT                                           // sai do loop
   ENDI
ENDD
IF (!(drvdbf==drv_dbf) .OR.;                         // se mudou diretorio de trabalho
   !(drvntx==drv_ntx)) .AND.;                        // e nao for a primeira vez, testa
   !pri_vez .AND. !cn                                // existencia dos DBF e NTX,
   cn=!CRIADBF()                                     // caso nao exista, cria-os
ENDI
IF cn                                                // se cancelou,
   drvdbf=drv_dbf;drvntx=drv_ntx;drverr=drv_err      // retorna dir anteriores
ELSE
   SAVE TO (arqconf) ALL LIKE drv*                   // salva diretorios no disco
ENDI

#ifdef COM_PROTECAO
   IF !pri_vez                                       // se veio do apoio
      EVAL(protdbf,.t.)                              // desprotege DBFs
   ENDI
#endi

RETU !cn

/*
   Sintaxe: CRIADRV( <ExpC> )
   Funcao.: Testa/cria se nao exitir o diretorio ExpC
   Retorna: .t. se teve sucesso.
*/
FUNC CRIADRV(drv_)
LOCAL drv_atual:="\"+CURDIR(),x
drv_=LEFT(drv_,LEN(drv_)-1)
IF !CHDIR(drv_) .AND. LEN(drv_)>2                    // se diretorio nao existe
   ALERTA(2)                                         // beep, beep e
   x="Criar "+drv_+"|Digitar outro diret�rio"        // pergunta se quer
   op_=DBOX(x,,,E_MENU,,"DIRET�RIO N�O EXISTE!")     // cria-lo
   IF op_!=1                                         // se nao quis...
      RETU .f.                                       // retorna
   ENDI
   IF !MKDIR(drv_)                                   // se nao conseguiu criar
      ALERTA(4)                                      // avisa e retorna
      x="Erro ao criar o diret�rio"
      op_=DBOX(x,,,3,,"ERRO!")
      RETU .f.
   ENDI
ELSE                                                 // ok diretorio existe
   CHDIR(drv_atual)                                  // posiciona dentro dele
ENDI
RETU .t.

/*
   Sintaxe: ABRE( <ExpC> <,ExpL> )
   Funcao.: Abre/cria arquivo binario para backup
              ExpC = nome do arquivo a ser criado/aberto
              ExpL = .t. cria, .f. abre
   Retorna: "Handle" do arquivo
*/
FUNC ABRE(arq_,cria_)
LOCAL i, handle:=1
DO WHIL .t.
   IF cria_                        // se quer criar arquivo
      handle=FCREATE(arq_)         // vamos cria-lo
   ELSE                            // senao,
      handle=FOPEN(arq_)           // abriremos para leitura
   END IF
   IF FERROR() !=0                 // deu erro na aberura do arquivo
      ALERTA()                     // manda aviso sonoro
      cod_sos=1                    // e deixa tentar novamente
      i=DBOX("Tentar novamente|Cancelar opera��o",,,E_MENU,,"ERRO!|IMPOSS�VEL ABRIR O ARQUIVO|"+arq_)
      IF i!=1                      // nao quer tentar mais...
         cn=.t.                    // retorna
         EXIT
      ENDI
   ELSE                            // tudo certo
      EXIT                         // abriu corretamente
   ENDI
ENDD
RETU handle                        // retorna o "handle" do arquivo

/*
   Sintaxe: CRIADBF()
   Funcao.: Verifica e cria os arquivos DBF e NTX, quando nao existirem.
   Retorna: .t. se teve sucesso
*/
FUNC CRIADBF
LOCAL tel_a:=SAVESCREEN(0,0,MAXROW(),79)              // salva a tela
FOR i=1 TO nss                                        // para cada subsistema,
   dbf=drvdbf+sistema[i,O_ARQUI]; harq=.f.            // obtem nome do DBF
   IF !FILE(dbf+".dbf")                               // existe?
      IF i=1
         cod_sos=1
         ALERTA(3)                                    // beep, beep, beep
         msg="Criar os arquivos|"+;                   // confirma a criacao
             "Abandonar a opera��o"
         op_=DBOX(msg,,,E_MENU,,"ARQUIVOS N�O ENCONTRADOS")
         IF op_!=1
            RETU (.f.)                                // retorna .f. pois abandonou
         ENDI
      ENDI
      harq=.t.                                        // monta o nome do modulo
      stru=LEFT(sistema[i,O_ARQUI],3)+"_estr"         // que cria a estrutura
      DBOX(dbf+".DBF",,,,NAO_APAGA,"CRIANDO")         // avisa...
      &stru.()                                        // e cria a estrutura
      RESTSCREEN(0,0,MAXROW(),79,tel_a)               // restaura a tela
   ENDI
   ntx=drvntx+sistema[i,O_INDIC,1]                    // obtem nome do indice
   IF !FILE(ntx+".ntx").OR.harq                       // se nao existir ou criou estrutura
      DBOX(ntx+".NTX",,,,NAO_APAGA,"CRIANDO")         // vamos criar...

      #ifdef COM_REDE
         IF !USEARQ(dbf,.t.,20,1,.f.)                 // tenta abrir arquivo modo exclusivo
            SETPOS(23,1)
            RETU (.f.)                                // retorna .f., pois nao conseguiu
         ENDI
      #else
         USE (dbf)                                    // abre arquivo
      #endi

      INDE ON &(sistema[i,O_CHAVE,1]) TO (ntx)        // e indexa
      RESTSCREEN(0,0,MAXROW(),79,tel_a)               // restaura tela
   ENDI
   CLOS ALL                                           // fecha tudo
NEXT
RETU (.t.)                                            // retorna .t. - ok

/*
   Sintaxe: IMPCTL( <ExpC> )
   Funcao.: Imprime codigo de controle na impressora
              ExpC = codigo de controle
   Retorna: NIL
*/
FUNC IMPCTL(ctl_)
LOCAL li_:=PROW(), co_:=PCOL()   // salva posicao do carro da impressora
IF LEN(ctl_)>0                   // se foi passado um codigo de controle
   lp_=SET(_SET_PRINTER,.t.)     // liga "echo" para impressora
   lc_=SET(_SET_CONSOLE,.f.)     // desliga saidas para video
   ?? &ctl_.                     // imprime caracteres de controle
   SET(_SET_PRINTER,lp_)         // retorna o "echo" original da impressora
   SET(_SET_CONSOLE,lc_)         // impressao no video habilitada
   SETPRC(li_,co_)               // retorna cabeca impressora
ENDI
RETURN NIL                       // para a posicao original

/*
   Sintaxe: PTAB( <ExpC1>, <ExpC2> [,ExpN] [,ExpL] )
   Funcao.: Executa pesquisa em tabelas
              ExpC1 = chave de pesquisa
              ExpC2 = arquivo alvo
              ExpN  = numero do indice associado a ExpC2
              ExpL  = se .t. deixa na ordem do indice do parametro
  
   Retorna: .t. se o registro existe
*/
FUNC PTAB(ch_,db_,or_dem,fix_ind_)
LOCAL ar_:=SELECT(), in_, sem_dbf:=ALIAS(), achou, del_a:=SET(_SET_DELETED,.f.)
or_dem=IF(or_dem=NIL,1,or_dem)
fix_ind_=IF(fix_ind_=NIL,.f.,fix_ind_)
IF !USEARQ(db_)              // tenta abrir DBF e seus indices
   RETU (.f.)                // retorna .f. se nao conseguiu
ENDI
in_=INDEXORD()               // salva ordem atual dos indices
DBSETORDER(or_dem)           // vai para o indice desejado
SEEK ch_                     // procura o registro
achou=(!EOF().AND.!DELE())   // flag se achou (DELE() nao vale)
IF !fix_ind_                 // se nao quer deixar na ordem da pesquisa
   DBSETORDER(in_)           // retorna ordem original
ENDI
IF EMPTY(sem_dbf)            // se area anterior estiver vaga
   SELE 0                    //  seleciona proxima area vaga
ELSE                         // senao
   SELE (ar_)                //  seleciona area anterior
ENDI
SET(_SET_DELETED,del_a)   // retorna a visibilidade dos excluidos
RETU achou

/*
   Sintaxe: USEARQ( <ExpC> [,ExpL1] [,ExpN1], [,ExpN2] [,ExpL2] )
   Funcao.: Abre arquivo de dados e seus �ndices associados
              ExpC  = nome do arquivo
              ExpL1 = .t. abre modo exclusivo
              ExpN1 = num de vezes que sera tentada a abertura
              ExpN2 = tempo em segundos entre as tentativas de abertura
              ExpL2 = .t. abre associando os ntx
   Retorna: .t. se abriu o arquivo
*/
FUNC USEARQ(db_,use_ex,n_tent,t_tent,com_ntx)
LOCAL op_sis, qt_ind, p_, drv_dbf, p_sempre, v_r, msg, ind01
n_tent=IF(n_tent=NIL,0,n_tent)
t_tent=IF(t_tent=NIL,1,t_tent)
com_ntx=IF(com_ntx=NIL,.t.,com_ntx)
use_ex=IF(use_ex=NIL,.f.,use_ex)
p_sempre=(n_tent=0)
n_ant=n_tent
v_r=.f.
drv_dbf=drvdbf                                     // drive de dados
IF "\" $ db_                                       // verifica se passou diretorio + arquivo
   p_=RAT("\",db_)
   drv_dbf=LEFT(db_,p_)                            // pega diretorio passado e
   db_=SUBS(db_,p_+1)                              // o nome do arquivo
ENDI
IF EMPTY(SELECT(db_))                              // o arquivo nao esta' em uso, vamos abri-lo...
   db_f=drv_dbf + db_
   SELE 0                                          // seleciona proxima area livre

   #ifdef COM_REDE
      msgt="OUTRO USU�RIO ACESSANDO|O ARQUIVO"
      DO WHIL n_tent>=0 .OR. p_sempre              // tenta abrir o aruivo n vezes ou p/ sempre
         IF use_ex                                 // tenta abrir com exclusividade
            USE (db_f) EXCLUSIVE
         ELSE                                      // tenta abrir compartilhado
            USE (db_f) SHARED
         ENDI
         IF ! NETERR()                             // abriu sem problemas
            v_r=.t.
            EXIT
         ENDI
         DBOX("Tentando abrir|"+;                  // avisa usuario, espera n_tent
              IF(p_sempre,"(N�O","(ESC")+;         // segundos para tentar novamente
              " cancela)",15,,t_tent,,msgt)
         n_tent-=t_tent
         IF !p_sempre .AND. LASTKEY()=K_ESC        // se nao for para sempre e quer
            EXIT                                   // cancelar, nao tenta abrir mais
         ENDI
      ENDD
      CLEA TYPEAHEAD                               // limpa o buffer do teclado
      IF ! v_r                                     // se nao conseguiu abrir o arquivo
         RETU (.f.)                                // retorna falso
      ENDI
   #else
      USE (db_f)                                   // abre o arquivo
   #endi

   IF com_ntx                                      // abre arquivo com os indices
      op_sis=EVAL(qualsis,ALIAS())                 // obtem subscricao do DBF no vetor Sistema
      IF op_sis=0                                  // se o arquivo e' externo ao sistema...
         v_r=AT(".",db_)                           //  tira extensao do arquivo
         n_t_x=IF(v_r>0,LEFT(db_,v_r-1),db_)       //  caso exista
         nt_x=drv_dbf+LEFT(n_t_x,7)+"1"            //  verifica se existe arquivo
         IF FILE(nt_x+".NTX")                      //  se existir indice com nome xxx1.ntx,
            SET INDE TO (nt_x)                     //   vamos usa-lo
         ELSE                                      //  se nao procura
            IF FILE(n_t_x+".NTX")                  //  indice com nome xxx.ntx, usa
               SET INDE TO (n_t_x)
            ENDI
         ENDI
      ELSE                                         // senao, abre indices segundo vetor sistema
         IF op_sis<=nss                          // se nao for as senhas, coloca path
            ind01=drvntx+sistema[op_sis,O_INDIC,1]
         ELSE                                    // senao, ja tem path
            ind01=sistema[op_sis,O_INDIC,1]
         ENDI
         SET INDE TO (ind01)                       // abre arquivo indice
      ENDI
   ENDI
ELSE
   SELE SELECT(db_)                                // arquivo ja' estava aberto
ENDI
RETU .t.                                           // deu tudo certo...

/*
   Sintaxe: CRIT( <ExpC1> <,ExpN> [,ExpC2] )
   Funcao.: Executa validacao de campos/ mostra formulas na tela
              ExpC1 = expressao de validacao e a mensagem a ser mostrada
                      separados separadas pelo caracter "~".
              ExpN  = linha onde sera mostrada a mensagem
              ExpC2 = formulas a serem mostradas na tela. ("nn|nn|nn|...",
                      "nn"=num das f�rmulas especificadas no vetor "sistema"
   Retorna: .t. se critica ok
*/
FUNC CRIT(msgc,li,form_)
LOCAL cond, msg, flag:=.t., no_gets, i_
PRIV  l, c
no_gets=(RIGHT(PROCNAME(1),5)="_GETS")                // flg se nao esta consultando
IF !EMPT(msgc) .AND. !("V"==msgc) .AND. !("I"==msgc)
   li=IF(li=NIL.OR.li>MAXROW()-5,MAXROW()-5,li)       // ajusta linha da mensagem
   msg =SUBS(msgc,AT("~",msgc)+1)                     // mensagem a mostrar
   cond=LEFT(msgc,AT("~",msgc)-1)                     // condicao de validacao
   IF !(&cond.)                                       // se condicao nao satisfeita,
      IF !no_gets .AND. LEN(TRIM(msg))>0              // se tem msg para mostrar
         ALERTA()                                     // beep, beep, beep
         DBOX(msg,li,,,,"ATEN��O! "+usuario)          // avisa ao usuario
      ENDI
      flag=.f.                                        //  retornando falso
   ENDI
ENDI
IF flag .AND. form_!=NIL                              // validacao ok e tem formulas
   DO WHIL LEN(form_)>0                               // mostraremos todas ...
      i_=VAL(PARSE(@form_,"|"))                       // pega subscricao da formula
      IMP_FORM(sistema[op_sis,O_FORMULA,i_])          // imprime a formula
   ENDD
ENDI
RETU flag                                             // retorna ok se validacao ok

/*
   Sintaxe: EDITA( <N1> <,N2> <,N3> <,N4> <,ExpL|ExpC1> <,Arr1> <,Arr2> <,ExpC2> <,ExpC3> )
   Funcao.: Apresenta a tela de consulta no objeto "TBrowse" com diversos recursos.
              N1,N2,N3,N4 = coordenadas da janela de consulta
               ExpL|ExpC1 = rotinas nao acessadas
                     Arr1 = arranjo de campos a apresentar na janela
                     Arr2 = titulos dos campos de Arr1
                    ExpC2 = filtro inicial
                    ExpC3 = ordem inicial
   Retorna: NIL
*/
FUNC EDITA(li_supp,co_supp,li_infp,co_infp,mo_difp,coluna_cp,coluna_tit,cr_,ord_)
LOCAL op_sy_:=op_sis, cor_orig, i_, t_f8, dele_atu:=SET(_SET_DELETED)
PRIV cp_:="", cond_p:="", tit_cons:={"",""}, db_1rela:="", cpord,;
     db_2rela:="", cpord:="", criterio, ind_ord:=1, ind_rela:=1, chvpesq:="",;
     grava_db:=.f., op_db:=1, volta_db, ch_tecl:="05042419", op_menu:=PROJECOES,;
     di_tecl:="24262527", br_reg_ori, br_reg_out, brw_tempo, brw_ant:=brw,;
     col_cp:=coluna_cp,col_tit:=coluna_tit, li_sup:=li_supp, vr_edita,;
     li_inf:=li_infp, co_sup:=co_supp, co_inf:=co_infp, posi_cur,;
     dir_cur:=IF(op_sis>nss,2,3), mo_dif:=mo_difp, hlp_cod:=cod_sos
IF ! USED()                                  // se nao existir arquivo
   RETU .f.                                  // aberto, cai fora
ENDI
criterio=IF(cr_=NIL,"",cr_)                  // tem filtro inicial?
cpord=IF(ord_=NIL,"",ord_)                   // tem ordem inicial?
FOR i_=1 TO FCOU()                           // declara privados todos os
   msg=FIELD(i_)                             // campos do arquivo da consulta
   PRIV &msg.
NEXT

#ifdef COM_MOUSE
   IF drvmouse
      DO WHIL MOUSEGET(0,0)!=0               // se qualquer botao do mouse
      ENDD                                   // estiver pressionado espera
   ENDI                                      // liberacao
#endi

brw=.t.                                      // pega posicao atual da tela
vr_edita=NOVAPOSI(@li_sup,@co_sup,@li_inf,@co_inf)
mo_dif=IF(mo_dif=NIL,.t.,mo_dif)             // trata as rotinas
IF TYPE("mo_dif")="L"                        // que nao poderao
   IF !mo_dif                                // ser acessadas
      mo_dif="DERMG"                         // durante a consulta
   ELSE
      mo_dif=""
   ENDI
ENDI
cor_orig=SETCOLOR()                          // salva cor original
brw_reg=RECN()                               // registro atual
volta_db=.t.

#ifdef COM_REDE
   brw_tempo=drvtempo                        // tempo de "refresh"
#endi

t_f8=SETKEY(K_ALT_F8,NIL)                    // salva/reseta tecla ALT-F8
BRWFUNC()                                    // funcoes auxiliares
SETKEY(K_ALT_F8,t_f8)                        // seta tecla ALT-F8

#ifdef COM_REDE
   IF brw_tempo!=drvtempo                    // se alterou o tempo de "refresh"
      SAVE TO (arqconf) ALL LIKE drv*        // salva em disco
   ENDI
#endi

SETCOLOR(cor_orig)                           // restaura cor original
op_sis = op_sy_
SET KEY K_TAB TO                             // resta TAB
brw=brw_ant
SET(_SET_DELETED,dele_atu)                   // SET DELE=anterior
RETU .t.

/*
   Sintaxe: MOV_PTR( <ExpN> )
   Funcao.: Move o ponteiro em arquivo relacionado e ou filtrado
              ExpN  = numero de registros para mover o ponteiro
   Retorna: Num de registros pulados
*/
FUNC MOV_PTR(a_pular)
LOCAL ja_pulado := 0, chv_
IF a_pular = 0                                   // nao vai pular registros
   SKIP 0
ELSE                                             // vai pular registros...
   chv_=&("{||"+INDEXKEY(0)+"=["+;               // so servem os registro que
        IF(EMPT(criterio),"","T")+chv_1+"]}")    // atendao ao filtro/relacao
   DO WHILE !EOF() .AND. !BOF() .AND.;           // pula qtos reg's forao pedidos
      a_pular != ja_pulado .AND. EVAL(chv_)      // ate eof ou fora filtro/relacao
      IF a_pular > 0                             // pulando para frente
         SKIP
         ja_pulado++                             // conta quando foroa pulados
      ELSE                                       // pulando para traz
         SKIP -1
         ja_pulado--                             // menos um pulado
      ENDI
   ENDD
   IF !EVAL(chv_) .OR. EOF() .OR. BOF()          // reg nao atende filtro/relacao
      IF a_pular > 0                             // esta pulando para frente
         FIM_ARQ()                               // acha o fim do arquivo
         ja_pulado--                             // decrementa um na qde de reg pulados
      ELSE                                       // pulando para traz
         INI_ARQ()                               // acha o inicio do arquivo
         ja_pulado++                             // incrementa um na qde de reg pulados
      ENDI
   ENDI
ENDI
RETU ja_pulado                                   // retorna a qde exata de reg pulados

/*
   Sintaxe: CABBRW()
   Funcao.: Monta cabecalho da consulta
   Retorna: NIL
*/
STATIC FUNC CABBRW
br_w:hilite()                                   // tira barra cursora da tela
br_w:headsep:=chr(205)+chr(209)+chr(205)        // separador do cabecalho (���)
br_w:colsep:=" "+chr(179)+" "                   // separador das colunas  ( � )
op_sis=EVAL(qualsis,ALIAS())                    // subscricao do arquivo atual
br_w:cargo:={"","","",INDEXORD()}               // salva alguns parametros da consulta
RETU NIL

/*
   Sintaxe: MONTABRW()
   Funcao.: Monta janela de visualiza��o da consulta
   Retorna: NIL
*/
STATIC FUNC MONTABRW()
LOCAL id_carg:={}
op_sis   = EVAL(qualsis,ALIAS())             // subscricao do arquivo atual
arq_cor  = LEFT(ALIAS(),3)                   // prefixo do arquivo
id_carg  = br_w:cargo                        // variaveis da consulta
criterio = id_carg[1]                        // filtro
cpord    = id_carg[2]                        // ordenacao
chv_rela = id_carg[3]                        // relacao
ind_ord  = id_carg[4]                        // indice atual
DBSETORDER(ind_ord)                          // escolhe o indice atual
PEGACHV2()                                   // pega final do relaciomento
SETCOLOR(drvcorbox)                          // cor da janela selecionada

#ifdef COM_MOUSE
   IF drvmouse                               // define area de atuacao do mouse
      MOUSEBOX(br_w:ntop-1,br_w:nleft-1,br_w:nbottom+1,br_w:nright+1)
   ENDI
#endi


/*
   Monta janela de consulta e mensagens de status e teclas disponiveis
   nas suas bordas
*/
CAIXA(mold+CHR(0),br_w:ntop-2, br_w:nleft-1, br_w:nbottom+1, br_w:nright+1)
@ br_w:ntop-2,br_w:nleft SAY IF(EMPTY(criterio),"{Qde="+LTRIM(STR(RECC(),10))+"}",REPL(SUBS(mold,2,1),11))
msg="TAB [ ],F10"+IF(op_sis<=nss.AND.((M->v_out.AND.tem_t).OR.!M->v_out),",F9","")

#ifdef COM_MOUSE
   IF drvmouse                               // botoes do mouse
      msg+=" "+CHR(174)+" "+CHR(175)+" "+CHR(30)+" "+CHR(31)+" "+CHR(24)+" "+CHR(26)+" "+CHR(25)+" "+CHR(27)+" "+CHR(18)
   ENDI
#endi

msg=LEFT(msg,br_w:nright-br_w:nleft)
posi_cur=INT((br_w:nright-br_w:nleft-LEN(msg))/2)
@ br_w:nbottom+1,br_w:nleft+posi_cur SAY msg
@ br_w:nbottom+1,br_w:nleft+posi_cur+5 SAY CHR(VAL(SUBS(di_tecl,dir_cur*2-1,2)))
x=br_w:nright-br_w:nleft+1
@ br_w:ntop-1,br_w:nleft SAY PADC(MAIUSC(tit_cons[IF(br_w == br_origem,1,2)]),x,' ')
RETU NIL

/*
   Sintaxe: FORCABRW( <ExpL> )
   Funcao.: Reimprime dados da funcao EDITA()
              ExpL = se .t. reimprime inclusive a moldura.
   Retorna: NIL
*/
STATIC FUNC FORCABRW(imp_cx)
LOCAL id_carg:={}
PRIV op_sis, chv_1, chv_2, criterio, cpord, chv_rela, chv_1, chv_2
COMMIT
IF br_outro != NIL                     // se a 2a. janela estiver aberta
   TROCA_BRW()                         // troca janela do browse

   #ifdef COM_REDE
      COMMIT                           // forca atualizacao em disco
   #endi

   id_carg = br_w:cargo                // retira da variavel de instancia
   criterio=id_carg[1]                 // o filtro que tinha
   cpord=id_carg[2]                    // a ordenacao
   chv_rela=id_carg[3]                 // a relacao
   ind_ord=id_carg[4]                  // e o indice utilizado
   SET ORDE TO (ind_ord)
   op_sis=EVAL(qualsis,ALIAS())    // obtem subscricao do DBF no vetor Sistema
   PEGACHV2()                      // pega final do relaciomento
   IF imp_cx                           // reemprime moldura da janela
      SETCOLOR(drvcortna)
      br_w:colorspec := drvcortna+","+INVCOR(drvcortna)+","+drvcorenf+","+drvcorget
      CAIXA(mold+CHR(0),br_w:ntop-2, br_w:nleft-1, br_w:nbottom+1, br_w:nright+1)
      x=br_w:nright-br_w:nleft+1
      @ br_w:ntop-1,br_w:nleft SAY PADC(MAIUSC(tit_cons[IF(br_w == br_origem,1,2)]),x,' ')
   ENDI
   IF DELE().AND.SET(_SET_DELETED)     // registro esta apagado e nao visivel
      MOV_PTR(-1)                      // acha o 1o. reg nao apagado
   ENDI
   br_w:refreshall()                   // forca atualizacao da tela nao selecionada
   br_w:forcestable()                  // apresenta os dados
   br_w:dehilite()                     // liga barra cursora
   TROCA_BRW()                         // troca janela do browse
ENDI
RETU NIL

/*
   Sintaxe: ABREOUTRO( <ExpN> )
   Funcao.: Abre segunda janela de consulta
              ExpN = subscricao do arquivo dentro vetor "sistema"
   Retorna: .t. se teve sucesso
*/
STATIC FUNC ABREOUTRO(op_s)
LOCAL ar_, c_1, c_2
ar_=UPPER(sistema[op_s,O_ARQUI])            // nome do arquivo da consuta

#ifdef COM_REDE
   IF !USEARQ(ar_,.f.,20,1)                 // se nao conseguiu abrir o arquivo
      DBOX(ms_uso,20)                       // avisa
      SELE (m_origem)                       // retorna para o DBF original
      RETU .f.                              // e retorna
   ENDI
#else
   USEARQ(ar_)                              // abre DBF da consulta
#endi

outro_db=ALLTRIM(STR(SELEC(ar_)))           // salva area do arquivo aberto
SELE (m_origem)
M->tp=li_sup+INT((li_inf-li_sup-1)/2)+1     // linha de divisao das janelas
br_reg_ori=RECNO()                          // salva registro do DBF original
br_w:dehilite()                             // apaga barra cursora
br_w:nbottom := M->tp - 2                   // final da janela do DBF original
br_w:configure()                            // seta remontagem da janela
c_1=br_w:nleft                              // salva coordenadas da direita
c_2=br_w:nright                             // e da esquerda para a nova janela
SELE (outro_db)                             // novo arquivo
GO TOP                                      // monta browse da nova consulta
br_outro=TBROWSENEW(M->tp+1,c_1,li_inf,c_2)
br_outro:colorspec := drvcorbox+","+INVCOR(drvcorbox)+","+drvcorenf+","+drvcorget
br_w=br_outro                               // browse atual
CABBRW()                                    // monta janela do novo browse
RETU .t.                                    // e retorna

/*
         Sintaxe: MOSTRA_RELA()
         Funcao.: Verifica se a janela de baixa esta relacionada e
                                    se e' necessario mostra os seus registros
         Retorna: .t. se preciso remonta-la
*/
STATIC FUNC MOSTRA_RELA()
LOCAL ok:=.f.
PRIV chv_rela, criterio, cpord, chv_1, chv_2, op_sis
IF TYPE("br_outro")="O"                             // tem outra janela aberta?
   id_carg = br_outro:cargo
   IF !EMPT(id_carg[3])                             // a janela esta relacionada?
      criterio = id_carg[1]                         // restabelece o filtro
      cpord    = id_carg[2]                         // ordem e a
      chv_rela = id_carg[3]                         // relacao entre as janelas
      SELE (outro_db)                               // seleciona dbf da janela
      op_sis=EVAL(qualsis,ALIAS())                  // sua subscricao no vetor sistema
      PEGACHV2()                                    // acha o inicio/fim da relacao
      IF chv_1 != &chv_rela .OR. !br_outro:stable   // precisa remonta-la?
         INI_ARQ()                                  // acha o inicio da relacao
         br_reg_out = RECNO()                       // salva reg atual
         br_outro:rowpos := 1                       // cursor na 1a. lin do browse
         ok:=.t.                                    // tem que remontar a janela
      ENDI
      SELE (m_origem)                               // seleciona janela superior
   ENDI
ENDI
RETU ok

/*
   Sintaxe: BRWFUNC()
   Funcao.: Diversas funcoes auxiliares da EDITA()
   Retorna: NIL
*/
STATIC FUNC BRWFUNC()
LOCAL br_w1, brw_tela, cri_ant, brw_reg, cp_exp:={}, estr_dbf:={}, tps,;
      tecl_p, l_sup, l_inf, m_od, arqexp, dli_exp, id_carg:={}, q_tela,;
      just_memo, tot_num, Li:=1, Co:=1, ppp:=0, pp:=0, t, i, l_m, Tp_Sai,;
      tit_rel, brw_fundo:=SAVESCREEN(0,0,MAXROW(),79), dele_atu, x_, y_
PRIV cp_, cp_titu, cp_masc, cp_crit, cp_when, cp_help, cp_cmd, tp_cp, br_w,;
     fg_loc:=.f., volta_db:=.t., arq_cor:=LEFT(ALIAS(),3), br_origem,;
     br_outro:=NIL, m_origem, outro_db:=NIL, chv_rela:="", chv_1:="",;
     chv_2:="", l_s, c_s, l_i, c_i, db_zoom:=.f., br_arq:="", br_tit:=""
m_origem = ALLTRIM(STR(SELEC()))
br_origem = TBROWSENEW(li_sup,co_sup,li_inf,co_inf)
br_origem:colorspec := drvcorbox+","+INVCOR(drvcorbox)+","+drvcorenf+","+drvcorget
br_w = br_origem
CABBRW()                                                    // monta cabecalho da consulta
tit_cons[1]=sistema[op_sis,O_MENS]                          // titulo da janela
IF !LDBEDIT(.t.)                                            // menu de consultas gravadas
   RETU NIL
ENDI
col_cp:=col_tit := NIL
tb = {{K_DOWN,      {||br_w:down()}},;                      // vetor contendo as teclas
      {K_UP,        {||br_w:up()}},;                        // e suas acoes
      {K_PGDN,      {||br_w:pagedown()}},;
      {K_PGUP,      {||br_w:pageup()}},;
      {K_CTRL_PGUP, {||br_w:gotop()}},;
      {K_CTRL_PGDN, {||br_w:gobottom()}},;
      {K_RIGHT,     {||br_w:right()}},;
      {K_LEFT,      {||br_w:left()}},;
      {K_HOME,      {||br_w:home()}},;
      {K_END,       {||br_w:end()}},;
      {K_CTRL_LEFT, {||br_w:panleft()}},;
      {K_CTRL_RIGHT,{||br_w:panright()}},;
      {K_CTRL_HOME, {||br_w:panhome()}},;
      {K_CTRL_END,  {||br_w:panend()}};
     }
SETCOLOR(drvcorbox)
volta_db=.t.
MONTABRW()                                                  // inicializa tbrowse
DO WHILE volta_db
   SET CURSO OFF                                            // apaga cursor da tela
   DO WHILE !br_w:stabilize() .AND. NEXTKEY()=0             // apresenta dados na tela
   ENDD
   x_ = COL() ; y_ = ROW()                                  // salva posicao atual do cursor
   READINSERT(.f.)                                          // retira o "insert"
   t = SUBS(mold,2,1)
   IF br_w:nleft+22<br_w:nright                             // msg no canto superior esquerdo
      @ br_w:ntop-2,br_w:nleft+12 SAY IF(DELE(),"{Exclu�do}",REPL(t,10))
   ENDI
   IF br_w:nleft+31<br_w:nright                             // msg inicio/fim de arq no centro
      msg=IF(br_w:hittop,"{In�cio}",IF(br_w:hitbottom,"{Final}"+t,REPL(t,8)))
      @ br_w:ntop-2,br_w:nleft+23 SAY msg
   ENDI
   IF br_w == br_origem .AND. br_w:stable                   // esta na janela superior
      IF MOSTRA_RELA()                                      // e' preciso refazer janela de baixo
         FORCABRW(.f.)                                      // entao vamos la...
      ENDI
   ENDI
   cod_sos=hlp_cod

   #ifdef COM_MOUSE
      tecl_p=MOUSETECLA(br_w:ntop-1,br_w:nleft-1,;           // aguarda com controle de mouse
                        br_w:nbottom+1,br_w:nright+1,.f.;
             )
      MOUSEGET(@li,@co)                                      // salva posicao atual do mouse
      IF tecl_p=CLICK                                        // se botao esquerdo foi pressionado
         t=br_w:rowpos; colpos_=br_w:colpos                  // salva linha/coluna atual
         br_w:dehilite(); tecl_p=0                           // desliga cursor do browse
         br_w:rowpos:=t+li-y_                                // linha do clique
         FOR i=br_w:rightvisible TO br_w:leftvisible STEP -1
            br_w:dehilite()                                  // deliga/liga cursor da coluna para
            br_w:colpos:=i                                   // pegar as nova coordenadas do cursor
            br_w:hilite()
            IF COL()-1<=co                                   // a coluna do clique e' esta?
               tecl_p=1                                      // flag fim da procura
               EXIT                                          // e sai do FOR...
            ENDI
         NEXT
         IF tecl_p=0 .AND. Br_w:freeze>0                     // se ainda nao achou a coluna
            FOR i=br_w:freeze TO 1 STEP -1                   // verifica se esta' nas colunas
               br_w:dehilite()                               // congeladas
               br_w:colpos:=i
               br_w:hilite()
               IF COL()-1<=Co                                // achamos a coluna do clique
                  EXIT
               ENDI
            NEXT
         ENDI
         IF t=br_w:rowpos .AND. colpos_=br_w:colpos          // clicou duas vezes na mesma
            KEYB CHR(77)                                     // coluna entao forca modificacao
         ENDI
         tecl_p=0                                            // nao faz nada
      ENDI
   #else

      #ifdef COM_TUTOR

         #ifdef COM_REDE
            tecl_p=IN_KEY(drvtempo)                          // espera tecla ser digitada
         #else
            tecl_p=IN_KEY(0)                                 // espera tecla ser digitada
         #endi

      #else

         #ifdef COM_REDE
            tecl_p=INKEY(drvtempo)                           // espera tecla ser digitada
         #else
            tecl_p=INKEY(0)                                  // espera tecla ser digitada
         #endi

      #endi

   #endi

   #ifdef COM_REDE
      IF tecl_p=0                                            // nao teclou nada, sai pelo
         br_w:refreshall()                                   // tempo de "refresh" entao
         FORCABRW(.f.)                                       // forca reimpressao dos dados
         LOOP                                                // na tela e volta
      ENDI
   #endi

   IF SETKEY(tecl_p)!=NIL                                    // executa funcao associada a
      EVAL(SETKEY(tecl_p))                                   // tecla digitada se existir
      tecl_p=0                                               // nao faz mais nada
   ENDI
   SET CURSO ON                                              // acende o cursor
   nm = ASCAN(tb,{|ve_a| tecl_p = ve_a[1]})                  // verifica se tecla esta
   IF nm != 0                                                // no vetor de teclas progamadas
      IF tb[nm,2]!=NIL                                       // em caso afirmativo,
         EVAL(tb[nm,2])                                      // executa a funcao definida para
      ENDI                                                   // a tecla
   ELSE
      br_w:dehilite()                                        // apaga barra cursora
      IF tecl_p=K_F10
         SET CURS OFF                                        // desliga cursor
         tbmenu="PFDMERVNAIOQL"+IF(fg_loc,"S","")+;
                "GCTJXZ"

         #ifdef COM_REDE
            tbmenu+="+-"                                     // teclas de "refresh"
         #endi

         l_m=IF(op_sis>nss,"",exrot[op_sis])                 // senhas nao tem rotinas
         l_m=RTRIM(mo_dif+l_m)                               // para serem retiradas
         FOR i=1 TO LEN(l_m)                                 // retira rotina que o usuario
            tbmenu=STRTRAN(tbmenu,SUBS(l_m,i,1),"")          // nao pode acessar e monta menu
            tbmenu=STRTRAN(tbmenu,SUBS(l_m,i,1),"")          // nao pode acessar e monta menu
         NEXT                                                // com as rotinas disponiveis
         msg =IF(AT("P",tbmenu)>0,"P. Procura determinado registro  �|","")
         msg+=IF(AT("F",tbmenu)>0,"F. Filtragem (seleciona/ordena)  �|","")
         msg+=IF(AT("D",tbmenu)>0,"D. Digita��o - inclui registros  �|","")
         msg+=IF(AT("M",tbmenu)>0,"M. Modifica conte�do do campo    �|","")
         msg+=IF(AT("E",tbmenu)>0,"E. Exclui (marca apagamento)     �|","")
         msg+=IF(AT("R",tbmenu)>0,"R. Recupera (desmarca apagamento)�|","")
         msg+=IF(AT("V",tbmenu)>0,"V. V� todo o registro na tela    �|","")
         msg+=IF(AT("N",tbmenu)>0,"N. Nova coluna                    |","")
         msg+=IF(AT("A",tbmenu)>0,"A. Apaga coluna do cursor        �|","")
         msg+=IF(AT("I",tbmenu)>0,"I. Imprime a consulta            �|","")
         msg+=IF(AT("O",tbmenu)>0,"O. Ordena os registros           �|","")
         msg+=IF(AT("Q",tbmenu)>0,"Q. Quantifica registros          �|","")
         msg+=IF(AT("L",tbmenu)>0,"L. Localiza um registro          �|","")
         msg+=IF(AT("S",tbmenu)>0,"S. Seguinte - localiza seguinte  �|","")
         msg+=IF(AT("G",tbmenu)>0,"G. Global - processa os registros�|","")
         msg+=IF(AT("C",tbmenu)>0,"C. Congela/descongela colunas    �|","")
         msg+=IF(AT("T",tbmenu)>0,"T. Tamanho - muda tamanho coluna �|","")
         msg+=IF(AT("J",tbmenu)>0,"J. "+IF(outro_db=NIL,"Janela - abre uma nova janela �|","Janela - troca de janelas     �|"),"")
         msg+=IF(AT("X",tbmenu)>0,"X. eXporta dados (TXT, SDF, DBF) �|","")
         msg+=IF(AT("Z",tbmenu)>0,"Z. totaliZa coluna (se num�rica) �|","")

         #ifdef COM_REDE
            msg+=IF(AT("+",tbmenu)>0,"+. +5 seg na remontagem da tela  �|","")
            msg+=IF(AT("-",tbmenu)>0,"-. -5 seg na remontagem da tela  �|","")
         #endi

         msgt="OP��ES|(ALT-F10=excluidos, ALT-Z=zoom, ALT-G=grava)"
         op_db=DBOX(msg,,,E_MENU,,msgt,,,op_db)               // escolhe a rotina
         IF op_db = 0                                         // cancelou...
            LOOP
         ENDI
         tecl_p = ASC(SUBS(tbmenu,op_db,1))                   // pega o ASC
         IF SUBS(tbmenu,op_db,1)="L"                          // se escolheu "localiza", entao ajusta
            op_db++                                           // default para o continua
         ENDI
         SET CURSO ON                                         // acende o cursor
      ELSEIF tecl_p = K_F9 .AND. op_sis<=nss                  // ve outros arquivos
         tecl_p=K_F9
         IF !M->v_out                                         // se tem permissao
            l_sup=li_sup; l_inf=li_inf                        // salva coordenadas da janela
            c_sup=co_sup; c_inf=co_inf
            m_od=mo_dif                                       // salva rotinas acessadas e
            br_w1 := br_w                                     // o objeto browse atual
            VEOUTROS()                                        // escolhe arquivo a consultar
            br_w := br_w1                                     // restaura o browse
            br_w:configure()                                  // remonta titulo da colunas
            volta_db=.t.
            li_sup=l_sup; li_inf=l_inf                        // restaura as coordenadas da
            co_sup=c_sup; co_inf=c_inf                        // janela e
            mo_dif=m_od                                       // rotinas acessadas
            br_w:refreshall()                                 // refaz os dados na tela
            FORCABRW(.f.)                                     // forca browse do 2a. janela (se existir)
            MONTABRW()                                        // remonta as bordas da janela
         ELSEIF tem_t                                         // transfere o campo para o get pendente
            SEPARA(br_w:getcolumn(br_w:colpos):cargo)         // separa atrib coluna e transf p/ caracter
            IF tp_cp="D"
               msg=STRTRAN(DTOC(&cp_.),"/")
            ELSE
               msg=TRANSCAMPO(.t.,cp_)
            ENDI
            KEYB ALLTRIM(msg)                                 // coloca campo no buffer do teclado
            volta_db=.f.
         ENDI
      ELSEIF tecl_p = K_ALT_F10                               // ALT-F10 esconde e mostra os
         SET(_SET_DELETED,!SET(_SET_DELETED))                 // registros excluidos na consulta
         IF DELE() .AND. SET(_SET_DELETED)                    // registro esta apagado
            MOV_PTR(1)                                        // acha o 1o. reg nao apagado
         ENDI
         br_w:refreshall()                                    // remonta os dados do browse
         br_w:forcestable()                                   // apresenta os dados
         br_w:refreshcurrent()                                // refaz so' a linha do browse
         FORCABRW(.f.)

      ELSEIF tecl_p = K_ALT_G                                 // grava a consulta em arquivo
         t=ALIAS()                                            // salva arquivo corrente
         br_w1 := br_w                                        // e browse atual
         SELE (m_origem)                                      // selecion dbf da janela de cima
         cod_sos=22                                           // novo codigo de help
         db_aqcom=PADR(br_tit,58)                             // default para o titulo a gravar
         ALERTA(2)                                            // solicita o titulo para a consulta
         db_aqcom=DBOX("Identifique-a para grava��o. ESC cancela",,,,,"GRAVA CONSULTA",db_aqcom)
         db_aqcom=ALLTRIM(db_aqcom)                           // tira brancos do nome
         IF LASTKEY()!=K_ESC.AND.!EMPT(db_aqcom)              // se nao cancelou...
            pas = "1"                                         // grava paramenetros das duas janelas
            br_w = br_origem                                  // vai para janela de cima
            db_outro=IF(outro_db=NIL,"",ALIAS(VAL(outro_db)))
            db_indrela=ind_rela                               // indice utilizado para relacionar
            DO WHILE .t.
               db_&pas.qtdc=br_w:colcount                     // numero de colunas
               FOR i=1 TO db_&pas.qtdc                        // para cada coluna
                  tt=RIGHT(STR(100+i,3),2)
                  db_&pas.carg&tt.= br_w:getcolumn(i):cargo   // (conteudo,mascara,titulo,pre-val,valida,tipo)
                  db_&pas.tam&tt. = br_w:getcolumn(i):width   // tamanho da coluna
               NEXT
               id_carg = br_w:cargo                           // situacao do browse
               db_&pas.expo=id_carg[2]                        // ordem
               db_&pas.arqf=id_carg[1]                        // filtro
               db_&pas.chvr=id_carg[3]                        // relacionamento, outra janela
               db_&pas.ind_ord=id_carg[4]                     // indice atual
               db_&pas.freeze=br_w:freeze                     // coluna congelada
               IF pas = "1" .AND. br_outro != NIL             // tem outra janela aberta?
                  pas="2"                                     // salva o mesmo
                  SELE (outro_db)                             // para a outra janela
                  br_w = br_outro
               ELSE
                  EXIT                                        // tudo feito...
               ENDI
            ENDD
            IF br_tit==db_aqcom                               // se for a mesma consulta lida
               aqdbe=br_arq                                   // grava no arquivo de mesmo nome
            ELSE                                              // se nao,
               DO WHIL .t.                                    // procura um nome para gravar
                  hms=TIME()                                  // a consulta
                  resaq=LEFT(hms,2)+SUBS(hms,4,2)+RIGHT(hms,2)+"."+LEFT(ALIAS(VAL(m_origem)),3)
                  aqdbe=drvdbf+"DB"+resaq
                  IF ! FILE("&aqdbe.")                        // se achou um
                     EXIT                                     // cai fora...
                  ENDI
               ENDD
            ENDI
            SAVE ALL LIKE db_* TO (aqdbe)                     // salva em disco a consulta
         ENDI
         SELE (t)                                             // volta para a area anterior
         br_w := br_w1                                        // e browse atual

      ELSEIF tecl_p = K_ALT_F8                                // ALT-F8 rola a janela
         li_sup-=2; co_sup--                                  // ajusta coordenadas e
         li_inf++; co_inf++                                   // executa a rolagem da janela
         MUDA_PJ(@li_sup,@co_sup,@li_inf,@co_inf,brw_fundo,.t.)
         li_sup+=2; co_sup++                                  // reajusta as coordenadas
         li_inf--; co_inf--
         PUBL &vr_edita.:=STR(li_sup,2)+STR(co_sup,2)         // publica variaves que contem
         SAVE TO (arqconf) ALL LIKE drv*                      // as coordenadas da janela e
         REST FROM (arqconf) ADDI                             // grava em disco
         br_origem:ntop   := li_sup                           // ajusta browse com
         br_origem:nleft  := co_sup                           // as novas coordenadas
         br_origem:nbottom:= li_inf
         br_origem:nright := co_inf
         IF br_outro != NIL                                   // se existe outra janela aberta
            M->tp=li_sup+INT((li_inf-li_sup-1)/2)+1           // ajusta as coordenadas dela
            br_origem:nbottom:=M->tp-2                        // tambem
            br_outro:ntop   := M->tp+1
            br_outro:nleft  := co_sup
            br_outro:nbottom:= li_inf
            br_outro:nright := co_inf
            FORCABRW(.f.)                                     // reemprime dados na tela
         ENDI
      ENDI
      carac_ = UPPER(CHR(tecl_p))                             // escolheu uma rotina...
      IF AT(carac_,"ERMG")>0 .AND.RECC()=0                    // nao permite alterar um
         LOOP                                                 // arquivo vazio...
      ENDI
      l_m=IF(op_sis>nss,"",exrot[op_sis])                     // arq de senhas nao tem restricoes
      IF AT(carac_,mo_dif+l_m)>0                              // se usuario nao tem permissao
         LOOP                                                 // nao deixa executar
      ENDI
      IF AT(carac_,"DERMGV")>0 .AND.;                         // se vai alterar um registro
         LEN(sistema[op_sis,O_CPRELA])>0                      // e se e' um filho
         POSIPAI()                                            // abre/posiciona seus pais
      ENDI
      DO CASE

         #ifdef COM_REDE
            CASE (tecl_p=43 .OR. tecl_p=45)                   // teclou + ou - para mudar o "refresh"
               DO WHILE .T.
                  msg=LTRIM(STR(drvtempo))
                  msg=IF(drvtempo=0,"N�o",msg+" seg")         // tempo=0 nao tem "refresh"
                  ALERTA(1)
                  DBOX(msg,,,25,,"'REFRESH`|(+/-)")           // mostra msg do tempo atual
                  IF LASTKEY()=43                             // teclou +, entao
                     drvtempo=IF(drvtempo>57,60,drvtempo+5)   // aumenta o tempo em 5 seg
                  ELSEIF LASTKEY()=45                         // teclou -, entao
                     drvtempo=IF(drvtempo<1,0,drvtempo-5)     // diminui o tempo em 5 seg
                  ELSE                                        // teclou algo diferente de + e -
                     EXIT                                     // entao aceita refresh atual
                  ENDI
               ENDD
         #endi


         CASE tecl_p = K_ENTER                                // teclou o ENTER
            KEYB CHR(VAL(SUBS(ch_tecl,dir_cur*2-1,2)))        // anda para onde a SETA (TAB) aponta

         CASE tecl_p = K_TAB                                  // teclou o TAB
            dir_cur()                                         // muda direcao do cursor

         CASE tecl_p = K_ALT_Z .AND. !db_zoom                 // aumenta o tamanho da janela
            li_sup=3; li_inf=22; co_sup=3; co_inf=77          // coordenadas da janela expandida
            br_origem:nTop   := li_sup                        // passa as novas coordenadas
            br_origem:nbottom:= li_inf                        // para o browse de cima
            br_origem:nleft  := co_sup
            br_origem:nright := co_inf
            IF br_outro != NIL                                // existe a janela de baixo
               M->tp=li_sup+INT((li_inf-li_sup-1)/2)+1        // linha de divisao das janelas
               br_origem:nbottom := M->tp - 2                 // final da janela de cima
               br_outro:nTop   := M->tp+1                     // topo da jenela de baixo
               br_outro:nbottom:= li_inf                      // ajusta o resto das
               br_outro:nleft  := co_sup                      // coordenadas
               br_outro:nright := co_inf
            ENDI
            db_zoom:=.t.                                      // flag dizendo do zoom
            FORCABRW(.t.)                                     // reimprime janela nao ativa
            MONTABRW()                                        // remonta janela

         CASE tecl_p = K_F1                                   // teclou F1
            help()                                            // mostra ajuda correspondente

         CASE tecl_p = K_ESC                                  // teclou ESC
            volta_db=.f.                                      // abandona a consulta

         CASE carac_="A" .AND. br_w:colcount > 1              // apaga consulta se mais de 1 coluna
            ALERTA(2)                                         // pede confirmacao
            msg="Apagar a coluna|Cancelar a opera��o"
            cod_sos=1
            op_=DBOX(msg,,,E_MENU,,"COLUNA "+MAIUSC(br_w:getcolumn(br_w:colpos):heading))
            IF op_=1                                          // confirmou...
               br_w:delColumn(br_w:colpos)                    // retira a coluna do browse
               grava_db = .t.                                 // seta flag de consulta alterada
               br_w:configure()                               // remonta todo browse
            ENDI

         CASE carac_="C" .AND.;                               // congela/descongela coluna se
              br_w:colpos-1 != br_w:freeze                    // a coluna ja' congelada
            IF br_w:freeze != 0                               // se outra coluna ja' congelada
               br_w:getcolumn(br_w:freeze+1):colsep:=NIL      // retira o marcador da coluna congelada
            ENDI
            br_w:freeze := br_w:colpos - 1                    // congela coluna requerida
            IF br_w:freeze != 0                               // se nao descongelou todas colunas
               br_w:getcolumn(br_w:colpos):colsep:=" � "      // coloca marcador de colunas congeladas
            ENDI
            br_w:configure()                                  // remonta todo browse
            grava_db = .t.                                    // seta flag de consulta alterada

         CASE carac_="D"                                      // inclusao de registros
            IF LEN(sistema[op_sis,O_CPRELA])>0 .AND.;         // se for arquivo filho
               (br_w==br_origem .OR. EMPTY(chv_rela))         // e for janela original
               ALERTA(2)                                      // nao pode incluir!
               DBOX("Inclus�o n�o permitida!",,,3)            // mensagem ao usuario
               LOOP                                           // e retorna ao browse
            ENDI
            dele_atu=SET(_SET_DELETED,!drvvisivel)            // salva DELE() atual,
            br_w1 := br_w                                     // browse atual,
            brw_tela = SAVESCREEN(0,0,MAXROW(),79)            // tela atual e o
            in_=INDEXORD()                                    // indice atual para incluirmos
            DBSETORDER(1)                                     // sempre pelo indice principal
            brw=.f.; op_menu=INCLUSAO                         // prepara para inclusao
            Tela_fundo=SAVESCREEN(0,0,MAXROW(),79)            // salva pano de fundo para ALT-F8
            IF op_sis>nss
               PW_INCL()                                      // inclusao de novos operadores
            ELSE
               &arq_cor._incl()                               // inclusao de novos registros de dados
            ENDI
            op_menu=PROJECOES; brw=.t.                        // volta para consulta
            DBSETORDER(in_)                                   // retorna ao indice da consulta
            REGINICIO()                                       // verifica se reg esta' no filtro
            RESTSCREEN(0,0,MAXROW(),79,brw_tela)              // restaura a tela,
            SET(_SET_DELETED,dele_atu)                        // DELE() e o
            br_w := br_w1                                     // browse anteriores
            br_w:refreshall()                                 // reapresenta os dados na tela
            FORCABRW(.f.)                                     // forca remontagem da janela relacionada
            MONTABRW()

         CASE carac_="E"                                      // exclui registro

            #ifdef COM_REDE
               IF !BLOREG(10,.5)                              // tenta bloquear o arquivo
                  LOOP                                        // nao conseguiu...
               ENDI
            #endi

            IF ! DELE()                                       // ja esta excluido?
               IF CONFEXCL()                                  // pede confirmacao
                  IF op_sis<=nss                              // se nao for a senha
                     &arq_cor._get1(EXCLUI)                   // exclui registro/processo inverso
                  ELSE                                        // se nao,
                     DELE                                     // so' exclui
                  ENDI
                  br_w:refreshall()                           // remonta os reg da tela
                  FORCABRW(.f.)                               // remonta janela relacionada
               ENDI
            ENDI

            #ifdef COM_REDE
               UNLOCK                                         // libera o registro
            #endi

            IF DELE() .AND.SET(_SET_DELETED)                  // se nao que ver excluidos
               MOV_PTR(1)                                     // procura o proximo que
            ENDI                                              // nao esteje excluido

         CASE carac_="F" .OR. carac_="Q"                      // filtra/quantifica
            cri_ant = criterio
            IF carac_="F"                                     // filtra
               FILTRA(.t.,.t.)                                // escolhe o filtro
               br_w:cargo := {criterio,cpord,chv_rela,INDEXORD()}
               br_w:refreshall()                              // refaz toda a tela
               IF cri_ant!=criterio.AND.!EMPTY(criterio)      // se alterou o filtro
                  grava_db=.t.                                // seta flag de consulta alterada
               ENDI
            ELSE                                              // quantifica
               FILTRA(.f.)                                    // so' monta a expressao
               condq=criterio                                 // retorna filtro anterior
               criterio = cri_ant
            ENDI
            brw_reg=RECN()                                    // salva registro atual
            IF carac_="Q" .AND. LEN(condq)>2                  // continuacao da quantificacao
               brw_tela = SAVESCREEN(0,0,MAXROW(),79)         // da mensagem que esta contando...
               DBOX("Condi��o:|"+LEFT(condq,78)+"|| AGUARDE...  Contando. ESC cancela",,,,NAO_APAGA)
               INI_ARQ()                                      // move ponteiro para o inicio do arquivo

               #ifdef COM_TUTOR
                  COUN FOR &condq WHIL IN_KEY()!=K_ESC TO qu  // conta....
               #else
                  COUN FOR &condq WHIL INKEY()!=K_ESC TO qu   // conta....
               #endi

               IF LASTKEY()!=K_ESC                            // nao cancelou entao mostra
                  ALERTA(2)                                   // quantos reg foram contados
                  DBOX("Existe(m) "+LTRIM(TRAN(qu,"@E 9,999,999"))+" registro(s)|na condi��o|"+LEFT(condq,78)+"|*",8)
               ENDI
               RESTSCREEN(0,0,MAXROW(),79,brw_tela)           // restaura a tela anterior e
               GO brw_reg                                     // o registro
            ENDI
            MONTABRW()                                        // remonta janela de visualizacao

         CASE carac_="G"                                      // processo glogal
            brw_tela = SAVESCREEN(0,0,MAXROW(),79)            // salva situacao atual
            brw_reg = RECNO()
            GLOBAL()                                          // executa processo
            GO brw_reg                                        // restabelece situacao anterior
            REGINICIO()                                       // verifica se reg esta' no filtro
            br_w:cargo := {criterio,cpord,chv_rela,INDEXORD()}
            br_w:refreshall()                                 // remonta dados da tela
            RESTSCREEN(0,0,MAXROW(),79,brw_tela)              // restaura tela
            MONTABRW()                                        // remonta janela do browse

         CASE carac_="I"                                      // imprime consulta
            IMP_BRW()

         CASE carac_="J" .AND. br_outro != NIL                // troca janela de consulta
            TROCA_BRW()                                       // troca arquivo do browse
            br_w:colorspec := drvcorbox+","+INVCOR(drvcorbox)+","+drvcorenf+","+drvcorget
            FORCABRW(.t.)                                     // troca as cores da janela
            MONTABRW()                                        // remonta dados e a
            br_w:hilite()                                     // janela com a nova cor

         CASE carac_="J"                                      // abre uma nova janela
            msg=""; op_a=0; db=""
            pp=SETKEY(K_F9,NIL)                               // desliga F9 (consulta outro DBF)
            FOR i=1 TO nss                                    // monta menu de DBF disponiveis
               IF sistema[i,O_OUTROS,O_NIVEL]<=nivelop
                  msg+="|"+sistema[i,O_MENU]
                  db+=RIGHT(STR(100+i),2)
               ENDI
            NEXT
            cod_sos=30
            IF LEN(msg)>1                                     // escolhe o DBF da nova janela
               op_a=DBOX(SUBS(msg,2),,,E_MENU,,"BASES DE DADOS")
            ENDI
            IF op_a>0                                         // escolheu...
               op_a=VAL(SUBS(db,op_a*2-1,2))                  // acha a sua subscricao
               op_sis_x=op_sis                                // salva subscricao atual
               SETCOLOR(drvcortna)
               IF abreoutro(op_a)                             // e abre a outra janela
                  grava_db = .t.                              // flag de consulta alterada
                  tit_cons[2]=sistema[op_sis,O_MENS]          // titulo da segunda janela
                  IF op_sis_x != op_sis
                     SELE (m_origem)
                     x_=ASCAN(sistema[op_sis_x,O_DBRELA],{|db_|sistema[op_sis,O_ARQUI]=db_})
                     i_=LEN(sistema[op_sis,O_CPRELA])         // se DBF escolhido e relacionado,
                     IF x_>0.AND.i_>0                         // monta a expressao de relacionamento
                        chv_rela=""
                        FOR i=1 TO LEN(sistema[op_sis,O_CPRELA])
                           chv_rela+="+"+TRANSCAMPO(.f.,sistema[op_sis,O_CPRELA,i],i)
                        NEXT
                     ELSE                                     // se usuario montar expressao
                        PEGARELA(.t.)
                     ENDI
                     chv_rela=IF(LEN(chv_rela)>2,SUBS(chv_rela,2),"")
                     br_outro:cargo := {"","",chv_rela,1}     // inicializa variavel de usuario
                  ENDI
                  criterio:=cpord := ""                       // inicializa filtro/ordenacao
                  SELE (outro_db)                             // muda para a janela de baixo
                  PEGACHV2()                                  // pega final do relaciomento
                  INI_ARQ()                                   // procura 1o. reg da relacao
                  LDBEDIT(.f.)                                // monta as novas colunas
                  FORCABRW(.t.)                               // imprime dados da janela de cima
                  MONTABRW()                                  // monta nova janela de visualizacao
               ELSE
                  op_sis = op_sis_x                           // nao conseguiu abrir nova janela
               ENDI
            ENDI
            SETKEY(K_F9,pp)                                   // habilita F9 (consulta outros DBFs)

         CASE carac_="L"                                          // localiza registro
            SEPARA(br_w:getcolumn(br_w:colpos):cargo)             // separa atributos da coluna
            cod_sos=36
            ecara=(tp_cp=="C".OR.tp_cp=="M")                      // tipo do campo
            brw_tela = SAVESCREEN(0,0,MAXROW(),79)                // salva tela atual
            chvpesq=IF(ecara,SPAC(30),IF(tp_cp="D",CTOD(''),IF(tp_cp="L",.t.,0)))
            msg="Argumento - Localiza argumento no campo "+cp_titu+;
                "|Condi��o - Localiza registro sob uma condi��o"+;
                "|Cancelar a opera��o"                            // escolhe o tipo de localizacao
            x=DBOX(msg,,,E_MENU,,SEPLETRA("LOCALIZA��O",1))
            IF x!=0 .AND. x!=3                                    // nao cancelou
               cond_p=""
               IF x=1                                             // localiza por argumento
                  msg="LOCALIZAR ARGUMENTO "+IF(ecara,"CONTIDO ","")+" EM "+MAIUSC(cp_titu)
                  chvpesq=DBOX("Informe o argumento",,,,,msg,chvpesq,cp_masc)
                  IF cp_crit=="V" .OR. CRIT(cp_crit,18)           // argumento de pesquisa ok?
                     IF (!EMPT(chvpesq) .OR. tp_cp="L").AND.LASTKEY()!=K_ESC
                        IF ecara                                  // se for caracter
                           chvpesq=ALLTRIM(chvpesq)               // deixa localizar so as letras digitadas
                           igc=1                                  // se tem minusculo no campo
                           IF cp_masc!="@!"                       // pergunta se quer ignorar a caixa
                              igc=DBOX("Sim|N�o|Cancelar a opera��o",,,E_MENU,,"IGNORAR CAIXA|(A=a)?")
                           ENDI
                           IF igc=1.OR.igc=2                      // prepara expressao de pesquisa
                              cond_p=IF(igc=2,"'"+chvpesq+"' $ "+cp_,"MAIUSC('"+chvpesq+"') $ UPPER("+cp_+")")
                           ENDI
                        ELSE
                           cond_p=cp_+"=chvpesq"                  // prepara expressao de pesquisa
                        ENDI
                     ENDI
                  ENDI
               ELSE                                               // localiza por condicao
                  cri_ant = criterio                              // salva filtro atual
                  FILTRA(.f.)                                     // monta expressao de pesquisa
                  cond_p=criterio
                  criterio = cri_ant                              // retorna filtro atual
               ENDI
               RESTSCREEN(0,0,MAXROW(),79,brw_tela)               // restaura tela anterior
               IF LEN(cond_p)>2                                   // continua a localizar...
                  DBOX("Localizando|"+LTRIM(TRAN(chvpesq,""))+"|*|ESC interrompe",,,,NAO_APAGA,"AGUARDE...")
                  brw_reg=RECN()
                  INI_ARQ()                                       // move ponteiro para o inicio do arquivo

                  #ifdef COM_TUTOR
                     LOCA FOR &cond_p. WHIL IN_KEY()!=K_ESC       // tenta localizar registro desejado
                  #else
                     LOCA FOR &cond_p. WHIL INKEY()!=K_ESC        // tenta localizar registro desejado
                  #endi

                  IF ! FOUND().AND.LASTKEY()!=K_ESC               // nao achou ou cancelou
                     ALERTA(4)
                     DBOX("N�o encontrado!|*",13,40)              // mensagem ao usuario
                     GO brw_reg
                  ELSE
                     ALERTA(1)                                    // achou...
                     fg_loc=.t.                                   // sinal sonoro
                  ENDI
               ENDI
               br_w:refreshall()                                  // remonta os dados da consulta
            ENDI
            RESTSCREEN(0,0,MAXROW(),79,brw_tela)                  // restaura tela anterior

         CASE carac_="M"                                          // modifica registro
            IF !br_w:stable                                       // forca a apresentacao de
               br_w:forcestable()                                 // todos os registros na tela
               x_=COL(); y_=ROW()                                 // salva coordenadas atuais do cursor
            ENDI

            #ifdef COM_REDE
               IF !BLOREG(10,.5)                                  // tenta bloquear o registro
                  LOOP                                            // nao conseguiu...
               ENDI
            #endi

            SEPARA(br_w:getcolumn(br_w:colpos):cargo)             // separa atributos da coluna
            evirt=(cp_crit=="V")                                  // pode modificar?
            IF (AT(UPPER(cp_),UPPER(INDEXKEY(1)))>0.AND.sistema[op_sis,O_OUTROS,O_TPCHV]).OR.;
               evirt.OR.DELE()
               ALERTA()
               DBOX(IF(DELE(),"REGISTRO EXCLU�DO","CAMPO N�O EDIT�VEL"),12,,1)
            ELSE
               IF op_sis<=nss                                     // se nao esta' alterando a senha,
                  &arq_cor._get1(FORM_INVERSA)                    // executa processo inverso, se existir
               ENDI
               pp=.f.                                             // flag "refresh" na outra janela?
               IF IF(!EMPTY(cp_when).AND.;                        // tem pre-validacao. pode modificar?
                  !("MTAB(" $ cp_when),EVAL(&("{||"+cp_when+"}")),.t.)
                  SETCOLOR(drvcorbox)                             // coloca mensagem no topo da janela
                  IF br_w:nleft+22<br_w:nright                    // avisando que estamos modificando
                     @ br_w:ntop-2,br_w:nleft+12 SAY "{Modifica}"
                  ENDI
                  brw_reg = RECNO()                               // salva registro atual
                  ALERTA(1)                                       // Beep!
                  IF tp_cp=="M"                                   // campo memo...
                     EDIMEMO(cp_,cp_titu,15,2,MAXROW()-1,3+VAL(SUBS(cp_masc,3)),cp_crit)
                  ELSE
                     i = br_w:getcolumn(br_w:colpos):width        // o tamanho atual da coluna
                     IF i != LEN(TRAN(&cp_.,cp_masc)) .AND.;      // esta' diferente to tamanho
                        tp_cp="C"                                 // real do campo estao vamos
                        cp_masc="@S"+ALLTRIM(STR(i,3))+cp_masc    // forcar a rolagem do campo
                     ENDI
                     @ y_,x_ GET &cp_. PICT cp_masc;
                                       VALI CRIT(cp_crit);
                                       WHEN cp_when
                                       AJUDA cp_help
                                       CMDF8 cp_cmd
                     READ
                  ENDI
                  IF br_w:nleft+22<br_w:nright                    // retira mensagem de alteracao
                     @ br_w:ntop-2,br_w:nleft+12 SAY REPL(SUBS(mold,2,1),10)
                  ENDI
                  REGINICIO()                                     // verifica se reg esta' no filtro
                  br_w:refreshcurrent()                           // refaz a linha onde o campo foi modificado
                  IF tp_cp!="M".AND.LASTKEY()!=K_ESC.AND.;        // se o campo nao for memo, nao deu ESC,
                     RECNO()=brw_reg .AND.;                       // nao esta fora do filtro/relacao e
                     AT(UPPER(cp_),UPPER(INDEXKEY(0)))=0          // o campo nao faz parte do indice
                     i_=CHR(VAL(SUBS(ch_tecl,dir_cur*2-1,2)))     // entao passa para o proximo campo
                     KEYB i_+"M"                                  // onte o TAB esta indicando
                  ELSE                                            // caso contrario,
                     IF RECNO() <> brw_reg .OR.;                  // se o campo esta fora do filtro
                        AT(UPPER(cp_),UPPER(INDEXKEY(0)))>0       // ou o campo for parte do indice
                        br_w:refreshall()                         // remonta toda a tela
                     ENDI
                     pp=.t.                                       // flag para refazer o browse
                  ENDI
                  GO brw_reg                                      // reposiciona ponteiro

               ELSE                                               // nao pode ser modificado
                  ALERTA()                                        // mostra por que
                  DBOX("Modifica quando "+UPPER(cp_when),,,3,,"PR�-CR�TICA N�O ATENDIDA!")
               ENDI

               IF op_sis<=nss                                     // se nao for o arquivo de senhas,
                  &arq_cor._get1(FORM_DIRETA)                     // executa processos/lancamentos
               ENDI
               IF pp                                              // se for preciso, forca
                  REGINICIO()                                     // verifica se reg esta' no filtro
                  FORCABRW(.f.)                                   // browse da outra janela
               ENDI
            ENDI

            #ifdef COM_REDE
               UNLOCK                                             // atualiza o disco
            #endif


         CASE carac_="N"                                          // cria nova coluna
            cod_sos=28
            cp_ =SPAC(250) ; cp_titu=SPAC(30)                     // inicializa variveis
            cp_masc=SPAC(30)
            msg="T�tulo da nova coluna:"
            f10=.f.                                               // recebe titulo da nova coluna
            SET KEY K_F10 TO colnova                              // F10 campo de outro arquivo
            cp_titu=DBOX(msg,,,,,"NOVA COLUNA|*|F10=CAMPO DE OUTRO ARQUIVO",cp_titu)
            SET KEY K_F10 TO                                      // desativa F10
            IF LASTKEY()!=K_ESC                                   // se nao abandonou e nao teclou
               IF !f10                                            // F10, recebe conteudo da nova coluna
                  msg+=" "+ALLTRIM(cp_titu)+"|Express�o conte�do:"
                  DO WHILE .t.
                     SET KEY K_F10 TO ve_campos                   // F10 ve campos da estrutura
                     cp_=DBOX(msg,,,,,"NOVA COLUNA|*|F10=CAMPOS DO ARQUIVO",cp_,"@S52@!")
                     SET KEY K_F10 TO                             // desativa F10
                     IF LASTKEY()!=27 .AND. !EMPTY(cp_)           // verifica se o conteudo e valido
                        IF !CRIT("[U]!=TYPE(cp_) .OR. ([|] $ cp_ .AND. [->] $ cp_)~EXPRESS�O ILEGAL",15)
                           LOOP
                        ENDI
                     ENDI
                     EXIT
                  ENDD
               ENDI
               IF !EMPT(cp_) .AND. LASTKEY()!=K_ESC              // nao cancelou...
                  IF !f10                                        // recebe mascara da nova coluna
                     msg+=" "+LEFT(ALLTRIM(cp_),30)+"|Com a m�scara:"
                     cp_masc=DBOX(msg,,,,,"NOVA COLUNA",cp_masc,"@!")
                  ENDI
                  IF LASTKEY()!=K_ESC                            // se nao cancelou
                     IF SETARELA(cp_)                            // coloca set relation
                        IF br_w == br_origem                     // e prepara variavel para
                           db_1rela=db_1rela+TRIM(cp_)+"�"       // a gravacao da consulta
                        ELSE
                           db_2rela=db_2rela+TRIM(cp_)+"�"
                        ENDI
                        cp_=SUBS(cp_,AT("|",cp_)+1)
                     ENDI                                        // cria nova coluna com o que
                     ncol = br_w:colpos                          // foi informado
                     cp_titu=ALLTRIM(cp_titu) ; cp_=ALLTRIM(cp_) ; cp_masc=ALLTRIM(cp_masc)
                     br_w:inscolumn(ncol,tbcolumnnew(cp_titu,&("{||TRAN("+cp_+",["+cp_masc+"])}")))
                     br_w:getcolumn(ncol):cargo := cp_+"�"+cp_masc+"�"+cp_titu+"��V"
                     br_w:getcolumn(ncol):width := LEN(TRAN(&cp_.,cp_masc))
                     br_w:getcolumn(ncol):colorblock={||IF(DELE(),{3,2},{1,2})}
                     grava_db = .t.                              // modificou a consulta (flag)
                     br_w:refreshall()                           // remonta toda a tela
                  ENDI
               ENDI
            ENDI
            SET KEY K_F10 TO                                     // desativa F10

         CASE carac_="O"                                     // ordenacao da consulta
            cpord=""
            br_wx = br_w                                     // salva browse atual
            CLASS(.t.)                                       // recebe expressao de ordenacao
            IF !EMPT(cpord)                                  // montou ordenacao?
               br_w:refreshall()                             // refaz toda a tela
               grava_db = .t.                                // guarda ordenacao na variavel de usuario
               br_w:cargo:={criterio,cpord,chv_rela,INDEXORD()}
            ENDI
            MONTABRW()                                       // refaz todo o browse

         CASE carac_="P" .AND. ! EMPT(INDEXKEY(1))           // pesquisa indexada de registro
            brw_reg = RECNO()                                // registro atual
            POSI()                                           // recebe/procura registro
            IF brw_reg != RECNO()                            // se o reg nao e o mesmo,
               br_w:rowpos = 1                               // coloca reg atual na primeira
            ENDI                                             // linha da tela
            br_w:configure()                                 // refaz a configuracao do browse

         CASE carac_="R"                                     // recupera registro

            #ifdef COM_REDE
               IF !BLOREG(10,.5)                             // se nao bloqueou o registro,
                  LOOP                                       // retorna ao browse
               ENDI
            #endi

            IF DELE()                                        // se o registro esta' excluido
               IF op_sis<=nss                                // se o arquivo nao for o de senhas,
                  &arq_cor._get1(RECUPERA)                   // recupera reg/processo direto
               ELSE                                          // se for o de senhas
                  RECA                                       // so' recupera
               ENDI
               ALERTA(1)                                     // aviso sonoro
               br_w:refreshcurrent()                         // refaz so' a linha do browse
               FORCABRW(.f.)                                 // remonta a outra janela (se houver)
            ENDI

            #ifdef COM_REDE
               UNLOCK                                        // libera registro
            #endi


         CASE carac_="S".AND.fg_loc                          // seguinte (proximo do localiza)
            brw_tela = SAVESCREEN(0,0,MAXROW(),79)           // salva tela/avisa que esta localizando
            DBOX("LOCALIZANDO "+LTRIM(TRAN(chvpesq,""))+".|ESC interrompe",,,,NAO_APAGA,"AGUARDE!")
            brw_reg=RECN()                                   // salva registro atual
            SKIP IF(EOF(),0,1)                               // pula para o proximo, se nao for fim de arq

            #ifdef COM_TUTOR
               LOCA FOR &cond_p. WHIL IN_KEY()!=K_ESC        // continua a procura...
            #else
               LOCA FOR &cond_p. WHIL INKEY()!=K_ESC         // continua a procura...
            #endi

            IF ! FOUND().AND.LASTKEY()!=K_ESC                // se nao achou,
               ALERTA(4)                                     // avisa
               DBOX("Registro n�o encontrado!",13,40)
               GO brw_reg
            ELSE                                             // achou...
               ALERTA(1)                                     // avisa com beep e
               br_w:refreshall()                             // prepara p/ remontar toda a tela
            ENDI
            RESTSCREEN(0,0,MAXROW(),79,brw_tela)             // retira msg de "localizando"

         CASE carac_="T"                                     // muda tamanho da coluna
            SEPARA(br_w:getcolumn(br_w:colpos):cargo)        // pega tamanho atual
            x=IF(TYPE(cp_)=="M",60,LEN(TRAN(&cp_.,cp_masc)))
            msg="Informe o novo tamanho da coluna "+;
                MAIUSC(br_w:getcolumn(br_w:colpos):heading)
            cod_sos=1
            x=DBOX(msg,,,,,"TAMANHO DA COLUNA",x,"99")       // recebe o novo tamanho
            IF CRIT(STR(x)+"<=77.AND."+STR(x)+;              // se o tamanho e valido
               ">0~TAMANHO ILEGAL",12)
               br_w:getcolumn(br_w:colpos):width = x         // atualiza tamanho da coluna
               grava_db = .t.                                // no browse e
               br_w:configure()                              // reconfigura tudo
            ENDI

         CASE carac_="V"                                     // ve todo o registro na tela
            tela_fundo=SAVESCREEN(0,0,MAXROW(),79)           // salva tela
            t_tab:=SETKEY(K_TAB,NIL)                         // desativa o TAB
            q_tela=sistema[op_sis,O_TELA,O_ATUAL]            // salva numero da tela atual
            sistema[op_sis,O_TELA,O_ATUAL]=1                 // e move para a primeira tela

            #ifdef COM_MOUSE
               IF drvmouse                                   // se mouse esta' ativo,
                  MOUSEGET(@x_,@y_)                          // salva sua posicao atual
               ENDI
            #endi

            i_=SETCOLOR()                                    // salva a cor atual
            DO WHILE .t.
               DISPBEGIN()                                   // comeca a montagem da tela
               IMPRELA()                                     // imprime telas relacionadas
               &arq_cor._gets()                              // apresenta o conteudo do registro
               INFOSIS()                                     // imprime o rodape' da tela
               DISPEND()                                     // mostra tela pronta
               ALERTA(1)
               cod_sos=35

               #ifdef COM_MOUSE
                  tecl_p=MOUSETECLA(l_s,c_s,l_i,c_i,.f.)     // espera clique ou alguma tecla
               #else

                  #ifdef COM_TUTOR

                     #ifdef COM_REDE
                        tecl_p=IN_KEY(drvtempo)                // espera tecla ou sai para refresh
                     #else
                        tecl_p=IN_KEY(0)                       // espera uma tecla ser digitada
                     #endi

                  #else

                     #ifdef COM_REDE
                        tecl_p=INKEY(drvtempo)                 // espera tecla ou sai para refresh
                     #else
                        tecl_p=INKEY(0)                        // espera uma tecla ser digitada
                     #endi

                  #endi

               #endi

               DO CASE
                  CASE tecl_p=K_ALT_F8                       // teclou F8 (rolagem da janela)
                     rola_t=.t.                              // liga flag e
                     ROLATELA()                              // executa a rolagem
                  CASE tecl_p=K_PGUP                         // pagina anterior
                     IF sistema[op_sis,O_TELA,O_ATUAL]=1
                        sistema[op_sis,O_TELA,O_ATUAL]=1
                     ELSE
                        sistema[op_sis,O_TELA,O_ATUAL]--
                     ENDI
                  CASE tecl_p=K_PGDN                         // pagina seguinte
                     IF sistema[op_sis,O_TELA,O_ATUAL]>=sistema[op_sis,O_TELA,O_DEF]
                        sistema[op_sis,O_TELA,O_ATUAL]=sistema[op_sis,O_TELA,O_DEF]
                     ELSE
                        sistema[op_sis,O_TELA,O_ATUAL]++
                     ENDI
                  CASE tecl_p=K_ESC.OR.tecl_p=K_ENTER.OR.tecl_p=32
                     EXIT                                    // abandona
               ENDC
            ENDD
            SETCOLOR(i_)                                     // restaura cor anterior

            #ifdef COM_MOUSE
               IF drvmouse                                   // define janela do mouse
                  MOUSEBOX(br_w:ntop-1,br_w:nleft-1,br_w:nbottom+1,br_w:nright+1)
                  DO WHIL MOUSEGET(0,0)!=0                   // so' sai se os botoes do
                  ENDD                                       // mouse estiverem liberados
                  MOUSESET(x_,y_)                            // restaura a posicao do mouse
               ENDI
            #endi

            sistema[op_sis,O_TELA,O_ATUAL]=q_tela            // restaura num da tela
            RESTSCREEN(0,0,MAXROW(),79,tela_fundo)           // restaura tela
            SETKEY(K_TAB,t_tab)                              // TAB volta a funcionar

         CASE carac_="X"                                           // exporta dados
            cod_sos=32                                             // escolhe o formato da exportacao
            msg="Texto - delimitados, para editores de texto|"+;
                "SDF - 'standard Data Format` para outros sistemas|"+;
                "DBF - formato padr�o dBASE"
            op_exp=DBOX(msg,,,E_MENU,,"TIPO DE ARQUIVO DE SAIDA")
            IF op_exp!=0
               IF op_exp=1                                         // escolheu o delimitado, entao
                  dli_exp=","                                      // escolhe o delimitador
                  dli_exp=DBOX("Informe o delimitador",,,,,"SEPARA��O DOS CAMPOS",dli_exp)
               ENDI
               IF LASTKEY()!=K_ESC
                  brw_tela = SAVESCREEN(0,0,MAXROW(),79)           // salva a tela
                  arq_=ARQGER()                                    // recebe o nome do arquivo a gerar
                  IF !EMPTY(arq_)                                  // quer continuar...
                     cod_sos=1
                     arqexp=arq_+".TXT"                            // se o arq informado existir
                     IF FILE(arqexp)                               // verifica se pode gravar por cima
                        op_=DBOX("Gravar por cima|Cancelar a opera��o",,,E_MENU,,"ARQUIVO "+UPPER(arqexp)+" JA EXISTE!")
                        cn=(op_!=1)
                        IF !cn                                     // pode sobrepor,
                           ERASE (arqexp)                          // entao mata arq
                        ENDI
                     ENDI
                     IF op_exp=3                                   // se exporta para outro DBF
                        IF FILE(arq_+".DBF")                       // verifica se o DBF ja existe
                           op_=DBOX("Gravar por cima|Cancelar a opera��o",,,E_MENU,,"ARQUIVO "+UPPER(arq_)+".DBF JA EXISTE!")
                           cn=(op_!=1)
                        ENDI
                     ENDI
                  ENDI
                  IF !cn                                           // avisa que esta' trabalhando...
                     DBOX("Gerando o arquivo "+arqexp,15,,,NAO_APAGA)
                     ASIZE(estr_dbf,0); ASIZE(cp_exp,0)            // vetores auxiliares
                     FOR i=1 TO br_w:colcount                      // exporta todas as colunas
                        SEPARA(br_w:getcolumn(i):cargo)            // separa atributo da coluna
                        IF tp_cp!="M"                              // campo memo nao e' exportado
                           IF op_exp=3                             // exporta para DBF
                              cp_x=cp_
                              casadec=0                            // se a coluna for numerica, verifica
                              IF tp_cp="N"                         // a qde de casas decimais
                                 casadec=IF("." $ cp_masc,LEN(cp_masc)-RAT(".",cp_masc),0)
                                 tamanho=0                         // acha o tamanho
                                 FOR t=1 TO LEN(cp_masc)           // do campo
                                    IF !(SUBS(cp_masc,t,1) $ "@BCDEKXZR, ()")
                                       tamanho++
                                    ENDI
                                 NEXT
                              ELSEIF tp_cp="D"                     // a coluna e' uma data
                                 tamanho=8                         // o tamanho e' sempre 8
                              ELSEIF tp_cp="L"                     // a coluna e' tipo logico
                                 tamanho=1                         // o tamanho e' sempre 1
                              ELSE                                 // coluna tipo caracter
                                 tamanho=br_w:getcolumn(i):width
                                 cp_="LEFT("+cp_+"+["+SPAC(tamanho)+"],"+STR(tamanho,3)+")"
                              ENDI
                              IF "->" $ cp_x                       // coluna de outro arquivo
                                 cp_x=SUBS(cp_x,AT("->",cp_x)+2)   // retira o nome do DBF
                              ENDI
                              FOR tt=1 TO 12                       // retira caracteres ilegais
                                 cr_=SUBS(" ()*/+-^%$@&",tt,1)     // do conteudo da coluna
                                 IF cr_ $ cp_x                     // nome do campo do DBF a exportar
                                    cp_x=STRTRAN(cp_titu,cr_,"")
                                 ENDI
                              NEXT                                 // monta vetor da nova estrutura
                              AADD(estr_dbf,{cp_x,tp_cp,tamanho,casadec})
                           ELSE                                    // exportacao TXT/SDF
                              IF AT(tp_cp,"CN")>0                  // caracter/numerico trunca pelo tam da coluna
                                 cp_="LEFT(TRAN("+cp_+",["+cp_masc+"])+["+SPAC(br_w:getcolumn(i):width)+"],"+STR(br_w:getcolumn(i):width,3)+")"
                              END IF
                           ENDI
                           AADD(cp_exp,cp_)                        // vetor com conteudos a exportar
                        ENDI
                     NEXT
                     brw_reg = RECNO()                             // volta para registro anterior
                     dele_atu:=SET(_SET_DELETED,.t.)               // os excluidos nao serao exportados
                     INI_ARQ()                                     // move ponteiro para o inicio do arquivo
                     SET ALTE TO (arq_)                            // abre o arquivo para gravacao
                     SET ALTE ON                                   // liga gravacao
                     SET CONS OFF                                  // nao iremos exibir na tela
                     q=CHR(34)                                     // "aspas"
                     DO WHIL !EOF()                                // para todos os registros
                        FOR t=1 TO LEN(cp_exp)                     // e para todas as colunas
                           c_p=EVAL(&("{||"+cp_exp[t]+"}"))        // "code block" com o conteudo da coluna
                           IF op_exp!=1                            // se nao for delimitado
                              c_p=IF(VALTYPE(c_p)="D",DTOS(c_p),c_p)
                              ?? c_p                               // grava no arquivo
                           ELSE                                    // se delimitado grava entre aspas
                              c_p=IF(VALTYPE(c_p)="D",DTOC(c_p),c_p)
                              ?? q+ALLTRIM(c_p)+q+IF(t=LEN(cp_exp),"",dli_exp)
                           ENDI
                        NEXT
                        ?                                          // pula para proxima linha
                        SKIP                                       // pega proximo registro
                     ENDD
                     SET ALTE OFF                                  // desliga a gravacao
                     SET ALTE TO                                   // fecha arquivo
                     SET CONS ON                                   // reabilita o video
                     SET(_SET_DELETED,dele_atu)                    // restaura situacao do DELE()
                     GO brw_reg                                    // volta para registro anterior
                     IF op_exp=3                                   // exportacao para DBF
                        DBOX("Gerando o arquivo "+arq_+".DBF",15,,,NAO_APAGA)
                        i_=LEN(estr_dbf)                           // verifica/assegura que os nomes
                        FOR t=1 TO i_                              // dos campos nao estao repetidos
                           FOR i=t+1 TO i_
                              IF estr_dbf[t,1]=estr_dbf[i,1]
                                 estr_dbf[i,1]=LEFT(estr_dbf[i,1],8)+STRZERO(i,2)
                              ENDI
                           NEXT
                        NEXT
                        are_a:=SELECT()                            // area atual
                        SELE 0
                        DBCREATE(arq_,estr_dbf)                    // cria o novo DBF
                        USE (arq_)                                 // abre
                        APPEND FROM (arqexp) SDF                   // e anexa os registros
                        USE                                        // fecha
                        ERASE (arqexp)                             // elimina arq .txt temporario
                        SELE (are_a)                               // retorna para area DBF origem
                     ENDI
                     AFILL(cp_exp,"")
                     RESTSCREEN(0,0,MAXROW(),79,brw_tela)          // restaura a tela e
                     ALERTA()                                      // beep
                  ENDI
               ENDI
            ENDI

         CASE carac_="Z"                                   // totaliza coluna
            SEPARA(br_w:getcolumn(br_w:colpos):cargo)      // separa atributos da coluna
            IF !(tp_cp $ "NC")                             // se o campo nao for numerico
               ALERTA()                                    // nao da para somar
               DBOX("Coluna n�o pode ser totalizada",,,2)
            ELSE
               brw_tela = SAVESCREEN(0,0,MAXROW(),79)      // salva tela, registro e avisa
               brw_reg=RECN()                              // que esta somando
               DBOX("Totalizando "+MAIUSC(cp_titu)+"|ESC interrompe",,,,NAO_APAGA,"AGUARDE!")
               INI_ARQ()                                   // vai para o topo do arquivo
               x=INDEXKEY(0)                               // e comeca a somar
               y=IF(EMPTY(criterio),"1=1",criterio)

               #ifdef COM_TUTOR
                  IF tp_cp="N"
                     SUM &cp_. TO tot_ FOR !DELE() WHIL IN_KEY()!=K_ESC .AND. &y. .AND. IF(EMPTY(chv_rela).OR.br_w==br_origem,.t.,&x.=chv_1)
                  ELSE
                     SUM VAL(&cp_.) TO tot_ FOR !DELE() WHIL IN_KEY()!=K_ESC .AND. &y. .AND. IF(EMPTY(chv_rela).OR.br_w==br_origem,.t.,&x.=chv_1)
                  ENDI
               #else
                  IF tp_cp="N"
                     SUM &cp_. TO tot_ FOR !DELE() WHIL INKEY()!=K_ESC .AND. &y. .AND. IF(EMPTY(chv_rela).OR.br_w==br_origem,.t.,&x.=chv_1)
                  ELSE
                     SUM VAL(&cp_.) TO tot_ FOR !DELE() WHIL INKEY()!=K_ESC .AND. &y. .AND. IF(EMPTY(chv_rela).OR.br_w==br_origem,.t.,&x.=chv_1)
                  ENDI
               #endi

               GO brw_reg
               IF LASTKEY()!=K_ESC                         // nao cancelou
                  ms="999,999,999,999,999,999"             // mostra quanto foi o somatorio
                  dec=AT(".",cp_masc)
                  ms+=IF(dec>0,SUBS(cp_masc,dec),".99")
                  ms=IF(LEFT(cp_masc,1)="@",LEFT(cp_masc,3)+ms,ms)
                  ALERTA(4)
                  DBOX("O somat�rio de "+MAIUSC(cp_titu)+" �|"+TRAN(tot_,ms),,,,,"TOTALIZA��O")
               ENDI
               RESTSCREEN(0,0,MAXROW(),79,brw_tela)        // restaura a tela
            ENDI

      ENDC
   ENDI
ENDD

#ifdef COM_MOUSE
   IF drvmouse
      DO WHIL MOUSEGET(@Li,@Co)!=0                         // se qualquer botao do mouse
      ENDD                                                 // estiver pressionado, espera
      MOUSEBOX(0,0,MAXROW(),79)                            // a sua liberacao
   ENDI
#endi

RETU NIL

/*
   Sintaxe: IMP_BRW()
   Funcao.: Imprime a consulta da funcao EDITA()
   Retorna: NIL
*/
STATIC FUNC IMP_BRW()
LOCAL dele_atu
ALERTA(1)
x=PADR(tit_cons[IF(br_w == br_origem,1,2)],40)                            // recebe um titulo do relatorio
cod_sos=38                                                                // sugerindo o titulo da consulta
tit_rel=DBOX("Informe um t�tulo",,,,,"IMPRESS�O DE CONSULTA",x)
IF LASTKEY()!=K_ESC
   cod_sos=1
   ALERTA(1)                                                              // a onde vai imprimir?
   tps=TP_SAIDA(,0,.T.)                                                   // escolhe a saida...
   IF tps>0 .AND. LASTKEY()!=K_ESC
      cn=.f.
      ALERTA(1)
      IF tps=2                                                            // saida para arquivo
         arq_=ARQGER()                                                    // solicita um nome
         cn=EMPTY(arq_)
      ELSE                                                                // vai para a impressora
         cn=!PREPIMP()                                                    // pede para prepara-la
         arq_=drvporta                                                    // porta de saida configurada
      ENDI
      IF !cn
         brw_reg=RECN()                                                   // salva registro atual
         dele_atu=SET(_SET_DELETED,.t.)                                   // salva/seta visao dos reg apagados
         brw_tela = SAVESCREEN(0,0,MAXROW(),79)                           // salva tela
         ltot := ltot_o := 0                                              // inicializa variaveis
         brw_cb1 = ""; brw_imp:=just_memo:=tot_num := .f.
         IF br_w == br_origem .AND. VALTYPE(outro_db) = "C"               // se esta imprimindo da janela de cima
            id_carg = br_outro:cargo                                      // vamos verificar se a janela
            brw_imp = !EMPTY(id_carg[3])                                  // de baixo esta relacionada
         ENDI
         FOR t = 1 TO br_w:colcount                                       // para cada coluna,
            SEPARA(br_w:getcolumn(t):cargo)                               // separa os atributos
            le_=br_w:getcolumn(t):width                                   // tamanho da coluna
            brw_cb1 +=" "+PADR(ALLTRIM(cp_titu),le_)                      // monta linha de cabecalho
            ltot += le_ + 1                                               // tamanho do relatorio
            IF tp_cp=="N"                                                 // coluna e' numerica?
               var="to"+SUBS(STR(t+100,3),2)                              // inicializa variavel
               &var.=0; tot_num=.t.                                       // para totalizar a coluna
            ENDI
            IF tp_cp="M"                                                  // coluna e' memo?
               just_memo=.t.                                              // liga flag da pergunta
            ENDI                                                          // para justificar memo
         NEXT
         brw_cb1 = SUBS(brw_cb1,2)                                        // tira 1o. espaco do titulo e
         ltot--                                                           // ajusta tamanho do relatorio
         IF brw_imp                                                       // existe janela relacionada?
            SELE (outro_db)                                               // seleciona o DBF da janela de
            ltot_o = 0                                                    // baixo e inicializa variaveis
            brw_cb2 = ""
            FOR t = 1 TO br_outro:colcount                                // para cada coluna
               SEPARA(br_outro:getcolumn(t):cargo)                        // separa os atributos
               le_=br_outro:getcolumn(t):width                            // tamanho da coluna
               brw_cb2 +=" "+PADR(ALLTRIM(cp_titu),le_)                   // monta titulo das colunas
               ltot_o += le_ + 1                                          // e o tamanho do relatorio
               IF tp_cp=="N"                                              // coluna e' numerica?
                  var="too"+SUBS(STR(t+100,3),2)                          // inicializa variavel
                  &var.=0; tot_num=.t.                                    // para totalizar a coluna
               END IF
               IF tp_cp="M"                                               // coluna e' memo?
                  just_memo=.t.                                           // liga flag de pergunta
               ENDI                                                       // para justificar memo
            NEXT
            brw_cb2 = SUBS(brw_cb2,2)                                     // tira 1o. espaco do titulo e
            ltot_o--                                                      // ajusta tamanho do relatorio
            SELE (m_origem)                                               // seleciona DBF da janela de cima
         ENDI
         IF tot_num                                                       // tem alguma coluna numerica?
            ALERTA(1)                                                     // pergunta se quer totalizar
            cod_sos=1                                                     // o relatorio
            i=DBOX("Sim|N�o",,,E_MENU,,"TOTALIZAR AS|COLUNAS NUM�RICAS")
            IF i=0
               RETU                                                       // cancelou...
            ENDI                                                          // flag se quer totalizar
            tot_num=(i=1)
         ENDI
         IF just_memo                                                     // tem algum campo memo?
            ALERTA(1)                                                     // pergunta se quer justificar
            cod_sos=50                                                    // os campos memos no relatorio
            i=DBOX("Sim|N�o",,,E_MENU,,"JUSTIFICAR OS|CAMPOS MEMO")
            IF i=0
               RETU                                                       // cancelou...
            ENDI
            just_memo=(i=1)                                               // flag se quer justificar memos
         ENDI
         DBOX("Aguarde o final de impress�o||ESC para interromper",17,,,NAO_APAGA)
         INI_ARQ()                                                      // vai para o inicio do arquivo
         cl:=pg:=creg := 0                                                // inicializar variaveis
         SET PRINTER TO (arq_)                                            // abre arq escolhido ou redireciona saida
         SET DEVI TO PRIN                                                 // se tamanho > 80, comprime
         @ PROW(),PCOL() SAY IF(MAX(ltot,ltot_o)>80,&drvpcom.,"")
         cl=CABCONS(brw_cb1,tit_rel)                                      // imprime cabecalho da janela superior
         brw_cn = .f.
         x = INDEXKEY(0)
         DO WHIL ! EOF() .AND. ! brw_cn .AND.;                            // imprime ate o fim do arquivo
            IF(EMPTY(chv_rela).OR.br_w==br_origem,.t.,&x.=IF(EMPTY(criterio),"","T")+chv_1)
            IF cl>IF(brw_imp,54,57)                                       // atingiu o final da folha
               EJEC                                                       // pula para proxima pagina
               cl=CABCONS(brw_cb1,tit_rel)                                // e reimprime o cabecalho
            ENDI

            #ifdef COM_TUTOR
               IF IN_KEY()=K_ESC .OR. MOUSEGET(0,0)=2                     // quer cancelar a impressao?
            #else
               IF INKEY()=K_ESC .OR. MOUSEGET(0,0)=2                      // quer cancelar a impressao?
            #endi
               brw_cn = CANC(1)                                           // pede confimacao do cancelamento
               LOOP
            ENDI
            lin=""; tem_memo=.f.; qli_m=0
            FOR t=1 TO br_w:colcount                                      // monta linha a imprimir
               SEPARA(br_w:getcolumn(t):cargo)                            // separa os atributos da coluna
               i = br_w:getcolumn(t):width                                // tamanho da coluna
               IF tp_cp="M"                                               // coluna e' memo?
                  IF qli_m<MLCOUNT(&cp_.,i)                               // mumero maximo de linhas
                     qli_m=MLCOUNT(&cp_.,i)                               // a imprimir de todos campos memo
                  ENDI                                                    // monta linha de impressao
                  lin += IMPAC(LEFT(MEMOLINE(&cp_.,i,1)+SPACE(i),i),just_memo)+" "
                  tem_memo=.t.                                            // flag tem memo?
               ELSE
                  IF tp_cp=="N" .AND. tot_num                             // coluna e' numerica?
                     var="to"+SUBS(STR(t+100,3),2)                        // soma coluna para
                     &var. += &cp_.                                       // totalizacao
                  ENDI
                  lin+=LEFT(TRAN(&cp_.,cp_masc)+SPAC(i),i)+" "            // monta linha de impressao
               ENDI
            NEXT
            @ cl++,0 SAY lin                                              // joga linha na impressora
            IF tem_memo .AND. qli_m>1                                     // imprime resto do memo
               li_m=1
               DO WHIL .t.
                  li_m++                                                  // proxima linha do memo
                  IF li_m>qli_m                                           // se ja' imprimiu todos
                     EXIT                                                 // cai fora...
                  ENDI
                  lin=""
                  FOR t=1 TO br_w:colcount                                // procura todos os memo
                     SEPARA(br_w:getcolumn(t):cargo)                      // e monta uma linha so'
                     i = br_w:getcolumn(t):width
                     IF tp_cp="M"
                        lin += IMPAC(LEFT(MEMOLINE(&cp_.,i,li_m)+SPACE(i),i),just_memo)+" "
                     ELSE
                        lin += SPAC(i+1)
                     ENDI
                  NEXT
                  IF cl+1>IF(brw_imp,54,57)
                     EJEC                                                 // quebra de folha
                     cl=CABCONS(brw_cb1,tit_rel)
                  ENDI
                  @ cl++,0 SAY lin                                        // imprime as linhas dos memo

                  #ifdef COM_TUTOR
                     IF IN_KEY()=K_ESC .OR. MOUSEGET(0,0)=2               // quer cancelar a impressao?
                  #else
                     IF INKEY()=K_ESC .OR. MOUSEGET(0,0)=2                // quer cancelar a impressao?
                  #endi

                     brw_cn = CANC(1)
                     LOOP
                  ENDI
               ENDD
            ENDI
            IF tem_memo                                                   // se imprimiu algum campo
               cl++                                                       // memo, forca espacejamento duplo
            ENDI
            creg++                                                        // contador de registros impressos
            IF brw_imp                                                    // tem outra janela relacionada?
               cl++                                                       // forca salto de linha
               id_carg=br_outro:cargo                                     // prepara para a impressao
               c_antes=IF(EMPTY(id_carg[1]),"","T")+&(id_carg[3])         // da janela relacionada
               SELE (outro_db)
               SEEK c_antes                                               // acha o 1o. registro da relacao
               ind_outro = INDEXKEY(0)                                    // ordem atual do arquivo
               imp_brw_out=.f.
               IF !EOF().AND.!brw_cn.AND.&ind_outro.=c_antes              // se tem registro a imprimir
                  cl=CABCONS_O(cl,brw_cb2)                                // imprime cabecalho
                  cl++
               ENDI
               DO WHIL !EOF().AND.!brw_cn.AND.&ind_outro.=c_antes         // imprime so quem atende a relacao
                  cl--
                  IF cl>57                                                // final da folha
                     EJEC                                                 // salta para proxima
                     cl=CABCONS(brw_cb1,tit_rel)                          // imprime cabecalho do "pai"
                  ENDI

                  #ifdef COM_TUTOR
                     IF IN_KEY()=K_ESC .OR. MOUSEGET(0,0)=2               // quer cancelar?
                  #else
                     IF INKEY()=K_ESC .OR. MOUSEGET(0,0)=2                // quer cancelar?
                  #endi

                     brw_cn = CANC(1)                                     // pede confirmacao
                     LOOP
                  ENDI
                  lin_o=""; tem_memo=.f.; qli_m=0
                  FOR t=1 TO br_outro:colcount                            // monta linha a imprimir
                     SEPARA(br_outro:getcolumn(t):cargo)                  // separa os atributos da coluna
                     IF tp_cp="M"                                         // tamanho da coluna
                        IF qli_m<MLCOUNT(&cp_.,i)                         // coluna e' memo?
                           qli_m=MLCOUNT(&cp_.,i)                         // mumero maximo de linhas
                        ENDI                                              // a imprimir de todos campos memo
                        lin_o+=" "+IMPAC(LEFT(MEMOLINE(&cp_.,i,1)+;
                             SPACE(i),i),just_memo)                       // monta linha de impressao
                        tem_memo=.t.                                      // flag se tem memo
                     ELSE
                        IF tp_cp=="N" .AND. tot_num                       // coluna e' numerica?
                           var="too"+SUBS(STR(t+100,3),2)                 // soma coluna para
                           &var. += &cp_.                                 // totalizacao
                        ENDI
                        i = br_outro:getcolumn(t):width                   // tamanho da coluna
                        lin_o+=" "+LEFT(TRAN(&cp_.,cp_masc)+SPAC(i),i)    // monta linha de impressao
                     ENDI
                  NEXT
                  imp_brw_out=.t.
                  @ cl,0 SAY PADL(SUBS(lin_o,2),MAX(ltot,ltot_o))         // joga linha na impressora
                  IF tem_memo .AND. qli_m>1                               // imprime resto do memo
                     li_m=1
                     DO WHIL .t.
                        li_m++                                            // proxima linha do memo
                        IF li_m>qli_m                                     // se ja imprimiu todos
                           EXIT                                           // cai fora...
                        ENDI
                        lin=""
                        FOR t=1 TO br_w:colcount                          // procura todos os memo
                           SEPARA(br_w:getcolumn(t):cargo)                // e monta uma linha so'
                           i = br_w:getcolumn(t):width
                           IF tp_cp="M"
                              lin += IMPAC(LEFT(MEMOLINE(&cp_.,i,li_m)+SPACE(i),i),just_memo)+" "
                           ELSE
                              lin += SPAC(i+1)
                           ENDI
                        NEXT
                        IF cl+1>57                                        // chegou no final da folha?
                           EJEC                                           // salta para proxima pagina
                           cl=CABCONS(brw_cb1,tit_rel)                    // reimprime cabecalho do "pai"
                        ENDI
                        @ ++cl,0 SAY PADL(lin,MAX(ltot,ltot_o))           // imprime linhas dos memo

                        #ifdef COM_TUTOR
                           IF IN_KEY()=K_ESC .OR. MOUSEGET(0,0)=2         // quer cancelar?
                        #else
                           IF INKEY()=K_ESC .OR. MOUSEGET(0,0)=2          // quer cancelar?
                        #endi

                           brw_cn = CANC(1)
                           LOOP
                        ENDI
                     ENDD
                  ENDI
                  cl += 2
                  SKIP                                                    // de imprimir o proximo "pai"
               ENDD
               IF imp_brw_out                                             // se imprimiu algum registro...
                  @ cl-1,0 SAY PADL(REPL("-",ltot_o),MAX(ltot,ltot_o))
               ENDI
               cl++
               IF tot_num                                                 // pediu para totalizar
                  lin_o=""
                  FOR t=1 TO br_outro:colcount                            // monta linha dos totais
                     SEPARA(br_outro:getcolumn(t):cargo)
                     i=br_outro:getcolumn(t):width
                     IF tp_cp=="N"
                        var="too"+SUBS(STR(t+100,3),2)                    // variavel com a mascara
                        lin_o+=" "+LEFT(TRAN(&var.,cp_masc)+SPAC(i),i)    // da propria coluna
                        &var.=0
                     ELSE
                        lin_o += SPAC(i+1)
                     ENDI
                  NEXT
                  IF LEN(ALLTRIM(lin_o))>0                                // se tem totais, imprime
                     @ cl-1,0 SAY PADL(SUBS(lin_o,2),MAX(ltot,ltot_o))
                     cl++
                  ENDI
               ENDI
               SELE (m_origem)                                            // retorna ao "pai"
            ENDI
            SKIP
         ENDD
         @ PROW()+1,0 SAY REPL("=", MAX(ltot,ltot_o))                     // traco do fim do relatorio
         lin=""
         IF tot_num                                                       // quer totalizar
            FOR t=1 TO br_w:colcount                                      // monta linha dos totais
               SEPARA(br_w:getcolumn(t):cargo)
               i = br_w:getcolumn(t):width
               IF tp_cp=="N"
                  var="to"+SUBS(STR(t+100,3),2)                           // variavel com a mascara
                  lin += LEFT(TRAN(&var.,cp_masc)+SPAC(i),i)+" "          // da propria coluna
               ELSE
                  lin += SPAC(i+1)
               ENDI
            NEXT
            @ PROW()+1,0 SAY lin
         ENDI                                                             // se tem totais, imprime
         @ PROW()+1,0 SAY "Listados: "+;                                  // imprime qde de registros
                          LTRIM(TRAN(creg,"@E 999,999"))+;                // listados
                          IF(MAX(ltot,ltot_o)>80,&drvtcom.,"")
         EJEC
         SET PRINTER TO (drvporta)                                        // finaliza o relatorio
         SET DEVI TO SCRE
         SET(_SET_DELETED,dele_atu)                                       // restaura visao dos reg apagados
         GO brw_reg                                                       // reposiciona o ponteiro
         IF tps=2                                                         // se vai para arquivo/video
            BROWSE_REL(arq_,2,3,MAXROW()-2,78)                            // mostra o arquivo gravado
         ENDI
         RESTSCREEN(0,0,MAXROW(),79,brw_tela)                             // restaura a tela e
      ENDI                                                                // do arquivo
   ENDI
ENDI
RETU NIL

/*
   Sintaxe: CABCONS(<ExpC1> <,ExpC2> )
   Funcao.: Imprime cabecalho da consulta na impressora (pai)
              ExpC1 = titulo da consulta
              ExpC2 = titulo extra
   Retorna: Linha de impressao do proximo registro
*/
STATIC FUNC CABCONS(cb_1,tit_rel)
pg++
@ 1,ltot-18 SAY DATE()                   // data do sistema
@ 1,ltot-7  SAY TRAN(pg,"Pag 999")       // numero da pagina
@ 2,0 SAY IMPAC(PADC(TRIM(nemp),ltot))   // nome da empresa
@ 3,0 SAY PADC(TRIM(tit_rel),ltot)       // titulo informado
@ 4,0 SAY IMPAC(cb_1)                    // titulo das colunas
@ 5,0 SAY REPL("=",MAX(ltot,ltot_o))
RETU 6

/*
   Sintaxe: CABCONS_O()
   Funcao.: Imprime cabecalho da consulta na impressora (filho)
              ExpC1 = titulo da consulta
              ExpC2 = titulo extra
   Retorna: Linha de impressao do proximo registro
*/
STATIC FUNC CABCONS_O(cl,cb_1)
@ cl++,0 SAY IMPAC(PADL(cb_1,MAX(ltot,ltot_o)))              // titulo das colunas
@ cl++,0 SAY IMPAC(PADL(REPL("-",ltot_o),MAX(ltot,ltot_o)))  // justificado a direita
RETU cl

/*
   Sintaxe: TROCA_BRW()
   Funcao.: Troca os arquivos do browse
   Retorna: NIL
*/
STATIC FUNC TROCA_BRW()
IF br_w == br_outro      // se for a janela de baixo
   br_reg_out = RECNO()  // salva situacao e
   SELE (m_origem)       // passa para a janela de cima
   br_w = br_origem
   GO br_reg_ori
ELSE                     // esta' na janela de cima
   br_reg_ori = RECNO()  // salva situacao e
   SELE (outro_db)       // passa para a janela de baixo
   br_w = br_outro
   GO br_reg_out
ENDI
RETU NIL

/*
   Sintaxe: LDBEDIT( <ExpL> )
   Funcao.: Carrega parametros de consulta
            se .t. le consulta dos discos e apresenta menu
   Retorna: .t. se teve sucesso.
*/
STATIC FUNC LDBEDIT(lecons)
LOCAL aqdbe, naq, qarq, cor_, ret_:=.t., sos_cod:=cod_sos, leat_,;
      tela_brw:=SAVESCREEN(0,0,MAXROW(),79), i_, l_mp, c_mp
IF ! USED()                                                      // nao existe DBF aberto
   RETU .f.
ENDI
cod_sos=27
leat_=.t.
IF lecons                                                        // se quer ler consultas gravadas
   DBOX("AGUARDE!",,,,NAO_APAGA)
   aqdbe=drvdbf+"DB*."+LEFT(ALIAS(),3)                           // mascara dos arquivos
   qarq=ADIR(aqdbe)                                              // capta arquivo do disco
   IF qarq>0                                                     // existe alguma consulta gravada?
      PRIV l_arq[qarq+1]
      ADIR(aqdbe,l_arq)                                          // monta vetor com os titulos
      FOR i=qarq TO 1 STEP -1                                    // de cada consulta
         naq=drvdbf+l_arq[i]
         REST FROM (naq) ADDI
         l_arq[i+1]=db_aqcom+"�"+l_arq[i]
      NEXT
      l_arq[1]="* Definir nova consulta *"                       // primeira opcao do menu
      volta_ac=.t.
      RESTSCREEN(0,0,MAXROW(),79,tela_brw)
      DO WHIL volta_ac
         volta_ac=.f.
         msg=""                                                  // tira os espacos dos titulos
         AEVAL(l_arq,{|ms|;                                      // da consulta
                       IF(ms!=NIL,msg+="|"+ALLTRIM(PARSE(ms,"�")),"");
                     };
         )
         l_mp=IF(TYPE("lin_menu")="N",lin_menu+2,NIL)            // coordenadas do menu
         c_mp=IF(TYPE("col_menu")="N",col_menu+8,NIL)            // apresenta menu
         op_co=DBOX(SUBS(msg,2),l_mp,c_mp,E_MENU)
         IF volta_ac                                             // quer apagar a consulta
            pos_=RAT("�",l_arq[op_co])
            IF pos_>3                                            // evita matar opcao sem aquivo
               naq=drvdbf+SUBS(l_arq[op_co],pos_+1)
               i_=ALLTRIM(UPPE(LEFT(l_arq[op_co],pos_-1)))
               ALERTA()                                          // pede confirmacao
               msg="Cancelar a opera��o|Efetivar exclus�o"
               op_=DBOX(msg,8,,E_MENU,,"EXCLUINDO|� "+i_+" �")
               IF op_=2                                          // se confirmou exclusao elimina
                  ERAS &naq.                                     // arquivo de atributos da consulta
                  ADEL(l_arq,op_co)                              // exclui consulta do menu
               ENDI
            ENDI
         ENDI
      ENDD
      RELE ALL LIKE db_*                                         // libera variaveis com "DB"
      db_1rela:=db_2rela := ""
      db_zoom=.f.
      IF op_co=0                                                 // nao quis ler consulta
         ret_=.f.
      ELSEIF op_co>1
         op_=l_arq[op_co]                                        // consulta escolhida
         br_tit=ALLTRIM(PARSE(@op_,"�"))                         // extrai o nome do arquivo
         br_arq=drvdbf+op_
         REST FROM (br_arq) ADDI                                  // le variaveis do disco
         pas = "1"
         tit_cons[1]=ALLTRIM(br_tit)                             // titulo da consulta
         IF db_zoom                                              // se janela tem zoom
            li_sup=3; li_inf=22; co_sup=3; co_inf=77             // ajusta as coordanadas
            br_w:nTop   := li_sup                                // da janela e do browse
            br_w:nbottom:= li_inf
            br_w:nleft  := co_sup
            br_w:nright := co_inf
         END IF
         ind_rela=db_indrela                                     // indice utilizado para relacionar
         DO WHILE .t.
            xdb_rela=LEFT(db_&pas.rela,LEN(db_&pas.rela)-1)
            DO WHIL LEN(xdb_rela)>0                              // restabelece relations
               n_cp=ALLTRIM(PARSE(@xdb_rela,"�"))
               SETARELA(n_cp)
            ENDD
            FOR t=1 TO db_&pas.qtdc                              // remonta todas colunas
               tt=RIGHT(STR(100+t,3),2)
               cargox=db_&pas.carg&tt.
               cp_ =PARSE(@cargox,"�")                           // conteudo
               cp_masc=PARSE(@cargox,"�")                        // mascara
               cp_titu=PARSE(@cargox,"�")                        // titulo
               cp_when=PARSE(@cargox,"�")                        // pre-validacao
               cp_crit=PARSE(@cargox,"�")                        // validacao
               br_w:addcolumn(tbcolumnnew(cp_titu,&("{||"+IF(TYPE(cp_)=="M","MEMOLINE("+cp_+")","TRAN("+cp_+",["+cp_masc+"])")+"}")))
               br_w:getcolumn(t):cargo = db_&pas.carg&tt.
               br_w:getcolumn(t):width = db_&pas.tam&tt.         // tamanho da coluna
               br_w:getcolumn(t):colorblock = {||IIF(DELE(),{3,2},{1,2})}
            NEXT
            br_w:freeze = db_&pas.freeze                         // coluna congelada
            IF br_w:freeze != 0
               br_w:getcolumn(br_w:freeze+1):colsep := " � "
               br_w:configure()
            ENDI
            criterio=db_&pas.arqf                                // filtro
            cpord=db_&pas.expo                                   // ordem
            chv_rela=db_&pas.chvr                                // ligacao entre janelas
            ind_ord=db_&pas.ind_ord                              // indice atual
            br_w:cargo         := {criterio,cpord,chv_rela,ind_ord}
            br_w:gobottomblock := {||FIM_ARQ()}
            br_w:gotopblock    := {||INI_ARQ()}
            br_w:skipblock     := {|n|MOV_PTR(n)}
            PEGACHV2()
            INDTMP()
            IF pas = "1"
               br_reg_ori = IF(FOUND(),RECNO(),1)
               IF TYPE("db_outro")=="C".AND.!EMPTY(db_outro)     // tem duas janelas?
                  opi = ASCAN(sistema,{|sis| UPPER(db_outro)=UPPER(sis[O_ARQUI])})
                  IF !abreoutro(opi)                             // abre o segundo browse
                     EXIT
                  ENDI
                  SETCOLOR(drvcortna)                            // monta janela
                  CAIXA(mold,br_outro:ntop-2, br_outro:nleft-1, br_outro:nbottom+1, br_outro:nright+1)
               ELSE
                  EXIT
               ENDI
               pas = "2"
               tit_cons[2]=sistema[opi,O_MENS]                   // titulo da segunda janela
               DBSETORDER(ind_rela)                              // vai para utilizado da relacao
            ELSE
               br_reg_out = IF(FOUND(),RECNO(),1)                // segunda janela
               SELE (m_origem)
               br_w = br_origem
               GO br_reg_ori
               br_outro:colorspec := drvcortna+","+INVCOR(drvcortna)+","+drvcorenf+","+drvcorget
               FORCABRW(.f.)                                     // imprime dados na tela
               EXIT
            ENDI
         ENDD
         leat_=.f.
      ENDI
   ELSE
      RESTSCREEN(0,0,MAXROW(),79,tela_brw)                       // restaura tela
   ENDI
ENDI
IF leat_
   IF col_cp!=NIL                                                // passou arranjo das colunas
      estr_dbf=DBSTRUCT()                                        // campos dos arquivo
      ct_cp=0
      FOR i=1 TO LEN(col_cp)
         t=ASCAN(estr_dbf,{|db_|UPPER(col_cp[i])==db_[1]})       // ve se a coluna e cp do arquivo
         IF t>0
            MONTA_COL()                                          // e' um campo do arquivo
         ELSE
            ct_cp++                                              // nao e' campo do arquivo
            br_w:addcolumn(tbcolumnnew(col_cp[i],&("{||"+col_cp[i]+"}")))
            x=LEN(&(col_cp[i]))
            br_w:getcolumn(ct_cp):width := LEN(&(col_cp[i]))
            br_w:getcolumn(ct_cp):colorblock := {||IF(DELE(),{3,2},{1,2})}
            i_=IF(TYPE("col_tit[i]")!="UE".AND.!EMPTY(col_tit[i]),col_tit[i],"")
            br_w:getcolumn(ct_cp):cargo := col_cp[i]+"�@X�"+i_+"��V�"+VALTYPE(col_cp[i])
         ENDI
         IF TYPE("col_tit[i]")!="UE" .AND. !EMPTY(col_tit[i])
            br_w:getcolumn(ct_cp):heading := col_tit[i]
         ENDI
      NEXT
   ELSE                                                          // monta consulta com todos
      estr_dbf=DBSTRUCT()                                        // os campos do arquivo
      ct_cp=0
      FOR t=1 TO LEN(estr_dbf)
         IF !("I"==sistema[op_sis,O_CAMPO,t,O_CRIT])             // exceto os invisiveis...
            MONTA_COL()
         END IF
      NEXT
   ENDI
   br_w:gobottomblock := {||FIM_ARQ()}
   br_w:gotopblock    := {||INI_ARQ()}
   br_w:skipblock     := {|n|MOV_PTR(n)}
   IF !EMPTY(criterio) .OR. !EMPTY(cpord)                        // tem filtro ou ordem inicial
      i_=IF(!EMPTY(criterio).AND.&criterio.,RECNO(),0)           // reg atual esta dentro do filtro?
      INDTMP()                                                   // cria indice temporario
      IF i_>0                                                    // se reg estava no filtro
         GO i_                                                   // reposiciona em cima dele
      ENDI
   ENDI
   br_w:cargo := {criterio,cpord,chv_rela,INDEXORD()}            // grada nova configuracao
ENDI
RELE ALL LIKE db_*                                               // libera variaveis
cod_sos=sos_cod
RETU ret_                                                        // .t. montou consulta com sucesso

/*
   Sintaxe: MONTA_COL()
   Funcao.: Enche uma coluna da edita com atributos de campo
   Retorna: NIL
*/
STATIC FUNC MONTA_COL
M->ms:=sistema[op_sis,O_CAMPO,t,O_MASC]                  // mascara
M->tm:=LEN(TRAN(&(FIELD(t)),M->ms))                      // conteudo
M->tm:=IF(M->tm=0,34,M->tm)                              // ajusta tamanho
M->tm:=IF(LEFT(M->ms,2)="@S",VAL(SUBS(M->ms,3)),M->tm)   // da coluna
ct_cp++
br_w:addcolumn(;                                         // inicializa coluna
       tbcolumnnew(sistema[op_sis,O_CAMPO,t,O_TITU],;
                      &("{||"+;
                        IF(TYPE(estr_dbf[t,1])=="M",;
                           "MEMOLINE("+estr_dbf[t,1]+")",;
                           "TRAN("+estr_dbf[t,1]+",["+M->ms+"])";
                        )+"}";
                       );
       );
     )
br_w:getcolumn(ct_cp):cargo := estr_dbf[t,1]+"�"+M->ms+"�"+sistema[op_sis,O_CAMPO,t,O_TITU]+"�"+;
                               sistema[op_sis,O_CAMPO,t,O_WHEN]+"�"+sistema[op_sis,O_CAMPO,t,O_CRIT]+"�"+;
                               sistema[op_sis,O_CAMPO,t,O_HELP]+"�"+sistema[op_sis,O_CAMPO,t,O_CMD]
br_w:getcolumn(ct_cp):width := M->tm
br_w:getcolumn(ct_cp):colorblock := {||IF(DELE(),{3,2},{1,2})}
RETU

/*
   Sintaxe: SEPARA( <ExpC> )
   Funcao.: Separa atributos de campos da coluna da consulta
              ExpC = atributos (nome do campo/mascara/titulo/validacao)
   Retorna: NIL
*/
STATIC FUNC SEPARA(cr_)
cp_ =PARSE(@cr_,"�")     // conteudo
cp_masc=PARSE(@cr_,"�")  // mascara
cp_titu=PARSE(@cr_,"�")  // titulo
cp_when=PARSE(@cr_,"�")  // pre-validacao
cp_crit=PARSE(@cr_,"�")  // validacao (critica)
cp_help=PARSE(@cr_,"�")  // help do campo
cp_cmd =PARSE(@cr_,"�")  // comando especial
tp_cp= TYPE(cp_)         // tipo da coluna
RETU NIL

/*
   Sintaxe: DIR_CUR()
   Funcao.: Muda direcionamento do cursor dentro da funcao EDITA() quando
            o TAB e' acionado
   Retorna: NIL
*/
STATIC FUNC DIR_CUR
dir_cur=IF(dir_cur=4,1,dir_cur+1)
@ br_w:nbottom+1,br_w:nleft+posi_cur+5 SAY CHR(VAL(SUBS(di_tecl,dir_cur*2-1,2)))
RETU NIL

/*
   Sintaxe: COLNOVA()
   Funcao.: Cria uma nova coluna na consulta
   Retorna: NIL
*/
STATIC FUNC COLNOVA
LOCAL brw_tela, ar_, i, ii, db:="", msg:=""
PRIV cod_sos:=1
brw_tela = SAVESCREEN(0,0,MAXROW(),79)                           // salva tela e monta
FOR i=1 TO nss                                                   // menu dos arquivos possiveis
   IF sistema[i,O_ARQUI]!=ALIAS(VAL(m_origem)) .AND. ;
      IF(EMPTY(outro_db),.t.,sistema[i,O_ARQUI]!=ALIAS(VAL(outro_db))) .AND.;
      sistema[i,O_OUTROS,O_NIVEL]<=nivelop
      msg+="|"+sistema[i,O_MENU]
      db+=RIGHT(STR(100+i),2)
   ENDI
NEXT
IF LEN(msg) <= 0                                                 // nao existe arq a escolher
   ALERTA()
   DBOX("N�o h� mais arquivos dispon�veis",15,,3,,"ATEN��O!, "+usuario)
   KEYB CHR(K_ESC)
ELSE
   tit="SELECIONE O ARQUIVO|DO QUAL SER� MOSTRADO O CAMPO"
   op_a=DBOX(SUBS(msg,2),,,E_MENU,,tit)                          // escolhe um arquivo
   ar_:=SELECT()
   IF op_a>0                                                     // escolheu...
      op_a=VAL(SUBS(db,op_a*2-1,2))                              // subscricao de "sistema"
      db=sistema[op_a,O_ARQUI]                                   // nome do arquivo (sem dir)
      IF USEARQ(db)                                              // abre o arquivo
         SELE (ar_)
         IF PEGARELA(.f.)                                        // pega campos de relacionamentos
            msg=""
            SELE (db)
            FOR i=1 TO FCOU()                                    // menu de campos
               IF !("I"==sistema[op_a,O_CAMPO,i,O_CRIT])         // exceto os invisiveis...
                  msg+="|"+sistema[op_a,O_CAMPO,i,O_TITU]
               ENDI
            NEXT
            op_0=DBOX(SUBS(msg,2),,,E_MENU,,"CAMPO A MOSTRAR NA NOVA COLUNA")
            IF LASTKEY()!=K_ESC .AND. op_0 > 0                   // escolheu um campo
               ii=0
               FOR i=1 TO FCOU()                                 // acha campo escolhido
                  IF !("I"==sistema[op_a,O_CAMPO,i,O_CRIT])
                     ii++
                  ENDI
                  IF ii=op_0
                     op_0=i
                     EXIT
                  ENDI
               NEXT
               v_ar=READVAR()                                   // titulo da coluna
               &v_ar.:=sistema[op_a,O_CAMPO,op_0,O_TITU]        // contera' o titulo do campo
               cp_masc:=sistema[op_a,O_CAMPO,op_0,O_MASC]       // mascara
               cp_ =cp_+"|"+db+"->"+FIEL(op_0)             // expressao para relacionar
            ELSE
               cp_=" "
            ENDI
         ELSE
            cp_=" "
         ENDI
      ENDI
   ENDI
   SELE (ar_)                                                   // seleciona arquivo original
   f10=.t.
   KEYB CHR(K_CTRL_W)                                           // forca saida do get pendente
ENDI
RETU NIL

/*
   Sintaxe: PEGARELA( <ExpL> )
   Funcao.: Monta menu com arquivos e campos para relacionamento
              ExpL = .t. relacao entre duas janelas
                     .f. relacao entre colunas
   Retorna: .t. se teve sucesso.
*/
STATIC FUNC PEGARELA(fl)
LOCAL tit_chv:="", msg:="", op_0:=0, cp_rela:="", ii
PRIV cod_sos:=31
op_x = EVAL(qualsis,ALIAS())                      // subscricao do arquivo atual
FOR i=1 TO FCOU()                                 // monta menu com os campos do
   IF !("I"==sistema[op_x,O_CAMPO,i,O_CRIT])      // arquivo, exceto os invisiveis
      msg+="|"+sistema[op_x,O_CAMPO,i,O_TITU]
   ENDI
NEXT                                              // titulo da DBOX()
tit="RELACIONAMENTO|*|ESCOLHA O CAMPO PARA|SINCRONIZAR OS ARQUIVOS|ESC=FIM|*"
IF fl
   chv_rela=""                                    // vai sincronizar duas janelas
ENDI
temrela=.f.
DO WHIL .t.                                       // escolhe um campo
   op_0=DBOX(SUBS(msg,2),,,E_MENU,,tit+tit_chv,,,op_0)
   IF LASTKEY()=K_ESC .OR. op_0<=0
      EXIT                                        // cancelou ou ja terminou
   ENDI
   ii=0                                           // procura campo escolhido
   FOR i=1 TO FCOU()
      IF !("I"==sistema[op_x,O_CAMPO,i,O_CRIT])   // despreza os invisiveis
         ii++
      ENDI
      IF ii=op_0
         op_0=i
         EXIT
      ENDI
   NEXT
   cp_ = FIEL(op_0)                               // campo escolhido
   IF TYPE(cp_)="M"
      DBOX("Campo ilegal",,,3,,"ATEN��O!")        // campo memo nao pode...
      LOOP
   ELSE
      temrela=.t.                                 // atualiza o titulo da DBOX()
      tit_chv+="|"+MAIUSC(sistema[op_x,O_CAMPO,op_0,O_TITU])+","
      cp_=TRANSCAMPO(.f.,cp_,op_0)                // transforma campo em caracter
      IF fl
         chv_rela+="+"+ALIAS()+"->"+cp_           // chave de relacionamento entre janelas
      ENDI
      cp_rela+="+"+cp_                            // mais um campo de sincronismo?
      op_0=DBOX("Prosseguir|Informar outro campo",,,E_MENU,,"RELACIONAMENTO POR"+tit_chv)
      IF op_0!=2
         cp_=SUBS(cp_rela,2)                      // sincronismo terminado
         EXIT
      ENDI
   ENDI
ENDD
RETU temrela

/*
   Sintaxe: SETARELA( <ExpC> )
   Funcao.: Estabelece relacionamento de arquivos na consulta
              ExpC = parametros de relacionamento
   Retorna: .t. se relacionou
*/
STATIC FUNC SETARELA(p_cp)
p_m=RAT("->",p_cp)
p_b=AT("|",p_cp)
IF p_m>0 .AND. p_b>0                         // existe campo e arq para o relacionamento
   c_rel=LEFT(p_cp,p_b-1)                    // campo ou expressao para a relacao
   a_u=SUBS(p_cp,p_b+1,(p_m-1)-p_b)          // nome do arquivo que sera' relacionado
   a_r_=SELEC()
   IF USEARQ(a_u)                            // abre arquivo e seus indices
      SELE (a_r_)
      ja=.f.
      FOR t=1 TO 99                          // verifica se a relacao ja' foi feita
         x=DBRSELECT(t)
         IF x>0
            IF UPPER(a_u) == ALIAS(x)
               ja=.t.                        // existe o relacionamento
               EXIT
            ENDI
         ENDI
      NEXT
      IF !ja                                 // relaciona se nao tem o relacionamento
         SET RELA ADDI TO &c_rel. INTO &a_u.
      ENDI
   ELSE
      CLOSE ALL                              // ocorreu erro de abertura de arquivo
      BREAK                                  // cancela toda a operacao
   ENDI
ENDI
RETU (p_m>0 .AND. p_b>0)                     // retorna .t. se relacionou

/*
   Sintaxe: POINTER_DBF( [ExpA] [,ExpL] )
   Funcao.: acha/restaura ponteiro dos dbf do vetor sistema
               ExpA = arranjo de RECNO() dos dbf do vetor sistema
               ExpL = se .t. deixa abertos os dbf's usados apos salvamento
   Retorna: arranjo de RECNO() dos dbf do vetor sistema
*/
FUNC POINTER_DBF(reg_dbf, deixa_ab)
LOCAL t, i_, i_reg, i_ord, db_, repoe:=(reg_dbf!=NIL)
deixa_ab=IF(deixa_ab=NIL,.f.,deixa_ab)
IF !repoe                                // ira retornar os RECNO() de cada dbf
   reg_dbf:={}                           // inicializa vetor de retorno
   i_=SELECT()                           // salva area atual
ENDI
FOR t=1 TO nss                           // para cada sistema do vetor sistema...
   db_=sistema[t,O_ARQUI]                // nome do dbf
   IF repoe                              // vai repor os ponteiros dos dbf's
      IF reg_dbf[t,1]>=0                 // se o arquivo estava aberto
         SELE (db_)                      // seleciona-o e
         DBSETORDER(reg_dbf[t,2])        // restaura o indice e o
         GO reg_dbf[t,1]                 // seu ponteiro
      ELSE                               // se o arquivo estava fechado
         IF !EMPTY(SELECT(db_)) .AND.;   // e agora esta aberto
            !deixa_ab                    // e quer fechar,
            CLOSE (db_)                  // entao vamos fecha-lo
         ENDI
      ENDI
   ELSE                                  // acha situacao dos dbf's
      IF !EMPTY(SELECT(db_))             // se o dbf esta aberto
         i_reg=(db_)->(RECNO())          // pega o seu ponteiro
         i_ord=(db_)->(INDEXORD())       // e o seu indice atual
      ELSE                               // caso contrario vamos
         i_reg:= i_ord := -1             // colocar uma flag para fecha-lo depois
      ENDI
      AADD(reg_dbf,{i_reg,i_ord})        // adiciona ponteiro ao vetor de retorno
   ENDI
NEXT
IF !repoe                                // se esta enchendo o vetor, adiciona
   AADD(reg_dbf,i_)                      // a area atual no ultimo elemento
ELSE                                     // se esta restabelecendo,
   SELE (reg_dbf[nss+1])                 // retorna para area original
ENDI
RETU reg_dbf                             // retorna vetor


#ifdef COM_MOUSE

   /*
      Sintaxe: MOUSETECLA( [N1] [,N2] [,N3] [,N4] [,ExpL] )
      Funcao.: Aguarda digita��o de tecla com controle de mouse
                 N1,N2,N3,N4 = janela de avaliacao
                        ExpL = .f. somente as bordas da janela serao verificadas
      Retorna: codigo ASCII da tecla digitada
   */
   FUNC MOUSETECLA(l1,c1,l2,c2,cx_toda)
   LOCAL tecl_p, i, li:=1, co:=1, clic:=0, Tp_Sai, lin_cur, col_cur,;
         cur_, e_calc:=(PROCNAME(3)="MAQCALC")
   IF drvmouse                                        // mouse esta' ligado?
      lin_cur=ROW()                                   // salva linha e
      col_cur=COL()                                   // coluna atual do mouse
      cur_=SETCURSOR()                                // setuacao atual do cursor
      IF e_calc                                       // mouse na calculadora
         l1=lisu_+5                                   // ajusta area de atuacao do mouse
         c1=cosu_+2
         l2=lisu_+8
         c2=cosu_+22
      ELSE
         l1=IF(l1=NIL,0,l1)                           // acha a area de atuacao do mouse
         c1=IF(c1=NIL,0,c1)
         l2=IF(l2=NIL,MAXROW(),l2)
         c2=IF(c2=NIL,79,c2)
      ENDI
      cx_toda=IF(cx_toda=NIL,.t.,cx_toda)             // avalia toda a area de atuacao do mouse?
      MOUSEBOX(l1,c1,l2,c2)                           // define area do mouse
      Tecl_p=0
      MOUSECUR(.t.)                                   // liga cursor do mouse

      #ifdef COM_REDE
         Tp_Sai=SECONDS()+drvtempo                    // tempo de "refresh"
      #endi

      DO WHIL Tecl_p=0

         #ifdef COM_REDE
            IF drvtempo>0.AND.SECONDS()>Tp_Sai        // see' tempo do "refresh"
               EXIT                                   // cai fora...
            ENDI
         #endi

         DO WHILE (clic:=MOUSEGET(@li,@co))>0         // espera um clique do mouse
            IF SECONDS()>tpo_mouse                    // botao do mouse retido por mais de 1 seg,
               EXIT                                   // significa mouse sendo arrastado com
            ENDI                                      // o botao apertado
         ENDD
         tecl_p=NEXTKEY()                             // le tecla do buffer do teclado
         IF tecl_p=0                                  // esta vazio
            IF clic=ESQUERDO                          // botao esquerdo pressionado
               tecl_p=CLICK
               IF li=l1 .OR. li=l2 .OR. cx_toda       // avalia onde foi o clique
                  IF CLICK_EM(gcr,li,co)
                     tecl_p=K_ENTER
                  ELSEIF CLICK_EM("F10",li,co)
                     tecl_p=K_F10
                  ELSEIF CLICK_EM("F9",li,co)
                     tecl_p=K_F9
                  ELSEIF CLICK_EM("F8",li,co)
                     tecl_p=K_F8
                  ELSEIF CLICK_EM("F4",li,co)
                     tecl_p=K_F4
                  ELSEIF CLICK_EM("F3",li,co)
                     tecl_p=K_F3
                  ELSEIF CLICK_EM("TAB",li,co)
                     tecl_p=K_TAB
                  ELSEIF CLICK_EM(CHR(27),li,co)
                     tecl_p=K_LEFT
                  ELSEIF CLICK_EM(CHR(26),li,co)
                     tecl_p=K_RIGHT
                  ELSEIF CLICK_EM(CHR(24),li,co)
                     tecl_p=K_UP
                  ELSEIF CLICK_EM(CHR(25),li,co)
                     tecl_p=K_DOWN
                  ELSEIF CLICK_EM("PgUp",li,co) .OR. CLICK_EM(CHR(30),li,co)
                     tecl_p=K_PGUP
                  ELSEIF CLICK_EM("PgDn",li,co) .OR. CLICK_EM(CHR(31),li,co)
                     tecl_p=K_PGDN
                  ELSEIF CLICK_EM("Topo",li,co) .OR. CLICK_EM(CHR(174),li,co)
                     tecl_p=K_CTRL_PGUP
                  ELSEIF CLICK_EM("Fim",li,co)  .OR. CLICK_EM(CHR(175),li,co)
                     tecl_p=K_CTRL_PGDN
                  ELSEIF CLICK_EM(CHR(18),li,co)
                     tecl_p=74
                  ELSEIF e_calc                       // clique da calculadora sobre
                     msg="1234567890.+-*/%^#$C=R"     // um numero ou sinal
                     FOR i=1 TO LEN(msg)
                        IF CLICK_EM(SUBS(msg,i,1),li,co)
                           tecl_p=ASC(SUBS(msg,i,1))
                           EXIT
                        ENDI
                     NEXT
                  ENDI
               ENDI
            ELSEIF clic=DIREITO                       // botao da direita
               tecl_p=K_ESC                           // abandona com ESC
            ELSE
               tpo_mouse=-1                           // reseta o tempo do mouse
            ENDI
            IF tecl_p>2                               // tecla de funcao clicada
               KEYB CHR(tecl_p)                       // forca tecla no buffer do teclado

               #ifdef COM_TUTOR
                  IN_KEY(0)
               #else
                  INKEY(0)
               #endi

            ENDI
         ELSE

            #ifdef COM_TUTOR
               IN_KEY(0)                              // recebe tecla digitada
            #else
               INKEY(0)                               // recebe tecla digitada
            #endi

         ENDI
      ENDD
      MOUSECUR(.f.)                                   // deliga cursor do mouse
      tpo_mouse=IF(tpo_mouse=-1,SECONDS()+1,tpo_mouse)
      IF cur_!=0
         SETPOS(lin_cur,col_cur)                      // retorna o cursor a posicao original
      ENDI
   ELSE                                               // mouse esta' desligado...

      #ifdef COM_TUTOR

         #ifdef COM_REDE
            tecl_p=IN_KEY(drvtempo)                   // faz "refresh" a cada drvtempo seg
         #else
            tecl_p=IN_KEY(0)                          // aguarda usuario teclar algo
         #endi

      #else

         #ifdef COM_REDE
            tecl_p=INKEY(drvtempo)                    // faz "refresh" a cada drvtempo seg
         #else
            tecl_p=INKEY(0)                           // aguarda usuario teclar algo
         #endi

      #endi

   ENDI
   RETU tecl_p                                        // retorna tecla desejada

   /*
      Sintaxe: CLICK_EM( <ExpC> <,ExpN1> <,ExpN2> )
      Funcao.: Verifica se ExpC esta sobre as coordenadas ExpN1 e ExpN2
      Retorna: .t. se teve sucesso
   */
   STATIC FUNC CLICK_EM(te_cl,li,co)
   LOCAL t_s:="", t1, t2, t_
   t1=LEN(te_cl)                                      // salva trecho de tela nas
   t_ := SAVESCREEN(li,co-t1,li,co+t1)                // coordenadas do clique
   t1=LEN(t_)
   FOR t2=1 TO t1 STEP 2                              // separa os atributos das letras
      t_s+=SUBST(t_,t2,1)                             // do trecho salvo
   NEXT
   t1=AT(te_cl,t_s)                                   // tecla esta sob o cursor?
   IF t1>0                                            // verifica se a tecla nao e'
      t2=ASC(SUBS(t_s,t1-1,1))                        // um pedaco de palavvra
      t1=ASC(SUBS(t_s,t1+LEN(te_cl),1))
      IF (t1<65 .OR. t1>125) .AND. (t2<65 .OR. t2>125)
         RETU .t.                                     // ok. a tecla foi clicada
      ENDI
   ENDI
   RETU .f.                                           // a tecla nao foi clicada

#endi

* \\ Final de LIB_FUNC.PRG
