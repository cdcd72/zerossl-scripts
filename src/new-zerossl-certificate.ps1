param (
    [Parameter(Mandatory)]
    [string]$ApiKey,        # ZeroSSL API 金鑰
    [Parameter(Mandatory)]
    [string]$CsrPath,       # CSR 檔案路徑
    [Parameter(Mandatory)]
    [string[]]$Domains,     # 支援多網域輸入（例如 @("example.com", "www.example.com")）
    [Parameter(Mandatory)]
    [string]$OutputPath,     # 憑證儲存路徑
    [int]$ValidityDays = 90 # 憑證有效天數（預設 90 天）
)

Write-Host "🔐 開始申請憑證：$($Domains -join ', ')"

# 將多網域合併為逗號分隔字串
$domainList = $Domains | Where-Object { $_.Trim() -ne "" } | Sort-Object -Unique | Join-String -Separator ','

# 步驟 1：提交 CSR 並申請憑證（使用 CNAME 驗證）
$certId = & ".\create-zerossl-certificate.ps1" -ApiKey $ApiKey -CsrPath $CsrPath -Domain $domainList -ValidityDays $ValidityDays
Write-Host "✅ 憑證已申請成功，ID：$certId"

# 步驟 2：查詢 CNAME 驗證資訊
$challengeInfoList = & ".\get-zerossl-cname-challenge-info.ps1" -ApiKey $ApiKey -CertId $certId

foreach ($info in $challengeInfoList) {
    Write-Host "📡 [$($info.Domain)] 請設定以下 CNAME 記錄："
    Write-Host " Host: $($info.TargetHost)"
    Write-Host " Record: $($info.TargetRecord)"
}

# 步驟 3：等待使用者確認 DNS 記錄已生效
Read-Host "⏳ 請確認所有 DNS 記錄已設定並生效，按 Enter 繼續驗證"

# 步驟 4：通知 ZeroSSL 進行 CNAME 驗證
& ".\verify-zerossl-cname-validation.ps1" -ApiKey $ApiKey -CertId $certId
Write-Host "✅ 已通知 ZeroSSL 進行 CNAME 驗證"

# 步驟 5：輪詢憑證狀態直到簽發
$success = & ".\wait-zerossl-validation-completion.ps1" -ApiKey $ApiKey -CertId $certId
if (-not $success) {
    Write-Warning "❌ 憑證驗證失敗，請檢查 DNS 記錄或重新申請"
    return
}
Write-Host "✅ 憑證已簽發"

# 步驟 6：下載憑證與 CA 鍊
$certData = & ".\download-zerossl-certificate-bundle.ps1" -ApiKey $ApiKey -CertId $certId
Write-Host "📦 憑證資料已下載"

# 步驟 7：儲存憑證檔案到指定路徑
& ".\save-zerossl-certificate-files.ps1" -CertificateData $certData -OutputPath $OutputPath
Write-Host "💾 憑證已儲存至：$OutputPath"

Write-Host "🎉 憑證申請流程完成"
