/*
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 \ Empresa.: Denny Paulista Azevedo Filho
 \ Programa: CLIENTES.PRG
 \ Data....: 10-12-96
 \ Sistema.: Libera��o de Uso de Softwares
 \ Funcao..: Gerenciador do chaves de liberacao
 \ Analista: Denny Paulista Azevedo Filho
 \ Criacao.: GAS-Pro v3.0 
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/

#include "libuso.ch"    // inicializa constantes manifestas

PARA lin_menu,col_menu
PRIV op_sis, tela_fundo:=SAVESCREEN(0,0,MAXROW(),79)
op_sis=EVAL(qualsis,"CLIENTES")
IF nivelop<sistema[op_sis,O_OUTROS,O_NIVEL]                  // se usuario nao tem permissao,
   ALERTA()                                                  // entao, beep, beep, beep
   DBOX(msg_auto,,,3)                                        // lamentamos e
   RETU                                                      // retornamos ao menu
ENDI
cn:=fgrep :=.f.

#ifdef COM_LOCK
   IF LEN(pr_ok)>0                                           // se a protecao acusou
      ? pr_ok                                                // erro, avisa e
      QUIT                                                   // encerra a aplicacao
   ENDI
#endi

t_fundo=SAVESCREEN(0,0,MAXROW(),79)                          // salva tela do fundo
op_cad=1
DO WHIL op_cad!=0
   criterio=""
   sistema[op_sis,O_TELA,O_ATUAL]=1
   RESTSCREEN(,0,MAXROW(),79,t_fundo)                        // restaura tela do fundo
   cod_sos=54 ; cn=.f.
   CLEA TYPEAHEAD                                            // limpa o buffer do teclado
   fgrep=.f.
   SET KEY K_F3 TO                                           // retira das teclas F3 e F4 as
   SET KEY K_F4 TO                                           // funcoes de repeticao e confirmacao
   msg="Inclus�o|"+;
       "Manuten��o|"+;
       "Consulta"
   op_cad=DBOX(msg,lin_menu,col_menu,E_MENU,NAO_APAGA,,,,op_cad)
   IF op_cad!=0                                              // se escolheu uma opcao
      Tela_fundo=SAVESCREEN(0,0,MAXROW(),79)                 // salva a tela para ROLATELA()
      SELE A                                                 // e abre o arquivo e seus indices

      #ifdef COM_REDE
         IF !USEARQ(sistema[op_sis,O_ARQUI],.f.,20,1)        // se falhou a abertura do
            RETU                                             // arquivo volta ao menu anterior
         ENDI
      #else
         USEARQ(sistema[op_sis,O_ARQUI])
      #endi

      SET KEY K_F9 TO veoutros                               // habilita consulta em outros arquivos
   ENDI
   DO CASE
      CASE op_cad=01                                         // inclus�o
         op_menu=INCLUSAO
         IF AT("D",exrot[op_sis])=0                          // se usuario pode fazer inclusao
            CLI_INCL()                                       // neste arquivo chama prg de inclusao
         ELSE                                                // caso contrario vamos avisar que
            ALERTA()                                         // ele nao tem permissao para isto
            DBOX(msg_auto,,,3)
         ENDI

      CASE op_cad=02                                         // manuten��o
         op_menu=ALTERACAO
         cod_sos=7
         EDIT()

      CASE op_cad=03                                         // consulta
         op_menu=PROJECOES
         cod_sos=8
         EDITA(3,3,MAXROW()-2,77)

   ENDC
   SET KEY K_F9 TO                                           // F9 nao mais consultara outros arquivos
   CLOS ALL                                                  // fecha todos arquivos abertos
ENDD
RETU

PROC CLI_incl     // inclusao no arquivo CLIENTES
LOCAL getlist:={}, cabem:=1, rep:=ARRAY(FCOU()), ult_reg:=RECN(),;
      ctl_r, ctl_c, ctl_w, t_f3_, t_f4_, dele_atu:=SET(_SET_DELETED,.f.)
PRIV op_menu:=INCLUSAO, tem_borda, criterio:="", cpord:=""
FOR i=1 TO FCOU()                                            // cria/declara privadas as
   msg=FIEL(i)                                               // variaveis de memoria com
   PRIV &msg.                                                // o mesmo nome dos campos
NEXT                                                         // do arquivo
AFILL(rep,"")
t_f3_=SETKEY(K_F3,{||rep()})                                 // repeticao reg anterior
t_f4_=SETKEY(K_F4,{||conf()})                                // confirma campos com ENTER
ctl_w=SETKEY(K_CTRL_W,{||nadafaz()})                         // enganando o CA-Clipper...
ctl_c=SETKEY(K_CTRL_C,{||nadafaz()})
ctl_r=SETKEY(K_CTRL_R,{||nadafaz()})
DO WHIL cabem>0
   cod_sos=6
   sistema[op_sis,O_TELA,O_ATUAL]=1                          // primeira tela...
   rola_t=.f.                                                // flag se quer rolar a tela
   SELE CLIENTES
   GO BOTT                                                   // forca o
   SKIP                                                      // final do arquivo
   
   /*
      cria variaveis de memoria identicas as de arquivo, para inclusao
      de registros
   */
   FOR i=1 TO FCOU()
      msg=FIEL(i)
      M->&msg.=IF(fgrep.AND.!EMPT(rep[1]),rep[i],&msg.)
   NEXT
   DISPBEGIN()                                               // apresenta a tela de uma vez so
   IMPRELA()
   CLI_TELA()
   INFOSIS()                                                 // exibe informacao no rodape' da tela
   DISPEND()
   cabem=DISKSPACE(IF(LEN(drvdbf)<2.OR.drvdbf="\",0,ASC(drvdbf)-64))
   cabem=INT((cabem-2048)/CLIENTES->(RECSIZE()))
   IF cabem<1                                                // mais nenhum!!!
      ALERTA()
      msg="Verifique ESPA�O EM DISCO, "+usuario
      DBOX(msg,,,,,"INCLUS�O INTERROMPIDA!")                 // vamos parar por aqui!
      EXIT
   ENDI
   SELE 0                                                    // torna visiveis variaveis de memoria
   SETCOLOR(drvcortel+","+drvcorget+",,,"+corcampo)
   SET KEY K_ALT_F8 TO ROLATELA
   
   /*
      recebe chaves do arquivo de indice basico
   */
   @ l_s+04 ,c_s+04 GET  empresa1
                    DEFINICAO 1

   READ
   SET KEY K_ALT_F8 TO
   IF rola_t
      ROLATELA()
      LOOP
   ENDI
   SELE CLIENTES
   IF LASTKEY()=K_ESC                                        // cancelou ou chave em branco
      cabem=0                                                // prepara saida da inclusao
      LOOP                                                   // volta p/ menu de cadastramento
   ENDI
   SEEK M->empresa1
   aprov_reg_=(FOUND().AND.DELE().AND.!drvvisivel)           // vai aproveitar o registro?
   IF FOUND() .AND. !aprov_reg_                              // pesquisou e achou!
      op_menu=ALTERACAO                                      // seta flag de ateracao
      DISPBEGIN()
      IMPRELA()
      CLI_GETS()                                             // mostra conteudo do registro
      INFOSIS()                                              // exibe informacao no rodape' da tela
      DISPEND()
      ALERTA()
      msg="Consultar/alterar|Retornar � inclus�o"            // pergunta se deseja
      op_=DBOX(msg,,,E_MENU,,"REGISTRO J� EXISTE")           // alterar o registro
      IF op_ =1                                              // caso afirmativo
         EDIT()                                              // deixa alterar
      ENDI
      op_menu=INCLUSAO
      LOOP                                                   // volta para inclusao
   ENDI
   SELE 0
   CLI_GET1(INCLUI)                                          // recebe campos
   SELE CLIENTES
   IF LASTKEY()=K_ESC                                        // se cancelou
      ALERTA()                                               // avisa que o registro
      DBOX("Registro n�o inclu�do!",18,,1)                   // nao foi incluido, e volta
      LOOP
   ENDI

   #ifdef COM_REDE
      GO BOTT                                                // vamos bloquear o final do
      SKIP                                                   // arq para que nehum outro
      BLOREG(0,.5)                                           // usuario possa incluir
      SEEK M->empresa1                                       // se registro foi incluido
      aprov_reg_=(FOUND().AND.DELE().AND.!drvvisivel)        // vai aproveitar o registro?
      IF FOUND() .AND. !aprov_reg_                           // por outro usuario, entao
         BLOREG(0,.5)
         FOR i=1 TO FCOU()
            msg=FIEL(i)
            rep[i]=&msg.
            REPL &msg. WITH M->&msg.
         NEXT
         CLI_GET1(FORM_INVERSA)                              // executa formula inversa
         RECA
         FOR i=1 TO FCOU()
            msg=FIEL(i)
            REPL &msg. WITH rep[i]
         NEXT
         ALERTA(4)                                           // beep 4 vezes
         msg="Registro acabou de ser|inclu�do por outro usu�rio!"
         DBOX(msg,,,,,"ATEN��O!")                            // avisa
         SELE CLIENTES
         UNLOCK                                              // libera o registro
         LOOP                                                // e recebe chave novamente
      ENDI
   #endi

   IF aprov_reg_                                             // se vai aproveitar reg excluido

      #ifdef COM_REDE
         BLOREG(0,.5)
      #endi

      RECA                                                   // excluido, vamos recupera-lo
   ELSE                                                      // caso contrario
      APPEND BLANK                                           // inclui reg em branco no dbf
   ENDI
   FOR i=1 TO FCOU()                                         // para cada campo,
      msg=FIEL(i)                                            // salva o conteudo
      rep[i]=M->&msg.                                        // para repetir
      REPL &msg. WITH rep[i]                                 // enche o campo do arquivo
   NEXT

   #ifdef COM_REDE
      UNLOCK                                                 // libera o registro e
      COMMIT                                                 // forca gravacao
   #else
      IF RECC()-INT(RECC()/20)*20=0                          // a cada 20 registros
         COMMIT                                              // digitados forca gravacao
      ENDI
   #endi

   ult_reg=RECN()                                            // ultimo registro digitado
   SUBNIVEL("SENHAMIL")
ENDD
GO ult_reg                                                   // para o ultimo reg digitado
SETKEY(K_F3,t_f3_)                                           // restaura teclas de funcoes
SETKEY(K_F4,t_f4_)
SET(_SET_DELETED,dele_atu)                                      // ecluidos visiveis/invisiveis
SETKEY(K_CTRL_W,ctl_w)
SETKEY(K_CTRL_C,ctl_c)
SETKEY(K_CTRL_R,ctl_r)
RETU

PROC CLI_tela     // tela do arquivo CLIENTES
tem_borda=.f.
l_s=Sistema[op_sis,O_TELA,O_LS]           // coordenadas da tela
c_s=Sistema[op_sis,O_TELA,O_CS]
l_i=Sistema[op_sis,O_TELA,O_LI]
c_i=Sistema[op_sis,O_TELA,O_CI]
SETCOLOR(drvtittel)
vr_memo=NOVAPOSI(@l_s,@c_s,@l_i,@c_i)     // pega posicao atual da tela
CAIXA(SPAC(8),l_s+1,c_s+1,l_i,c_i-1)      // limpa area da tela/sombra
SETCOLOR(drvcortel)
IF sistema[op_sis,O_TELA,O_ATUAL]=1
   @ l_s+01,c_s+1 SAY "������������������������� Clientes - MILENIUM ��������������������������"
   @ l_s+03,c_s+1 SAY " � Empresa ����������������������������� CGC ������������������������Ŀ"
   @ l_s+04,c_s+1 SAY " �                                     �                              �"
   @ l_s+05,c_s+1 SAY " � Inscri��o Estadual ��� Endere�o ���������������������������� N� ��Ĵ"
   @ l_s+06,c_s+1 SAY " �                      �                                     �       �"
   @ l_s+07,c_s+1 SAY " � Bairro ������������� Cidade ��������������� UF � Pa�s ������������Ĵ"
   @ l_s+08,c_s+1 SAY " �                    �                      �    �                   �"
   @ l_s+09,c_s+1 SAY " � CEP �����������Telefone �������� Fax ������������� Telex ���������Ĵ"
   @ l_s+10,c_s+1 SAY " �              �                 �                 �                 �"
   @ l_s+11,c_s+1 SAY " ����������������������������������������������������������������������"
   @ l_s+13,c_s+1 SAY " ������������������������� M�dulos Instalados �������������������������"
   @ l_s+14,c_s+1 SAY " ��������������������������������������������������������������������ͻ"
   @ l_s+15,c_s+1 SAY " � Recep��o       �     � Reserva        �     � Retaguarda     �     �"
   @ l_s+16,c_s+1 SAY " ��������������������������������������������������������������������Ķ"
   @ l_s+17,c_s+1 SAY " � Restaurante    �     � Estoque        �     � Financeiro     �     �"
   @ l_s+18,c_s+1 SAY " ��������������������������������������������������������������������Ķ"
   @ l_s+19,c_s+1 SAY " � Or�ament�rio   �     � Ve�culo        �     � Marina         �     �"
   @ l_s+20,c_s+1 SAY " ��������������������������������������������������������������������ͼ"
ELSE
   @ l_s+01,c_s+1 SAY "������������������������� Clientes - MILENIUM ��������������������������"
   @ l_s+03,c_s+1 SAY "                 ���������� Libera��o de Uso ���������"
   @ l_s+04,c_s+1 SAY "                 �����������������������������������ͻ"
   @ l_s+05,c_s+1 SAY "                 � Inicio do Contrato  �             �"
   @ l_s+06,c_s+1 SAY "                 �����������������������������������Ķ"
   @ l_s+07,c_s+1 SAY "                 � Termino do Contrato �             �"
   @ l_s+08,c_s+1 SAY "                 �����������������������������������ͼ"
   @ l_s+09,c_s+1 SAY "                 � Observa��o Ŀ"
   @ l_s+10,c_s+1 SAY "                 �             �"
   @ l_s+11,c_s+1 SAY "                 ���������������"
ENDI
RETU

PROC CLI_gets     // mostra variaveis do arquivo CLIENTES
LOCAL getlist := {}, ctl_c, ctl_r, t_f7_
CLI_TELA()
SETCOLOR(drvcortel+","+drvcorget+",,,"+corcampo)
IF sistema[op_sis,O_TELA,O_ATUAL]=1
   @ l_s+04 ,c_s+04 GET  empresa1

   @ l_s+04 ,c_s+42 GET  cgc1;
                    PICT sistema[op_sis,O_CAMPO,02,O_MASC]

   @ l_s+06 ,c_s+04 GET  inscr1;
                    PICT sistema[op_sis,O_CAMPO,03,O_MASC]

   @ l_s+06 ,c_s+27 GET  ender1

   @ l_s+06 ,c_s+65 GET  numero1;
                    PICT sistema[op_sis,O_CAMPO,05,O_MASC]

   @ l_s+08 ,c_s+04 GET  bairro1

   @ l_s+08 ,c_s+25 GET  cidade1

   @ l_s+08 ,c_s+48 GET  uf1;
                    PICT sistema[op_sis,O_CAMPO,08,O_MASC]

   @ l_s+08 ,c_s+53 GET  pais1

   @ l_s+10 ,c_s+04 GET  cep1;
                    PICT sistema[op_sis,O_CAMPO,10,O_MASC]

   @ l_s+10 ,c_s+19 GET  tele1;
                    PICT sistema[op_sis,O_CAMPO,11,O_MASC]

   @ l_s+10 ,c_s+37 GET  fax1;
                    PICT sistema[op_sis,O_CAMPO,12,O_MASC]

   @ l_s+10 ,c_s+55 GET  tex1

   @ l_s+15 ,c_s+21 GET  recepcao;
                    PICT sistema[op_sis,O_CAMPO,14,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,14,O_CRIT],,"1")

   @ l_s+15 ,c_s+44 GET  reserva;
                    PICT sistema[op_sis,O_CAMPO,15,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,15,O_CRIT],,"2")

   @ l_s+15 ,c_s+67 GET  retaguarda;
                    PICT sistema[op_sis,O_CAMPO,16,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,16,O_CRIT],,"5")

   @ l_s+17 ,c_s+21 GET  restaurant;
                    PICT sistema[op_sis,O_CAMPO,17,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,17,O_CRIT],,"3")

   @ l_s+17 ,c_s+44 GET  estoque;
                    PICT sistema[op_sis,O_CAMPO,18,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,18,O_CRIT],,"4")

   @ l_s+17 ,c_s+67 GET  financeiro;
                    PICT sistema[op_sis,O_CAMPO,19,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,19,O_CRIT],,"6")

   @ l_s+19 ,c_s+21 GET  orcamen;
                    PICT sistema[op_sis,O_CAMPO,20,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,20,O_CRIT],,"7")

   @ l_s+19 ,c_s+44 GET  veiculo;
                    PICT sistema[op_sis,O_CAMPO,21,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,21,O_CRIT],,"8")

   @ l_s+19 ,c_s+67 GET  marina;
                    PICT sistema[op_sis,O_CAMPO,22,O_MASC]
                    CRIT(sistema[op_sis,O_CAMPO,22,O_CRIT],,"9")

