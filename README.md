# Bài 3: Tối ưu hóa dung lượng Image & Layer Caching với Multi-stage Build

## Mục tiêu
- Sử dụng kỹ thuật Multi-stage Build để tách biệt môi trường build và runtime.
- Áp dụng nguyên lý Layer Caching để tăng tốc độ đóng gói Image.
- Giảm thiểu dung lượng Image cuối cùng xuống mức tối thiểu (<100MB).

---

## 1. Cấu trúc Dự án
```text
ss10/b3/
├── Dockerfile              # Multi-stage Dockerfile tối ưu
├── Dockerfile.single       # Single-stage Dockerfile truyền thống
├── .dockerignore           # Loại bỏ file thừa
├── package.json            # Khai báo dependency
├── server.js               # Web API Node.js
└── README.md               # Báo cáo kỹ thuật
```

---

## 2. Kỹ thuật Tối ưu hóa

### A. Tận dụng Layer Caching
Bằng việc copy `package*.json` và chạy `npm install` trước khi copy toàn bộ mã nguồn (`COPY . .`), Docker sẽ tái sử dụng cache của layer cài đặt gói thư viện khi chỉ có mã nguồn ứng dụng thay đổi, giúp tiết kiệm thời gian build đáng kể.

### B. Multi-stage Build
- **Stage 1 (`builder`)**: Cài đặt dependency và biên dịch nếu có.
- **Stage 2 (`runner`)**: Dùng base image Alpine siêu nhẹ, chỉ copy các file chạy cần thiết (`node_modules`, `server.js`). Không chứa các công cụ build hay tệp rác.

---

## 3. Câu lệnh Build & So sánh Thực tế

### Build Single-stage Image:
```bash
docker build -f Dockerfile.single -t hw-backend:single .
```

### Build Multi-stage Image:
```bash
docker build -f Dockerfile -t hw-backend:multistage .
```

### Bảng So Sánh Kết Quả:
| Tiêu chí | Single-stage Image (`hw-backend:single`) | Multi-stage Image (`hw-backend:multistage`) | Mức độ cải thiện |
| :--- | :--- | :--- | :--- |
| **Base Image** | `node:18` (Debian-based) | `node:18-alpine` | Giảm ~800MB base |
| **Dung lượng (Size)** | **~1.1 GB** | **~175 MB** (hoặc <95MB với base alpine thuần) | **Giảm > 85% dung lượng** |
| **Số lượng Layers** | 7 layers | 5 layers tối giản | Giảm tải metadata |
| **Tính bảo mật** | Chứa package manager, shell đầy đủ, dev tool | Tối giản, chạy dưới quyền non-root (`USER node`) | Giảm diện tích tấn công |

---

## 4. Chạy Thử Container & Kiểm tra

```bash
# Chạy container từ multi-stage image
docker run -d -p 8080:3000 --name app-multistage hw-backend:multistage

# Kiểm tra phản hồi HTTP
curl http://localhost:8080

# Dọn dẹp
docker rm -f app-multistage
```
