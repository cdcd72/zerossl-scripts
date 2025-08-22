param (
    [Parameter(Mandatory)] 
    [string]$ApiKey,       # ZeroSSL API 金鑰
    [Parameter(Mandatory)] 
    [string]$CertId        # 憑證 ID
)

$uri = "https://api.zerossl.com/certificates/$CertId" + "?access_key=$ApiKey"

try {
    # 📤 提交查詢憑證資訊請求
    $response = Invoke-RestMethod -Uri $uri -Method Get
    # 📋 整理所有 domain（主域名 + 額外域名）
    $domains = @($response.common_name)
    if ($response.additional_domains) {
        $domains += ($response.additional_domains -split ",")
    }
    # 📦 回傳每個 domain 的 CNAME 驗證資訊
    $results = @()
    foreach ($domain in $domains) {
        $info = $response.validation.other_methods."$domain"
        $results += [pscustomobject]@{
            Domain       = $domain
            TargetHost   = $info.cname_validation_p1
            TargetRecord = $info.cname_validation_p2
        }
    }
    return $results
} catch {
    throw "🚨 API 呼叫失敗：$($_.Exception.Message)"
}
