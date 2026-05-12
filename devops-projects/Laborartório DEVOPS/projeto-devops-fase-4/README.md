# Projeto DevOps - Automação de Deploy de Site em Instância EC2

## Descrição
Este projeto implementa uma pipeline CI/CD utilizando GitHub Actions para automatizar o build, push de uma imagem Docker para o Amazon ECR e o deploy de um site estático em uma instância EC2 na AWS. O site é composto por arquivos HTML, CSS e JavaScript, containerizados via Docker. A pipeline é acionada em pushes para a branch `main`, garantindo integração contínua e entrega contínua com foco em segurança e eficiência, seguindo melhores práticas de DevSecOps, como uso de credenciais temporárias via OIDC e segredos gerenciados.

Essa abordagem promove escalabilidade, com o uso de Infrastructure as Code (IaC) implícito na configuração da pipeline, e reliability através de dependências entre jobs para evitar deploys falhos. Para mais detalhes sobre GitHub Actions, consulte a [documentação oficial](https://docs.github.com/en/actions).

## Assista ao Tutorial em Vídeo
Para complementar esta documentação, elaborei um vídeo completo que explica passo a passo a implementação da pipeline CI/CD, desde a configuração inicial até o deploy na instância EC2, com foco em melhores práticas de DevOps, como uso de credenciais temporárias via OIDC e tagging dinâmico de imagens Docker.

Esse vídeo faz parte da série "DevOps na Prática", e corresponde à parte 4 de uma playlist abrangente, que cobre todo o processo desde os conceitos iniciais até as otimizações avançadas, incluindo integração com ferramentas como Terraform e SonarQube. Acesse a playlist completa aqui: [Playlist DevOps na Prática](https://youtube.com/playlist?list=PLOCRt8ucq6xNSMUvfTxnk-M4mk9Etwpy6&si=LOoW5N9Xc6-QViKN). Recomendo assistir para uma visão prática e visual.

## Pré-requisitos

- Conta AWS com permissões para ECR e EC2.
- Repositório GitHub com segredos configurados: `INSTANCE_KEY` (chave SSH privada) e `PUBLIC_IP` (IP público da instância EC2).
- Role IAM no AWS para GitHub Actions (usando OIDC para autenticação segura, sem chaves de acesso permanentes). Veja [documentação AWS para GitHub Actions](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html).
- Instância EC2 com Docker instalado e acesso SSH configurado para o usuário `ec2-user`.
- Repositório ECR criado na região `us-east-2`.

## Estrutura do Repositório

- **website/**: Contém os arquivos do site:
  - `index.html`: Página principal.
  - Arquivos CSS e JavaScript para estilização e funcionalidades.
- **Dockerfile**: Arquivo para build da imagem Docker do site, baseado em uma imagem web server como Nginx ou similar (exemplo: copia arquivos para `/usr/share/nginx/html`).
- **.github/workflows/deploy.yaml**: Workflow do GitHub Actions para a pipeline CI/CD.

## Pipeline CI/CD

A pipeline é definida no arquivo `deploy.yaml` e consiste em dois jobs sequenciais: build e push para ECR, seguido de deploy via SSH na EC2.

```yaml
name: Pipeline CI/CD

on:
  push:
    branches:
      - main

permissions:
  id-token: write
  contents: read

jobs:
  job1:
    name: build_ecr
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v5.0.0

      - name: "Configure AWS Credentials" 
        uses: aws-actions/configure-aws-credentials@v4.3.1
        with:
          role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/GitHubActionsRepoApp
          aws-region: us-east-2

      - name: Amazon ECR "Login" Action for GitHub Actions
        uses: aws-actions/amazon-ecr-login@v2.0.1
      
      - name: Build, Tag, and Push image to Amazon ECR
        run: |
          docker build -t meu-website:v1.0 .
          docker tag meu-website:v1.0 <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/site_prod:v1.0
          docker push <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/site_prod:v1.0

  job2:
    name: deploy_ec2
    needs: job1
    env:
      INSTANCE_KEY: ${{secrets.INSTANCE_KEY}}
      PUBLIC_IP: ${{secrets.PUBLIC_IP}}
    runs-on: ubuntu-latest
    steps:
     - name: Deploy EC2 SSH
       run: |
          echo "$INSTANCE_KEY" > chave-site.pem
          chmod 400 chave-site.pem
          ssh -i chave-site.pem -o StrictHostKeyChecking=no ec2-user@$PUBLIC_IP << EOF
            aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com
            docker pull <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/site_prod:v1.0
            echo "parando container antigo site"
            docker stop site || true
            echo "removendo container antigo site"
            docker rm site || true
            echo "rodando nova tag da imagem"
            docker run -d -p 80:80 --name site <ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/site_prod:v1.0
            echo "Parabéns! Imagem foi atualizada!"
            docker ps
          EOF
          rm chave-site.pem
```

**Observações de Segurança:**
- Substitua `<ACCOUNT_ID>` pelo ID da sua conta AWS.
- Use segredos do GitHub para armazenar chaves sensíveis, evitando exposição no código.
- A opção `-o StrictHostKeyChecking=no` é usada para automação

## Explicação das Etapas

1. **Trigger**: A pipeline é acionada automaticamente em pushes para a branch `main`.

2. **Job 1 - build_ecr**:
   - **Checkout**: Baixa o código do repositório.
   - **Configure AWS Credentials**: Assume uma role IAM via OIDC para autenticação segura sem chaves de acesso.
   - **ECR Login**: Realiza login no ECR usando credenciais temporárias.
   - **Build, Tag e Push**: Constrói a imagem Docker a partir do `Dockerfile`, tagga com a versão e envia para o repositório ECR.

3. **Job 2 - deploy_ec2** (dependente do Job 1):
   - Usa segredos para chave SSH e IP da EC2.
   - Cria um arquivo temporário com a chave SSH e configura permissões.
   - Conecta via SSH à instância EC2 e executa comandos para:
     - Login no ECR.
     - Pull da nova imagem.
     - Parada e remoção do container antigo (se existir).
     - Execução do novo container mapeando porta 80.
     - Verificação com `docker ps`.
   - Remove a chave temporária para evitar vazamentos.



## Pipeline CI/CD Customizável (deploy2.yaml)

### Descrição

Esta é uma versão customizável e ligeiramente mais complexa da pipeline CI/CD, definida no arquivo `deploy2.yaml`. Ela aprimora a automação de build, tag e push de imagens Docker para o Amazon ECR, seguida de deploy em uma instância EC2 via SSH. As melhorias incluem: tagging dinâmico da imagem com base no commit SHA e ambiente (prod ou dev, dependendo da branch), uso de outputs para passar variáveis entre jobs, e maior flexibilidade para ambientes multi-branch. Isso segue melhores práticas de DevSecOps, como uso de credenciais temporárias via OIDC, variáveis de ambiente para configuração dinâmica, e atomicidade via dependências de jobs, reduzindo toil e melhorando a rastreabilidade (ex.: logs com tags únicas). Para detalhes sobre outputs em GitHub Actions, consulte a [documentação oficial](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idoutputs).

Essa versão é ideal para cenários onde se deseja escalabilidade, como integração com múltiplos ambientes ou integração com ferramentas como Terraform para provisionamento dinâmico de recursos. Ela mantém foco em segurança, utilizando segredos gerenciados e permissões mínimas (`contents: read` e `id-token: write`).

### Pré-requisitos

Mesmos da pipeline original, com adição de:
- Configuração de branches adicionais (ex.: `dev` para ambientes de teste), ajustando a lógica de `ENVIRONMENT`.
- Repositório ECR com permissões para push de tags dinâmicas.

### Pipeline CI/CD Customizável

O workflow é acionado em pushes para `main`, mas pode ser expandido para outras branches. Aqui está o conteúdo do `deploy2.yaml` (com dados sensíveis substituídos por placeholders):

```yaml
name: Pipeline CI/CD

on:
  push:
    branches:
      - main
permissions:
  contents: read
  id-token: write

jobs:
  build-ecr:
    runs-on: ubuntu-latest
    outputs:
      registry: ${{ steps.login-ecr.outputs.registry }}
      image_tag: ${{ steps.build.outputs.image_tag }}
      image_uri: ${{ steps.build.outputs.image_uri }}
    steps:
      - uses: actions/checkout@v5.0.0

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4.3.1
        with:
          role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/gitHubActionsECR
          aws-region: us-east-2

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build, tag, and push docker image to Amazon ECR
        id: build
        env:
          REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          REPOSITORY: site_prod
          ENVIRONMENT: ${{ github.ref_name == 'main' && 'prod' || 'dev' }}
        run: |
          COMMIT_SHA=$(echo $GITHUB_SHA | cut -c1-7)
          IMAGE_TAG=${ENVIRONMENT}-${COMMIT_SHA}
          docker build -t $REGISTRY/$REPOSITORY:$IMAGE_TAG .
          docker push $REGISTRY/$REPOSITORY:$IMAGE_TAG
          echo "image_tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
          echo "image_uri=$REGISTRY/$REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

  deploy-ssh:
    runs-on: ubuntu-latest
    needs: build-ecr
    steps:
      - name: Deploy to EC2 via SSH
        env:
          IMAGE_TAG: ${{ needs.build-ecr.outputs.image_tag }}
          IMAGE_URI: ${{ needs.build-ecr.outputs.image_uri }}
          REGISTRY: ${{ needs.build-ecr.outputs.registry }}
          INSTANCE_KEY: ${{ secrets.INSTANCE_KEY }}
          ELASTIC_IP: ${{ secrets.ELASTIC_IP }}
        run: |
          echo $IMAGE_URI
          echo "$INSTANCE_KEY" > key.pem
          chmod 400 key.pem
          ssh -i key.pem -o StrictHostKeyChecking=no ec2-user@$ELASTIC_IP << EOF
            aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $REGISTRY
            echo "baixando imagem $IMAGE_TAG"
            docker pull $IMAGE_URI
            echo "parando container antigo e iniciando novo"
            docker stop site || true
            docker rm site || true
            echo "iniciando container novo com a imagem $IMAGE_TAG"
            docker run -d -p 80:80 --name site $IMAGE_URI
            docker ps
            echo "deploy finalizado"
          EOF
          rm key.pem
```

### Explicação das Etapas

1. **Trigger e Permissões**: Acionado em pushes para `main`, com permissões mínimas para leitura de conteúdo e geração de ID tokens OIDC.

2. **Job build-ecr**:
   - **Checkout**: Baixa o código.
   - **Configure AWS Credentials**: Assume role IAM via OIDC.
   - **Login to ECR**: Gera credenciais temporárias e expõe `registry` como output.
   - **Build, Tag e Push**: Define ambiente dinamicamente (`prod` para `main`, `dev` otherwise), gera tag única com SHA do commit para versionamento imutável, constrói e pusha a imagem. Outputs (`image_tag`, `image_uri`) são passados para o próximo job, promovendo decoupling.

3. **Job deploy-ssh** (dependente de build-ecr):
   - Usa outputs do job anterior para imagem dinâmica.
   - Cria chave SSH temporária com permissões seguras.
   - Via SSH na EC2: Loga no ECR, puxa a imagem específica, para/remove container antigo, inicia novo mapeando porta 80, verifica com `docker ps`.
   - Remove chave para evitar exposição.

Essa estrutura melhora reliability com tags imutáveis (facilitando rollbacks) e scalability para multi-ambientes, alinhando com SRE principles como SLOs para deploy time (monitore via Prometheus).

### Melhorias em Relação à Versão Original

- **Tagging Dinâmico**: Usa commit SHA para tags únicas, evitando sobrescrita e permitindo traceability (ex.: rollback para tag específica via `docker pull`).
- **Ambientes Customizáveis**: Lógica condicional para `prod/dev`, expansível para mais branches com GitOps tools como ArgoCD.
- **Outputs entre Jobs**: Melhora modularidade, facilitando adição de jobs (ex.: testes com SonarQube antes de deploy).
- **Flexibilidade**: Fácil integração com IaC (ex.: Terraform para criar ECR/EC2) ou monitoramento (ex.: Datadog para alertas em falhas).

Para testes locais, build com `docker build -t <registry>/<repo>:prod-<sha> .` e simule deploy manual. Para otimizações, integre Snyk para scans de vulnerabilidades no build (doc: [Snyk GitHub Actions](https://docs.snyk.io/integrations/ci-cd-integrations/github-actions-integration)).