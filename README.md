**專案簡介**
按照架構圖設計
位於 VPC(10.0.0.0/16)內, 部署在特定Subnet 中的運算資源(EC2), 發出對 Subnet 中特定 S3的存取請求, 接著Subnet 關聯的 Route Table 進行路由判斷。
Route Table 中設定了指向 VPC Gateway Endpoint的路由 (endpoint policy決定這個 VPC 內的請求 可以經由此 Endpoint 存取特定S3 資源)，
請求直接走 AWS 內部網路，抵達對應的S3 bucket，S3 依據 Bucket Policy決定是否可存取，如果不是這個vpc發出的請求則拒絕存取。
例外條款: 因使用terraform創立, terraform位於VPC外, 所以從terraform來的管理員操作作為例外而許可

**使用說明**
1. 執行terraform init, terraform plan, terraform apply看執行結果

**驗證步驟 (透過 AWS Console)**
部署完成後，請按照以下步驟進行完整的邏輯驗證：

第一步：登入 EC2
進入 AWS Console > EC2。
選中名為 demo-app-server 的實例。
點擊上方 連線 (Connect) 按鈕。
切換到 Session Manager 頁籤，點擊 連線 (Connect)。
如果按鈕反灰，代表上面的 verify.tf 還沒完全生效或 Agent 尚未註冊，請稍等 1-2 分鐘。
這會開啟一個黑色的終端機視窗。

第二步：取得 Bucket 名稱
在終端機內輸入以下指令，將 Bucket 名稱存為變數（方便後續測試）：
# 請將這裡替換成您 terraform output 顯示的 bucket 名稱
export BUCKET_NAME="demo-secure-bucket-xxxxxxxxx" 

第三步：執行測試情境
測試 A：正向測試（應該成功）
測試 VPC 內的 EC2 是否能存取指定的 Bucket。
# 建立一個測試檔案
echo "Hello from VPC" > test.txt

# 上傳檔案 (應該顯示 upload: ... )
aws s3 cp test.txt s3://$BUCKET_NAME/test.txt

# 列出檔案 (應該顯示 test.txt)
aws s3 ls s3://$BUCKET_NAME

預期結果：指令成功執行。這證明了 Route Table 路由正確，且 Endpoint Policy 與 Bucket Policy 均允許存取。

測試 B：Endpoint Policy 攔截測試（應該失敗）
# 嘗試列出一個公開 Bucket (例如 amazonaws 的公開資料集, 我是使用自己開的public s3)
aws s3 ls s3://noaa-gsod-pds --region ap-northeast-1
預期結果：Access Denied。

原因：雖然網路通暢，但我們的 VPC Endpoint Policy 只允許 Resource: [aws_s3_bucket.secure_bucket.arn]，因此其他所有 S3 存取都會被 Endpoint 這一層擋下。


**架構圖**

![Architecture Diagram](docs/gateway_endpoint.png)
