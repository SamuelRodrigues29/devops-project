# ============================================================
# Etapa 1 - Escolher a imagem base
# ============================================================
FROM node:20-alpine3.19 AS builder

# ============================================================
# Etapa 2 - Criar o ambiente de build
# ============================================================
WORKDIR /usr/src/app

# Habilita o Corepack para utilizar a versão do Yarn definida
# no package.json e no .yarn/releases
RUN corepack enable

# ============================================================
# Etapa 3 - Copiar arquivos de dependências
# ============================================================
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# ============================================================
# Etapa 4 - Instalar dependências
# ============================================================
# --immutable garante que package.json e yarn.lock estejam sincronizados
RUN yarn install --immutable

# ============================================================
# Etapa 5 - Copiar o código-fonte
# ============================================================
COPY . .

# ============================================================
# Etapa 6 - Compilar a aplicação
# ============================================================
RUN yarn build

# ============================================================
# Etapa 7 - Criar a imagem de runtime
# ============================================================
FROM node:20-alpine3.19 AS runtime

WORKDIR /usr/src/app

RUN corepack enable

# ============================================================
# Etapa 8 - Copiar apenas os artefatos necessários
# ============================================================
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/.yarnrc.yml ./
COPY --from=builder /usr/src/app/yarn.lock ./
COPY --from=builder /usr/src/app/.yarn ./.yarn

COPY --from=builder /usr/src/app/node_modules ./node_modules

COPY --from=builder /usr/src/app/dist ./dist

# ============================================================
# Etapa 9 - Executar como usuário não-root
# ============================================================
USER node

EXPOSE 3000

# ============================================================
# Etapa 10 - Executar a aplicação compilada
# ============================================================
CMD ["node", "dist/main"]