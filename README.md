## Sơ đồ hệ thống

![](/images/icon-coin98.png)

Các thành phần chính:
+ AWS Elastic Container Service để chạy API
+ Application Load Balancer
+ CloudWatch để xem logs API
+ S3 để lưu trữ tệp tin upload

## Các bước chuẩn bị trước khi chạy project
Tải source code xuống. Thư mục `terraform` là nơi chứa code TF để tạo hạ tầng của dự án. Thư mục `code` là nơi chứa mã nguồn của API, ta tạo repository mới với mã nguồn trong thư mục `code` để chạy CI/CD.

Sau khi tạo repository xong dùng câu lệnh sau để tạo kết nối từ AWS tới Github của ta.


```
aws codestar-connections create-connection --provider-type GitHub --connection-name coin98
```

Kết nối ta tạo sẽ ở trạng thái `PENDING`.

![](/images/01.png)

Hiện tại thì AWS chưa có câu lệnh giúp ta auto ở bước này. Nên để chuyển trạng thái kết nối sang `AVAILABLE` ta mở Console lên và làm theo hướng dẫn sau [Update a pending connection](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html). Ta làm theo hướng dẫn và chọn Github. Sau khi kết nối chuyển sang `AVAILABLE`.

![](/images/02.png)

Ta copy ARN của nó và di chuyển tới thư mục `terraform`, mở tệp tin `terraform.tfvars` và cập nhật các giá trị sau:

```
repository = {
  connection_arn = "arn:aws:codestar-connections:ap-southeast-1:10391374461:connection/21bcd37c-7d1e-4fdc-b17b-29fbcfe62864"
  id             = "hoalongnatsu/coin98-api-interview"
  branch         = "main"
}
```

Với `id` là theo format là `<account>/<repository-name>` và `branch` là nhánh ta chọn chạy CI/CD.

## Chạy project
Tiếp theo ta chạy câu lệnh TF:

```
terraform init && terraform apply
```

Gõ `yes` và đợi hạ tầng được tạo. Nếu có lỗi xảy ra thường là do S3 Bucket Name đã tồn tại, ta có thể sửa tên khác trong tệp tin `terraform.tfvars` và chạy `apply` lại. Sau khi Terraform chạy xong sẽ in ra URL của Application Load Balancer.

```
Outputs:

alb = "ecs-alb-441303974.ap-southeast-1.elb.amazonaws.com"
```

Trước khi gọi tới ALB ta cần kiểm tra các resource của ta đã hoạt động hết chưa.

## CI/CD
Truy cập CodePipeline Console ta sẽ thấy CI/CD của ta đang chạy để build và deploy code lên ECS.

![](/images/03.png)

Luồng CI/CD như hình minh họa sau:

![](/images/icon-coin98-cicd.png)

Source Stage pull code từ Github. Build Stage lấy source code và thực thi build sau đó đẩy lên ECR. Deploy Stage sẽ lấy Image mới từ ECR và triển khai lên ECS, đợi Codepipeline chạy xong.

![](/images/04.png)

Ta chuyển sang ECS Console.

## ECS
Nếu thấy ECS Task đã chuyển sang `2 Running` thành công thì ta có thể gọi vào ALB để kiểm tra API.

![](/images/05.png)

```
curl ecs-alb-441303974.ap-southeast-1.elb.amazonaws.com/healthz
```


## API Docs
GET `/v1/files/:name`

+ API truy cập và tải tệp tin
+ `:name` là tên tệp tin ta truy cập

POST `/v1/files/upload`
+ API upload tệp tin
+ Cú pháp upload với Linux `curl --location --request POST 'http://localhost:3000/v1/files/upload' --form 'file=@"path/to/file.png"'`. Thay đổi `localhost:3000` bằng URL của ALB
+ Với Windows ta có thể xài POSTMAN

![](/images/06.png)

Phần Body ta chọn `form-data`. Mục KEY ta chọn loại là File. Mục VALUE khi bấm vào POSTMAN sẽ thiển thị popup cho ta chọn tệp tin.

DELETE `/v1/files/:name`
+ API xóa tệp tin
+ `:name` là tên tệp tin ta muốn xóa

**Note**: sau khi chạy xong ta nhớ chạy `terraform destory`.
