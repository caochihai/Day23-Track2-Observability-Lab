# Hướng dẫn chi tiết Lab Day 23: Observability Stack (Prometheus + Grafana + OTel + Jaeger + Loki)

Tài liệu này hướng dẫn bạn từng bước thực hiện Lab Day 23, tập trung vào việc chụp ảnh minh chứng (evidence) đúng yêu cầu của Rubric để đạt điểm tối đa.

## 1. Kiến trúc hệ thống (Architecture)
Hệ thống bao gồm 7 service chạy bằng Docker Compose:
- **FastAPI App (day23-app)**: Service chính được gắn các instrumentation để đẩy Metrics, Traces, Logs.
- **Prometheus**: Thu thập và lưu trữ Metrics.
- **Grafana**: Hiển thị Dashboards (Overview, SLO, Cost).
- **OpenTelemetry Collector**: Tiếp nhận Traces từ App và đẩy sang Jaeger.
- **Jaeger**: Lưu trữ và hiển thị Traces.
- **Loki**: Lưu trữ Logs tập trung.
- **Alertmanager**: Quản lý cảnh báo và đẩy sang Slack.

---

## 2. Các bước thực hiện & Chụp ảnh minh chứng

### Bước 0: Setup ban đầu
1. Copy file `.env.example` thành `.env`: `cp .env.example .env`.
2. Điền `SLACK_WEBHOOK_URL` vào file `.env` nếu bạn muốn nhận cảnh báo trên Slack (Yêu cầu để lấy điểm Alert).
3. Chạy `make setup` để kiểm tra môi trường.
4. Chạy `make up` để khởi động 7 container.
5. Chạy `make smoke` để đảm bảo mọi thứ đã sẵn sàng.

---

### Bước 1: Thu thập Metrics & Dashboard (Track 01 & 02)
Chạy lệnh tạo tải giả lập để có dữ liệu hiển thị:
```bash
make load
```
Lệnh này sẽ chạy Locust trong 60 giây. Trong lúc này, hãy thực hiện các screenshot sau:

#### 📸 Screenshot 1: Metrics Active Gauge
- **Cần chụp gì**: Đồ thị metric `inference_active_gauge` tăng lên khi có tải và giảm về 0 khi hết tải.
- **Cách chụp**: Mở trình duyệt vào [http://localhost:9090](http://localhost:9090) (Prometheus UI). Gõ `inference_active_gauge` vào ô tìm kiếm, chọn tab **Graph**.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `01_metrics_active_gauge.png`

#### 📸 Screenshot 2: Overview Dashboard
- **Cần chụp gì**: Dashboard tổng quan với ít nhất 6 panel có dữ liệu (RPS, Latency P50/95/99, Errors, GPU, Tokens, Cost).
- **Cách chụp**: Vào [http://localhost:3000](http://localhost:3000) (admin/admin). Mở dashboard **"AI Service Overview"**. Chờ khoảng 1-2 phút sau khi chạy `make load`.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `02_dashboard_overview.png`

#### 📸 Screenshot 3: SLO Burn-rate Dashboard
- **Cần chụp gì**: Panel hiển thị Burn Rate và Error Budget còn lại.
- **Cách chụp**: Trong Grafana, mở dashboard **"SLO Burn Rate"**.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `02_dashboard_slo.png`

#### 📸 Screenshot 4: Cost & Tokens Dashboard
- **Cần chụp gì**: Panel hiển thị ước tính chi phí $/hr và lượng tokens.
- **Cách chụp**: Trong Grafana, mở dashboard **"Cost and Tokens"**.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `02_dashboard_cost.png`

---

### Bước 2: Alerts & Slack (Track 02)
Chạy lệnh giả lập sự cố (kill app container):
```bash
make alert
```

#### 📸 Screenshot 5: Alertmanager firing
- **Cần chụp gì**: Danh sách các cảnh báo `ServiceDown` hoặc `HighInferenceLatency` đang ở trạng thái **Firing** (màu đỏ).
- **Cách chụp**: Vào [http://localhost:9093](http://localhost:9093).
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `02_alertmanager_firing.png`

#### 📸 Screenshot 6: Slack Notifications
- **Cần chụp gì**: Tin nhắn từ Slack báo **[FIRING]** và sau đó là **[RESOLVED]** khi app sống lại.
- **Cách chụp**: Chụp cửa sổ chat Slack của bạn.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `02_slack_alerts.png`

---

### Bước 3: Tracing (Track 03)
#### 📸 Screenshot 7: Jaeger Trace Detail
- **Cần chụp gì**: Một Trace của endpoint `POST /predict` với 3 child spans (`embed`, `vector_search`, `generate`).
- **Cách chụp**: Vào [http://localhost:16686](http://localhost:16686). Chọn service `day23-app`, click **Find Traces**. Chọn 1 trace bất kỳ để xem chi tiết các span bên trong.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `03_jaeger_trace.png`

#### 📸 Screenshot 8: Span Attributes (GenAI Semantic)
- **Cần chụp gì**: Panel chi tiết của một Span, hiển thị các attributes như `gen_ai.model_name`, `gen_ai.prompt_tokens`...
- **Cách chụp**: Trong Jaeger, click vào một span, mở rộng phần **Tags** hoặc **Process**.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `03_jaeger_attributes.png`

---

### Bước 4: Drift Detection (Track 04)
Chạy script phát hiện trôi dạt dữ liệu:
```bash
make drift
```

#### 📸 Screenshot 9: Evidently HTML Report
- **Cần chụp gì**: Giao diện báo cáo Drift của Evidently với các biểu đồ so sánh phân phối.
- **Cách chụp**: Mở file `04-drift-detection/reports/drift-report.html` bằng trình duyệt.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `04_drift_report.png`

---

### Bước 5: Integration (Track 05)
#### 📸 Screenshot 10: Cross-day Dashboard
- **Cần chụp gì**: Dashboard tích hợp dữ liệu từ các ngày trước (hoặc các panel stub).
- **Cách chụp**: Trong Grafana, mở dashboard **"Cross-day Integration"**.
- **Lưu tại**: `submission/screenshots/`
- **Tên file**: `05_integration_dashboard.png`

---

## 3. Tổng hợp file cần nộp
Trước khi submit, hãy chạy:
```bash
make verify
```
Nếu hiện `All core checkpoints passed!`, bạn đã sẵn sàng.

**Danh mục file trong thư mục `submission/`:**
1. `screenshots/`: Chứa 10 file ảnh đã liệt kê ở trên.
2. `setup-report.json`: Sinh ra từ bước setup.
3. `drift-summary.json`: Sinh ra từ bước drift.
4. `REFLECTION.md`: File trả lời các câu hỏi tự luận (Rất quan trọng, chiếm 15 điểm).

## 4. Mẹo chụp ảnh đẹp
- Sử dụng phím tắt `Windows + Shift + S` trên Windows để chụp vùng màn hình.
- Đảm bảo ảnh nhìn rõ các con số và biểu đồ.
- Không nên chụp toàn màn hình quá rộng, hãy crop vào phần quan trọng nhất của Dashboard/UI.
