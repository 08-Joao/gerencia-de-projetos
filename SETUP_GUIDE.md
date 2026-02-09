# Semana da Computação DECSI - Guia de Setup Completo

## 📱 Aplicativo Mobile Flutter + Firebase

Este é um aplicativo completo para gerenciar a Semana da Computação do DECSI, com suporte a múltiplos tipos de usuários, check-in, programação, agenda personalizada, perguntas aos palestrantes e painel administrativo.

## 🏗️ Arquitetura

### Stack Tecnológico
- **Frontend**: Flutter (multiplataforma iOS/Android)
- **Backend**: Firebase (Firestore, Authentication, Cloud Functions)
- **Armazenamento**: Firebase Storage
- **Notificações**: Firebase Cloud Messaging (FCM)
- **State Management**: Provider
- **Cache Local**: Hive

### Estrutura do Projeto

```
lib/
├── models/              # Modelos de dados
│   ├── user_model.dart
│   ├── event_model.dart
│   ├── activity_model.dart
│   ├── question_model.dart
│   ├── checkin_model.dart
│   ├── agenda_model.dart
│   ├── aviso_model.dart
│   └── notificacao_model.dart
├── services/            # Serviços Firebase
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── providers/           # State Management
│   ├── user_provider.dart
│   ├── event_provider.dart
│   ├── agenda_provider.dart
│   ├── question_provider.dart
│   ├── admin_provider.dart
│   └── checkin_provider.dart
├── screens/             # Telas da aplicação
│   ├── home_screen.dart
│   ├── programming_screen.dart
│   ├── agenda_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   ├── admin_panel_screen.dart
│   └── speaker_management_screen.dart
├── signin.dart          # Tela de login
├── signup.dart          # Tela de cadastro
└── main.dart            # Ponto de entrada
```

## 🔐 Sistema de Usuários

### Tipos de Usuário

#### 1. **PARTICIPANTE** (Padrão)
- Acesso automático após cadastro
- Pode fazer check-in no evento
- Pode criar agenda personalizada
- Pode enviar perguntas aos palestrantes
- Visualiza programação completa

#### 2. **PALESTRANTE**
- Requer aprovação de admin
- Pode cadastrar/editar suas palestras
- Visualiza perguntas recebidas
- Acesso a todas funcionalidades de participante
- Status: `pendente` → `ativo` (após aprovação)

#### 3. **ADMIN**
- Acesso total ao sistema
- Aprova contas de palestrantes
- Gerencia eventos e atividades
- Envia avisos gerais
- Modera perguntas
- Visualiza estatísticas

### Estrutura de Dados do Usuário (Firestore)

```json
{
  "uid": "string",
  "email": "string",
  "nome": "string",
  "tipo": "participante|palestrante|admin",
  "status": "ativo|pendente|recusado",
  "fotoPerfil": "url",
  "instituicao": "string",
  "bio": "string (apenas palestrantes)",
  "criadoEm": "timestamp",
  "atualizadoEm": "timestamp"
}
```

## 🚀 Funcionalidades Implementadas

### 1. Autenticação e Cadastro
- ✅ Login com email e senha
- ✅ Cadastro com validação em tempo real
- ✅ Opção "Sou palestrante" com campo de bio
- ✅ Recuperação de senha
- ✅ Logout seguro

### 2. Check-in no Evento
- ✅ Botão destacado "Fazer Check-in"
- ✅ Verificação de período ativo do evento
- ✅ Modal de confirmação
- ✅ Feedback visual (ícone de check verde)
- ✅ Timestamp registrado no Firestore
- ✅ Prevenção de múltiplos check-ins

### 3. Programação Completa
- ✅ Lista de atividades agrupadas por dia
- ✅ Cards com informações detalhadas
- ✅ Filtros por tipo, tag e palestrante
- ✅ Busca por palestrante
- ✅ Botão "Adicionar à agenda"
- ✅ Indicador de tipo de atividade

### 4. Agenda Personalizada
- ✅ Favoritar atividades
- ✅ Visualizar apenas atividades favoritadas
- ✅ Configurar lembretes (5, 15, 30, 60 minutos)
- ✅ Detecção de conflitos de horário
- ✅ Modal de alerta para conflitos
- ✅ Remover atividades da agenda