ELSE
   @ l_s+05 ,c_s+43 GET  dtinicont;
                    PICT sistema[op_sis,O_CAMPO,23,O_MASC]

   @ l_s+07 ,c_s+43 GET  dtfimcont;
                    PICT sistema[op_sis,O_CAMPO,24,O_MASC]

   @ l_s+10 ,c_s+23 SAY "{M} "

ENDI
CLEAR GETS
RETU

PROC CLI_get1     // capta variaveis do arquivo CLIENTES
LOCAL getlist := {}, ctl_c, ctl_r, t_f7_
PRIV  blk_clientes:=.t.
PARA tp_mov
IF tp_mov=INCLUI
   ctl_r=SETKEY(K_CTRL_R,{||tela_ant()})
   IF op_menu!=INCLUSAO
      ctl_c=SETKEY(K_CTRL_C,{||tela_seg()})
   ENDI
   DO WHILE sistema[op_sis,O_TELA,O_ATUAL]<=sistema[op_sis,O_TELA,O_DEF]
      volta=0; rola_t=.f.
      memo25:="{F7}"
      t_f7_=SETKEY(K_F7,{||CLI_memo()})
      SET KEY K_ALT_F8 TO ROLATELA
      SETCOLOR(drvcortel+","+drvcorget+",,,"+corcampo)
      IF sistema[op_sis,O_TELA,O_ATUAL]=1
         @ l_s+04 ,c_s+42 GET  cgc1;
                          PICT sistema[op_sis,O_CAMPO,02,O_MASC]
                          DEFINICAO 2

         @ l_s+06 ,c_s+04 GET  inscr1;
                          PICT sistema[op_sis,O_CAMPO,03,O_MASC]
                          DEFINICAO 3

         @ l_s+06 ,c_s+27 GET  ender1
                          DEFINICAO 4

         @ l_s+06 ,c_s+65 GET  numero1;
                          PICT sistema[op_sis,O_CAMPO,05,O_MASC]
                          DEFINICAO 5

         @ l_s+08 ,c_s+04 GET  bairro1
                          DEFINICAO 6

         @ l_s+08 ,c_s+25 GET  cidade1
                          DEFINICAO 7

         @ l_s+08 ,c_s+48 GET  uf1;
                          PICT sistema[op_sis,O_CAMPO,08,O_MASC]
                          DEFINICAO 8

         @ l_s+08 ,c_s+53 GET  pais1
                          DEFINICAO 9

         @ l_s+10 ,c_s+04 GET  cep1;
                          PICT sistema[op_sis,O_CAMPO,10,O_MASC]
                          DEFINICAO 10

         @ l_s+10 ,c_s+19 GET  tele1;
                          PICT sistema[op_sis,O_CAMPO,11,O_MASC]
                          DEFINICAO 11

         @ l_s+10 ,c_s+37 GET  fax1;
                          PICT sistema[op_sis,O_CAMPO,12,O_MASC]
                          DEFINICAO 12

         @ l_s+10 ,c_s+55 GET  tex1
                          DEFINICAO 13

         @ l_s+15 ,c_s+21 GET  recepcao;
                          PICT sistema[op_sis,O_CAMPO,14,O_MASC]
                          DEFINICAO 14
                          MOSTRA sistema[op_sis,O_FORMULA,1]

         @ l_s+15 ,c_s+44 GET  reserva;
                          PICT sistema[op_sis,O_CAMPO,15,O_MASC]
                          DEFINICAO 15
                          MOSTRA sistema[op_sis,O_FORMULA,2]

         @ l_s+15 ,c_s+67 GET  retaguarda;
                          PICT sistema[op_sis,O_CAMPO,16,O_MASC]
                          DEFINICAO 16
                          MOSTRA sistema[op_sis,O_FORMULA,5]

         @ l_s+17 ,c_s+21 GET  restaurant;
                          PICT sistema[op_sis,O_CAMPO,17,O_MASC]
                          DEFINICAO 17
                          MOSTRA sistema[op_sis,O_FORMULA,3]

         @ l_s+17 ,c_s+44 GET  estoque;
                          PICT sistema[op_sis,O_CAMPO,18,O_MASC]
                          DEFINICAO 18
                          MOSTRA sistema[op_sis,O_FORMULA,4]

         @ l_s+17 ,c_s+67 GET  financeiro;
                          PICT sistema[op_sis,O_CAMPO,19,O_MASC]
                          DEFINICAO 19
                          MOSTRA sistema[op_sis,O_FORMULA,6]

         @ l_s+19 ,c_s+21 GET  orcamen;
                          PICT sistema[op_sis,O_CAMPO,20,O_MASC]
                          DEFINICAO 20
                          MOSTRA sistema[op_sis,O_FORMULA,7]

         @ l_s+19 ,c_s+44 GET  veiculo;
                          PICT sistema[op_sis,O_CAMPO,21,O_MASC]
                          DEFINICAO 21
                          MOSTRA sistema[op_sis,O_FORMULA,8]

         @ l_s+19 ,c_s+67 GET  marina;
                          PICT sistema[op_sis,O_CAMPO,22,O_MASC]
                          DEFINICAO 22
                          MOSTRA sistema[op_sis,O_FORMULA,9]

      ELSE
         @ l_s+05 ,c_s+43 GET  dtinicont;
                          PICT sistema[op_sis,O_CAMPO,23,O_MASC]
                          DEFINICAO 23

         @ l_s+07 ,c_s+43 GET  dtfimcont;
                          PICT sistema[op_sis,O_CAMPO,24,O_MASC]
                          DEFINICAO 24

         @ l_s+10 ,c_s+23 GET  memo25;
                          PICT "@!"
                          DEFINICAO 25

      ENDI
      READ
      SETKEY(K_F7,t_f7_)
      SET KEY K_ALT_F8 TO
      IF rola_t
         ROLATELA()
         LOOP
      ENDI
      IF LASTKEY()!=K_ESC .AND. drvincl .AND. op_menu=INCLUSAO
         IF !CONFINCL()
            LOOP
         ENDI
      ENDI
      IF volta=0 .AND. LASTKEY()=K_ESC
         EXIT
      ENDI
      sistema[op_sis,O_TELA,O_ATUAL]++
      IF sistema[op_sis,O_TELA,O_ATUAL]<=sistema[op_sis,O_TELA,O_DEF]
         CLI_TELA()
         IF op_menu=ALTERACAO .OR. volta=1
            CLI_GETS()
         ENDI
         INFOSIS()
      ELSE
         sistema[op_sis,O_TELA,O_ATUAL]=sistema[op_sis,O_TELA,O_DEF]
         EXIT
      ENDI
   ENDD
   SETKEY(K_CTRL_R,ctl_r)
   IF op_menu!=INCLUSAO
      SETKEY(K_CTRL_C,ctl_c)
   ENDI
