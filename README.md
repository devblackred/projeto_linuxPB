# Projeto Linux - PB DevSecOps - JUN 2024

Este repositório contém os artefatos desenvolvidos durante a Sprint 4 do Programa de Bolsas DevSecOps - JUN 2024. O projeto tem como objetivo a criação de um ambiente Linux na AWS, utilizando os serviços EC2, EFS e automação com scripts.

## Arquitetura da Solução

A solução proposta consiste em uma instância EC2, com um sistema de arquivos EFS anexado, hospedando um servidor web Apache. Um script automatizado verifica periodicamente o status do servidor, registrando as informações em arquivos de log.

## Passo a Passo na AWS

### Etapa 1: Gerando Chaves de Acesso

1. **Acesse o serviço EC2:** No console da AWS, navegue até `Serviços` > `Computação` > `EC2`.
2. **Gerencie Pares de Chaves:** Na barra lateral, clique em `Rede e Segurança` > `Pares de chaves`.
3. **Crie um Novo Par de Chaves:**
   - Clique em **`Criar par de chaves`**.
   - **Nome:** `projeto-linux`
   - **Tipo:** `RSA`
   - **Formato:** `.pem`
   - **Adicione as seguintes tags:**
     - **Name:** `PB - JUN 2024`
     - **CostCenter:** `C092000024`
     - **Project:** `PB - JUN 2024`

### Etapa 2: Criando a Instância EC2

1. **Inicie uma Nova Instância:** No serviço EC2, clique em `Instâncias` > `Executar instâncias`.
2. **Configure a Instância:**
   - **Tags:**
     - **Name:** `PB - JUN 2024`
     - **CostCenter:** `C092000024`
     - **Project:** `PB - JUN 2024`
     - **Tipos de recursos:** `Instâncias e Volumes`
   - **Imagem:** `Amazon Linux 2`
   - **Tipo:** `t3.small`
   - **Par de chaves:** `projeto-linux`
   - **Rede:**
     - **VPC:** Selecione uma VPC com acesso à Internet.
     - **Sub-rede:** Escolha uma sub-rede com acesso à Internet.
     - **IP Público:** `Desabilitar`
     - **Firewall:** `Criar grupo de segurança`
       - **Nome:** `projeto-linux`
       - **Descrição:** `Acesso público: (22/TCP, 111/TCP e UDP, 2049/TCP/UDP, 80/TCP, 443/TCP)`
   - **Armazenamento:**
     - **Tamanho:** `16GB`
     - **Tipo:** `gp2`

### Etapa 3: Alocando um IP Elástico

1. **Acesse IPs Elásticos:** No serviço EC2, navegue até `Rede e Segurança` > `IPs elásticos`.
2. **Aloque um Endereço IP:** Clique em **`Alocar endereço IP elástico`**.
   - **Conjunto de endereços:** `Conjunto de endereços IPv4 da Amazon`
   - **Grupo de borda de rede:** `us-east-1`
   - **Tags:**
     - **Name:** `PB - JUN 2024`
     - **CostCenter:** `C092000024`
     - **Project:** `PB - JUN 2024`
3. **Associe o IP à Instância:**
   - Selecione o IP elástico alocado.
   - Clique em `Ações` > **`Associar endereço IP elástico`**.
   - **Tipo de recurso:** `Instância`
   - **Instância:** Selecione a instância criada.
   - **Endereço IP privado:** Escolha o IP privado da instância.

### Etapa 4: Configurando o Grupo de Segurança

