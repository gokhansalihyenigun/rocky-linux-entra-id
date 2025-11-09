# Rocky Linux 9 - Azure Entra ID Login Kurulum Dokümantasyonu

## Genel Bakış
Bu doküman, Azure'da Rocky Linux 9 VM oluşturup Microsoft Entra ID (eski adıyla Azure AD) ile SSH giriş yapmayı açıklar.

## Önemli Güncellemeler (Kasım 2025)
- ✅ Rocky Linux publisher artık **resf** (Red Hat Enterprise Linux clone projects)
- ✅ Rocky Linux 8 ve 9, Microsoft Entra ID için resmi olarak destekleniyor
- ✅ URN formatı: `resf:rockylinux-x86_64:9-base:latest`

## Adım Adım Kurulum

### 1. Resource Group Oluştur
```bash
az group create --name AzureADLinuxVM --location southcentralus
```

### 2. Mevcut Rocky Linux 9 Görüntülerini Kontrol Et
```bash
az vm image list --location southcentralus --publisher resf --offer rockylinux-x86_64 --sku 9-base --all -o table
```
Bu komut güncel URN listesini verir. Format: `publisher:offer:sku:version`

### 3. Marketplace Şartlarını Kabul Et (Gerekirse)
```bash
az vm image terms accept --urn resf:rockylinux-x86_64:9-base:latest
```
Bazı subscription'larda bu adım zorunludur.

### 4. VM Oluştur
```bash
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
```

**Önemli Parametreler:**
- `--assign-identity`: Managed Identity etkinleştirir
- `--generate-ssh-keys`: SSH key çiftini otomatik oluşturur
- `--size Standard_B2s`: Küçük-orta iş yükleri için uygun
- `--storage-sku Premium_LRS`: SSD disk performansı

### 5. Microsoft Entra ID SSH Extension'ını Kur
```bash
az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory \
    --name AADSSHLoginForLinux \
    --resource-group AzureADLinuxVM \
    --vm-name myRockyLinuxVM
```
Bu extension:
- `aadsshlogin` paketlerini kurar
- Entra ID ile SSH sertifika tabanlı auth'u etkinleştirir
- OpenSSH'ı Entra ID ile entegre eder

### 6. RBAC Rol Ataması Yap
```bash
username=$(az account show --query user.name -o tsv)
vmid=$(az vm show -g AzureADLinuxVM -n myRockyLinuxVM --query id -o tsv)

# Tam yönetici erişimi
az role assignment create --role "Virtual Machine Administrator Login" --assignee "$username" --scope "$vmid"

# VEYA sadece kullanıcı erişimi (sudo yok)
# az role assignment create --role "Virtual Machine User Login" --assignee "$username" --scope "$vmid"
```

**Rol Farkları:**
- **Virtual Machine Administrator Login**: sudo erişimi var
- **Virtual Machine User Login**: normal kullanıcı, sudo yok

## VM'e Bağlanma

### 1. Azure'a Giriş Yap
```bash
az login
```

### 2. SSH ile Bağlan
```bash
az ssh vm -n myRockyLinuxVM -g AzureADLinuxVM
```

Bu komut:
- Otomatik olarak Entra ID token'ı alır
- OpenSSH certificate-based authentication kullanır
- Geleneksel SSH key'e gerek yok

## Sorun Giderme

### Extension Durumu Kontrol Et
```bash
az vm extension show --resource-group AzureADLinuxVM --vm-name myRockyLinuxVM --name AADSSHLoginForLinux
```

### VM Durumu Kontrol Et
```bash
az vm show -g AzureADLinuxVM -n myRockyLinuxVM --show-details
```

### SSH Debug Modu
```bash
az ssh vm -n myRockyLinuxVM -g AzureADLinuxVM -- -v
```

### Rol Atamalarını Kontrol Et
```bash
az role assignment list --scope "$vmid" --assignee "$username" -o table
```

## Güvenlik Notları

1. **Network Security Group**: Varsayılan olarak SSH (22) portu açılır
2. **SSH Keys**: Otomatik oluşturulan key'ler `~/.ssh/` dizininde saklanır
3. **Managed Identity**: VM'in Azure kaynaklarına erişimi için kullanılır
4. **Certificate-based Auth**: Geleneksel password/key auth yerine sertifika kullanılır

## Maliyet Optimizasyonu

- `Standard_B2s`: 2 vCPU, 4 GB RAM - küçük iş yükleri için
- `Standard_B1s`: 1 vCPU, 1 GB RAM - test ortamları için
- VM'i kullanmadığınızda durdurun: `az vm deallocate`

## Kaynaklar

- [Microsoft Learn - Linux VM Entra ID Login](https://learn.microsoft.com/en-us/entra/identity/devices/howto-vm-sign-in-azure-ad-linux)
- [Rocky Linux Azure Images Documentation](https://docs.rockylinux.org/10/guides/cloud/migration-to-new-azure-images/)
- [Azure VM Image Terms](https://learn.microsoft.com/en-us/cli/azure/vm/image/terms)

## Temizlik

Kaynakları silmek için:
```bash
az group delete --name AzureADLinuxVM --yes --no-wait
```