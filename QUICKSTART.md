# Rocky Linux 9 Azure VM - Hızlı Başlangıç

## Tek Komutla Kurulum

PowerShell kullanıyorsanız:
```powershell
.\setup-rocky-linux-entra-id.ps1
```

Bash kullanıyorsanız:
```bash
chmod +x setup-rocky-linux-entra-id.sh
./setup-rocky-linux-entra-id.sh
```

## Manuel Kurulum

### Önkoşullar
- Azure CLI kurulu ve `az login` ile giriş yapılmış
- Gerekli subscription permissions

### Hızlı Komutlar

```bash
# 1. Resource group
az group create --name AzureADLinuxVM --location southcentralus

# 2. Marketplace terms kabul et
az vm image terms accept --urn resf:rockylinux-x86_64:9-base:latest

# 3. VM oluştur
az vm create \
    --resource-group AzureADLinuxVM \
    --name myRockyLinuxVM \
    --image resf:rockylinux-x86_64:9-base:latest \
    --assign-identity \
    --admin-username azureuser \
    --generate-ssh-keys \
    --size Standard_B2s

# 4. Entra ID extension
az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory \
    --name AADSSHLoginForLinux \
    --resource-group AzureADLinuxVM \
    --vm-name myRockyLinuxVM

# 5. RBAC rol ataması
username=$(az account show --query user.name -o tsv)
vmid=$(az vm show -g AzureADLinuxVM -n myRockyLinuxVM --query id -o tsv)
az role assignment create --role "Virtual Machine Administrator Login" --assignee "$username" --scope "$vmid"

# 6. Bağlan
az ssh vm -n myRockyLinuxVM -g AzureADLinuxVM
```

## Önemli Değişiklikler

✅ **Publisher güncellendi**: `resf` (eskiden `generic` idi)  
✅ **URN güncel**: `resf:rockylinux-x86_64:9-base:latest`  
✅ **Rocky 8 ve 9**: Entra ID için resmi destek  
✅ **Extension name**: `AADSSHLoginForLinux`  

## Test

VM oluştuktan sonra test edin:
```bash
az ssh vm -n myRockyLinuxVM -g AzureADLinuxVM
```

Başarılı olursa, SSH bağlantısı Entra ID ile yapılacak! 🎉