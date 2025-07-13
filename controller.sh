#!/bin/bash

# Função para exibir texto com cores
color_text() {
  case $1 in
    red)
      echo -e "\033[31m$2\033[0m"
      ;;
    green)
      echo -e "\033[32m$2\033[0m"
      ;;
    yellow)
      echo -e "\033[33m$2\033[0m"
      ;;
    blue)
      echo -e "\033[34m$2\033[0m"
      ;;
    *)
      echo "$2"
      ;;
  esac
}

# Função para verificar dependências
verificar_dependencias() {
  if ! command -v docker &> /dev/null; then
    color_text red "Docker não está instalado. Por favor, instale o Docker antes de continuar."
    exit 1
  fi

  if ! command -v docker compose &> /dev/null; then
    color_text red "Docker Compose não está instalado. Por favor, instale o Docker Compose antes de continuar."
    exit 1
  fi
}

# Função para verificar e criar .env se necessário
verificar_env() {
  local service_path="$1"
  if [ ! -f "$service_path/.env" ]; then
    color_text yellow "O arquivo .env não foi encontrado em $service_path."
    if [ -f "$service_path/.env.example" ]; then
      read -p "Deseja criar uma cópia do .env.example como .env? (s/n): " resposta
      resposta=$(sanitize_input "$resposta")
      if [[ "$resposta" =~ ^[sS]$ ]]; then
        cp "$service_path/.env.example" "$service_path/.env"
        color_text green "Arquivo .env criado com sucesso."
      else
        color_text red "O serviço não pode ser iniciado sem o arquivo .env."
        return 1
      fi
    else
      color_text red "Nenhum arquivo .env.example encontrado. O serviço não pode ser iniciado."
      return 1
    fi
  fi
  return 0
}

comando_docker() {
  while true; do
    color_text blue "Comandos Docker"
    echo "Escolha uma opção:"
    echo -e "  1) Listar containers"
    echo -e "  2) Listar images"
    echo -e "  3) Listar volumes"
    echo -e "  4) Limpar containers"
    echo -e "  5) Limpar images"
    echo -e "  6) Limpar volumes"
    echo -e "  7) Limpar tudo"
    echo -e "  0) Voltar ao menu principal"
    read -p "  > " opcao
    opcao=$(sanitize_input "$opcao")
    case $opcao in
      1)
        echo "Listando containers..."
        docker ps -a
        echo ""
        ;;
      2)
        echo "Listando images..."
        docker images
        echo ""
        ;;
      3)
        echo "Listando volumes..."
        docker volume ls
        echo ""
        ;;
      4)
        echo "Limpando containers..."
        docker container prune -f
        echo ""
        ;;
      5)
        echo "Limpando images..."
        docker image prune -a -f
        echo ""
        ;;
      6)
        echo "Limpando volumes..."
        docker volume prune -f
        echo ""
        ;;
      7)
        echo "Limpando tudo..."
        docker system prune -a --volumes -f
        echo ""
        ;;
      0)
        color_text green "Voltando ao menu principal..."
        return
        ;;
      *)
        color_text red "Opção inválida. Tente novamente."
        sleep 2
        ;;
    esac
  done
}

# Função para gerenciar o Pi-hole
gerenciar_pihole() {
  if ! verificar_env "services/dns"; then
    return
  fi
  while true; do
    color_text blue "Gerenciamento do Pi-hole"
    echo "Escolha uma opção:"
    echo -e "  1) Subir o container"
    echo -e "  2) Derrubar o container"
    echo -e "  3) Reiniciar o container"
    echo -e "  0) Voltar ao menu principal"
    read -p "  > " opcao
    opcao=$(sanitize_input "$opcao")

    case $opcao in
      1)
        echo "Subindo o container do Pi-hole..."
        (cd services/dns && docker compose --env-file .env -f pihole.yml -p dns up -d)
        echo ""
        ;;
      2)
        echo "Derrubando o container do Pi-hole..."
        (cd services/dns && docker compose --env-file .env -f pihole.yml -p dns down)
        echo ""
        ;;
      3)
        echo "Reiniciando o container do Pi-hole..."
        (cd services/dns && docker compose --env-file .env -f pihole.yml -p dns restart)
        echo ""
        ;;
      0)
        color_text green "Voltando ao menu principal..."
        return
        ;;
      *)
        color_text red "Opção inválida. Tente novamente."
        sleep 2
        ;;
    esac
  done
}