### 5. Perguntas aos Palestrantes
- ✅ Envio de perguntas com validação
- ✅ Filtro automático de conteúdo inapropriado
- ✅ Status de pergunta (pendente/aprovada/recusada)
- ✅ Lista "Minhas Perguntas"
- ✅ Painel de moderação para admin
- ✅ Notificação de aprovação/recusa

### 6. Cadastro de Palestras (Palestrante)
- ✅ Tela de gerenciamento de palestras
- ✅ Formulário completo com validações
- ✅ Salvar como rascunho ou publicar
- ✅ Editar palestras existentes
- ✅ Detecção de conflito de horário
- ✅ Upload de material de apoio (estrutura pronta)

### 7. Avisos e Notificações
- ✅ Painel admin para envio de avisos
- ✅ Tipos: Urgente, Normal, Informativo
- ✅ Notificações push via FCM
- ✅ Lista de avisos com status lido/não lido
- ✅ Configurações de notificação
- ✅ Histórico de notificações

### 8. Painel Administrativo
- ✅ Dashboard com estatísticas
- ✅ Aprovação/recusa de palestrantes
- ✅ Moderação de perguntas
- ✅ Envio de avisos
- ✅ Visualização de métricas
- ✅ Gerenciamento de eventos

## 📊 Estrutura de Dados Firestore

### Coleções Principais

```
users/
  {uid}/
    - email, nome, tipo, status, instituicao, bio, fotoPerfil, criadoEm

eventos/
  {eventoId}/
    - nome, descricao, dataInicio, dataFim, ativo
    
atividades/
  {atividadeId}/
    - eventoId, titulo, descricao, palestranteId, palestranteNome
    - data, horaInicio, horaFim, local, tipo, tags, capacidade, publicada
    
agendas/
  {userId}/
    atividades/
      {atividadeId}/
        - adicionadaEm, lembreteMinutos
        
checkins/
  {userId}/
    {eventoId}/
      - timestamp, atividadeId
      
perguntas/
  {perguntaId}/
    - atividadeId, autorId, autorNome, texto, status
    - criadaEm, moderadaEm, motivoRecusa, respondida
    
avisos/
  {avisoId}/
    - titulo, mensagem, tipo, destinatarios[], criadoEm, autorId
    
notificacoes/
  {userId}/
    {notificacaoId}/
      - tipo, titulo, mensagem, lida, criadaEm, referenciaId
```

## 🔧 Configuração do Firebase

### 1. Criar Projeto Firebase
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Criar projeto"
3. Nome: "Semana Computacao DECSI"
4. Aceite os termos e crie o projeto

### 2. Configurar Autenticação
1. No Firebase Console, vá para **Authentication**
2. Clique em **Começar**
3. Ative **Email/Password**
4. Salve as configurações

### 3. Criar Banco de Dados Firestore
1. Vá para **Firestore Database**
2. Clique em **Criar banco de dados**
3. Modo: **Iniciar no modo de teste**
4. Localização: **Selecione a mais próxima**
5. Crie o banco