1. **Acesse Grupos de Segurança:** No serviço EC2, vá para `Rede e Segurança` > `Security groups`.
2. **Edite as Regras de Entrada:**
   - Selecione o grupo `projeto-linux`.
   - Clique em `Ações` > **`Editar regras de entrada`**.
   - Adicione as seguintes regras:

     | Porta | Protocolo | Origem     | Descrição              |
     |-------|-----------|------------|-----------------------|
     | 22    | TCP       | 0.0.0.0/0 | SSH/22 - Acesso Público |
     | 111   | TCP       | 0.0.0.0/0 | TCP/111 - Acesso Público |
     | 111   | UDP       | 0.0.0.0/0 | UDP/111 - Acesso Público |
     | 2049  | TCP       | 0.0.0.0/0 | TCP/2049 - Acesso Público |
     | 2049  | UDP       | 0.0.0.0/0 | UDP/2049 - Acesso Público |
     | 80    | TCP       | 0.0.0.0/0 | TCP/80 - Acesso Público  |
     | 443   | TCP       | 0.0.0.0/0 | TCP/443 - Acesso Público |

### Etapa 5: Criando o Sistema de Arquivos EFS

1. **Acesse o serviço EFS:** No console da AWS, vá para `Serviços` > `Armazenamento` > `EFS`.
2. **Crie um Sistema de Arquivos:**
   - **Nome:** `projeto-linux`
   - **VPC:** Selecione a mesma VPC da instância EC2.
3. **Configure a Rede do EFS:**
   - Selecione o EFS criado.
   - Clique em **`Visualizar detalhes`**.
   - Navegue até a seção `Rede` > **`Gerenciar`**.
   - Defina o **"Grupo de segurança"** como `projeto-linux`.
4. **Obtenha as Instruções de Montagem:**
   - Selecione o EFS.
   - Clique em `Anexar` > **`Montar via IP`**.
   - Anote o código fornecido (será usado na instância EC2).

## Passo a Passo no Linux

### Etapa 6: Conectando-se à Instância

1. **Acesse a Instância EC2:** No serviço EC2, selecione a instância e clique em **`Conectar`**.
2. **Utilize o EC2 Instance Connect** (recomendado) ou SSH.

### Etapa 7: Configurando o Ambiente Linux

1. **Atualize o Sistema:**
   ```bash
   sudo yum update && sudo yum upgrade -y
   ```
2. **Instale o NFS:**
   ```bash
   sudo yum install nfs-utils -y
   ```
3. **Crie o Diretório de Montagem:**
   ```bash
   sudo mkdir /efs
   ```
4. **Monte o EFS:**
   - Utilize o código obtido na **Etapa 5** (substitua os valores entre colchetes):
     ```bash
     sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport [IP do NFS]:/ [Diretório de montagem]
     ```
5. **Verifique a Montagem:**
   ```bash
   df -h
   ```
6. **Crie um Diretório no EFS:**
   ```bash
   sudo mkdir /efs/seu_nome
   ```
7. **Instale o Apache:**
   ```bash
   sudo yum install httpd -y
   ```
8. **Inicie o Apache:**
   ```bash
   sudo systemctl start httpd
   ```

### Etapa 8: Criando o Script de Validação

1. **Crie o Arquivo do Script:**
   ```bash
   sudo nano check_apache.sh
   ```
2. **Insira o Código do Script:**
   ```bash
   #!/bin/bash
   STATUS=$(systemctl is-active httpd)
   TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
   if [ "$STATUS" = "active" ]; then
       echo "$TIMESTAMP Apache ONLINE - Tudo Certo" >> /home/ec2-user/efs/seu_nome/apache_online.log
   else
       echo "$TIMESTAMP Apache OFFLINE - Servico indisponivel" >> /home/ec2-user/efs/seu_nome/apache_offline.log
   fi
   ```
3. **Defina as Permissões do Script:**
   ```bash
   sudo chmod 755 check_apache.sh
   ```

### Etapa 9: Automatizando a Execução do Script

1. **Edite o Crontab:**
   ```bash
   sudo crontab -e
   ```
2. **Adicione a Tarefa Cron:**
   ```
   */5 * * * * /home/ec2-user/check_apache.sh
   ```
   - Esta configuração executará o script a cada 5 minutos.

## Considerações Finais

Este guia detalhado orienta a criação de um ambiente Linux na AWS, desde a geração de chaves até a automação de tarefas. O projeto demonstra a utilização dos serviços EC2 e EFS, além de boas práticas de segurança e monitoramento. 