ENDI
IF tp_mov=EXCLUI .OR. tp_mov=FORM_INVERSA
   INTREF(FORM_INVERSA)
   DELE
ELSEIF tp_mov=INCLUI .OR. tp_mov=RECUPERA .OR. tp_mov=FORM_DIRETA
   IF op_menu!=INCLUSAO
      RECA
      INTREF(FORM_DIRETA)
   ENDI
ENDI
RETU

PROC CLI_MEMO
IF READVAR()="MEMO25"
   EDIMEMO("obs",sistema[op_sis,O_CAMPO,25,O_TITU],4,2,13,37)
ENDI
RETU

PROC SEN_incl     // inclusao no arquivo SENHAMIL
LOCAL getlist:={}, cabem:=1, rep:=ARRAY(FCOU()), ult_reg:=RECN(), cond_incl_,;
      ctl_r, ctl_c, ctl_w, t_f3_, t_f4_, dele_atu:=SET(_SET_DELETED,.f.)
cond_incl_={||CLIENTES->empresa1!=SENHAMIL->empresa1}        // condicao de inclusao de registros
IF !EVAL(cond_incl_)                                         // se nao pode incluir
   IF op_menu!=INCLUSAO                                      // nao inclusao nao tem msg
      ALERTA(2)                                              // avisa o motivo
      DBOX("N�o � poss�vel digitar pois,|j� existe uma senha para esta empresa.",,,4,,"ATEN��O, "+usuario)
   ENDI
   RETU                                                      // e retorna
