param (
    [Parameter(Mandatory)]
    [string]$ApiKey,        # ZeroSSL API 金鑰
    [Parameter(Mandatory)]
    [string]$CsrPath,       # CSR 檔案路徑
    [Parameter(Mandatory)]
    [string]$Domain,        # 網域名稱
    [int]$ValidityDays = 90 # 憑證有效天數（預設 90 天）
)

try {
    # 📋 讀取 CSR 內容
    $csr = Get-Content -Path $CsrPath -Raw
} catch {
    throw "🚨 無法讀取 CSR 檔案：$($_.Exception.Message)"
}

$uri = "https://api.zerossl.com/certificates?access_key=$ApiKey"

$body = @{
    certificate_domains = $Domain
    certificate_csr = $csr
    certificate_validity_days = $ValidityDays
}

try {
    # 📤 提交憑證申請請求
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    if (-not $response.id) {
        throw "⚠️ API 回應中未包含憑證 ID"
    }
    return $response.id
} catch {
    throw "🚨 API 呼叫失敗：$($_.Exception.Message)"
}
