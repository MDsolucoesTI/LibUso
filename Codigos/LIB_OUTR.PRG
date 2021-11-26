/*
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 \ Empresa.: Denny Paulista Azevedo Filho
 \ Programa: LIB_OUTR.PRG
 \ Data....: 05-08-96
 \ Sistema.: Libera��o de Uso de Softwares
 \ Funcao..: Gerenciador do chaves de liberacao
 \ Analista: Denny Paulista Azevedo Filho
 \ Criacao.: GAS-Pro v3.0
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/

#include "libuso.ch"    // inicializa constantes manifestas


#ifdef COM_CALE
   PROC CALE      // Rotina para exibir calend�rio

   /*
      Simplificando a estrutura CASE   (thank you Rick Spence!)
      tbc e' um vetor bidimensional que contem as teclas a serem testadas
      e suas respectivas acoes (dentro de "code blocks")
   */
   LOCAL cale_tela:=SAVESCREEN(0,0,MAXROW(),79), cor_atual:=SETCOLOR(),;
         col_dia, dia_1, lisu_:=6, cosu_:=58, liin_:=20, coin_:=79,;
         i_, cl_, vr_cale, m_e_s, a_n_o, ult_dia,;
         tbc:={;
                {K_DOWN, {||datac:=datac-30}},;
                {K_UP,   {||datac:=datac+30}},;
                {K_RIGHT,{||datac:=datac+365}},;
                {K_LEFT, {||datac:=datac-365}};
              }
   SETCOLOR(drvtitmsg)
   vr_cale=NOVAPOSI(@lisu_,@cosu_,@liin_,@coin_)            // posicao atual do calendario
   CAIXA(mold,lisu_,cosu_,liin_,coin_)                      // monta tela de apresentacao
   SETCOLOR(drvcorenf)                                      // do calendario
   @ lisu_+2,cosu_+1 SAY "Do 2a 3a 4a 5a 6a Sa"
   SETCOLOR(drvtitmsg)
   @ lisu_+ 9,cosu_+1 SAY REPL("�",coin_-cosu_-1)
   @ lisu_+10,cosu_+2 SAY " Incrementa o MES"              // montra teclas disponiveis
   @ lisu_+11,cosu_+2 SAY " Decrementa o MES"
   @ lisu_+12,cosu_+2 SAY CHR(26)+" Incrementa o ANO"
   @ lisu_+13,cosu_+2 SAY CHR(27)+" Decrementa o ANO"
   SETCOLOR(drvcormsg)
   DO WHIL .t.
      @ lisu_+1,cosu_+1 SAY PADL(TRIM(NMES(datac))+" - "+STR(YEAR(datac)),20)
      dia_1=DOW(datac-DAY(datac)+1)              // dia da semana do 1o. dia do mes
      cl_=lisu_+3
      @ cl_,cosu_+1 CLEAR TO liin_-6,coin_-1     // limpa area dos dias
      col_dia=1+cosu_+3*(dia_1-1)                // coluna inicai do 1o. dia do mes
      m_e_s=MONTH(datac)                         // mes
      a_n_o=YEAR(datac)                          // ano
      IF INT(m_e_s/2) = m_e_s/2                  // acha ultimo dia do mes
         ult_dia=IF(m_e_s<8,IF(m_e_s=2,IF(INT(a_n_o/4)=a_n_o/4,29,28),30),31)
      ELSE
         ult_dia=IF(m_e_s<8,31,30)
      ENDI
      FOR i_=1 TO ult_dia                        // imprime os dias
         IF DAY(DATE())=i_                       // se for heje
            SETCOLOR(drvcorenf)                  // enfatiza
         ENDI
         @ cl_,col_dia SAY PADL(STR(i_,2),2)     // imprime o dia na tela
         SETCOLOR(drvcormsg)                     // retorna a cor normal
         col_dia+=3                              // proxima coluna
         IF dia_1/7=INT(dia_1/7)                 // fim da tela do calendario
            cl_++ ; col_dia=cosu_+1              // passa para proxima linha
         ENDI
         dia_1++                                 // proximo dia
      NEXT
      x=SETCURSOR(0)                             // apaga cursor, x=cursor atual

      #ifdef COM_MOUSE
         k=MOUSETECLA(lisu_+10,cosu_+2,liin_-1,cosu_+2)
      #else

         #ifdef COM_TUTOR
            k=IN_KEY(0)                          // aguarda pressionar tecla
         #else
            k=INKEY(0)                           // aguarda pressionar tecla
         #endi

      #endi

      SETCURSOR(x)                               // volta tamanho original do cursor
      nm=ASCAN(tbc,{|ve_a| k=ve_a[1]})           // procura tecla dentro do vetor tbc (e' o CASE)
      IF nm!=0                                   // achou!
         EVAL(tbc[nm,2])                         // portanto, executa a acao...
      ELSE
         IF k=K_ALT_F8                           // muda calendario de posicao
            MUDA_PJ(@lisu_,@cosu_,@liin_,@coin_,cale_tela,.t.)
            sinal_=" "
            PUBL &vr_cale.:=STR(lisu_,2)+STR(cosu_,2)
            SAVE TO (arqconf) ALL LIKE drv*      // salva as coordenadas em disco
         ELSE                                    // tecla sem acao, portanto,
            EXIT                                 // fora...
         ENDI
      ENDI
   ENDD
   RESTSCREEN(0,0,MAXROW(),79,cale_tela)         // restaura tela e
   SETCOLOR(cor_atual)                           // o esquema de cor

   #ifdef COM_MOUSE
      IF drvmouse                                // se o mouse esta' ativo
         DO WHIL MOUSEGET(0,0)!=0                // espera que os botoes sejam
         ENDD                                    // liberados (nao pressionados)
      ENDI
   #endi

   RETU
