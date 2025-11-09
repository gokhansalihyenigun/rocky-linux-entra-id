# Rocky Linux 9 VM with Entra ID Login Setup
# Güncel komutlar - Kasım 2025

Write-Host "Rocky Linux 9 VM with Entra ID Login kurulumu başlatılıyor..." -ForegroundColor Green

# 1. Resource group oluştur
Write-Host "`n1. Resource group oluşturuluyor..." -ForegroundColor Yellow
az group create --name AzureADLinuxVM --location southcentralus

# 2. Rocky Linux 9 görüntülerini listele (güncel URN'ları görmek için)
Write-Host "`n2. Mevcut Rocky Linux 9 görüntüleri kontrol ediliyor..." -ForegroundColor Yellow
az vm image list --location southcentralus --publisher resf --offer rockylinux-x86_64 --sku 9-base --all -o table

# 3. Marketplace terms kabul et (gerekirse)
Write-Host "`n3. Marketplace şartları kabul ediliyor..." -ForegroundColor Yellow
az vm image terms accept --urn resf:rockylinux-x86_64:9-base:latest

# 4. VM oluştur
Write-Host "`n4. Rocky Linux 9 VM oluşturuluyor..." -ForegroundColor Yellow
az vm create `
    --resource-group AzureADLinuxVM `
    --name myRockyLinuxVM `
    --image resf:rockylinux-x86_64:9-base:latest `
    --assign-identity `
    --admin-username azureuser `
    --generate-ssh-keys `
    --size Standard_B2s `
    --authentication-type ssh `
    --storage-sku Premium_LRS

# 5. Entra ID login extension'ını kur
Write-Host "`n5. Microsoft Entra ID SSH Login extension kuruluyor..." -ForegroundColor Yellow
az vm extension set `
    --publisher Microsoft.Azure.ActiveDirectory `
    --name AADSSHLoginForLinux `
    --resource-group AzureADLinuxVM `
    --vm-name myRockyLinuxVM

# 6. RBAC rol ataması yap
Write-Host "`n6. RBAC rol ataması yapılıyor..." -ForegroundColor Yellow
$username = az account show --query user.name -o tsv
$vmid = az vm show -g AzureADLinuxVM -n myRockyLinuxVM --query id -o tsv

# Virtual Machine Administrator Login rolü ata
az role assignment create --role "Virtual Machine Administrator Login" --assignee "$username" --scope "$vmid"

# Alternatif olarak Virtual Machine User Login rolü (daha kısıtlı)
# az role assignment create --role "Virtual Machine User Login" --assignee "$username" --scope "$vmid"

Write-Host "`nKurulum tamamlandı!" -ForegroundColor Green
Write-Host "VM'e bağlanmak için şu komutu kullanın:" -ForegroundColor Cyan
Write-Host "az ssh vm -n myRockyLinuxVM -g AzureADLinuxVM" -ForegroundColor White

Write-Host "`nEğer bağlantı sorunu yaşarsanız:" -ForegroundColor Yellow
Write-Host "1. az login komutu ile oturum açtığınızdan emin olun" -ForegroundColor White
Write-Host "2. VM'in tamamen başlatıldığını kontrol edin" -ForegroundColor White
Write-Host "3. Extension'ın kurulum durumunu kontrol edin:" -ForegroundColor White
Write-Host "   az vm extension show --resource-group AzureADLinuxVM --vm-name myRockyLinuxVM --name AADSSHLoginForLinux" -ForegroundColor Gray