### 4. Configurar Regras de Segurança Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários - cada um edita apenas seus dados
    match /users/{userId} {
      allow read: if request.auth.uid == userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'admin';
      allow write: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId ||
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'admin';
    }
    
    // Eventos - leitura pública, escrita apenas admin
    match /eventos/{eventoId} {
      allow read: if true;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'admin';
    }
    
    // Atividades - leitura pública, escrita palestrante/admin
    match /atividades/{atividadeId} {
      allow read: if true;
      allow create: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo in ['palestrante', 'admin'];
      allow update: if resource.data.palestranteId == request.auth.uid ||
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'admin';
    }
    
    // Agenda - cada um gerencia sua própria
    match /agendas/{userId}/atividades/{atividadeId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Check-ins - cada um registra seu próprio
    match /checkins/{userId}/{eventoId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Perguntas - leitura pública, escrita autenticado
    match /perguntas/{perguntaId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'admin';
    }
    
    // Avisos - leitura pública, escrita admin
    match /avisos/{avisoId} {
      allow read: if true;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'admin';
    }
    
    // Notificações - cada um lê suas próprias
    match /notificacoes/{userId}/{notificacaoId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### 5. Configurar Firebase no Flutter

1. Instale o Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
```

2. Configure o projeto Flutter:
```bash
cd gerencia_projetos_flutter
flutterfire configure
```

3. Selecione o projeto Firebase criado
4. Selecione as plataformas (Android/iOS)

### 6. Criar Primeiro Usuário Admin

1. No Firebase Console, vá para **Authentication**
2. Clique em **Adicionar usuário**
3. Email: seu email
4. Senha: senha segura
5. Copie o UID

6. Vá para **Firestore** e crie um documento em `users/{uid}`:
```json
{
  "email": "seu@email.com",
  "nome": "Seu Nome",
  "tipo": "admin",
  "status": "ativo",
  "instituicao": "DECSI",
  "criadoEm": "2024-01-01T00:00:00Z",
  "atualizadoEm": "2024-01-01T00:00:00Z"
}
```

## 📦 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^17.1.0
  provider: ^6.1.0
  cached_network_image: ^3.3.1
  intl: ^0.19.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^5.0.0
  uuid: ^4.0.0
  mask_text_input_formatter: ^2.9.0
  cupertino_icons: ^1.0.8
```

## 🚀 Instalação e Execução

### 1. Clonar o Repositório
```bash
git clone <repo-url>
cd gerencia-de-projetos/gerencia_projetos_flutter
```

### 2. Instalar Dependências
```bash
flutter pub get
```

### 3. Gerar Código Firebase
```bash
flutterfire configure
```

### 4. Executar a Aplicação
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web (experimental)
flutter run -d chrome
```

## 🧪 Fluxos de Teste

### Teste de Participante
1. Cadastre-se como participante
2. Faça check-in no evento
3. Visualize a programação
4. Adicione atividades à agenda
5. Envie uma pergunta

### Teste de Palestrante
1. Cadastre-se como palestrante
2. Aguarde aprovação do admin
3. Crie uma palestra
4. Visualize perguntas recebidas
5. Marque como respondida

### Teste de Admin
1. Acesse com conta admin
2. Abra o painel administrativo
3. Aprove/recuse palestrantes
4. Modere perguntas
5. Envie avisos

## 📝 Validações Implementadas

- ✅ Email válido
- ✅ Senha com mínimo 6 caracteres
- ✅ Campos obrigatórios
- ✅ Conflito de horário na agenda
- ✅ Período de check-in válido
- ✅ Filtro de conteúdo inapropriado em perguntas
- ✅ Validação de tipo de usuário para ações

## 🔔 Notificações

### Tipos de Notificação
- Avisos gerais
- Lembretes de atividades
- Mudanças na programação
- Respostas às perguntas
- Aprovação/recusa de palestrante

### Configuração FCM
1. No Firebase Console, vá para **Cloud Messaging**
2. Copie a chave do servidor
3. Configure em Cloud Functions (quando implementado)

## 🎨 Design

- Material Design 3
- Tema claro com suporte a escuro
- Cores da instituição (azul primário)
- Componentes consistentes
- Feedback visual para todas ações

## 📱 Navegação

### Bottom Navigation Bar
- Início (Dashboard)
- Programação
- Agenda
- Avisos
- Perfil

### Navegação Condicional
- Palestrantes: aba "Minhas Palestras"
- Admins: acesso ao painel administrativo

## 🔐 Segurança

- Autenticação Firebase
- Regras de segurança Firestore
- Validação de dados no frontend
- Proteção de dados sensíveis
- Logout seguro

## 🐛 Troubleshooting

### Erro: "Target of URI doesn't exist"
- Execute `flutter pub get`
- Execute `flutterfire configure`
- Limpe o cache: `flutter clean`

### Erro: "Firebase not initialized"
- Verifique se Firebase foi configurado com `flutterfire configure`
- Verifique as credenciais do Firebase

### Erro: "Permission denied" no Firestore
- Verifique as regras de segurança
- Verifique se o usuário está autenticado
- Verifique o tipo de usuário

## 📚 Recursos Adicionais

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)

## 👥 Suporte

Para dúvidas ou problemas, entre em contato com a equipe de desenvolvimento.

---

**Versão**: 1.0.0  
**Última atualização**: Janeiro 2024