#endi


#ifdef COM_MAQCALC
   PROC MAQCALC      // Apresenta "pop-calculadora"
   LOCAL tela_c:=SAVESCREEN(0,0,MAXROW(),79), cur_sor:=SETCURSOR(1),;
         getlist:={}, vr_calc, pg_up, pg_dn, tec_f3, tec_f4, tec_f9, tec_f8
   PRIV  sinal_:=" ", num_disp, fgpaste, cor_calc:=SETCOLOR(),;
         lisu_:=1, cosu_:=40, liin_:=9, coin_:=64, sinal_ant:=" "
   vr_calc=NOVAPOSI(@lisu_,@cosu_,@liin_,@coin_)   // pega posicao atual da calculadora
   fgpaste=(!EMPT(READVAR()).AND.;     // ve se ha campo pendente (captura)
           LEFT(READVAR(),4)!="OPC_")
   SETKEY(K_F6,NIL)                    // evita recursividade
   pg_up =SETKEY(K_PGUP,NIL)           // desabilita PgUp,
   pg_dn =SETKEY(K_PGDN,NIL)           // PgDn,
   tec_f3=SETKEY(K_F3,NIL)             // F3,
   tec_f4=SETKEY(K_F4,NIL)             // F4,
   tec_f9=SETKEY(K_F9,NIL)             // F9 e move caixa ( ALT-F8 )
   tec_f8=SETKEY(K_ALT_F8,{||sinal_dig()})

   SETKEY(35 ,{||sinal_dig()})         // #   raiz quadrada
   SETKEY(36 ,{||sinal_dig()})         // $   inteiro/flutuante
   SETKEY(37 ,{||sinal_dig()})         // %   percentual
   SETKEY(42 ,{||sinal_dig()})         // *   multiplica
   SETKEY(43 ,{||sinal_dig()})         // +   soma
   SETKEY(45 ,{||sinal_dig()})         // -   subtrai
   SETKEY(47 ,{||sinal_dig()})         // /   divide
   SETKEY(61 ,{||sinal_dig()})         // =   total
   SETKEY(94 ,{||sinal_dig()})         // ^   exponencial
   SETKEY(99 ,{||sinal_dig()})         // c   limpa display
   SETKEY(67 ,{||sinal_dig()})         // C
   IF fgpaste
      SETKEY(82 ,{||sinal_dig()})      // R   captura resultado do display
      SETKEY(114,{||sinal_dig()})      // r
   ENDI
   SETCOLOR(drvcormsg)
   CAIXA(mold,lisu_,cosu_,liin_,coin_)
   @ lisu_+1,cosu_+2 SAY "�������������������ͻ"
   @ lisu_+2,cosu_+2 SAY "�                   �"
   @ lisu_+3,cosu_+2 SAY "�                   �"
   @ lisu_+4,cosu_+2 SAY "�������������������ͼ"
   @ lisu_+5,cosu_+2 SAY " 7 8 9 C     +  -  * "
   @ lisu_+6,cosu_+2 SAY " 4 5 6 .  =  /  %  ^ "
   @ lisu_+7,cosu_+2 SAY " 1 2 3 0     "+CHR(K_ESC)+"  #  $ "
   SETCOLOR(drvcorget)
   @ lisu_+8,cosu_+2 SAY IF(fgpaste,"R, resultado no campo","")
   SETCOLOR(drvcorget+","+drvcorget+",,,"+drvcorget)
   DO WHIL .t.
      gab=IF(fgint,"   999999999999999",;             // mascara
                   "999999999999999.99")
      num_disp=0.00                                   // numero no display
      @ lisu_+2,cosu_+3 SAY "="
      @ lisu_+2,cosu_+4 GET nu_calc PICT gab          // mostra total
      CLEAR GETS
      @ lisu_+3,cosu_+3 SAY sinal_ant
      @ lisu_+3,cosu_+4 GET num_disp PICT gab         // capta operando
      READ
      DO CASE
         CASE LASTKEY()=K_ESC.OR.sinal_="R"           // finalizou
            IF fgpaste.AND.sinal_="R"
               KEYB ALLTRIM(TRAN(nu_calc,gab))        // joga resultado no campo
            ENDI
            EXIT                                      // e sai
         CASE sinal_="AF8"                            // muda calculadora de posicao
            MUDA_PJ(@lisu_,@cosu_,@liin_,@coin_,tela_c,.t.)
            sinal_=" "
            PUBL &vr_calc.:=STR(lisu_,2)+STR(cosu_,2)
            SAVE TO (arqconf) ALL LIKE drv*           // salva as coordenadas em disco
         CASE sinal_="$"                              // chaveou inteiro/decimal
            fgint=(!fgint); sinal_=" "
         CASE sinal_="C"                              // limpa display
            nu_calc=0; sinal_=" "
         CASE sinal_="#"                              // raiz quadrada
            IF !EMPTY(num_disp)                       // algum numero no display?
               IF sinal_ant="-"                       // op anterior=subtracao?
                  nu_calc-=SQRT(num_disp)             // subtrai a raiz
               ELSE                                   // do display no resultado
                  nu_calc+=SQRT(num_disp)             // senao, soma
               ENDI
            ELSE                                      // nao exite numero no
               nu_calc=SQRT(nu_calc)                  // display, porisso
            ENDI                                      // calcula raiz do total
            sinal_=" "
         OTHERWISE
            DO CASE
               CASE sinal_ant="-"                     // subtrai
                  nu_calc-=num_disp
               CASE sinal_ant="*"                     // multiplica
                  nu_calc=nu_calc*num_disp
               CASE sinal_ant="/"                     // divide
                  nu_calc=nu_calc/num_disp
               CASE sinal_ant="^"                     // eleva potencia
                  nu_calc=nu_calc^num_disp
               CASE sinal_ant="%"                     // obtem percentual
                  nu_calc=nu_calc/100*num_disp
               OTHERWISE                              // soma (+) ou sem operador
                  nu_calc+=num_disp
         ENDC
      ENDC
      sinal_=IF(sinal_="="," ",sinal_)                // igual nao pode ser exibido
      sinal_ant=sinal_; sinal_=" "                    // salva sinal digitado
   ENDD
   SETCOLOR(cor_calc)                                 // volta com as cores anteriores
   SETCURSOR(cur_sor)                                 // volta cursor com era antes
   SET KEY K_F6 TO maqcalc                            // reabilita calculadora (f6)
   SETKEY(35,NIL); SETKEY(36,NIL)                     // desabilita as teclas
   SETKEY(37,NIL); SETKEY(42,NIL)                     // utilizadas na operacao
   SETKEY(43,NIL); SETKEY(45,NIL)                     // da calculadora
   SETKEY(47,NIL); SETKEY(67,NIL)
   SETKEY(94,NIL); SETKEY(99,NIL)
   SETKEY(82,NIL); SETKEY(114,NIL)
   SETKEY(61,NIL)
   SETKEY(K_PGUP,pg_up)                               // habilita teclas PgUp,
   SETKEY(K_PGDN,pg_dn)                               // PgDn,
   SETKEY(K_F3,tec_f3)                                // F3,
   SETKEY(K_F4,tec_f4)                                // F4,
   SETKEY(K_F9,tec_f9)                                // F9 e
   SETKEY(K_ALT_F8,tec_f8)                            // ALT-F8
   RESTSCREEN(0,0,MAXROW(),79,tela_c)                 // restaura a tela
   RETU

   STATIC PROC SINAL_DIG  // Recebe sinal da calculadora
   sinal_=IF(LASTKEY()=K_ALT_F8,"AF8",;               // recebe sinal digitado e
          UPPER(CHR(LASTKEY())))                      // forca saida do get com
   KEYB CHR(K_ENTER)                                  // ENTER simulado
   RETU
