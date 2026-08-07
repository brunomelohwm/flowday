# FlowDay

FlowDay é um aplicativo Flutter simples para organização de tarefas diárias, com autenticação por email/senha e sincronização de dados no Firebase.

O objetivo do projeto é servir como um app funcional de portfólio, pronto para evoluir com novas funcionalidades sem mudar a base principal.

## Funcionalidades

- Cadastro e login com Firebase Authentication.
- Recuperação de senha por email.
- Criação, edição e exclusão de tarefas.
- Listagem de tarefas em tempo real com Cloud Firestore.
- Visualização de tarefas por calendário.
- Perfil com opção de sair e excluir conta.
- Exclusão de conta remove também o documento do usuário e suas tarefas.
- Validações básicas para evitar tarefas sem título.
- Estados vazios amigáveis para o primeiro uso.

## Stack

- Flutter
- Provider
- Firebase Authentication
- Cloud Firestore

## Estrutura de Dados

As tarefas são salvas no Firestore mantendo a estrutura:

```text
users/{uid}/tasks/{taskId}
```

Cada usuário possui seu próprio documento em `users/{uid}` e suas tarefas ficam isoladas na subcoleção `tasks`.

## Segurança e Privacidade

- O app usa Firebase Authentication como mecanismo principal de autenticação.
- A exclusão de conta exige reautenticação com senha antes de remover dados.
- Ao excluir a conta, o app remove as tarefas do usuário e o documento `users/{uid}`.
- As regras de segurança do Firestore não estão versionadas neste repositório e devem ser configuradas diretamente no Firebase Console .

## Como Rodar

1. Instale as dependências:

```bash
flutter pub get
```

2. Rode o app:

```bash
flutter run
```

## Status

Projeto em fase inicial, com foco em simplicidade, estabilidade e apresentação como portfólio.
