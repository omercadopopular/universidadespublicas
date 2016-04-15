///////////////////////////////////////////////////////////////////////////////
///////////////////////////// PROGRAMADO POR //////////////////////////////////
///////////////////////////////// CARLOS GOES /////////////////////////////////
///////////////////////////// andregoes@gmail.com /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// LEIA ME ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*

PROPÓSITO: Consolidar dados do Censo da Educação Superior

MÉTODOS UTILIZADOS: Consolidação de microdados

 
 */
 
//////////////////////////////////////////////////////////////////////////////
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
cd "U:\Research\Universidade\Censo Educacao Superior\microdados_educacao_superior_2014\Dados"
log using censo.log, replace

///////////////////////////////////////////////////////////////////////////////
/////////////////////// 2. ORGANIZAÇÃO DO BANCO DE DADOS //////////////////////
///////////////////////////////////////////////////////////////////////////////

// 2.1 Importe o banco de dados, crie novas variáveis e faça ajustes

import delimited "U:\Research\Universidade\Censo Educacao Superior\microdados_educacao_superior_2014\Dados\censoeducsup2014short.csv", clear

// 2.2 Cor/Raça

	// defina estudantes de universidade pública
		gen publica = 0
		replace publica = 1 if co_categoria_administrativa == 1
		replace publica = 1 if co_categoria_administrativa == 2
		replace publica = 1 if co_categoria_administrativa == 2

	// defina estudantes brancos
		gen branco = 0
		replace branco = 1 if co_cor_raca_aluno == 1

	// defina estudantes negros (soma de pretos + pardos)
		gen negro = 0
		replace negro = 1 if co_cor_raca_aluno == 2
		replace negro = 1 if co_cor_raca_aluno == 3

	// defina outras cores e raças
		gen outro = 0
		replace outro = 1 if co_cor_raca_aluno == 4
		replace outro = 1 if co_cor_raca_aluno == 5

	// defina cor/raça não informada
		gen ninf = 0
		replace ninf = 1 if co_cor_raca_aluno == 6
		replace ninf = 1 if co_cor_raca_aluno == 0
		

// 2.3 Ciência sem Fronteira

	// Resumir composição racial se participante do CsF
		tabulate ds_cor_raca_aluno if publica == 1 & co_mobilidade_academica_intern == 2

	// Resumir composição racial se não-participante do CsF
		tabulate ds_cor_raca_aluno if publica == 1 & co_mobilidade_academica_intern != 2
		
	// Definir quais cursos são elegíveis para o CsF e resumir composição racial de cursos elegíveis
		egen group = group(no_curso)
		bysort group: egen n = count(group)
		gen csf = 0 if publica == 0
		replace csf = 1 if publica == 1 & co_mobilidade_academica_intern == 2
		bysort group: egen csfe = max(csf)
		
		tabulate ds_cor_raca_aluno if publica == 1 & co_mobilidade_academica_intern != 2 & csfe == 1

// 2.4 Cursos

	// Resumir composição racial para cursos específicos
	  // excluindo cursos com menos de 10 mil estudantes
		// fazendo ajuste para não declarados
		// e gravar esse resumo em um arquivo CSV

		preserve
			keep if publica == 1
			drop if n < 10000
			collapse co_curso branco negro outro ninf n, by(no_curso)
			foreach var in branco negro outro {
				replace `var' = `var' / (1 - ninf)
			}
			sort branco
			drop ninf
			export delimited using "censoeducsup2014shortCOLLAPSE", replace
		restore
