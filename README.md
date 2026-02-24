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

## Configurando seu próprio Firebase

**Importante**: Os arquivos de configuração Firebase (`google-services.json` para Android e `GoogleService-Info.plist` para iOS) já estão presentes no repositório e **não são excluídos do GitHub**. Você pode usá-los como referência para criar os seus próprios.

Para usar a aplicação com seu próprio projeto Firebase, siga os passos abaixo:

### 1. Criar um Projeto Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto" ou "Create project"
3. Digite um nome para seu projeto
4. Siga as instruções para criar o projeto

### 2. Configurar Android

1. No Firebase Console, clique em "Adicionar app" e selecione **Android**
2. Preencha os dados:
   - **Nome do pacote**: Use o mesmo nome do pacote do seu projeto
   - Você pode encontrar o nome do pacote em `android/app/build.gradle` (procure por `applicationId`)
   - Como referência, veja o arquivo `android/app/google-services.json` existente no projeto para entender a estrutura esperada
3. Baixe o arquivo `google-services.json` gerado pelo Firebase
4. Substitua o arquivo existente em: `android/app/google-services.json`
   - O arquivo que já existe no projeto é um exemplo da estrutura correta
   - Seu novo arquivo terá as mesmas chaves, mas com valores específicos do seu projeto Firebase
5. Clique em "Próximo" e siga as instruções de configuração

### 3. Configurar iOS

1. No Firebase Console, clique em "Adicionar app" e selecione **iOS**
2. Preencha os dados:
   - **Bundle ID**: `com.example.gerenciaDeProjectos` (ou seu próprio bundle)
   - Você pode encontrar o Bundle ID em `ios/Runner.xcodeproj/project.pbxproj`
3. Baixe o arquivo `GoogleService-Info.plist`
4. Abra o Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
5. Arraste o arquivo `GoogleService-Info.plist` para o projeto Xcode (certifique-se de marcar "Copy items if needed")
6. Clique em "Próximo" e siga as instruções de configuração

### 4. Ativar Serviços Firebase Necessários

No Firebase Console, ative os seguintes serviços:

- **Authentication** - Para login de usuários
- **Cloud Firestore** - Para armazenar dados
- **Cloud Messaging** - Para notificações push

### 5. Executar a Aplicação

Após configurar o Firebase, execute:

```bash
flutter clean
flutter pub get
flutter run
```

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
