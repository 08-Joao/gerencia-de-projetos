# Guia de Implementação do Firestore

## ✅ O que foi feito

1. **Adicionado `cloud_firestore: ^5.4.0`** ao `pubspec.yaml`
2. **Criado `lib/services/user_service.dart`** com métodos para:
   - `createUserProfile()` - Salva dados do usuário no Firestore
   - `getCurrentUserProfile()` - Busca dados do usuário logado
   - `getUserProfile(uid)` - Busca dados de um usuário específico
   - `updateUserProfile()` - Atualiza dados do usuário

3. **Atualizado `lib/signup.dart`** para:
   - Importar `UserService`
   - Salvar dados do usuário no Firestore após criar conta no Firebase Auth

4. **Atualizado `lib/home.dart`** para:
   - Importar `UserService`
   - Buscar e exibir o nome do usuário do Firestore na tela inicial

## 📋 Próximos passos que VOCÊ precisa fazer

### 1. Executar `flutter pub get`
```bash
flutter pub get
```
Isso vai baixar a dependência `cloud_firestore` e resolver os erros de lint.

### 2. Configurar Firestore no Firebase Console
Acesse: https://console.firebase.google.com/

1. Selecione seu projeto
2. Vá para **Firestore Database**
3. Clique em **Criar banco de dados**
4. Escolha:
   - Localização: **Mais próxima de você** (ex: `southamerica-east1` para Brasil)
   - Modo de segurança: **Modo de teste** (para desenvolvimento)
5. Clique em **Criar**

### 3. Configurar Regras de Segurança do Firestore
No Firebase Console, vá para **Firestore Database > Regras** e substitua o conteúdo por:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Clique em **Publicar**.

### 4. Testar a implementação
1. Execute seu app Flutter
2. Crie uma nova conta
3. Verifique no Firebase Console > Firestore Database se a coleção `users` foi criada com os dados do usuário
4. Faça login e veja se o nome aparece na tela inicial

## 📊 Estrutura de dados no Firestore

Cada usuário terá um documento em `users/{uid}` com esta estrutura:

```json
{
  "uid": "user-id-aqui",
  "name": "João Silva",
  "email": "joao@email.com",
  "createdAt": "2024-02-09T...",
  "updatedAt": "2024-02-09T..."
}
```

## 🔄 Fluxo de dados

**Cadastro:**
1. Usuário preenche formulário de signup
2. Firebase Auth cria conta
3. UserService salva perfil no Firestore
4. App navega para Home

**Login:**
1. Firebase Auth autentica usuário
2. Home busca dados do Firestore
3. Exibe nome do usuário

## 💡 Próximas funcionalidades (opcional)

Você pode expandir isso para:
- Salvar projetos do usuário em `users/{uid}/projects/{projectId}`
- Salvar atividades em `users/{uid}/activities/{activityId}`
- Usar `StreamBuilder` para atualizar dados em tempo real
- Adicionar foto de perfil com Firebase Storage

## ⚠️ Modo de Teste vs Produção

**Modo de Teste (atual):**
- Qualquer um pode ler/escrever
- Bom para desenvolvimento
- Expira em 30 dias

**Modo de Produção:**
- Use as regras de segurança acima
- Apenas usuários autenticados podem acessar seus dados
- Recomendado para apps em produção