#endi

//Fun��o para a verifica��o da senha para o MILENIUM
Function Senha(Area)

If Select(Area)=0
   DbfParam=DrvDbf+Area
   UseArq(DbfParam)
EndIf
simnao:=0
sim=0
nao=0

simnao=simnao+(If(&Area->reserva=[S],83,78))
simnao=simnao+(If(&Area->recepcao=[S],83,78))
simnao=simnao+(If(&Area->retaguarda=[S],83,78))
simnao=simnao+(If(&Area->restaurant=[S],83,78))
simnao=simnao+(If(&Area->estoque=[S],83,78))
simnao=simnao+(If(&Area->financeiro=[S],83,78))
simnao=simnao+(If(&Area->orcamen=[S],83,78))
simnao=simnao+(If(&Area->veiculo=[S],83,78))
simnao=simnao+(If(&Area->marina=[S],83,78))

If(&Area->Recepcao=[S],Sim++,nao++)
If(&Area->reserva=[S],Sim++,nao++)
If(&Area->retaguarda=[S],Sim++,nao++)
If(&Area->restaurant=[S],Sim++,nao++)
If(&Area->estoque=[S],Sim++,nao++)
If(&Area->financeiro=[S],Sim++,nao++)
If(&Area->orcamen=[S],Sim++,nao++)
If(&Area->veiculo=[S],Sim++,nao++)
If(&Area->marina=[S],Sim++,nao++)

simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),01,01)))+17)+sim-nao)*2
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),02,01)))+17)+sim-nao)*3
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),04,01)))+17)+sim-nao)*4
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),05,01)))+17)+sim-nao)*5
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),07,01)))+17)+sim-nao)*7
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),08,01)))+17)+sim-nao)*8
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),09,01)))+17)+sim-nao)*9
simnao=simnao+(((asc(Substr(DtoC(&Area->dtinicont),10,01)))+17)+sim-nao)*10

simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),01,01)))+30)-sim+nao)*9
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),02,01)))+30)-sim+nao)*8
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),04,01)))+30)-sim+nao)*7
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),05,01)))+30)-sim+nao)*6
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),07,01)))+30)-sim+nao)*5
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),08,01)))+30)-sim+nao)*4
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),09,01)))+30)-sim+nao)*3
simnao=simnao+(((asc(Substr(DtoC(&Area->dtfimcont),10,01)))+30)-sim+nao)*2

For I:=1 to 35
   simnao=simnao+(Asc(Substr((&Area->Empresa1),I,01)))
Next
For I:=1 to 14
   simnao=simnao+Asc(Substr((&Area->Cgc1),I,01))
Next
For I:=1 to 12
   simnao=simnao+Asc(Substr((&Area->inscr1),I,01))
