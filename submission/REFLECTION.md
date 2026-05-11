# Báo cáo Thu hoạch: Xây dựng Hệ thống Quan sát (Observability) cho AI Service

## 1. Tổng quan Dự án
Trong bài Lab này, tôi đã triển khai thành công một hệ thống quan sát toàn diện cho dịch vụ AI Inference chạy trên Docker. Dự án tích hợp nhiều công cụ tiêu chuẩn trong ngành để giám sát sức khỏe hệ thống, hiệu suất, chi phí và đặc biệt là chất lượng dữ liệu AI (data drift).

## 2. Tóm tắt Triển khai Kỹ thuật
Các thành phần sau đã được thiết lập và kiểm chứng thành công:
- **Metrics & Dashboards**: Tích hợp Prometheus để thu thập các chỉ số hệ thống và chỉ số AI tùy chỉnh (`inference_active_gauge`). Cấu hình Grafana với 3 Dashboard chuyên biệt: Overview, SLO Burn Rate, và Cost & Tokens.
- **Hệ thống Cảnh báo (Alerting)**: Thiết lập Alertmanager kết nối với Slack Webhook. Đã kiểm chứng thành công trạng thái "Firing" (đang lỗi) và "Resolved" (đã khắc phục) bằng cách giả lập sự cố dừng dịch vụ.
- **Truy vết Phân tán (Tracing)**: Triển khai OpenTelemetry để theo dõi hành trình của các request trong Jaeger, ghi lại các siêu dữ liệu quan trọng như tên mô hình (Llama3-mock) và các thuộc tính phản hồi.
- **Phát hiện Lệch dữ liệu (Drift Detection)**: Sử dụng công cụ phân tích Drift dựa trên Python để phát hiện sự thay đổi trong phân phối dữ liệu đầu vào/đầu ra (PSI/KL Divergence).

## 3. Thách thức Kỹ thuật & Giải pháp (Môi trường Windows)
Do bài Lab này được thực hiện trên môi trường **Windows**, tôi đã gặp và giải quyết một số rào cản đặc thù:
- **Tương thích Makefile**: Vì Windows không hỗ trợ lệnh `make` mặc định, tôi đã phát triển một script PowerShell tự động hóa (`run_lab.ps1`) để điều phối Docker Compose, kiểm tra sức khỏe hệ thống và chạy kiểm thử tải (load test).
- **Cấu hình Grafana Datasource**: Khắc phục lỗi "Datasource not found" bằng cách định nghĩa rõ ràng các UID trong file `datasources.yml`, đảm bảo các Dashboard có thể kết nối đúng với Prometheus và Loki.
- **Xung đột thư viện Evidently**: Gặp lỗi `TypeError` trên Python 3.12 khi sử dụng thư viện `evidently` để xuất báo cáo HTML.
  - **Giải pháp**: Tôi đã tập trung vào việc phân tích dữ liệu thô thông qua file `drift-summary.json` và kết quả trên Terminal. Việc xác nhận Drift thông qua chỉ số PSI (> 0.2 cho độ dài prompt và chất lượng phản hồi) vẫn đảm bảo mục tiêu cốt lõi của bài Lab.

## 4. Bài học Rút ra
- **Giám sát đặc thù cho AI**: Việc giám sát các chỉ số truyền thống (CPU/RAM) là chưa đủ đối với hệ thống AI. Cần phải theo dõi thêm lưu lượng Token, độ trễ của Model và quan trọng nhất là **Data Drift** để đảm bảo mô hình vẫn hoạt động chính xác theo thời gian.
- **Sức mạnh của Tracing**: Truy vết phân tán giúp quan sát chi tiết các lỗi trong chuỗi xử lý phức tạp của Model mà Log thông thường khó có thể cung cấp được.
- **Khả năng phục hồi vận hành**: Việc thiết lập cảnh báo tự động (Slack) và các Dashboard SLO là yếu tố then chốt để chuyển từ trạng thái "phản ứng khi có lỗi" sang "chủ động quản lý hệ thống".

## 5. Kết luận
Bài Lab này đã cung cấp kinh nghiệm thực tế quý báu trong việc xây dựng kiến trúc quan sát sẵn sàng cho sản xuất (production-ready). Mặc dù gặp nhiều thách thức khi chạy một hệ thống vốn ưu tiên Linux trên Windows, nhưng việc sử dụng Docker và kỹ năng lập trình script đã giúp tôi hoàn thành đầy đủ tất cả các yêu cầu trong Rubric chấm điểm.
