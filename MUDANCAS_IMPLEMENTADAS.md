# Mudanças Implementadas - Telefone e Validação de Senha

## ✅ O que foi feito

### 1. **Adicionada dependência `mask_text_input_formatter`**
- Versão: `^2.9.0`
- Usada para máscara de telefone brasileiro: `(##) #####-####`

### 2. **Atualizado `lib/signup.dart`**
- ✅ Campo de telefone com máscara brasileira `(11) 99999-9999`
- ✅ Validação de telefone (mínimo 11 dígitos)
- ✅ Validação de senha forte com requisitos:
  - Mínimo 8 caracteres
  - Pelo menos 1 letra maiúscula
  - Pelo menos 1 letra minúscula
  - Pelo menos 1 número
  - Pelo menos 1 caractere especial (!@#$%^&* etc)

### 3. **Atualizado `lib/services/user_service.dart`**
- ✅ Adicionado parâmetro `phone` ao método `createUserProfile()`
- ✅ Telefone agora é salvo no Firestore junto com nome e email

## 📋 Próximos passos

### 1. Execute `flutter pub get`
```bash
cd /home/joao/Desktop/gerencia-de-projetos/gerencia_projetos_flutter
flutter pub get
```

Isso vai:
- Baixar a dependência `mask_text_input_formatter`
- Resolver todos os erros de lint

### 2. Teste a implementação
1. Execute o app: `flutter run`
2. Clique em "Criar Conta"
3. Preencha os campos:
   - **Nome**: Seu nome (mín. 3 caracteres)
   - **Telefone**: (11) 99999-9999 (máscara automática)
   - **Email**: seu@email.com
   - **Senha**: Deve conter:
     - Mínimo 8 caracteres
     - 1 maiúscula (ex: A)
     - 1 minúscula (ex: a)
     - 1 número (ex: 1)
     - 1 caractere especial (ex: @, !, #, $, %)
   - **Confirmar Senha**: Mesma senha

### 3. Verifique no Firestore
1. Acesse https://console.firebase.google.com/
2. Vá para **Firestore Database**
3. Abra a coleção `users`
4. Verifique se o documento contém:
   ```json
   {
     "uid": "...",
     "name": "Seu Nome",
     "email": "seu@email.com",
     "phone": "(11) 99999-9999",
     "createdAt": "...",
     "updatedAt": "..."
   }
   ```

## 📝 Exemplos de senhas válidas
- `Senha@123` ✅
- `MyPass!456` ✅
- `Test#2024` ✅
- `senha123` ❌ (sem maiúscula e caractere especial)
- `SENHA123!` ❌ (sem minúscula)
- `Senha!` ❌ (menos de 8 caracteres)

## 🔍 Estrutura de dados no Firestore
Cada usuário agora terá:
```
users/
  └── {uid}/
      ├── uid: "user-id"
      ├── name: "João Silva"
      ├── email: "joao@email.com"
      ├── phone: "(11) 99999-9999"
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

## 🎯 Resumo das mudanças
| Arquivo | Mudança |
|---------|---------|
| `pubspec.yaml` | Adicionado `mask_text_input_formatter: ^2.9.0` |
| `lib/signup.dart` | Campo telefone + validação senha forte |
| `lib/services/user_service.dart` | Parâmetro `phone` adicionado |
