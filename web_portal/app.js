/**
 * FPTU CAMPUS EVENT - ADMIN WEB PORTAL CONTROLLER
 * Style: Achromatic Ledger (Anti-slop v2)
 * Manages Live Gate Telemetry, Budget Approvals, PCCC Safety Compliance, and Excel Export
 */

const app = {
  // Application Data State
  state: {
    activeView: 'overview',
    checkinCount: 124,
    totalCapacity: 200,
    approvedBudget: 48500000,
    hourlyFlow: [
      { hour: '07:30', count: 8 },
      { hour: '08:00', count: 32 },
      { hour: '08:30', count: 46 },
      { hour: '09:00', count: 24 },
      { hour: '09:30', count: 14 }
    ],
    budgetProposals: [
      {
        id: 'PRJ-2026-01',
        title: 'FPTU Tech Expo 2026: AI & Robotics',
        club: 'CLB Lập trình F-Code',
        budget: 18000000,
        source: 'Quỹ HĐSV (12tr) + Doanh nghiệp (6tr)',
        status: 'approved',
        date: '28/10/2026'
      },
      {
        id: 'PRJ-2026-02',
        title: 'Workshop UI/UX Design Masterclass',
        club: 'CLB Truyền thông F-Media',
        budget: 6500000,
        source: 'Quỹ Hoạt động Sinh viên FPTU',
        status: 'pending',
        date: '05/11/2026'
      },
      {
        id: 'PRJ-2026-03',
        title: 'Giải Bóng Đá FPTU Champions League',
        club: 'CLB Thể thao Vovinam & Football',
        budget: 24000000,
        source: 'Quỹ CTSV Cấp Phép Thi Đấu',
        status: 'pending',
        date: '12/11/2026'
      },
      {
        id: 'PRJ-2026-04',
        title: 'Đêm Nhạc Giao Lưu F-Acoustic Chill 2026',
        club: 'CLB Âm nhạc Guitar FPTU',
        budget: 9000000,
        source: 'Quỹ CLB & Bán Vé Gây Quỹ',
        status: 'approved',
        date: '20/11/2026'
      }
    ],
    students: [
      {
        ticketCode: 'CE2026-083291',
        studentId: 'SE193989',
        name: 'Lê Quốc Khánh',
        major: 'Kỹ thuật Phần mềm (SE)',
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        checkInTime: '08:15:22 28/10/2026',
        status: 'checkedIn',
        points: 5,
        certId: 'CERT-2026-9901'
      },
      {
        ticketCode: 'CE2026-083292',
        studentId: 'SE182234',
        name: 'Trần Bảo An',
        major: 'Kỹ thuật Phần mềm (SE)',
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        checkInTime: '08:22:10 28/10/2026',
        status: 'checkedIn',
        points: 5,
        certId: 'CERT-2026-9902'
      },
      {
        ticketCode: 'CE2026-083293',
        studentId: 'IA190241',
        name: 'Nguyễn Hoàng Minh',
        major: 'An toàn Thông tin (IA)',
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        checkInTime: '08:35:48 28/10/2026',
        status: 'checkedIn',
        points: 5,
        certId: 'CERT-2026-9903'
      },
      {
        ticketCode: 'CE2026-083294',
        studentId: 'GD180452',
        name: 'Phạm Quỳnh Mai',
        major: 'Thiết kế Đồ họa (GD)',
        eventId: 'EVT-2026-02',
        eventTitle: 'Workshop UI/UX Design',
        checkInTime: '09:05:12 05/11/2026',
        status: 'checkedIn',
        points: 5,
        certId: 'CERT-2026-9904'
      },
      {
        ticketCode: 'CE2026-083295',
        studentId: 'SE191102',
        name: 'Đặng Tuấn Anh',
        major: 'Kỹ thuật Phần mềm (SE)',
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        checkInTime: '09:12:05 28/10/2026',
        status: 'checkedIn',
        points: 5,
        certId: 'CERT-2026-9905'
      },
      {
        ticketCode: 'CE2026-083296',
        studentId: 'MC184511',
        name: 'Lê Thùy Dương',
        major: 'Truyền thông Đa phương tiện',
        eventId: 'EVT-2026-02',
        eventTitle: 'Workshop UI/UX Design',
        checkInTime: '—',
        status: 'active',
        points: 0,
        certId: 'Chưa cấp'
      },
      {
        ticketCode: 'CE2026-083297',
        studentId: 'SE190881',
        name: 'Vũ Minh Đức',
        major: 'Trí tuệ Nhân tạo (AI)',
        eventId: 'EVT-2026-03',
        eventTitle: 'FPTU Champions League',
        checkInTime: '—',
        status: 'active',
        points: 0,
        certId: 'Chưa cấp'
      },
      {
        ticketCode: 'CE2026-083298',
        studentId: 'IB170293',
        name: 'Hoàng Kim Ngân',
        major: 'Kinh doanh Quốc tế (IB)',
        eventId: 'EVT-2026-01',
        eventTitle: 'FPTU Tech Expo 2026',
        checkInTime: '08:45:19 28/10/2026',
        status: 'checkedIn',
        points: 5,
        certId: 'CERT-2026-9908'
      }
    ]
  },

  // Initialize
  init() {
    this.setupNavigation();
    this.renderKPIs();
    this.renderRecentOverviewTable();
    this.renderBudgetTable();
    this.renderStudentsTable();
    this.renderGateChart();
    console.log('[Campus Event Portal] Initialized successfully in Achromatic Ledger mode.');
  },

  // Navigation Handler
  setupNavigation() {
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(item => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const targetView = item.getAttribute('data-view');
        this.switchView(targetView);
      });
    });
  },

  switchView(viewName) {
    this.state.activeView = viewName;
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(el => {
      el.classList.toggle('active', el.getAttribute('data-view') === viewName);
    });

    document.querySelectorAll('.view-section').forEach(sec => {
      sec.classList.remove('active');
    });

    const targetEl = document.getElementById(`view-${viewName}`);
    if (targetEl) {
      targetEl.classList.add('active');
    }

    if (viewName === 'overview') {
      this.renderGateChart();
    }
  },

  // Format currency VND
  formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount);
  },

  // Render KPIs
  renderKPIs() {
    const elCheckin = document.getElementById('kpi-checkin-count');
    if (elCheckin) elCheckin.innerText = this.state.checkinCount;

    const elApproved = document.getElementById('kpi-budget-approved');
    if (elApproved) elApproved.innerText = this.formatVND(this.state.approvedBudget);

    const pendingCount = this.state.budgetProposals.filter(b => b.status === 'pending').length;
    const elPending = document.getElementById('kpi-pending-docs');
    if (elPending) elPending.innerText = pendingCount;

    const elSidebarPending = document.getElementById('sidebar-pending-budget');
    if (elSidebarPending) elSidebarPending.innerText = pendingCount;

    const elSidebarCheckin = document.getElementById('sidebar-checkin-count');
    if (elSidebarCheckin) elSidebarCheckin.innerText = this.state.checkinCount;
  },

  // Render Overview Recent Table
  renderRecentOverviewTable() {
    const tbody = document.getElementById('overview-recent-table');
    if (!tbody) return;

    const recent = this.state.students.filter(s => s.status === 'checkedIn').slice(0, 5);
    tbody.innerHTML = recent.map(s => `
      <tr>
        <td class="mono" style="font-weight: 600;">${s.ticketCode}</td>
        <td style="font-weight: 500;">${s.name}</td>
        <td class="mono">${s.studentId}</td>
        <td>${s.eventTitle}</td>
        <td class="num">${s.checkInTime}</td>
        <td class="num" style="color: var(--positive); font-weight: 600;">+${s.points} Điểm</td>
        <td><span class="pill pill-positive">Đã Quét Vé</span></td>
      </tr>
    `).join('');
  },

  // Render Budget Table
  renderBudgetTable() {
    const tbody = document.getElementById('budget-table-body');
    if (!tbody) return;

    tbody.innerHTML = this.state.budgetProposals.map(p => {
      let statusPill = '';
      let actions = '';

      if (p.status === 'approved') {
        statusPill = '<span class="pill pill-positive">Đã Phê Duyệt</span>';
        actions = `<span style="font-size: 12px; color: var(--muted);">Đã giải ngân</span>`;
      } else if (p.status === 'rejected') {
        statusPill = '<span class="pill pill-negative">Từ Chối</span>';
        actions = `<span style="font-size: 12px; color: var(--muted);">Yêu cầu lập lại</span>`;
      } else {
        statusPill = '<span class="pill pill-warning">Chờ Thẩm Định</span>';
        actions = `
          <button class="btn btn-success btn-sm" onclick="app.approveBudget('${p.id}')">Duyệt Cấp</button>
          <button class="btn btn-danger btn-sm" onclick="app.rejectBudget('${p.id}')">Từ Chối</button>
        `;
      }

      return `
        <tr>
          <td class="mono" style="font-weight: 600;">${p.id}</td>
          <td style="font-weight: 600;">${p.title}</td>
          <td>${p.club}</td>
          <td class="num" style="font-weight: 700;">${this.formatVND(p.budget)} ₫</td>
          <td style="font-size: 12px; color: var(--muted);">${p.source}</td>
          <td>${statusPill}</td>
          <td style="text-align: right;">${actions}</td>
        </tr>
      `;
    }).join('');
  },

  // Approve Budget
  approveBudget(id) {
    const item = this.state.budgetProposals.find(p => p.id === id);
    if (!item) return;

    item.status = 'approved';
    this.state.approvedBudget += item.budget;
    this.renderKPIs();
    this.renderBudgetTable();
    this.showToast(`Đã duyệt ngân sách ${this.formatVND(item.budget)} ₫ cho "${item.title}"`);
  },

  // Reject Budget
  rejectBudget(id) {
    const item = this.state.budgetProposals.find(p => p.id === id);
    if (!item) return;

    const reason = prompt('Nhập lý do Phòng CTSV từ chối hoặc yêu cầu sửa dự toán:', 'Dự toán vượt hạn mức Quỹ CLB quý 4');
    if (reason === null) return;

    item.status = 'rejected';
    this.renderKPIs();
    this.renderBudgetTable();
    this.showToast(`Đã từ chối hồ sơ "${item.title}". Lý do: ${reason}`);
  },

  // Update Safety Compliance Score
  updateSafetyScore() {
    const checkboxes = [
      document.getElementById('check-1'),
      document.getElementById('check-2'),
      document.getElementById('check-3'),
      document.getElementById('check-4'),
      document.getElementById('check-5')
    ];

    const total = checkboxes.length;
    const checked = checkboxes.filter(c => c && c.checked).length;
    const score = Math.round((checked / total) * 100);

    const pill = document.getElementById('safety-score-pill');
    if (pill) {
      pill.innerText = `Đạt ${score}/100 Điểm`;
      if (score === 100) {
        pill.className = 'pill pill-positive';
      } else if (score >= 60) {
        pill.className = 'pill pill-warning';
      } else {
        pill.className = 'pill pill-negative';
      }
    }
  },

  issueSafetyCertificate() {
    this.showToast('Đã cấp Giấy chứng nhận An toàn PCCC số 108/BB-CTSV thành công!');
  },

  // Render Students Table
  renderStudentsTable(filteredList = null) {
    const tbody = document.getElementById('student-directory-body');
    if (!tbody) return;

    const list = filteredList || this.state.students;
    const countEl = document.getElementById('students-count-indicator');
    if (countEl) countEl.innerText = `Hiển thị ${list.length} sinh viên`;

    tbody.innerHTML = list.map(s => {
      const isChecked = s.status === 'checkedIn';
      const statusPill = isChecked 
        ? '<span class="pill pill-positive">Đã Check-in</span>' 
        : '<span class="pill pill-neutral">Chưa Vào</span>';
      
      const certBadge = isChecked
        ? `<span class="mono" style="font-size: 11px; color: var(--chart-primary); font-weight: 500;">${s.certId}</span>`
        : `<span style="font-size: 11px; color: var(--muted);">—</span>`;

      return `
        <tr>
          <td class="mono" style="font-weight: 600;">${s.ticketCode}</td>
          <td class="mono">${s.studentId}</td>
          <td style="font-weight: 600;">${s.name}</td>
          <td style="color: var(--muted);">${s.major}</td>
          <td>${s.eventTitle}</td>
          <td class="num">${s.checkInTime}</td>
          <td class="num" style="font-weight: 600; color: ${isChecked ? 'var(--positive)' : 'var(--muted)'};">
            ${isChecked ? '+' + s.points : '0'}
          </td>
          <td>${statusPill}</td>
          <td>${certBadge}</td>
        </tr>
      `;
    }).join('');
  },

  // Filter students
  filterStudents() {
    const query = (document.getElementById('student-search')?.value || '').toLowerCase().trim();
    const eventFilter = document.getElementById('event-filter')?.value || 'all';
    const statusFilter = document.getElementById('status-filter')?.value || 'all';

    const filtered = this.state.students.filter(s => {
      const matchQuery = s.name.toLowerCase().includes(query) || s.studentId.toLowerCase().includes(query);
      const matchEvent = eventFilter === 'all' || s.eventId === eventFilter;
      const matchStatus = statusFilter === 'all' || s.status === statusFilter;
      return matchQuery && matchEvent && matchStatus;
    });

    this.renderStudentsTable(filtered);
  },

  // Simulate incoming check-in
  simulateIncomingCheckin() {
    const firstUnchecked = this.state.students.find(s => s.status === 'active');
    if (firstUnchecked) {
      firstUnchecked.status = 'checkedIn';
      firstUnchecked.points = 5;
      firstUnchecked.checkInTime = new Date().toLocaleTimeString('vi-VN') + ' ' + new Date().toLocaleDateString('vi-VN');
      firstUnchecked.certId = 'CERT-2026-' + Math.floor(1000 + Math.random() * 9000);
      this.state.checkinCount += 1;
      this.renderKPIs();
      this.renderRecentOverviewTable();
      this.renderStudentsTable();
      this.showToast(`[Check-in thành công] ${firstUnchecked.name} (${firstUnchecked.studentId}) đã qua cửa.`);
    } else {
      this.showToast('Toàn bộ sinh viên trong danh sách đều đã check-in qua cổng!');
    }
  },

  // Export to CSV
  exportToCSV() {
    const headers = ['Mã Vé', 'MSSV', 'Họ Và Tên', 'Chuyên Ngành', 'Sự Kiện', 'Thời Gian Check-in', 'Điểm RL', 'Trạng Thái', 'Mã Chứng Nhận'];
    const rows = this.state.students.map(s => [
      s.ticketCode,
      s.studentId,
      `"${s.name}"`,
      `"${s.major}"`,
      `"${s.eventTitle}"`,
      s.checkInTime,
      s.points,
      s.status === 'checkedIn' ? 'Đã check-in' : 'Chưa check-in',
      s.certId
    ]);

    const csvContent = '\uFEFF' + [headers.join(','), ...rows.map(r => r.join(','))].join('\r\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `Bao_Cao_Checkin_Campus_Event_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    this.showToast('Đã tải xuống file CSV báo cáo sinh viên!');
  },

  // Export to Excel (.xlsx compatible HTML table with MIME format)
  exportToExcel() {
    const tableHtml = `
      <html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">
      <head>
        <!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Danh Sach Sinh Vien</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->
        <meta http-equiv="content-type" content="text/plain; charset=UTF-8"/>
      </head>
      <body>
        <h2>ĐẠI HỌC FPT TP.HCM - PHÒNG CHĂM SÓC & QUẢN LÝ ĐỜI SỐNG SINH VIÊN (CTSV)</h2>
        <h3>BÁO CÁO TỔNG HỢP ĐIỂM DANH SỰ KIỆN CAMPUS & CỘNG ĐIỂM RÈN LUYỆN</h3>
        <p>Ngày xuất dữ liệu: ${new Date().toLocaleDateString('vi-VN')} | Tổng số sinh viên: ${this.state.students.length}</p>
        <table border="1" cellpadding="6" cellspacing="0" style="border-collapse: collapse; font-family: sans-serif;">
          <thead>
            <tr style="background-color: #f2f2f2; font-weight: bold;">
              <th>Mã Vé</th>
              <th>MSSV</th>
              <th>Họ và Tên</th>
              <th>Chuyên Ngành</th>
              <th>Sự Kiện Tham Dự</th>
              <th>Thời Gian Check-in</th>
              <th>Điểm Rèn Luyện</th>
              <th>Trạng Thái</th>
              <th>Mã Chứng Nhận e-Certificate</th>
            </tr>
          </thead>
          <tbody>
            ${this.state.students.map(s => `
              <tr>
                <td>${s.ticketCode}</td>
                <td>${s.studentId}</td>
                <td>${s.name}</td>
                <td>${s.major}</td>
                <td>${s.eventTitle}</td>
                <td>${s.checkInTime}</td>
                <td style="text-align: right;">${s.points}</td>
                <td>${s.status === 'checkedIn' ? 'Đã điểm danh' : 'Chưa điểm danh'}</td>
                <td>${s.certId}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </body>
      </html>
    `;

    const blob = new Blob([tableHtml], { type: 'application/vnd.ms-excel;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `Bao_Cao_Sinh_Vien_Campus_Event_${new Date().toISOString().slice(0, 10)}.xls`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    this.showToast('Đã xuất file Excel (.xls) báo cáo gửi Ban Giám Hiệu & CTSV!');
  },

  // Toast
  showToast(message) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
      <span>${message}</span>
    `;
    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.2s ease';
      setTimeout(() => toast.remove(), 200);
    }, 3200);
  },

  // Refresh data
  refreshData() {
    this.renderKPIs();
    this.renderRecentOverviewTable();
    this.renderBudgetTable();
    this.renderStudentsTable();
    this.renderGateChart();
    this.showToast('Đã làm mới dữ liệu từ Cloud Firestore!');
  },

  // Render Gate Flow Canvas Chart
  renderGateChart() {
    const canvas = document.getElementById('gateChart');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.parentElement.clientWidth || 500;
    const height = 180;
    canvas.width = width;
    canvas.height = height;

    ctx.clearRect(0, 0, width, height);

    const data = this.state.hourlyFlow;
    const maxVal = Math.max(...data.map(d => d.count), 50);

    // Grid lines (3 faint rules)
    ctx.strokeStyle = '#e6e6e6';
    ctx.lineWidth = 1;
    for (let i = 0; i <= 3; i++) {
      const y = height - 30 - (i * (height - 50) / 3);
      ctx.beginPath();
      ctx.moveTo(40, y);
      ctx.lineTo(width - 20, y);
      ctx.stroke();

      // y-axis labels
      ctx.fillStyle = '#6b6b6b';
      ctx.font = '11px "Geist Mono", monospace';
      ctx.textAlign = 'right';
      ctx.fillText(Math.round((maxVal / 3) * i), 32, y + 4);
    }

    // Draw Bars
    const barWidth = Math.min(48, (width - 80) / data.length - 16);
    const startX = 60;
    const spacing = (width - 80) / data.length;

    data.forEach((d, idx) => {
      const x = startX + (idx * spacing);
      const barHeight = (d.count / maxVal) * (height - 50);
      const y = height - 30 - barHeight;

      // The one chart hue (#1d5fbf) on peak bar, #141414 on others
      ctx.fillStyle = (d.count === Math.max(...data.map(item => item.count))) ? '#1d5fbf' : '#141414';
      ctx.fillRect(x, y, barWidth, barHeight);

      // Value label on top
      ctx.fillStyle = '#0a0a0a';
      ctx.font = '11px "Geist Mono", monospace';
      ctx.textAlign = 'center';
      ctx.fillText(d.count, x + (barWidth / 2), y - 6);

      // x-axis label (hour)
      ctx.fillStyle = '#6b6b6b';
      ctx.font = '11px "Geist", sans-serif';
      ctx.fillText(d.hour, x + (barWidth / 2), height - 12);
    });
  }
};

// Auto-run on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  app.init();
});
window.addEventListener('resize', () => {
  if (app.state.activeView === 'overview') {
    app.renderGateChart();
  }
});