next
For I:=1 to 35
   simnao=simnao+Asc(Substr((&Area->ender1),I,01))
next
For I:=1 to 5
   simnao=simnao+Asc(Substr((&Area->numero1),I,01))
next
For I:=1 to 18
   simnao=simnao+Asc(Substr((&Area->bairro1),I,01))
next
For I:=1 to 20
   simnao=simnao+Asc(Substr((&Area->cidade1),I,01))
next
For I:=1 to 2
   simnao=simnao+Asc(Substr((&Area->uf1),I,01))
next
For I:=1 to 15
   simnao=simnao+Asc(Substr((&Area->pais1),I,01))
next
For I:=1 to 08
   simnao=simnao+Asc(Substr((&Area->cep1),I,01))
next
For I:=1 to 12
   simnao=simnao+Asc(Substr((&Area->tele1),I,01))
next
For I:=1 to 12
   simnao=simnao+Asc(Substr((&Area->fax1),I,01))
next
For I:=1 to 15
   simnao=simnao+Asc(Substr((&Area->tex1),I,01))
next
If Sim!=0
   simnao=(simnao*sim)-nao
EndIf
simnao=simnao*simnao*simnao
M->Palavra=Alltrim(Str(SimNao))
SENHAMIL->Palavra=Alltrim(Str(SimNao))
Return(.T.)

//Fun��o para verifica��o da senha para o TRITON

Function SenhaTri(Area)
If Select(Area)=0
   DbfParam=DrvDbf+Area
   UseArq(DbfParam)
EndIf
simnao:=0
sim=0
nao=0

simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),01,01)))+17)+sim-nao)*2
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),02,01)))+17)+sim-nao)*3
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),04,01)))+17)+sim-nao)*4
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),05,01)))+17)+sim-nao)*5
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),07,01)))+17)+sim-nao)*7
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),08,01)))+17)+sim-nao)*8
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),09,01)))+17)+sim-nao)*9
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtinicont),10,01)))+17)+sim-nao)*10

simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),01,01)))+30)-sim+nao)*9
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),02,01)))+30)-sim+nao)*8
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),04,01)))+30)-sim+nao)*7
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),05,01)))+30)-sim+nao)*6
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),07,01)))+30)-sim+nao)*5
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),08,01)))+30)-sim+nao)*4
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),09,01)))+30)-sim+nao)*3
simnao=simnao+(((asc(Substr(DtoC(&Area->Dtfimcont),10,01)))+30)-sim+nao)*2

For I:=1 to 35
   simnao=simnao+(Asc(Substr((&Area->Empresa),I,01)))
Next
For I:=1 to 14
   simnao=simnao+Asc(Substr((&Area->Cgc1),I,01))
Next
For I:=1 to 06
   simnao=simnao+Asc(Substr((&Area->Creci),I,01))
Next
For I:=1 to 35
   simnao=simnao+Asc(Substr((&Area->ender1),I,01))
next
For I:=1 to 5
   simnao=simnao+Asc(Substr(Str(&Area->numero1),I,01))
next
For I:=1 to 18
   simnao=simnao+Asc(Substr((&Area->bairro1),I,01))
next
For I:=1 to 20
   simnao=simnao+Asc(Substr((&Area->cidade1),I,01))
next
For I:=1 to 15
   simnao=simnao+Asc(Substr((&Area->Compl1),I,01))
next
For I:=1 to 2
   simnao=simnao+Asc(Substr((&Area->uf1),I,01))
next
For I:=1 to 08
   simnao=simnao+Asc(Substr((&Area->cep1),I,01))
next
For I:=1 to 12
   simnao=simnao+Asc(Substr((&Area->tele1),I,01))
next
For I:=1 to 12
   simnao=simnao+Asc(Substr((&Area->fax1),I,01))
next
simnao=simnao*simnao*simnao
M->Palavra=Alltrim(Str(SimNao))
SeTriton->Palavra=Alltrim(Str(SimNao))
Return(.T.)
* \\ Final de LIB_OUTR.PRG
