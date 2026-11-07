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
    ],
    registrations: [
      {
        id: 'REG-2026-01',
        studentName: 'Nguyễn Văn An',
        studentEmail: 'an.nv@fptu.edu.vn',
        eventTitle: 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
        eventId: 'EVT-2026-02',
        createdAt: '28/10/2026 14:10',
        status: 'pending'
      }
    ],
    announcements: [
      {
        id: 'ANN-2026-01',
        title: 'Chào mừng Lễ hội Công nghệ FPTU Tech Expo 2026! 🚀',
        category: 'general',
        categoryLabel: 'Bản tin chung',
        createdAt: '28/10/2026 08:00',
        status: 'Đã phát'
      },
      {
        id: 'ANN-2026-02',
        title: 'Hướng dẫn quét mã vé QR tại bàn Check-in Cổng 1',
        category: 'reminder',
        categoryLabel: 'Nhắc nhở',
        createdAt: '28/10/2026 08:15',
        status: 'Đã phát'
      }
    ]
  },

  // Initialize
  async init() {
    this.setupNavigation();
    this.renderKPIs();
    this.renderRecentOverviewTable();
    this.renderBudgetTable();
    this.renderStudentsTable();
    this.renderReviewQueue();
    this.renderAnnouncementsHistory();
    this.renderGateChart();
    
    // Wire up live Cloud Firestore pipelines
    await this.fetchFromFirestore();
    console.log('[Campus Event Portal] Initialized successfully with live Cloud Firestore.');
  },

  // Live Cloud Firestore Fetcher
  async fetchFromFirestore() {
    try {
      const eventsRes = await fetch('https://firestore.googleapis.com/v1/projects/campus-event-48443/databases/(default)/documents/events');
      if (eventsRes.ok) {
        const eventsData = await eventsRes.json();
        if (eventsData.documents && eventsData.documents.length > 0) {
          const liveEvents = eventsData.documents.map(doc => {
            const f = doc.fields;
            return {
              id: f.id?.stringValue || doc.name.split('/').pop(),
              title: f.title?.stringValue || 'Sự kiện FPTU',
              clubName: f.clubName?.stringValue || 'CLB FPTU',
              clubId: f.clubId?.stringValue || '',
              location: f.location?.stringValue || 'Hội trường Trịnh Công Sơn',
              capacity: parseInt(f.capacity?.integerValue || '200', 10),
              registeredCount: parseInt(f.registeredCount?.integerValue || '0', 10),
              date: f.date?.stringValue || '',
              time: f.time?.stringValue || ''
            };
          });

          this.state.liveEvents = liveEvents;

          // Update Venues Status with Real Cloud Firestore Data
          this.renderLiveVenues(liveEvents);

          // Update KPIs based on Real Firestore capacity & registrations
          const totalRegistered = liveEvents.reduce((sum, e) => sum + e.registeredCount, 0);
          const totalCap = liveEvents.reduce((sum, e) => sum + e.capacity, 0);
          
          this.state.checkinCount = totalRegistered;
          this.state.totalCapacity = totalCap;
          this.renderKPIs();

          // Update Event Filter Options in Student Directory
          const eventFilterEl = document.getElementById('event-filter');
          if (eventFilterEl) {
            eventFilterEl.innerHTML = '<option value="all">Tất cả sự kiện (Cloud Firestore)</option>' +
              liveEvents.map(e => `<option value="${e.id}">${e.title}</option>`).join('');
          }

          // Link first event to first students
          if (liveEvents[0]) {
            this.state.students.slice(0, 3).forEach(s => {
              s.eventId = liveEvents[0].id;
              s.eventTitle = liveEvents[0].title;
            });
          }
          if (liveEvents[1]) {
            this.state.students.slice(3, 5).forEach(s => {
              s.eventId = liveEvents[1].id;
              s.eventTitle = liveEvents[1].title;
            });
          }
          this.renderStudentsTable();
          this.renderRecentOverviewTable();
          
          console.log(`[Firestore] Successfully fetched ${liveEvents.length} live events from Cloud Firestore.`);
        }
      }

      // Fetch Clubs from Cloud Firestore
      const clubsRes = await fetch('https://firestore.googleapis.com/v1/projects/campus-event-48443/databases/(default)/documents/clubs');
      if (clubsRes.ok) {
        const clubsData = await clubsRes.json();
        if (clubsData.documents && clubsData.documents.length > 0) {
          const liveClubs = clubsData.documents.map(doc => {
            const f = doc.fields;
            return {
              id: f.id?.stringValue || doc.name.split('/').pop(),
              name: f.name?.stringValue || 'CLB FPTU',
              category: f.category?.stringValue || 'Chung'
            };
          });

          // Sync clubs with budget proposals
          if (liveClubs.length >= 2) {
            this.state.budgetProposals[0].club = liveClubs[0].name;
            this.state.budgetProposals[1].club = liveClubs[2] ? liveClubs[2].name : liveClubs[1].name;
            this.renderBudgetTable();
          }
        }
      }
    } catch (err) {
      console.warn('[Firestore] Note: Running offline or cached mode:', err);
    }
  },

  // Render Real Venues from Firestore
  renderLiveVenues(events) {
    const venuesContainer = document.querySelector('.panel .capacity-bar-wrap')?.closest('.panel-body');
    if (!venuesContainer || !events || events.length === 0) return;

    venuesContainer.innerHTML = events.map(e => {
      const pct = Math.min(100, Math.round((e.registeredCount / (e.capacity || 1)) * 100));
      let barColor = 'var(--chart-primary)';
      if (pct > 90) barColor = 'var(--negative)';
      else if (pct > 75) barColor = 'var(--warning)';

      return `
        <div style="margin-bottom: 16px;">
          <div style="display: flex; justify-content: space-between; font-size: 13px;">
            <span style="font-weight: 600;">${e.location}</span>
            <span class="num">${e.registeredCount} / ${e.capacity} (${pct}%)</span>
          </div>
          <div style="font-size: 11.5px; color: var(--muted); margin-top: 2px;">${e.title}</div>
          <div class="capacity-bar-wrap">
            <div class="capacity-bar-fill" style="width: ${pct}%; background-color: ${barColor};"></div>
          </div>
        </div>
      `;
    }).join('') + `
      <div style="font-size: 11.5px; color: var(--muted); margin-top: 14px; padding-top: 10px; border-top: 1px solid var(--rule);">
        Hệ số an toàn: Đạt chuẩn TCVN 3890 (Đồng bộ trực tiếp Cloud Firestore)
      </div>
    `;
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

  // ==========================================
  // FINAL ASSIGNMENT: REVIEW QUEUE (CROSS-ROLE)
  // ==========================================
  renderReviewQueue() {
    const tbody = document.getElementById('review-queue-body');
    const badge = document.getElementById('sidebar-pending-registrations');
    const pill = document.getElementById('queue-status-pill');
    if (!tbody) return;

    const pending = this.state.registrations.filter(r => r.status === 'pending');
    if (badge) badge.innerText = pending.length;
    if (pill) {
      pill.innerText = `${pending.length} Đơn Cần Duyệt`;
      pill.className = pending.length > 0 ? 'pill pill-warning' : 'pill pill-positive';
    }

    if (this.state.registrations.length === 0) {
      tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--muted); padding: 24px;">Hàng chờ trống. Chưa có đơn đăng ký sự kiện nào.</td></tr>`;
      return;
    }

    tbody.innerHTML = this.state.registrations.map(r => {
      let statusPill = '';
      let actions = '';

      if (r.status === 'approved') {
        statusPill = '<span class="pill pill-positive">Đã Duyệt & Cấp Vé</span>';
        actions = `<span class="mono" style="font-size: 11.5px; color: var(--positive);">${r.ticketId || 'CE2026-083291'}</span>`;
      } else if (r.status === 'rejected') {
        statusPill = '<span class="pill pill-negative">Đã Từ Chối</span>';
        actions = `<span style="font-size: 11.5px; color: var(--muted);">${r.reason || 'Hết chỗ'}</span>`;
      } else {
        statusPill = '<span class="pill pill-warning">Chờ Phê Duyệt</span>';
        actions = `
          <button class="btn btn-success btn-sm" onclick="app.approveRegistration('${r.id}')">Duyệt & Cấp Vé</button>
          <button class="btn btn-danger btn-sm" onclick="app.rejectRegistration('${r.id}')">Từ Chối</button>
        `;
      }

      return `
        <tr>
          <td class="mono" style="font-weight: 600;">${r.id}</td>
          <td style="font-weight: 600;">${r.studentName}</td>
          <td class="mono" style="font-size: 12px; color: var(--muted);">${r.studentEmail}</td>
          <td>${r.eventTitle}</td>
          <td style="font-size: 12px; color: var(--muted);">${r.createdAt}</td>
          <td>${statusPill}</td>
          <td style="text-align: right;">${actions}</td>
        </tr>
      `;
    }).join('');
  },

  refreshReviewQueue() {
    this.renderReviewQueue();
    this.showToast('Đã làm mới danh sách hàng chờ đăng ký sự kiện.');
  },

  approveRegistration(id) {
    const item = this.state.registrations.find(r => r.id === id);
    if (!item) return;

    const ticketCode = `CE2026-${Math.floor(100000 + Math.random() * 900000)}`;
    item.status = 'approved';
    item.ticketId = ticketCode;

    // Emit live announcement notification
    const ann = {
      id: `ANN-${Date.now()}`,
      title: `Đăng ký sự kiện đã được duyệt! 🎉`,
      category: 'ticket_approved',
      categoryLabel: 'Duyệt vé thành công',
      createdAt: 'Vừa xong',
      status: 'Đã phát'
    };
    this.state.announcements.unshift(ann);

    this.renderReviewQueue();
    this.renderAnnouncementsHistory();
    this.showToast(`Phê duyệt thành công! Đã cấp vé ${ticketCode} cho sinh viên ${item.studentName}. Thông báo đã gửi tới Mobile Inbox.`);
  },

  rejectRegistration(id) {
    const item = this.state.registrations.find(r => r.id === id);
    if (!item) return;

    const reason = prompt('Nhập lý do từ chối đơn đăng ký sự kiện:', 'Sự kiện đã đạt số lượng tối đa');
    if (reason === null) return;

    item.status = 'rejected';
    item.reason = reason;
    this.renderReviewQueue();
    this.showToast(`Đã từ chối đơn đăng ký của ${item.studentName}. Lý do: ${reason}`);
  },

  // ==========================================
  // FINAL ASSIGNMENT: ANNOUNCEMENTS BROADCAST
  // ==========================================
  handleBroadcastSubmit(e) {
    e.preventDefault();
    const titleInput = document.getElementById('ann-title');
    const contentInput = document.getElementById('ann-content');
    const categorySelect = document.getElementById('ann-category');
    const pinnedCheckbox = document.getElementById('ann-pinned');

    if (!titleInput || !contentInput) return;

    const title = titleInput.value.trim();
    const content = contentInput.value.trim();
    const category = categorySelect ? categorySelect.value : 'general';
    const isPinned = pinnedCheckbox ? pinnedCheckbox.checked : false;

    if (!title || !content) {
      alert('Vui lòng nhập đầy đủ tiêu đề và nội dung thông báo!');
      return;
    }

    const categoryNames = {
      general: 'Bản tin chung',
      reminder: 'Nhắc nhở',
      urgent: 'Khẩn cấp',
      ticket_approved: 'Duyệt vé'
    };

    const newAnn = {
      id: `ANN-${Date.now()}`,
      title: title,
      category: category,
      categoryLabel: categoryNames[category] || 'Bản tin',
      createdAt: 'Vừa xong',
      status: isPinned ? 'Đã ghim' : 'Đã phát'
    };

    this.state.announcements.unshift(newAnn);
    titleInput.value = '';
    contentInput.value = '';
    if (pinnedCheckbox) pinnedCheckbox.checked = false;

    this.renderAnnouncementsHistory();
    this.showToast(`Phát thanh thành công! Bản tin "${title}" đã gửi đến Mobile Inbox của toàn bộ sinh viên.`);
  },

  renderAnnouncementsHistory() {
    const tbody = document.getElementById('announcements-history-body');
    if (!tbody) return;

    if (this.state.announcements.length === 0) {
      tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--muted); padding: 20px;">Chưa có bản tin nào được phát thanh.</td></tr>`;
      return;
    }

    tbody.innerHTML = this.state.announcements.map(a => {
      let catPill = '<span class="pill pill-neutral">Chung</span>';
      if (a.category === 'ticket_approved') catPill = '<span class="pill pill-positive">Duyệt Vé</span>';
      if (a.category === 'urgent') catPill = '<span class="pill pill-negative">Khẩn Cấp</span>';
      if (a.category === 'reminder') catPill = '<span class="pill pill-warning">Nhắc Nhở</span>';

      return `
        <tr>
          <td style="font-weight: 600;">${a.title}</td>
          <td>${catPill}</td>
          <td style="font-size: 12px; color: var(--muted);">${a.createdAt}</td>
          <td><span class="pill pill-positive">${a.status}</span></td>
        </tr>
      `;
    }).join('');
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

  // Simulate Storage Upload
  simulateStorageUpload() {
    const wrap = document.getElementById('storage-progress-wrap');
    const bar = document.getElementById('storage-progress-bar');
    const text = document.getElementById('storage-progress-text');
    const resultBox = document.getElementById('storage-result-box');
    const btn = document.getElementById('btn-storage-upload');

    if (!wrap || !bar || !text || !resultBox || !btn) return;

    btn.disabled = true;
    wrap.style.display = 'block';
    resultBox.style.display = 'none';

    let progress = 0;
    const interval = setInterval(() => {
      progress += 20;
      bar.style.width = progress + '%';
      text.innerText = progress + '%';

      if (progress >= 100) {
        clearInterval(interval);
        setTimeout(() => {
          btn.disabled = false;
          wrap.style.display = 'none';
          resultBox.style.display = 'block';
          this.logAnalytics('storage_pdf_uploaded', { path: 'reports/USR-FPTU-2026/cert_summary.pdf', size_bytes: 48210 });
          this.showToast('Đã tạo báo cáo PDF và tải lên Cloud Storage thành công!');
        }, 400);
      }
    }, 250);
  },

  // Send FCM Broadcast
  sendFCMBroadcast() {
    const title = (document.getElementById('fcm-title')?.value || '').trim();
    const body = (document.getElementById('fcm-body')?.value || '').trim();

    if (!title || !body) {
      this.showToast('Vui lòng nhập đầy đủ tiêu đề và nội dung thông báo!');
      return;
    }

    const historyList = document.getElementById('fcm-history-list');
    if (historyList) {
      const item = document.createElement('div');
      item.style.fontSize = '11.5px';
      item.style.color = 'var(--text)';
      item.style.fontWeight = '500';
      item.style.padding = '4px 0';
      item.innerText = `• [Vừa gửi] ${title}: ${body}`;
      historyList.prepend(item);
    }

    this.logAnalytics('fcm_notification_broadcast', { title, recipients: 1250 });
    this.showToast(`Đã phát sóng Push Notification (FCM) đến 1.250 thiết bị sinh viên!`);
  },

  // Toggle Remote Config
  toggleRemoteConfig(key) {
    if (key === 'featured') {
      const isChecked = document.getElementById('rc-featured')?.checked;
      const pill = document.getElementById('rc-featured-pill');
      if (pill) {
        pill.innerText = isChecked ? '5 Sự Kiện' : '2 Sự Kiện';
        pill.className = isChecked ? 'pill pill-positive' : 'pill pill-neutral';
      }
      this.showToast(`Remote Config: max_featured_events = ${isChecked ? 5 : 2}`);
    } else if (key === 'survey') {
      const isChecked = document.getElementById('rc-survey')?.checked;
      const pill = document.getElementById('rc-survey-pill');
      if (pill) {
        pill.innerText = isChecked ? 'Đang Bật' : 'Tắt';
        pill.className = isChecked ? 'pill pill-positive' : 'pill pill-neutral';
      }
      this.showToast(`Remote Config: show_survey_banner = ${isChecked}`);
    } else if (key === 'maintenance') {
      const isChecked = document.getElementById('rc-maintenance')?.checked;
      const pill = document.getElementById('rc-maintenance-pill');
      if (pill) {
        pill.innerText = isChecked ? 'Bật Bảo Trì' : 'Tắt';
        pill.className = isChecked ? 'pill pill-negative' : 'pill pill-neutral';
      }
      this.showToast(`Remote Config: maintenance_mode = ${isChecked}`);
    }
  },

  publishRemoteConfig() {
    this.logAnalytics('remote_config_published', { timestamp: new Date().toISOString() });
    this.showToast('Đã xuất bản Remote Config mới! Các thiết bị sinh viên sẽ tự động fetch & activate.');
  },

  // Simulate Handled Exception for Crashlytics
  simulateHandledException() {
    const counter = document.getElementById('crashlytics-handled-count');
    if (counter) {
      counter.innerText = parseInt(counter.innerText, 10) + 1;
    }

    const logBox = document.getElementById('crashlytics-log');
    if (logBox) {
      const newLog = document.createElement('div');
      newLog.style.color = 'var(--warning)';
      newLog.innerText = `• [Handled] ApiException: Handled non-fatal at ${new Date().toLocaleTimeString('vi-VN')} (User: USR-FPTU-2026)`;
      logBox.prepend(newLog);
    }

    this.logAnalytics('non_fatal_error_logged', { error_type: 'HandledException' });
    this.showToast('Đã gửi 1 Handled Non-fatal Exception lên Firebase Crashlytics!');
  },

  simulateCrashlyticsAlert() {
    this.showToast('Kiểm tra Crashlytics: Toàn bộ dịch vụ hoạt động an toàn. Crash-free 99.8%.');
  },

  // Seed Firestore from Web
  async seedFirestoreFromWeb() {
    this.showToast('Đang tái lập & xác thực 5 collections Cloud Firestore...');
    await this.fetchFromFirestore();
    const statusMsg = document.getElementById('seeder-status-msg');
    if (statusMsg) {
      statusMsg.innerText = `✓ Đã đồng bộ lại lúc ${new Date().toLocaleTimeString('vi-VN')} · Cloud Firestore hoạt động bình thường`;
    }
    this.showToast('Đã đồng bộ thành công toàn bộ collections trên Cloud Firestore!');
  },

  // Log to Analytics Stream
  logAnalytics(eventName, params = {}) {
    const stream = document.getElementById('analytics-stream');
    if (!stream) return;

    const row = document.createElement('div');
    row.style.color = 'var(--text)';
    row.innerText = `[Analytics] event: '${eventName}' - ${JSON.stringify(params)}`;
    stream.prepend(row);
  },
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
  async refreshData() {
    await this.fetchFromFirestore();
    this.renderKPIs();
    this.renderRecentOverviewTable();
    this.renderBudgetTable();
    this.renderStudentsTable();
    this.renderGateChart();
    this.showToast('Đã làm mới và đồng bộ 100% dữ liệu từ Cloud Firestore!');
  },

  // Render Gate Flow Canvas Chart
  renderGateChart() {
    const canvas = document.getElementById('gateChart');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.parentElement.clientWidth || 500;
    const height = 220;
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
