class UserModel {
  final String id;
  final String nome;
  final String email;
  final String fotoUrl;
  final String telefone;
  final String dataNascimento;
  final String focoEstudo;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.fotoUrl,
    this.telefone = '',
    this.dataNascimento = '',
    this.focoEstudo = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'fotoUrl': fotoUrl,
      'telefone': telefone,
      'dataNascimento': dataNascimento,
      'focoEstudo': focoEstudo,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      fotoUrl: map['fotoUrl'] ?? '',
      telefone: map['telefone'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
      focoEstudo: map['focoEstudo'] ?? '',
    );
  }
}
