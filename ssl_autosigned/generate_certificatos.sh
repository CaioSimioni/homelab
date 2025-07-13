#!/bin/bash

# Diretório base para armazenar os certificados
BASE_DIR="$(dirname "$0")/certificates"

# Função para gerar certificados SSL autoassinados
gerar_certificado() {
  local DOMAIN=$1
  local CERT_DIR="$BASE_DIR/$DOMAIN"

  # Criar diretório para o domínio
  mkdir -p "$CERT_DIR"

  # Gerar chave privada
  openssl genrsa -out "$CERT_DIR/$DOMAIN.key" 2048

  # Gerar certificado autoassinado
  openssl req -new -x509 -key "$CERT_DIR/$DOMAIN.key" -out "$CERT_DIR/$DOMAIN.crt" -days 365 \
    -subj "/C=BR/ST=Estado/L=Cidade/O=Organizacao/OU=Unidade/CN=$DOMAIN"

  echo "Certificados gerados para o domínio: $DOMAIN"
  echo "Local: $CERT_DIR"
}

# Exportar o certificado para instalação em outras máquinas
exportar_certificado() {
  local DOMAIN=$1
  local CERT_DIR="$BASE_DIR/$DOMAIN"
  local EXPORT_DIR="$BASE_DIR/exported"

  # Criar diretório de exportação
  mkdir -p "$EXPORT_DIR"

  # Copiar o certificado para o diretório de exportação
  cp "$CERT_DIR/$DOMAIN.crt" "$EXPORT_DIR/$DOMAIN.crt"

  echo "Certificado exportado para: $EXPORT_DIR/$DOMAIN.crt"
}

# Verificar se o domínio foi fornecido
if [ -z "$1" ]; then
  echo "Uso: $0 <dominio>"
  exit 1
fi

# Gerar certificado para o domínio fornecido
gerar_certificado "$1"

# Exportar o certificado após gerá-lo
exportar_certificado "$1"
