#!/bin/bash

# Variables
RESOURCE_GROUP="rg-rag"
LOCATION="eastus2"
#Unique names
OPENAI_NAME="openai-rag-jaayg-notes"
SEARCH_NAME="search-rag-jaayg-notes-$RANDOM"
DEPLOYMENT_NAME="gpt-4o"
MODEL_NAME="gpt-4o"
MODEL_VERSION="2024-11-20"
SKU="S0"
#
# 1. Crear grupo de recursos
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Crear recurso de Azure OpenAI
az cognitiveservices account create --name $OPENAI_NAME  --resource-group $RESOURCE_GROUP --kind OpenAI --sku $SKU --location $LOCATION --yes --custom-domain $OPENAI_NAME

# 3. Desplegar modelo GPT-4
az cognitiveservices account deployment create --name $OPENAI_NAME --resource-group $RESOURCE_GROUP --deployment-name $DEPLOYMENT_NAME --model-name $MODEL_NAME --model-version $MODEL_VERSION --model-format OpenAI --sku-name "Standard" --sku-capacity 1

echo "------------------------------------------"
echo "--- INICIANDO CREACIÓN DE STORAGE ACCOUNT ---"
echo "------------------------------------------"

# 3.1 Crear cuenta de almacenamiento con acceso publico
STORAGE_NAME="storagerag$RANDOM"
az storage account create --name $STORAGE_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS --kind StorageV2 --public-network-access Enabled --allow-blob-public-access true

echo "------------------------------------------"
echo "--- FINALIZADA CREACIÓN DE STORAGE ACCOUNT ---"
echo "------------------------------------------"

# 4. Crear Azure AI Search
az search service create --name $SEARCH_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku basic --partition-count 1 --replica-count 1

# 5. Obtener claves y endpoints
echo "Azure OpenAI Key:"
az cognitiveservices account keys list --name $OPENAI_NAME --resource-group $RESOURCE_GROUP

echo "Azure AI Search Key:"
az search admin-key show --service-name $SEARCH_NAME --resource-group $RESOURCE_GROUP

echo "Entorno RAG listo para usar!"