# Gerência de Projetos Flutter

Aplicação Flutter para gerenciamento de projetos com integração Firebase.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Flutter SDK** - [Instruções de instalação](https://flutter.dev/docs/get-started/install)
- **Android Studio** (para desenvolvimento Android)
- **Git**

## Instalação de Dependências

Após clonar o repositório, navegue até a pasta do projeto e instale as dependências do Flutter:

```bash
cd gerencia_projetos_flutter
flutter pub get
```

Este comando irá baixar e instalar todas as dependências especificadas no arquivo `pubspec.yaml`.

## Executando a Aplicação

### Opção 1: Usando `flutter run` com Android Studio

1. Abra o Android Studio
2. Configure um emulador Android ou conecte um dispositivo físico
3. Na raiz do projeto (`gerencia_projetos_flutter`), execute:

```bash
flutter run
```

A aplicação será compilada e executada no emulador ou dispositivo conectado.

### Opção 2: Compilando para um Dispositivo Android

1. Conecte um dispositivo Android ao computador via USB
2. Certifique-se de que o modo de desenvolvedor está ativado no dispositivo
3. Execute:

```bash
flutter run
```

Ou, para gerar um APK para instalação manual:

```bash
flutter build apk
```

O APK gerado estará em `build/app/outputs/apk/release/app-release.apk`

## Estrutura do Projeto

- `lib/` - Código-fonte da aplicação
- `android/` - Configurações específicas para Android
- `ios/` - Configurações específicas para iOS
- `pubspec.yaml` - Dependências e configuração do projeto

## Dependências Principais

- **Firebase Core** - Integração com Firebase
- **Firebase Auth** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados em tempo real
- **Firebase Messaging** - Notificações push
- **Provider** - Gerenciamento de estado
- **Hive** - Armazenamento local

## Troubleshooting

Se encontrar problemas ao executar a aplicação:

1. Atualize o Flutter SDK:
   ```bash
   flutter upgrade
   ```

2. Limpe o cache do projeto:
   ```bash
   flutter clean
   flutter pub get
   ```

3. Verifique se o ambiente está configurado corretamente:
   ```bash
   flutter doctor
   ```

## Suporte

Para mais informações sobre Flutter, visite a [documentação oficial](https://flutter.dev/docs).
