# Gemini AI Feature Specification: Level 2 Structured Event Insights

**Course:** PRM393 — Final Assignment  
**API Engine:** Google Gemini Developer API (Firebase AI Logic)  
**Model:** `gemini-1.5-flash`  
**Level:** Level 2 (Structured Output: JSON $\longrightarrow$ Dart Model confirmed by user)  
**Implementation:** [`GeminiAiService`](file:///d:/University/FA26/PRM391/Lab2_3/lib/services/gemini_ai_service.dart), [`GeminiEventInsightCard`](file:///d:/University/FA26/PRM391/Lab2_3/lib/widgets/gemini_event_insight_card.dart)  

---

## 1. Feature Architecture & Compliance Checklist

* **Firebase AI Logic / Gemini Developer API:** Invoked via REST with JSON Schema enforcement (`responseMimeType: "application/json"`).
* **Remote Config Parameterization:**
  - `enable_gemini_insights` (Boolean flag): Allows disabling the feature instantly from Firebase Console without rebuilding the app.
  - `gemini_model_name` (String): Configures target model (default: `gemini-1.5-flash`).
  - `gemini_prompt_template` (String): Configures system prompt instruction remotely.
* **Strict Zero-PII Policy:** Under no circumstances are student names, emails, student IDs, or attendee facial photos transmitted to the AI engine. The prompt contains exclusively public event metadata:
  - Event title, description, category, venue, and public session agenda.
* **User Confirmation & Interactivity:** Users can copy suggested questions into the Live Q&A screen (`LiveCompanionScreen`) or edit them before submission.
* **Analytics Instrumentation:**
  - `ai_request`: Logged on AI prompt dispatch (`model`, `feature`, `event_id`).
  - `ai_result_accepted`: Logged when student copies or confirms a suggested question.
  - `ai_error`: Logged with error status code if quota is exhausted or network fails.
* **Graceful Degradation & Fallback:** If offline, timeout, or rate-limited (HTTP 429), the service seamlessly returns a deterministic structured fallback model (`isFallback = true`), ensuring the user flow never crashes.

---

## 2. Structured JSON Schema (Level 2)

```json
{
  "summary": "String (concise 2-3 sentence value summary)",
  "keyTakeaways": ["String", "String", "String"],
  "recommendedAudience": ["String", "String"],
  "suggestedQuestions": ["String", "String"]
}
```

---

## 3. Real Input & Output Demonstration

### Case 1: Technology & Generative AI Workshop
* **Input (Zero-PII):**
  - **Title:** *FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai*
  - **Category:** `Technology`
  - **Description:** *Triển lãm công nghệ thường niên quy mô 500 sinh viên tại Đại học FPT TP.HCM. Cập nhật các xu hướng AI, Generative Agents và cơ hội nghề nghiệp cùng chuyên gia Google, FPT Software.*
  - **Agenda:** *13:30: Check-in; 14:00: Keynote Autonomous Coding Agents; 15:15: Workshop Mobile App với Flutter & Firebase; 16:30: Q&A.*
* **Output (Structured JSON $\rightarrow$ Dart Model):**
  ```json
  {
    "summary": "FPTU Tech Expo 2026 là ngày hội công nghệ trọng điểm dành cho sinh viên FPTU tiếp cận kỷ nguyên Autonomous Coding Agents và giải pháp kiến trúc Mobile đám mây cùng chuyên gia Google và FPT Software.",
    "keyTakeaways": [
      "Hiểu rõ vai trò của AI Coding Agents trong quy trình kỹ thuật phần mềm hiện đại.",
      "Thực hành tích hợp dịch vụ Firebase vào ứng dụng Flutter di động chuẩn công nghiệp.",
      "Kết nối trực tiếp cơ hội thực tập và tuyển dụng tại các tập đoàn công nghệ."
    ],
    "recommendedAudience": [
      "Sinh viên chuyên ngành Kỹ thuật Phần mềm (SE) và Trí tuệ Nhân tạo (AI)",
      "Sinh viên đang làm đồ án tốt nghiệp hoặc môn học PRM393"
    ],
    "suggestedQuestions": [
      "Mô hình Generative AI nào đang mang lại hiệu năng suy luận tốt nhất trên thiết bị di động Flutter?",
      "Làm sao để bảo vệ khóa API và phân quyền dữ liệu an toàn khi gọi dịch vụ AI trên client?"
    ]
  }
  ```

### Case 2: UI/UX Mobile Design Masterclass
* **Input (Zero-PII):**
  - **Title:** *Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động*
  - **Category:** `Design`
  - **Description:** *Khám phá bí quyết thiết kế UI/UX theo 10 Heuristics của Jakob Nielsen, tối ưu Touch Target và đo lường tương phản WCAG 2.1 AA cho ứng dụng di động.*
  - **Agenda:** *09:00: Khai mạc; 09:30: 10 Heuristics & Anti-Slop Design; 10:45: Thực hành Figma to Flutter Tokens.*
* **Output (Structured JSON $\rightarrow$ Dart Model):**
  ```json
  {
    "summary": "Workshop chuyên sâu giúp lập trình viên và nhà thiết kế nắm vững 10 nguyên lý công thái học di động, tối ưu tương phản WCAG 2.1 AA và loại bỏ các lỗi Anti-Slop UI.",
    "keyTakeaways": [
      "Quy chuẩn kích thước Touch Target tối thiểu 48x48 dp trên màn hình cảm ứng.",
      "Cách chuyển đổi Design Tokens từ Figma sang Flutter ThemeData mà không hardcode màu.",
      "Kỹ thuật kiểm thử độ tương phản màu sắc để đạt chuẩn a11y quốc tế."
    ],
    "recommendedAudience": [
      "Sinh viên thiết kế UI/UX và lập trình viên Frontend / Flutter",
      "Thành viên ban truyền thông và kỹ thuật các CLB trường F"
    ],
    "suggestedQuestions": [
      "Làm thế nào để cân bằng giữa tính thẩm mỹ hiện đại và các quy chuẩn công thái học ngặt nghèo?",
      "Công cụ tự động nào hỗ trợ kiểm tra WCAG hiệu quả nhất trong quy trình CI/CD Flutter?"
    ]
  }
  ```

### Case 3: Entertainment & Sports Event
* **Input (Zero-PII):**
  - **Title:** *Giải Đấu Thể Thao Điện Tử FPTU Champions League*
  - **Category:** `Entertainment`
  - **Description:** *Vòng chung kết giải thể thao điện tử sinh viên toàn trường, phát sóng trực tiếp kèm quà tặng áo đấu độc quyền FPTU.*
* **Output (Structured JSON $\rightarrow$ Dart Model):**
  ```json
  {
    "summary": "Giải đấu thể thao điện tử thường niên quy mô toàn trường, tạo sân chơi giao lưu gắn kết tinh thần đồng đội và tìm kiếm các tài năng trẻ đại diện FPTU.",
    "keyTakeaways": [
      "Trải nghiệm không khí thi đấu cuồng nhiệt với bình luận viên chuyên nghiệp.",
      "Cơ hội nhận quà tặng độc quyền và tích lũy điểm rèn luyện phong trào sinh viên.",
      "Mở rộng mạng lưới kết nối giữa các câu lạc bộ giải trí trong trường."
    ],
    "recommendedAudience": [
      "Toàn thể sinh viên yêu thích thể thao điện tử và phong trào sinh viên",
      "Sinh viên cần bổ sung điểm rèn luyện hoạt động ngoại khóa"
    ],
    "suggestedQuestions": [
      "Lịch thi đấu các trận bán kết và chung kết được phân bổ theo khung giờ nào?",
      "Khán giả cổ vũ có được cộng điểm rèn luyện trực tiếp vào hệ thống không?"
    ]
  }
  ```

---

## 4. Failure Handling & Resilience Demonstration

### Scenarios Tested:
1. **Remote Config Kill Switch (`enable_gemini_insights = false`):**
   - *Observation:* The AI card automatically suppresses itself from the UI without any null-pointer exceptions or layout rebuild glitches.
2. **Rate Limit / Quota Exhaustion (HTTP 429) & Offline Disconnect:**
   - *Observation:* When tested under network disconnection (Airplane mode) or invalid API keys, `GeminiAiService` catches the network timeout (`12s timeout`), logs an `ai_error` analytics event, and immediately falls back to the deterministic structured model (`isFallback = true`).
   - *User Experience:* The UI displays an informational badge: `Chế độ dự phòng thông minh (Offline/Fallback Mode)` with pre-cached high-quality takeaways and suggested questions. The user can still interact and copy questions seamlessly.
