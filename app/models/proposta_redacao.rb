class PropostaRedacao < ApplicationRecord
  belongs_to :serie
  belongs_to :genero_textual, optional: true

  has_many :avaliacao_conhecimentos

  audited on: [:update, :destroy]	


  enum genero: { 
    carta: 1,
    conto_variacoes: 2,
    cronica: 3,
    receita: 4,
    texto_dissertativo_argumentativo: 5,
    noticia: 6,
    reportagem: 7,
    autobiografia: 8,
    biografia: 9,
    reconto: 10,
    relato: 11,
    fabula: 12,
    diario: 13,
    resumo: 14,
    artigo_de_opiniao: 15,
    resenha: 16,
    carta_aberta: 17,
    manifesto: 18,
    comentario: 19,
    carta_leitor: 20,
    depoimento: 21,
    texto_explicativo: 22,
    texto_narrativo: 23,
    apologo: 24,
    anuncio_publicitario: 25,
    parabola: 26,
    dedicatoria: 27,
    epigrafe: 28,
    discurso: 29,
    email: 30,
    carta_solicitacao: 31,
    carta_reclamacao: 32,
    circular: 33,
    abaixo_assinado: 34
   }
end
