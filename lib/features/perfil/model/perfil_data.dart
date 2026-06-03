class PerfilData {
  const PerfilData({
    this.nome = '',
    this.sobrenome = '',
    this.peso = '',
    this.altura = '',
    this.caminhoImagem,
  });

  final String nome;
  final String sobrenome;
  final String peso;
  final String altura;
  final String? caminhoImagem;
}