ENDI
PRIV op_menu:=INCLUSAO, op_sis, l_s, c_s, l_i, c_i, cod_sos, tem_borda, criterio:="", cpord:=""
op_sis=EVAL(qualsis,"SENHAMIL")
IF AT("D",exrot[op_sis])>0
   RETU
ENDI
FOR i=1 TO FCOU()                                            // cria/declara privadas as
   msg=FIEL(i)                                               // variaveis de memoria com
   PRIV &msg.                                                // o mesmo nome dos campos
NEXT                                                         // do arquivo
AFILL(rep,"")
t_f3_=SETKEY(K_F3,{||rep()})                                 // repeticao reg anterior
t_f4_=SETKEY(K_F4,{||conf()})                                // confirma campos com ENTER
ctl_w=SETKEY(K_CTRL_W,{||nadafaz()})                         // enganando o CA-Clipper...
ctl_c=SETKEY(K_CTRL_C,{||nadafaz()})
ctl_r=SETKEY(K_CTRL_R,{||nadafaz()})
DO WHIL cabem>0
   cod_sos=6
   sistema[op_sis,O_TELA,O_ATUAL]=1                          // primeira tela...
   rola_t=.f.                                                // flag se quer rolar a tela
   SELE SENHAMIL
   GO BOTT                                                   // forca o
   SKIP                                                      // final do arquivo
   
   /*
      cria variaveis de memoria identicas as de arquivo, para inclusao
      de registros
   */
   FOR i=1 TO FCOU()
      msg=FIEL(i)
      M->&msg.=IF(fgrep.AND.!EMPT(rep[1]),rep[i],&msg.)
   NEXT
   
   /*
      inicializa campos de relacionamentos do com os campos do arquivo
      superior (pai)
   */
   FOR i=1 TO LEN(sistema[op_sis,O_CPRELA])
      msg=FIEL(VAL(SUBS(sistema[op_sis,O_ORDEM,1],i*2-1,2)))
      M->&msg.=&(sistema[op_sis,O_CPRELA,i])
   NEXT
   DISPBEGIN()                                               // apresenta a tela de uma vez so
   SEN_TELA()
   INFOSIS()                                                 // exibe informacao no rodape' da tela
   DISPEND()
   IF !EVAL(cond_incl_)
      EXIT
   ENDI
   cabem=DISKSPACE(IF(LEN(drvdbf)<2.OR.drvdbf="\",0,ASC(drvdbf)-64))
   cabem=INT((cabem-2048)/SENHAMIL->(RECSIZE()))
   IF cabem<1                                                // mais nenhum!!!
      ALERTA()
      msg="Verifique ESPA�O EM DISCO, "+usuario
      DBOX(msg,,,,,"INCLUS�O INTERROMPIDA!")                 // vamos parar por aqui!
      EXIT
   ENDI
   SELE 0                                                    // torna visiveis variaveis de memoria
   SEN_GET1(INCLUI)                                          // recebe campos
   SELE SENHAMIL
   IF LASTKEY()=K_ESC                                        // se cancelou
      cabem=0
      LOOP
   ENDI

   #ifdef COM_REDE
      GO BOTT                                                // vamos bloquear o final do
      SKIP                                                   // arq para que nehum outro
      BLOREG(0,.5)                                           // usuario possa incluir
   #endi

   APPEND BLANK                                              // inclui reg em branco no dbf
   FOR i=1 TO FCOU()                                         // para cada campo,
      msg=FIEL(i)                                            // salva o conteudo
      rep[i]=M->&msg.                                        // para repetir
      REPL &msg. WITH rep[i]                                 // enche o campo do arquivo
   NEXT

   #ifdef COM_REDE
      UNLOCK                                                 // libera o registro e
      COMMIT                                                 // forca gravacao
   #else
      IF RECC()-INT(RECC()/20)*20=0                          // a cada 20 registros
         COMMIT                                              // digitados forca gravacao
      ENDI
   #endi

   ult_reg=RECN()                                            // ultimo registro digitado
ENDD
GO ult_reg                                                   // para o ultimo reg digitado
SETKEY(K_F3,t_f3_)                                           // restaura teclas de funcoes
SETKEY(K_F4,t_f4_)
SET(_SET_DELETED,dele_atu)                                      // ecluidos visiveis/invisiveis
SETKEY(K_CTRL_W,ctl_w)
SETKEY(K_CTRL_C,ctl_c)
SETKEY(K_CTRL_R,ctl_r)
RETU

PROC SEN_tela     // tela do arquivo SENHAMIL
tem_borda=.f.
l_s=Sistema[op_sis,O_TELA,O_LS]           // coordenadas da tela
c_s=Sistema[op_sis,O_TELA,O_CS]
l_i=Sistema[op_sis,O_TELA,O_LI]
c_i=Sistema[op_sis,O_TELA,O_CI]
SETCOLOR(drvtittel)
vr_memo=NOVAPOSI(@l_s,@c_s,@l_i,@c_i)     // pega posicao atual da tela
CAIXA(SPAC(8),l_s+1,c_s+1,l_i,c_i-1)      // limpa area da tela/sombra
SETCOLOR(drvcortel)
@ l_s+01,c_s+1 SAY "������������ Senha - MILENIUM ������������"
@ l_s+02,c_s+1 SAY "       � Senha deste per�odo ���Ŀ"
@ l_s+03,c_s+1 SAY "       �                         �"
@ l_s+04,c_s+1 SAY "       ���������������������������"
RETU

PROC SEN_gets     // mostra variaveis do arquivo SENHAMIL
LOCAL getlist := {}
SEN_TELA()
SETCOLOR(drvcortel+","+drvcorget+",,,"+corcampo)
@ l_s+03 ,c_s+12 GET  palavra;
                 PICT sistema[op_sis,O_CAMPO,02,O_MASC]

CLEAR GETS
RETU

PROC SEN_get1     // capta variaveis do arquivo SENHAMIL
LOCAL getlist := {}
PRIV  blk_senhamil:=.t.
PARA tp_mov, excl_rela
excl_rela=IF(excl_rela=NIL,.f.,excl_rela)
IF tp_mov=INCLUI
   DO WHILE .t.
      rola_t=.f.
      SET KEY K_ALT_F8 TO ROLATELA
      SETCOLOR(drvcortel+","+drvcorget+",,,"+corcampo)
      @ l_s+03 ,c_s+12 GET  palavra;
                       PICT sistema[op_sis,O_CAMPO,02,O_MASC]
                       DEFINICAO 2

      READ
      SET KEY K_ALT_F8 TO
      IF rola_t
         ROLATELA()
         LOOP
      ENDI
      IF LASTKEY()!=K_ESC .AND. drvincl .AND. op_menu=INCLUSAO
         IF !CONFINCL()
            LOOP
         ENDI
      ENDI
      EXIT
   ENDD
ENDI
IF tp_mov=EXCLUI .OR. tp_mov=FORM_INVERSA

   #ifdef COM_REDE
      IF !excl_rela
         REPL flag_excl WITH '*'
      ENDI
   #else
      IF !excl_rela
         REPL flag_excl WITH '*'
      ENDI
   #endi

   DELE
ELSEIF tp_mov=INCLUI .OR. tp_mov=RECUPERA .OR. tp_mov=FORM_DIRETA
   IF (op_menu=INCLUSAO .AND. LASTKEY()!=K_ESC) .OR. op_menu!=INCLUSAO
      IF tp_mov=RECUPERA .AND. op_menu!=INCLUSAO .AND. (CLIENTES->(DELE()))
         msg="|"+sistema[EVAL(qualsis,"CLIENTES"),O_MENU]
         ALERTA(2)
         DBOX("Registro exclu�do em:"+msg+"|*",,,,,"IMPOSS�VEL RECUPERAR!")
      ELSE
            IF !excl_rela
               IF op_menu=INCLUSAO
                  flag_excl=' '
               ELSE
                  REPL flag_excl WITH ' '
               ENDI
            ENDI
         IF op_menu!=INCLUSAO
            RECA
         ENDI
      ENDI
   ENDI
ENDI
RETU

* \\ Final de CLIENTES.PRG
