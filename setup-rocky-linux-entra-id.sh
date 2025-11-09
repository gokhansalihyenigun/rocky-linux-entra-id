#!/bin/bash
# Rocky Linux 9 VM with Entra ID Login Setup
# Güncel komutlar - Kasım 2025

echo -e "\e[32mRocky Linux 9 VM with Entra ID Login kurulumu başlatılıyor...\e[0m"

# 1. Resource group oluştur
echo -e "\e[33m\n1. Resource group oluşturuluyor...\e[0m"
az group create --name AzureADLinuxVM --location southcentralus

# 2. Rocky Linux 9 görüntülerini listele (güncel URN'ları görmek için)
echo -e "\e[33m\n2. Mevcut Rocky Linux 9 görüntüleri kontrol ediliyor...\e[0m"
az vm image list --location southcentralus --publisher resf --offer rockylinux-x86_64 --sku 9-base --all -o table

# 3. Marketplace terms kabul et (gerekirse)
echo -e "\e[33m\n3. Marketplace şartları kabul ediliyor...\e[0m"
az vm image terms accept --urn resf:rockylinux-x86_64:9-base:latest

# 4. VM oluştur
echo -e "\e[33m\n4. Rocky Linux 9 VM oluşturuluyor...\e[0m"
az vm create \
    --resource-group AzureADLinuxVM \
    --name myRockyLinuxVM \
    --image resf:rockylinux-x86_64:9-base:latest \
    --assign-identity \
    --admin-username azureuser \
    --generate-ssh-keys \
    --size Standard_B2s \
    --authentication-type ssh \
    --storage-sku Premium_LRS

# 5. Entra ID login extension'ını kur
echo -e "\e[33m\n5. Microsoft Entra ID SSH Login extension kuruluyor...\e[0m"
az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory \
    --name AADSSHLoginForLinux \
    --resource-group AzureADLinuxVM \
    --vm-name myRockyLinuxVM

# 6. RBAC rol ataması yap
echo -e "\e[33m\n6. RBAC rol ataması yapılıyor...\e[0m"
username=$(az account show --query user.name -o tsv)
vmid=$(az vm show -g AzureADLinuxVM -n myRockyLinuxVM --query id -o tsv)

# Virtual Machine Administrator Login rolü ata
az role assignment create --role "Virtual Machine Administrator Login" --assignee "$username" --scope "$vmid"

# Alternatif olarak Virtual Machine User Login rolü (daha kısıtlı)
# az role assignment create --role "Virtual Machine User Login" --assignee "$username" --scope "$vmid"

echo -e "\e[32m\nKurulum tamamlandı!\e[0m"
echo -e "\e[36mVM'e bağlanmak için şu komutu kullanın:\e[0m"
echo -e "\e[37maz ssh vm -n myRockyLinuxVM -g AzureADLinuxVM\e[0m"

echo -e "\e[33m\nEğer bağlantı sorunu yaşarsanız:\e[0m"
echo -e "\e[37m1. az login komutu ile oturum açtığınızdan emin olun\e[0m"
echo -e "\e[37m2. VM'in tamamen başlatıldığını kontrol edin\e[0m"
echo -e "\e[37m3. Extension'ın kurulum durumunu kontrol edin:\e[0m"
echo -e "\e[90m   az vm extension show --resource-group AzureADLinuxVM --vm-name myRockyLinuxVM --name AADSSHLoginForLinux\e[0m"