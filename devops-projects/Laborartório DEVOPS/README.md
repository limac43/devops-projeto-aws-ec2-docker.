# 🚀 Laboratório DevOps: Aprenda DevOps na Prática com Projetos Progressivos

Olá! Eu sou Maria Lazara, DevOps Engineer, e vou te guiar nessa jornada DevOps. Sei que conceitos como containerização, IaC e CI/CD podem parecer intimidadores no início. Por isso, adoto uma didática simples e prática: vamos construir o conhecimento **de trás pra frente**. Isso significa começar pelo problema real – algo que você pode vivenciar e sentir a dor – e só depois buscar a solução, experimentando ferramentas como Docker, Terraform e GitHub Actions. No final, conectamos à teoria para solidificar o aprendizado.

Meu foco é ensinar você a resolver problemas comuns que DevOps Engineers enfrentam diariamente, como "funciona na minha máquina, mas não no servidor" ou "deploys manuais causam downtime". Cada projeto aqui é uma peça de um quebra-cabeça: eles se conectam, aumentando a dificuldade gradualmente, simulando uma evolução real de um setup básico para um pipeline DevOps profissional.

Este repositório contém 3 pastas, cada uma com um projeto independente, mas interligado:
- **projeto-devops-fase-1**: O básico – containerize e deploy manual de um site estático na AWS.
- **projeto-devops-fase-2**: Adicione automação de infraestrutura com Terraform (IaC).
- **projeto-devops-fase-3**: Full automation com CI/CD usando GitHub Actions + Terraform + Docker.

Cada pasta tem seu próprio `README.md` com passos detalhados, incluindo desafios para você simular problemas reais. Baixe o repo, siga os passos e experimente!

*[Espaço para print: Estrutura do repositório no GitHub, mostrando as 3 pastas]*

## 📋 Pré-requisitos Técnicos

**⚠️ IMPORTANTE**: Este laboratório é para pessoas com conhecimento básico-intermediário em desenvolvimento e infraestrutura. Não é um curso de fundamentos.

### Conhecimentos Obrigatórios:

**🐧 Linux/Unix Básico**
- Navegação no terminal (ls, cd, mkdir, cp, mv, rm)
- Edição de arquivos (nano, vim ou VS Code)
- Permissões básicas (chmod, sudo)
- SSH e conexões remotas

**☁️ AWS Básico**
- Conceitos de EC2, IAM, VPC, Security Groups
- Como criar instâncias e configurar acesso
- AWS CLI configurado e funcional
- Entender Free Tier e custos básicos

**🐳 Docker Básico-Intermediário**
- Diferença entre imagem e container
- Comandos essenciais (build, run, push, pull)
- Como escrever Dockerfile básico
- Conceito de registries (Docker Hub, ECR)

**🏗️ Terraform Básico**
- Conceitos de Infrastructure as Code (IaC)
- Comandos básicos (init, plan, apply, destroy)
- Entender HCL (HashiCorp Configuration Language)
- Conceito de state file

**🔧 Git/GitHub**
- Comandos básicos (clone, add, commit, push, pull)
- Criação de repositórios
- Conceitos de branches

### Auto-avaliação Rápida:
✅ Consigo criar uma instância EC2 e conectar via SSH?
✅ Sei fazer build de uma imagem Docker e executar?
✅ Já usei terraform apply para criar recursos?
✅ Domino comandos básicos do terminal Linux?

**Se marcou menos de 4 ✅**: Estude os fundamentos primeiro antes de continuar.

---

## ❓ Por Que Essa Abordagem "De Trás Pra Frente"?
Em vez de começar com teoria seca ("o que é Docker?"), vamos imitar a vida real: Você enfrenta um problema concreto, sente a frustração, e então descobre a ferramenta que resolve. Isso torna o aprendizado memorável e prático. Por exemplo:
- Primeiro, vivencie o caos de um deploy manual.
- Depois, busque soluções como "como automatizar isso?".
- Finalmente, entenda a teoria por trás (ex.: "containers isolam dependências").

Isso é baseado em estudos de problemas: Cada projeto começa com uma situação real, como uma startup crescendo e enfrentando gargalos, inspirada em casos que vi em equipes reais.

## 🎯 Visão Geral dos Projetos
Vamos construir um website estático simples (HTML/CSS/JS) e deployá-lo na AWS. Mas o foco não é o site – é o processo DevOps ao redor dele. Cada fase resolve problemas da anterior, adicionando camadas de automação.

### Projeto 1: Containerização com Docker e Deploy Manual na AWS (Nível Básico)
- **Problema Real**: Imagine você em uma pequena equipe: O dev altera o código, mas no servidor AWS, "não funciona" por causa de dependências diferentes. Deploys envolvem SSH manual, levando a erros e tempo perdido.
- **Solução Prática**: Use Docker para "empacotar" o site em um container portátil. Crie um ECR na AWS, push a imagem e deploy manual na EC2.
- **Ferramentas Aprendidas**: Docker, AWS CLI, ECR, EC2, Security Groups.
- **Conexão**: Isso resolve o "funciona na minha máquina", mas ainda é manual – preparando o terreno para automação na Fase 2.
- **Tempo Estimado**: 2-3 horas.
- **Desafio Inicial**: Tente deployar manualmente sem Docker e veja os erros de dependências.

