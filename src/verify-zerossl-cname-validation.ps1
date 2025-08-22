param (
    [Parameter(Mandatory)] 
    [string]$ApiKey,       # ZeroSSL API 金鑰
    [Parameter(Mandatory)] 
    [string]$CertId        # 憑證 ID
)

$uri = "https://api.zerossl.com/certificates/$CertId/challenges?access_key=$ApiKey"

$body = @{
    validation_method = "CNAME_CSR_HASH"
}

try {
    # 📤 提交 CNAME 驗證請求
    Invoke-RestMethod -Uri $uri -Method Post -Body $body
} catch {
    throw "🚨 API 呼叫失敗：$($_.Exception.Message)"
}
