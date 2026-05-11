# Hướng dẫn chạy Lab trên Windows (Không cần `make`)

Vì Windows không hỗ trợ lệnh `make` mặc định, bạn có thể chạy trực tiếp các lệnh sau đây trong terminal (**PowerShell** hoặc **Command Prompt**).

## 1. Setup ban đầu (Thay cho `make setup`)
Mở PowerShell tại thư mục lab và chạy:

```powershell
# Copy file cấu hình
copy .env.example .env

# Pull các docker image cần thiết
docker pull prom/prometheus:latest
docker pull grafana/grafana:latest
docker pull grafana/loki:latest
docker pull jaegertracing/all-in-one:latest
docker pull otel/opentelemetry-collector-contrib:latest
docker pull prom/alertmanager:latest

# Kiểm tra môi trường bằng python
python 00-setup/verify-docker.py
```

## 2. Khởi động hệ thống (Thay cho `make up`)
```powershell
docker compose up -d
```
*Đợi khoảng 30 giây để các service khởi động hoàn tất.*

## 3. Kiểm tra sức khỏe (Thay cho `make smoke`)
Bạn chỉ cần mở trình duyệt và truy cập các địa chỉ sau, nếu hiện giao diện là OK:
- App: [http://localhost:8000/healthz](http://localhost:8000/healthz)
- Prometheus: [http://localhost:9090](http://localhost:9090)
- Grafana: [http://localhost:3000](http://localhost:3000) (admin/admin)
- Alertmanager: [http://localhost:9093](http://localhost:9093)
- Jaeger: [http://localhost:16686](http://localhost:16686)

## 4. Chạy giả lập tải (Thay cho `make load`)
Lưu ý: Bạn cần cài đặt locust trước (`pip install locust`).
```powershell
cd 02-prometheus-grafana/load-test
locust -f locustfile.py --headless -u 10 -r 2 -t 60s --host http://localhost:8000
cd ../..
```

## 5. Kích hoạt cảnh báo (Thay cho `make alert`)
Bạn chạy lần lượt các lệnh sau:
1. **Tắt app**: `docker stop day23-app`
2. **Đợi 1-2 phút**: Kiểm tra Slack hoặc Alertmanager xem có cảnh báo không.
3. **Bật lại app**: `docker start day23-app`

## 6. Chạy Drift Detection (Thay cho `make drift`)
```powershell
cd 04-drift-detection
python scripts/drift_detect.py
cd ..
```

## 7. Kiểm tra kết quả cuối cùng (Thay cho `make verify`)
```powershell
python scripts/verify.py
```

---
**Mẹo:** Nếu bạn muốn dùng lệnh `make` trên Windows, bạn có thể cài đặt [Chocolatey](https://chocolatey.org/) rồi chạy `choco install make`. Tuy nhiên, dùng lệnh trực tiếp như trên là cách nhanh nhất không cần cài thêm gì.
