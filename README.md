# Cafezinho

Cafezinho é uma linguagem de programação criada na disciplina de compiladores.

## Código em cafezinho
```javascript
int fatorial(int n){
    	se (n==0)
    	entao
    		retorne 1;
    	senao
    		retorne n* fatorial(n-1);
}
    
programa {
	int n;
	n = 1-0;

	enquanto (n<0) execute {
	        escreva "digite um numero";
	        novalinha;//Imprime uma linha em branco '\n'
	        leia n;    
	}	
  
  	escreva "O fatorial de ";
  	escreva n;
        escreva " e: ";
  	escreva fatorial(n);
  	novalinha;
}
```
## Compilador

O compilador presente nesse repositorio realiza 4 tarefas:

 1. Análise léxica
 2. Análise sintática
 3. Análise semântica
 4. Geração de código em mips

## Requerimentos

Para o compilador funcionar foram utilizadas as seguintes ferramentas:

 1. g++ (versão 7.4.0+)
 2. bison (GNU Bison) (versão 3.0.4+)
 3. flex (versão 2.6.4+)
 4. GNU Make (versão 4.1)
> **Obs:** O **GNU Make** é uma requisição opcional apenas para execular o Makefile do projeto, podendo ser ignorado e escrevendo o comando diretamente no terminal.

## Executar o compilador

No terminal rode o make:

    $ make

Será criado então um executável com nome **parser**. Para rodar basta utilizar:

    $ ./parser < CodigoEmLinguagemCafezinho.txt

## ToDo List
Algumas coisas ainda não estão funcionando bem no compilador, especificamente na parte de geração de código. Utilizando um simulador de Mips como Mars os seguintes erros/implementações podem ser observados:

 1. A geração de código para acesso em vetor ainda não está funcionando.
 2. A geração de código para alocar espaço na pilha para um parâmetro do tipo vetor de uma função, é feito não baseado no tamanho do vetor, mas sim em um tamanho fixo (por ex: 100bytes), o certo seria no tamanho real do vetor.