*[Espaço para print: Diagrama simples da arquitetura do Projeto 1, mostrando código local → Docker → ECR → EC2 → Browser]*

### Projeto 2: Automatização de Infraestrutura com Terraform (IaC) (Nível Intermediário)
- **Problema Real**: Agora a startup cresce: Você precisa recriar ambientes (dev/staging/prod) rapidamente, mas cliques manuais no console AWS causam inconsistências, erros e "drift" (mudanças não rastreadas). Um deploy de emergência falha porque uma configuração foi esquecida.
- **Solução Prática**: Trate a infra como código com Terraform. Declare recursos como EC2, ECR e IAM Roles em arquivos HCL, e o Terraform provisiona tudo automaticamente.
- **Ferramentas Aprendidas**: Terraform (init/plan/apply/destroy), backends remotos (S3 para state), outputs para integração.
- **Conexão**: Integra com o Docker do Projeto 1 – agora a infra é reproduzível, mas o deploy ainda requer SSH manual. Isso motiva a full automation na Fase 3.
- **Tempo Estimado**: 2-4 horas.
- **Desafio Inicial**: Tente recriar manualmente o ambiente do Projeto 1 em uma nova região e note os pontos de dor.

*[Espaço para print: Diagrama da arquitetura do Projeto 2, mostrando arquivos Terraform → AWS Infra (EC2/ECR) → Deploy Docker]*

### Projeto 3: Automatização Completa com CI/CD (GitHub Actions + Terraform + Docker) (Nível Avançado)
- **Problema Real**: Com múltiplos devs, changes diárias viram caos: Deploys manuais criam gargalos, erros humanos e falta de auditabilidade. Um pico de tráfego exige update rápido, mas conflitos no Terraform state causam downtime.
- **Solução Prática**: Separe repos (app e infra), use GitHub Actions para pipelines CI/CD. Push no código dispara builds Docker, plans Terraform e deploys com aprovações manuais para segurança.
- **Ferramentas Aprendidas**: GitHub Actions (workflows YAML, secrets, aprovações), integração multi-repo.
- **Conexão**: Une tudo: Docker do Projeto 1 + Terraform do Projeto 2 em um fluxo automatizado. Agora, é um pipeline DevOps real, escalável para equipes.
- **Tempo Estimado**: 3-5 horas.
- **Desafio Inicial**: Simule deploys simultâneos manuais no setup do Projeto 2 e veja conflitos.

*[Espaço para print: Diagrama completo da arquitetura do Projeto 3, mostrando Repos GitHub → Actions CI/CD → AWS Infra + Deploy]*

## 🔧 Como Começar
1. **Clone o Repositório**:
   ```bash
   git clone https://github.com/marialazara/devops-projects.git
   cd seu-repo-devops
   ```
2. **Escolha uma Fase**: Comece pela pasta `projeto-devops-fase-1` e avance. Cada README tem pré-requisitos, passos e troubleshooting.
3. **Ambiente**: Certifique-se de ter uma conta AWS gratuita (cuidado com custos – use Free Tier). Instale ferramentas como Docker, Terraform e AWS CLI conforme descrito.
4. **Dicas Gerais**:
   - Use VS Code para editar arquivos.
   - Sempre teste localmente antes de apply/destroy.
   - Limpe recursos AWS no final para evitar custos!
5. **Personalize**: Substitua placeholders (ex.: regiões AWS, nomes de repos) com os seus.

## 🎓 Conceitos Aprendidos no Geral
Ao final, você dominará ferramentas chave de um DevOps Engineer:
- **Containerização** (Docker): Resolve inconsistências de ambiente.
- **IaC** (Terraform): Automatiza e versiona infra.
- **CI/CD** (GitHub Actions): Orquestra fluxos para deploys rápidos e seguros.
- **Melhores Práticas**: Secrets management, aprovações, state locking, drift detection.

Esses projetos simulam uma progressão real: De manual para IaC para automatizado, resolvendo problemas como escalabilidade, colaboração e erros humanos.

## 📚 Recursos Adicionais
- [Documentação Docker](https://docs.docker.com/)
- [Terraform Learning](https://learn.hashicorp.com/terraform)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- Livros: "The DevOps Handbook" para teoria aplicada.
- Comunidades: Reddit r/devops, Stack Overflow.

## 🧹 Notas Finais
Lembre-se: DevOps é sobre cultura tanto quanto ferramentas – automatize para liberar tempo para inovação. Se travar, pesquise o erro (ex.: "Terraform AMI not found") – isso treina skills reais!

Desenvolvido com ❤️ por Maria Lazara. Assista ao meu vídeo explicativo no YouTube, onde falo desses projetos e do mundo DevOps: [Link para o Vídeo](https://www.youtube.com/@marialazaradev). Compartilhe seu progresso nos comentários! 🚀
