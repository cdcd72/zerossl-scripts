param (
    [Parameter(Mandatory)]
    [PSCustomObject]$CertificateData, # 憑證與 CA 鍊的資料
    [Parameter(Mandatory)]
    [string]$OutputPath          # 檔案儲存路徑
)

# 🗂️ 確保輸出資料夾存在
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null

# 💾 儲存主憑證
Set-Content -Path (Join-Path $OutputPath "certificate.crt") -Value $CertificateData.'certificate.crt'

# 💾 儲存 CA 鍊
Set-Content -Path (Join-Path $OutputPath "ca_bundle.crt") -Value $CertificateData.'ca_bundle.crt'
