# Cloud Firestore REST Seeder for Campus Event
$config = Get-Content "$env:USERPROFILE\.config\configstore\firebase-tools.json" | ConvertFrom-Json
$token = $config.tokens.access_token

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}
$base = "https://firestore.googleapis.com/v1/projects/campus-event-48443/databases/(default)/documents"

function Post-Doc($collection, $id, $fields) {
    $url = "$base/$collection`?documentId=$id"
    $body = @{ fields = $fields } | ConvertTo-Json -Depth 10
    try {
        $resp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
        Write-Host "✅ Created: $collection/$id"
    } catch {
        # If exists, update via patch
        $patchUrl = "$base/$collection/$id"
        $resp = Invoke-RestMethod -Uri $patchUrl -Method Patch -Headers $headers -Body $body
        Write-Host "🔄 Updated: $collection/$id"
    }
}

Write-Host "🌱 Seeding Users..."
Post-Doc "users" "USR-FPTU-2026" @{
    id = @{ stringValue = "USR-FPTU-2026" }
    name = @{ stringValue = "Nguyễn Văn An" }
    email = @{ stringValue = "an.nv@fptu.edu.vn" }
    avatarUrl = @{ stringValue = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150" }
    major = @{ stringValue = "Kỹ thuật Phần mềm (SE18)" }
    activityPoints = @{ integerValue = 25 }
    role = @{ stringValue = "student" }
    followedClubs = @{ arrayValue = @{ values = @(@{ stringValue = "fcode" }, @{ stringValue = "media_club" }) } }
}

Write-Host "🌱 Seeding Clubs..."
Post-Doc "clubs" "fcode" @{
    id = @{ stringValue = "fcode" }
    name = @{ stringValue = "CLB Học thuật F-Code" }
    category = @{ stringValue = "Technology" }
    description = @{ stringValue = "Câu lạc bộ Lập trình và Thuật toán hàng đầu Đại học FPT TP.HCM." }
    followerCount = @{ integerValue = 2450 }
    logoUrl = @{ stringValue = "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=120" }
}

Post-Doc "clubs" "jsclub" @{
    id = @{ stringValue = "jsclub" }
    name = @{ stringValue = "CLB Kỹ sư phần mềm Nhật Bản" }
    category = @{ stringValue = "Technology" }
    description = @{ stringValue = "Cộng đồng sinh viên định hướng làm việc tại các tập đoàn công nghệ Nhật Bản." }
    followerCount = @{ integerValue = 1820 }
    logoUrl = @{ stringValue = "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=120" }
}

Post-Doc "clubs" "media_club" @{
    id = @{ stringValue = "media_club" }
    name = @{ stringValue = "CLB Truyền thông Cóc Sài Gòn" }
    category = @{ stringValue = "Media" }
    description = @{ stringValue = "Tổ chức các sự kiện văn hóa, truyền thông và giải trí sinh viên FPTU." }
    followerCount = @{ integerValue = 3890 }
    logoUrl = @{ stringValue = "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=120" }
}

Write-Host "🌱 Seeding Events..."
Post-Doc "events" "EVT-2026-01" @{
    id = @{ stringValue = "EVT-2026-01" }
    title = @{ stringValue = "FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai" }
    description = @{ stringValue = "Triển lãm công nghệ thường niên quy mô 500 sinh viên tại Đại học FPT TP.HCM. Cập nhật các xu hướng AI, Generative Agents và cơ hội nghề nghiệp cùng chuyên gia Google, FPT Software." }
    category = @{ stringValue = "Technology" }
    clubId = @{ stringValue = "fcode" }
    clubName = @{ stringValue = "CLB F-Code" }
    date = @{ stringValue = "28/10/2026" }
    time = @{ stringValue = "13:30 - 17:30" }
    location = @{ stringValue = "Hội trường Trịnh Công Sơn" }
    capacity = @{ integerValue = 400 }
    registeredCount = @{ integerValue = 342 }
    bannerUrl = @{ stringValue = "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800" }
    isFeatured = @{ booleanValue = $true }
    speakers = @{
        arrayValue = @{
            values = @(
                @{
                    mapValue = @{
                        fields = @{
                            name = @{ stringValue = "TS. Nguyễn Văn Hùng" }
                            role = @{ stringValue = "Trưởng ban Nghiên cứu AI, FPT Software" }
                            avatarUrl = @{ stringValue = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120" }
                        }
                    }
                },
                @{
                    mapValue = @{
                        fields = @{
                            name = @{ stringValue = "ThS. Trần Thu Hà" }
                            role = @{ stringValue = "Product Lead, Google Developer Group" }
                            avatarUrl = @{ stringValue = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120" }
                        }
                    }
                }
            )
        }
    }
}

Post-Doc "events" "EVT-2026-02" @{
    id = @{ stringValue = "EVT-2026-02" }
    title = @{ stringValue = "Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động" }
    description = @{ stringValue = "Khám phá bí quyết thiết kế UI/UX theo 10 Heuristics của Jakob Nielsen, tối ưu Touch Target và đo lường tương phản WCAG 2.1 AA cho ứng dụng di động." }
    category = @{ stringValue = "Design" }
    clubId = @{ stringValue = "media_club" }
    clubName = @{ stringValue = "CLB Cóc Sài Gòn" }
    date = @{ stringValue = "30/10/2026" }
    time = @{ stringValue = "09:00 - 11:30" }
    location = @{ stringValue = "Phòng Hội thảo Alpha Building (Phòng 301)" }
    capacity = @{ integerValue = 120 }
    registeredCount = @{ integerValue = 94 }
    bannerUrl = @{ stringValue = "https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800" }
    isFeatured = @{ booleanValue = $true }
}

Post-Doc "events" "EVT-2026-03" @{
    id = @{ stringValue = "EVT-2026-03" }
    title = @{ stringValue = "Giải Đấu Thể Thao Điện Tử FPTU Champions League" }
    description = @{ stringValue = "Vòng chung kết giải thể thao điện tử sinh viên toàn trường, phát sóng trực tiếp kèm quà tặng áo đấu độc quyền FPTU." }
    category = @{ stringValue = "Entertainment" }
    clubId = @{ stringValue = "fcode" }
    clubName = @{ stringValue = "CLB F-Code" }
    date = @{ stringValue = "05/11/2026" }
    time = @{ stringValue = "18:00 - 21:30" }
    location = @{ stringValue = "Sân khấu Hội trường Lớn A2" }
    capacity = @{ integerValue = 300 }
    registeredCount = @{ integerValue = 288 }
    bannerUrl = @{ stringValue = "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800" }
    isFeatured = @{ booleanValue = $false }
}

Write-Host "🌱 Seeding Questions (Subcollection)..."
Post-Doc "events/EVT-2026-01/questions" "Q-01" @{
    id = @{ stringValue = "Q-01" }
    eventId = @{ stringValue = "EVT-2026-01" }
    userId = @{ stringValue = "USR-TEST-02" }
    studentName = @{ stringValue = "Lê Minh Quân (SE17)" }
    question = @{ stringValue = "Diễn giả đánh giá thế nào về tốc độ suy luận của Gemini 1.5 Flash so với GPT-4o trên thiết bị di động?" }
    upvotes = @{ integerValue = 18 }
}

Post-Doc "events/EVT-2026-01/questions" "Q-02" @{
    id = @{ stringValue = "Q-02" }
    eventId = @{ stringValue = "EVT-2026-01" }
    userId = @{ stringValue = "USR-TEST-03" }
    studentName = @{ stringValue = "Trần Hoài Nam (IA18)" }
    question = @{ stringValue = "Sinh viên năm 2 nên bắt đầu học Machine Learning từ nền tảng toán nào trước ạ?" }
    upvotes = @{ integerValue = 12 }
}

Write-Host "🌱 Seeding Tickets..."
Post-Doc "tickets" "TICKET-2026-01" @{
    id = @{ stringValue = "TICKET-2026-01" }
    eventId = @{ stringValue = "EVT-2026-01" }
    userId = @{ stringValue = "USR-FPTU-2026" }
    eventTitle = @{ stringValue = "FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai" }
    eventDate = @{ stringValue = "28/10/2026" }
    eventTime = @{ stringValue = "13:30 - 17:30" }
    eventLocation = @{ stringValue = "Hội trường Trịnh Công Sơn" }
    studentName = @{ stringValue = "Nguyễn Văn An" }
    studentId = @{ stringValue = "SE183291" }
    ticketCode = @{ stringValue = "CE2026-083291" }
    qrData = @{ stringValue = "FPTU-CE-EVT-2026-01-USR-FPTU-2026-CE2026-083291" }
    status = @{ stringValue = "confirmed" }
    checkInStatus = @{ booleanValue = $false }
}

Write-Host "🌱 Seeding Certificates..."
Post-Doc "certificates" "CERT-2026-9901" @{
    id = @{ stringValue = "CERT-2026-9901" }
    eventId = @{ stringValue = "EVT-2026-01" }
    eventTitle = @{ stringValue = "FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai" }
    userId = @{ stringValue = "USR-FPTU-2026" }
    studentName = @{ stringValue = "Nguyễn Văn An" }
    issueDate = @{ stringValue = "28/10/2026" }
    verificationHash = @{ stringValue = "HASH-FPTU-CERT-CE2026-083291" }
    downloadUrl = @{ stringValue = "https://firebasestorage.googleapis.com/v0/b/campus-event-48443.firebasestorage.app/o/reports%2FUSR-FPTU-2026%2Fcert.pdf?alt=media" }
}

Write-Host "🎉 Seeding complete! All collections created successfully on Cloud Firestore!"