# Função para gerenciar o Portainer
gerenciar_portainer() {
  if ! verificar_env "services/portainer"; then
    return
  fi
  while true; do
    color_text blue "Gerenciamento do Portainer"
    echo "Escolha uma opção:"
    echo -e "  1) Subir o container"
    echo -e "  2) Derrubar o container"
    echo -e "  3) Reiniciar o container"
    echo -e "  0) Voltar ao menu principal"
    read -p "  > " opcao
    opcao=$(sanitize_input "$opcao")

    case $opcao in
      1)
        echo "Subindo o container do Portainer..."
        (cd services/portainer && docker compose --env-file .env -f portainer.yml -p portainer up -d)
        echo ""
        ;;
      2)
        echo "Derrubando o container do Portainer..."
        (cd services/portainer && docker compose --env-file .env -f portainer.yml -p portainer down)
        echo ""
        ;;
      3)
        echo "Reiniciando o container do Portainer..."
        (cd services/portainer && docker compose --env-file .env -f portainer.yml -p portainer restart)
        echo ""
        ;;
      0)
        color_text green "Voltando ao menu principal..."
        return
        ;;
      *)
        color_text red "Opção inválida. Tente novamente."
        sleep 2
        ;;
    esac
  done
}

# Função para gerenciar o Nginx Proxy Manager
gerenciar_nginx_proxy_manager() {
  if ! verificar_env "services/proxy-manager"; then
    return
  fi
  while true; do
    color_text blue "Gerenciamento do Nginx Proxy Manager"
    echo "Escolha uma opção:"
    echo -e "  1) Subir o container"
    echo -e "  2) Derrubar o container"
    echo -e "  3) Reiniciar o container"
    echo -e "  0) Voltar ao menu principal"
    read -p "  > " opcao
    opcao=$(sanitize_input "$opcao")

    case $opcao in
      1)
        echo "Subindo o container do Nginx Proxy Manager..."
        (cd services/proxy-manager && docker compose --env-file .env -f nginx-proxy-manager.yml -p proxy-manager up -d)
        echo ""
        ;;
      2)
        echo "Derrubando o container do Nginx Proxy Manager..."
        (cd services/proxy-manager && docker compose --env-file .env -f nginx-proxy-manager.yml -p proxy-manager down)
        echo ""
        ;;
      3)
        echo "Reiniciando o container do Nginx Proxy Manager..."
        (cd services/proxy-manager && docker compose --env-file .env -f nginx-proxy-manager.yml -p proxy-manager restart)
        echo ""
        ;;
      0)
        color_text green "Voltando ao menu principal..."
        return
        ;;
      *)
        color_text red "Opção inválida. Tente novamente."
        sleep 2
        ;;
    esac
  done
}

# Função para sanitizar entrada do usuário
sanitize_input() {
  echo "$1" | sed 's/[^a-zA-Z0-9_-]//g'
}

# Adiciona um trap para capturar interrupções do script
trap "color_text red '\nScript interrompido pelo usuário.'; exit 1" SIGINT SIGTERM

# Função principal
# Sempre que um novo service é adicionado, a opção "Comandos Docker" deve descer um número
main() {
  while true; do
    color_text blue "Controle de Stacks Docker"
    echo "Escolha uma stack para gerenciar:"
    echo -e "  1) Pi-hole"
    echo -e "  2) Portainer"
    echo -e "  3) Nginx Proxy Manager"
    echo -e "  4) Comandos Docker"
    echo -e "  0) Sair"
    read -p "  > " stack_opcao
    stack_opcao=$(sanitize_input "$stack_opcao")

    case $stack_opcao in
      1)
        gerenciar_pihole
        ;;
      2)
        gerenciar_portainer
        ;;
      3)
        gerenciar_nginx_proxy_manager
        ;;
      4)
        comando_docker
        ;;
      0)
        color_text green "Saindo..."
        echo ""
        exit 0
        ;;
      *)
        color_text red "Opção inválida. Tente novamente."
        sleep 2
        ;;
    esac
  done
}

# Chama a verificação de dependências no início do script
verificar_dependencias

# Chama a função principal
main