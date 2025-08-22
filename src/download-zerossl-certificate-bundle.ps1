param (
    [Parameter(Mandatory)]
    [string]$ApiKey,       # ZeroSSL API 金鑰
    [Parameter(Mandatory)]
    [string]$CertId        # 憑證 ID
)

$uri = "https://api.zerossl.com/certificates/$CertId/download/return?access_key=$ApiKey"

try {
    # 📤 提交下載憑證資訊請求
    $response = Invoke-RestMethod -Uri $uri -Method Get
    return $response
} catch {
    throw "🚨 API 呼叫失敗：$($_.Exception.Message)"
}
