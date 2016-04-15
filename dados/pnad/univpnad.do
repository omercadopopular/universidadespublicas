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
 
capture log close 										// encerra todos os logs abertos
clear 													// limpa a memória
clear matrix 											// limpa a memória de matriz
clear mata 												// limpa a memória de mata
cd "U:\Research\Universidade" 							// define a pasta de trabalho
set more off  											
set maxvar 32000
set matsize 11000
log using universidade.log, replace  					// escolhe o arquivo de logo

///////////////////////////////////////////////////////////////////////////////
/////////////////////// 2. ORGANIZAÇÃO DO BANCO DE DADOS //////////////////////
///////////////////////////////////////////////////////////////////////////////

// 2.1 Importe o banco de dados, crie novas variáveis e faça ajustes
	
	import delimited "PNAD2013.csv", varnames(1)
	
	gen lnrend = ln(rendtrabprinc) 					// crie o log da renda do trabalho principal
	gen lnrfpc = ln(rfpc)							// crie o log da renda familiar per capita
	gen exp = idade - comecotrab					// derive a experiência da idade - idade de ingresso na força de trabalho
	gen exp2 = exp * exp 							// derive a experiência ao quadrado
	gen anosestudo2 = anosestudo * anosestudo 		// derive a anos de estudo ao quadrado
	drop if rfpc == 0 								// exclua as observações com renda familiar per capita atribuída como zero
	
	drop univpriv
	gen univpriv = 0
	replace univpriv = 1 if univ == 1 & univpub == 0 // defina quem estudou em universidade privada


// 2.2 Rotule as variáveis
		
	foreach z in `labels' {
		label var `z' "`l_`z''"
	}
