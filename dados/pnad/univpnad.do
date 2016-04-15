///////////////////////////////////////////////////////////////////////////////
///////////////////////////// PROGRAMADO POR //////////////////////////////////
///////////////////////////////// CARLOS GOES /////////////////////////////////
///////////////////////////// andregoes@gmail.com /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// LEIA ME ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*

PROPÓSITO: Verificar a probabilidade de alguém estudar em universidade pública
	e a relação entre anos de estudo e renda com dados da Pesquisa Nacional
	de Amostra de Domicílios - PNAD

MÉTODOS UTILIZADOS: Regressão Logística e Regressão Linear

	Tenha a seguinte extensão instalada:
     -> net search outreg2
 
 */
 
///////////////////////////////////////////////////////////////////////////////
////////////////////////////// INPUTS DO USUÁRIO //////////////////////////////
////////////// ALTERE OS VALORES AQUI PARA MODIFICAR OS RESULTADOS ////////////
///////////////////////////////////////////////////////////////////////////////
 
// I. Especifique a descrição das variáveis
		
	local l_metropolitana "Regiao Metropolitana = 1"
	local l_univpub "Universidade Publica = 1"
	local l_univpriv "Universidade Privada = 1"
	local l_univ "Universidade = 1"
	local l_co "Centro Oeste = 1"
	local l_sul "Sul = 1 "
	local l_sudeste "Sudeste = 1"
	local l_nordeste "Nordeste = 1"
	local l_norte "Norte = 1"
	local l_mulher "Mulher = 1"
	local l_urbano "Urbano = 1"
	local l_negroind "Nao Branco = 1"
	local l_anosestudo "Anos de Estudo"
	local l_anosestudo2 "Anos de Estudo ao Quadrado"
	local l_rfpc "Renda Familiar per Capita, em reais"
	local l_lnrfpc "Log Natural da Renda Familiar per Capita, em reais"
	local l_rendtrabprinc "Log Natural da Renda do Trabalho Principal, em reais"
	local l_lnrend "Log Natural da Renda do Trabalho Principal, em reais"
	
	local labels "lnrfpc metropolitana univpub univpriv univ sul sudeste nordeste norte mulher urbano negroind anosestudo rfpc rendtrabprinc lnrend"
	
// II. Determine os tipos de análise que você deseja realizar, se sim, defina o "local" como 1
		
	// Sumarizar as variáveis descritivas? Sim = 1, Não = 0	
		local descriptive = 1

	// Estimar a probabilidade se estudar em universidades públicas? Sim = 1, Não = 0	
		local logit = 1
		
	// Estimar a relação entre anos de estudo e renda? Sim = 1, Não = 0	
		local linear = 1
 
///////////////////////////////////////////////////////////////////////////////
///////////////////////// CÓDIGO (USUÁRIOS AVANÇADOS) /////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//////////////////// 1. ORGANIZAÇÃO DO ESPAÇO DE TRABALHO /////////////////////
///////////////////////////////////////////////////////////////////////////////
 
// encerre todos os logs abertos
capture log close 
										
// limpe a memória e libere as restrições
clear 													
clear matrix 											
clear mata
set more off  											
set maxvar 32000
set matsize 11000

// defina a pasta de trabalho e escolha o arquivo de log 
cd "U:\Research\Universidade" 							
log using universidade.log, replace

///////////////////////////////////////////////////////////////////////////////
/////////////////////// 2. ORGANIZAÇÃO DO BANCO DE DADOS //////////////////////
///////////////////////////////////////////////////////////////////////////////

// 2.1 Importe o banco de dados, crie novas variáveis e faça ajustes
	
	import delimited "PNAD2013.csv", varnames(1)
	
	// crie o log da renda do trabalho principal
	gen lnrend = ln(rendtrabprinc)
	
	// crie o log da renda familiar per capita
	gen lnrfpc = ln(rfpc)
	
	// derive a experiência da idade - idade de ingresso na força de trabalho
	gen exp = idade - comecotrab
	
	// derive a experiência ao quadrado
	gen exp2 = exp * exp 							
	
	// derive a anos de estudo ao quadrado
	gen anosestudo2 = anosestudo * anosestudo 		
	
	// exclua as observações com renda familiar per capita atribuída como zero
	drop if rfpc == 0 								
	
	// defina quem estudou em universidade privada
	drop univpriv
	gen univpriv = 0
	replace univpriv = 1 if univ == 1 & univpub == 0 


// 2.2 Rotule as variáveis
		
	foreach z in `labels' {
		label var `z' "`l_`z''"
	}



	
///////////////////////////////////////////////////////////////////////////////
//////////////////////// 3.  ESTATÍSTICAS DESCRIVITAS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

if (`descriptive' == 1) {

	// renda familiar per capita de jovens de universidade pública
	sum rfpc if univpub == 1 & idade > 17 & idade < 25, detail
	
	// renda familiar per capita de jovens sem universidade
	sum rfpc if univ == 0  & idade > 17 & idade < 25, detail	

	// T-tests para verificar significância estatística
	
	foreach var in univpub univpriv univ {
		di "`var'"
		ttest rfpc if idade > 17 & idade < 25, by(`var')
	}
	
}

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// 4.  MODELOS /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
