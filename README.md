# 📚 Clube do Livro

App em Flutter para o clube do livro: biblioteca compartilhada, votação da próxima leitura,
leitura atual, encontros e participantes.

> Um lugar para ler, conversar, discordar e descobrir novas histórias. 🌷

---

## ✨ Funcionalidades

- **Login e cadastro** de participantes (e-mail/senha). O primeiro participante cadastrado no
  clube se torna **admin** automaticamente.
- **Início** — leitura atual em destaque, próximo encontro marcado e atalhos para as outras seções.
- **Biblioteca** — todos os livros já passados pelo clube, com filtro por status:
  - `Sugestão` → `Em votação` → `Lendo agora` → `Lido` (ou `Arquivado`)
  - **Admin** pode adicionar livros em qualquer status e mover o status livremente.
  - **Participantes** podem **sugerir** livros (entram automaticamente como "Sugestão", aguardando o admin liberar a votação).
- **Votação** — mostra os livros que o admin abriu para votação; cada participante vota uma vez por livro (pode desmarcar o voto).
- **Leitura Atual** — destaque do livro em andamento, com opção de marcar "estou lendo junto".
- **Encontros** — admin cria (data, horário, local, formato, livro relacionado, pauta); participantes confirmam presença.
- **Participantes** — lista de membros, perfil individual e edição do próprio perfil (apelido, cidade, aniversário, Instagram, gêneros favoritos).

Identidade visual "cozy + literária": creme, rosa queimado, marrom e rosa claro, com
tipografia serifada (Playfair Display) nos títulos e Lato no corpo do texto.

### 🧩 Ainda não implementado (próximas etapas)
Discussões, Avaliações (nota + resenha por participante), Lista de Desejos separada, Ranking
divertido (categorias como "mais emocionante", "maior plot twist"), Desafios de leitura e
página de Regras do clube. A estrutura de dados já foi pensada para comportar isso depois.

---

## 🛠️ Tecnologias

- **Flutter** (Dart) — app mobile/web
- **Firebase Authentication** — login por e-mail/senha
- **Cloud Firestore** — banco de dados em tempo real
- **Provider** — gerenciamento de estado
- **google_fonts** — tipografia

---

## 📁 Estrutura do projeto

```
lib/
  models/       -> Participante, Livro, Votacao, Encontro
  services/     -> AuthService, FirestoreService, UserProvider (estado do usuário logado)
  theme/        -> paleta de cores e tipografia "cozy"
  screens/
    auth/            -> login, cadastro
    home/            -> tela inicial + shell de navegação
    biblioteca/      -> lista, formulário e detalhe de livros
    votacao/         -> tela de votação
    leitura_atual/   -> destaque do livro atual
    encontros/       -> lista, formulário e detalhe de encontros
    participantes/   -> lista, perfil e edição de perfil
firestore.rules  -> regras de segurança do banco (ver seção do banco de dados abaixo)
```

---

## 🔧 Como rodar o app localmente (front-end)

### 1. Instale o Flutter
https://docs.flutter.dev/get-started/install — confirme com `flutter doctor`.

### 2. Baixe as dependências
```bash
flutter pub get
```

### 3. Configure a conexão com o Firebase
Este repositório **não inclui** o arquivo `lib/firebase_options.dart` com credenciais reais
(ele é gerado localmente e não deve ser o mesmo para todo mundo que clonar o projeto, a não
ser que estejam todos usando o mesmo projeto Firebase). Veja a seção **"Banco de dados
(Firebase)"** abaixo para gerar o seu.

### 4. Rode o app
```bash
flutter run
```

### 5. Rode os testes (opcional)
```bash
flutter test
```

---

## 🔥 Banco de dados (Firebase) — leia se você for configurar o back-end

Esta seção é para quem vai criar e conectar o projeto Firebase que o app usa como banco de
dados. O app já está preparado para consumir essa estrutura — só falta criar o projeto e
gerar as credenciais.

### O que o app espera encontrar

**Authentication:** método de login por **e-mail/senha** habilitado.

**Firestore Database**, com estas coleções (criadas automaticamente pelo app na primeira
gravação, não precisa criar manualmente):

| Coleção | Descrição | Documento de referência |
|---|---|---|
| `participantes/{uid}` | Um documento por usuário, com o **mesmo id do Firebase Auth** | `lib/models/participante.dart` |
| `livros/{id}` | Biblioteca do clube (campo `status`: Sugestão, Em votação, Lendo agora, Lido, Arquivado) | `lib/models/livro.dart` |
| `votacoes/{id}` | Uma votação aberta por livro liberado pelo admin (campo `votosIds`) | `lib/models/votacao.dart` |
| `encontros/{id}` | Reuniões do clube | `lib/models/encontro.dart` |

> O **primeiro** documento criado em `participantes` (ou seja, o primeiro cadastro feito no
> app) recebe `isAdmin: true` automaticamente — é assim que a pessoa se torna administradora
> do clube. Para trocar depois, edite manualmente esse campo no Firestore.

### Passo a passo para criar o projeto

1. Acesse [console.firebase.google.com](https://console.firebase.google.com) e crie um novo projeto.
2. **Authentication** → Sign-in method → ative **E-mail/senha**.
3. **Firestore Database** → Criar banco de dados → edição **Standard** → região mais próxima
   dos usuários (ex.: `southamerica-east1`) → modo produção.
4. Na aba **Regras** do Firestore, cole o conteúdo do arquivo [`firestore.rules`](./firestore.rules)
   deste repositório e publique. Essas regras já implementam a lógica de permissões:
   - só o admin cria/edita livros e encontros (exceto marcar presença/leitura, que qualquer
     participante logado pode);
   - participantes podem sugerir livros (status obrigatoriamente "Sugestão") e votar (só
     alteram o próprio voto);
   - cada participante só edita o próprio perfil.
5. Gere as credenciais do app para o Flutter:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Escolha o projeto criado e as plataformas desejadas (Android/iOS/Web). Isso cria o arquivo
   `lib/firebase_options.dart` com as chaves reais — **é seguro comitar esse arquivo**, pois
   as chaves ali (`apiKey` etc.) não são secretas; a segurança real vem das regras do
   Firestore do passo 4. Se preferir manter fora do repositório mesmo assim, adicione
   `lib/firebase_options.dart` e `android/app/google-services.json` ao `.gitignore` e
   compartilhe esses arquivos por outro canal com quem for rodar o app.

### ⚠️ Índices do Firestore
A tela de Biblioteca filtra por `status` **e** ordena por `criadoEm` ao mesmo tempo — o
Firestore vai pedir um índice composto na primeira consulta desse tipo. Quando aparecer o
erro no console/terminal, ele já vem com um link pré-preenchido para criar o índice
automaticamente (leva 1–2 minutos).

---

## 📄 Licença
Projeto pessoal — sem licença definida ainda.
