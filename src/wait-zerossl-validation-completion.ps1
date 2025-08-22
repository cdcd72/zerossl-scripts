param (
    [Parameter(Mandatory)] 
    [string]$ApiKey,        # ZeroSSL API 金鑰
    [Parameter(Mandatory)] 
    [string]$CertId,        # 憑證 ID
    [int]$MaxRetries = 30,  # 最大輪詢次數
    [int]$DelaySeconds = 20 # 每次輪詢的延遲秒數
)

$uri = "https://api.zerossl.com/certificates/$CertId" + "?access_key=$ApiKey"

for ($i = 0; $i -lt $MaxRetries; $i++) {
    try {
        # 📤 提交查詢憑證資訊請求
        $response = Invoke-RestMethod -Uri $uri -Method Get
        $status = $response.status
        Write-Host "🔄 第 $($i+1) 次輪詢：憑證狀態 = $status"
        if ($status -eq "issued") {
            return $true
        }
        Start-Sleep -Seconds $DelaySeconds
    } catch {
        Write-Warning "⚠️ 輪詢失敗：$($_.Exception.Message)"
        Start-Sleep -Seconds $DelaySeconds
    }
}

Write-Warning "⏳ 超過最大輪詢次數，憑證尚未簽發"
return $false