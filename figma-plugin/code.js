// Figma Plugin for Campus Event PRM323/PRM393 Lab 2 Setup
figma.showUI(__html__, { width: 480, height: 640, themeColors: true });

const SCREEN_SPECS = [
  // Student Portal (Screens 01 - 21)
  { id: "S01", name: "01 - Home Campus Pulse", file: "01_home_campus_pulse.png" },
  { id: "S02", name: "02 - Explore Events", file: "02_explore_events.png" },
  { id: "S03", name: "03 - Search Results & Filter", file: "03_search_results.png" },
  { id: "S04", name: "04 - Event Map", file: "04_event_map.png" },
  { id: "S05", name: "05 - Event Detail", file: "05_event_detail.png" },
  { id: "S06", name: "06 - Event Schedule", file: "06_event_schedule.png" },
  { id: "S07", name: "07 - Registration Confirmation (Modal)", file: "07_registration_confirmation.png" },
  { id: "S08", name: "08 - Registration Loading", file: "08_registration_loading.png" },
  { id: "S09", name: "09 - Registration Success", file: "09_registration_success.png" },
  { id: "S10", name: "10 - Registration Error", file: "10_registration_error.png" },
  { id: "S11", name: "11 - My Events", file: "11_my_events.png" },
  { id: "S12", name: "12 - Digital Event Ticket (QR)", file: "12_digital_event_ticket.png" },
  { id: "S13", name: "13 - Campus Calendar", file: "13_campus_calendar.png" },
  { id: "S14", name: "14 - Notifications", file: "14_notifications.png" },
  { id: "S15", name: "15 - Profile", file: "15_profile.png" },
  { id: "S16", name: "16 - Login", file: "16_login.png" },
  { id: "S17", name: "17 - Login Loading", file: "17_login_loading.png" },
  { id: "S18", name: "18 - Login Error", file: "18_login_error.png" },
  { id: "S19", name: "19 - Forgot Password", file: "19_forgot_password.png" },
  { id: "S20", name: "20 - Reset Password", file: "20_reset_password.png" },
  { id: "S21", name: "21 - Role Resolution", file: "21_role_resolution.png" },

  // Event Leader Hub (Screens 22 - 34)
  { id: "EL01", name: "22 - Leader Dashboard", file: "22_event_management_dashboard.png" },
  { id: "EL02", name: "23 - My Created Events", file: "23_my_created_events.png" },
  { id: "EL03", name: "24 - Create Event (Step 1-4)", file: "24_create_event.png" },
  { id: "EL04", name: "25 - Edit Event", file: "25_edit_event.png" },
  { id: "EL05", name: "26 - Event Draft", file: "26_event_draft.png" },
  { id: "EL06", name: "27 - Submit Event (Modal)", file: "27_submit_event.png" },
  { id: "EL07", name: "28 - Approval Status Tracker", file: "28_event_approval_status.png" },
  { id: "EL08", name: "29 - Participants List", file: "29_event_participants.png" },
  { id: "EL09", name: "30 - Check-in Management", file: "30_event_check_in_management.png" },
  { id: "EL10", name: "31 - Check-in Staff Assignment", file: "31_check_in_staff_management.png" },
  { id: "EL11", name: "32 - QR Check-in Scanner", file: "32_event_qr_check_in.png" },
  { id: "EL12", name: "33 - Check-in Result (Success/Error)", file: "33_check_in_result.png" },
  { id: "EL13", name: "34 - Event Statistics", file: "34_event_statistics.png" },

  // Admin Portal (Screens 35 - 40)
  { id: "AD01", name: "35 - Admin Dashboard", file: "35_admin_dashboard.png" },
  { id: "AD02", name: "36 - User Management", file: "36_user_management.png" },
  { id: "AD03", name: "37 - User Detail & Permission", file: "37_user_detail_permission.png" },
  { id: "AD04", name: "38 - Event Approval Center", file: "38_event_approval_center.png" },
  { id: "AD05", name: "39 - Admin Event Review (Approve/Reject)", file: "39_admin_event_review.png" },
  { id: "AD06", name: "40 - Admin Check-in Monitoring", file: "40_admin_check_in_monitoring.png" }
];

const COLOR_TOKENS = [
  { name: "Primary", hex: "#463C75", rgb: { r: 0.275, g: 0.235, b: 0.459 } },
  { name: "Primary Container", hex: "#5E548E", rgb: { r: 0.369, g: 0.329, b: 0.557 } },
  { name: "Secondary", hex: "#625885", rgb: { r: 0.384, g: 0.345, b: 0.522 } },
  { name: "Background", hex: "#F8F6FA", rgb: { r: 0.973, g: 0.965, b: 0.980 } },
  { name: "Surface", hex: "#FFFFFF", rgb: { r: 1.0, g: 1.0, b: 1.0 } },
  { name: "Surface Container", hex: "#F3EBF8", rgb: { r: 0.953, g: 0.922, b: 0.973 } },
  { name: "On Surface (Text)", hex: "#1D1A23", rgb: { r: 0.114, g: 0.102, b: 0.137 } },
  { name: "On Surface Variant", hex: "#48454F", rgb: { r: 0.282, g: 0.271, b: 0.310 } },
  { name: "Outline", hex: "#797580", rgb: { r: 0.475, g: 0.459, b: 0.502 } },
  { name: "Outline Variant", hex: "#C9C4D0", rgb: { r: 0.788, g: 0.769, b: 0.816 } },
  { name: "Success", hex: "#4E8B65", rgb: { r: 0.306, g: 0.545, b: 0.396 } },
  { name: "Error", hex: "#C65B5B", rgb: { r: 0.776, g: 0.357, b: 0.357 } }
];

async function ensureFont() {
  const families = ["Inter", "Roboto"];
  for (const fam of families) {
    try {
      await figma.loadFontAsync({ family: fam, style: "Regular" });
      await figma.loadFontAsync({ family: fam, style: "Bold" });
      return fam;
    } catch (e) {}
  }
  return "Inter";
}

function getOrCreatePage(name) {
  let page = figma.root.children.find(p => p.name.trim().toLowerCase() === name.toLowerCase());
  if (!page) {
    try {
      page = figma.createPage();
      page.name = name;
    } catch (e) {
      return null;
    }
  }
  return page;
}

// ----------------------------------------------------
// MAIN SETUP
// ----------------------------------------------------
async function setupAll() {
  try {
    figma.notify("⏳ Đang thiết lập 40 màn hình chuẩn và Prototype...");
    const fontFam = await ensureFont();

    // 1. Setup Paint Styles (Colors)
    try {
      const existingStyles = figma.getLocalPaintStyles();
      for (const c of COLOR_TOKENS) {
        let style = existingStyles.find(s => s.name === `Color/${c.name}`);
        if (!style) {
          style = figma.createPaintStyle();
          style.name = `Color/${c.name}`;
        }
        style.paints = [{ type: "SOLID", color: c.rgb }];
      }
    } catch (paintErr) {}

    // 2. Setup Text Styles
    try {
      const TEXT_SPECS = [
        { name: "Display", size: 32, style: "Bold", lineHeight: 40 },
        { name: "Headline 1", size: 28, style: "Bold", lineHeight: 36 },
        { name: "Headline 2", size: 22, style: "Bold", lineHeight: 28 },
        { name: "Headline 3", size: 18, style: "Bold", lineHeight: 24 },
        { name: "Body Large", size: 16, style: "Regular", lineHeight: 24 },
        { name: "Body Medium", size: 14, style: "Regular", lineHeight: 20 },
        { name: "Caption", size: 12, style: "Bold", lineHeight: 16 },
        { name: "Small", size: 10, style: "Regular", lineHeight: 14 }
      ];

      const existingTextStyles = figma.getLocalTextStyles();
      for (const t of TEXT_SPECS) {
        let tStyle = existingTextStyles.find(s => s.name === `Typography/${t.name}`);
        if (!tStyle) {
          tStyle = figma.createTextStyle();
          tStyle.name = `Typography/${t.name}`;
        }
        tStyle.fontName = { family: fontFam, style: t.style === "Regular" ? "Regular" : "Bold" };
        tStyle.fontSize = t.size;
        tStyle.lineHeight = { value: t.lineHeight, unit: "PIXELS" };
      }
    } catch (textErr) {}

    // 3. Resolve Pages Safely
    if (figma.root.children.length > 0 && figma.root.children[0].name.toLowerCase().startsWith("page 1")) {
      figma.root.children[0].name = "01 User Flow";
    }

    const p01 = getOrCreatePage("01 User Flow") || figma.root.children[0];
    const p02 = getOrCreatePage("02 Wireframe") || (figma.root.children.length > 1 ? figma.root.children[1] : p01);
    const p03 = getOrCreatePage("03 Final UI") || (figma.root.children.length > 2 ? figma.root.children[2] : p02);
    const p04 = getOrCreatePage("04 Design System");
    const p05 = getOrCreatePage("05 Components");
    const p06 = getOrCreatePage("06 Prototype");

    // 4. Setup Page 03 Final UI (BẮT BUỘC 40 KHUNG MÀN HÌNH CHUẨN)
    setupPage03FinalUI(p03, fontFam);

    // 5. Setup Page 01 User Flow
    setupPage01UserFlow(p01, fontFam);

    // 6. Setup Page 02 Wireframe
    setupPage02Wireframe(p02, fontFam);

    // 7. Setup Design System & Components
    if (p04) setupPage04DesignSystem(p04, fontFam);
    if (p05) setupPage05Components(p05, fontFam);

    // 8. Setup Prototype (Nếu có p06 thì đặt p06, nếu chỉ có 3 pages thì đặt ngay bên phải p03)
    // 8. Setup Prototype (Nếu có p06 thì đặt p06, nếu chỉ có 3 pages thì đặt ngay bên phải p03)
    const protoPage = p06 || p03;
    const protoStartX = p06 ? 80 : 2600;
    await setupPage06Prototype(protoPage, fontFam, protoStartX);

    figma.currentPage = protoPage;
    try {
      const firstProto = protoPage.children.find(c => c.name.includes("16") || c.name.toLowerCase().includes("login"));
      if (firstProto) {
        figma.currentPage.selection = [firstProto];
        figma.viewport.scrollAndZoomIntoView([firstProto]);
      }
    } catch (e) {}

    figma.notify("✅ ĐÃ THIẾT LẬP 40 MÀN HÌNH VÀ 3 PROTOTYPE FLOWS!");
  } catch (err) {
    figma.notify("❌ Lỗi: " + err.message, { error: true });
    console.error("SetupAll error:", err);
  }
}

// ----------------------------------------------------
// PAGE 01: USER FLOW
// ----------------------------------------------------
function setupPage01UserFlow(page, fontFam) {
  [...page.children].forEach(n => n.remove());

  const board = figma.createFrame();
  board.name = "User Flows & Sitemap";
  board.resize(2200, 1400);
  board.fills = [{ type: "SOLID", color: { r: 0.973, g: 0.965, b: 0.980 } }];
  page.appendChild(board);

  const title = figma.createText();
  title.fontName = { family: fontFam, style: "Bold" };
  title.fontSize = 28;
  title.characters = "CAMPUS EVENT — 3 CORE USER FLOWS (PAGE 01)";
  title.x = 60; title.y = 40;
  title.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 } }];
  board.appendChild(title);

  const flows = [
    {
      title: "Flow 1: Student Discovery & 1-Tap QR Registration (Pre-Event)",
      steps: ["1. Login (S16)", "2. Home Pulse (S01)", "3. Event Detail (S05)", "4. Confirm Modal (S07)", "5. Success & QR (S09/S12)"],
      color: { r: 0.275, g: 0.235, b: 0.459 }
    },
    {
      title: "Flow 2: Student In-Event Companion, Live Q&A & Rewards (In/Post-Event)",
      steps: ["1. Digital Ticket (S12)", "2. Check-in Gate (S32)", "3. Live Q&A / Agenda", "4. Event Rating 5★", "5. Certificate & Điểm RL (S15)"],
      color: { r: 0.384, g: 0.345, b: 0.522 }
    },
    {
      title: "Flow 3: Staff Mobile Desk QR Scanner & Error Recovery (Gate Check-in)",
      steps: ["1. Role Switcher (S21)", "2. Camera Scanner (S32)", "3. Result Success/Err (S33)", "4. Manual Code Fallback", "5. Live Gate Counter"],
      color: { r: 0.306, g: 0.545, b: 0.396 }
    }
  ];

  let flowY = 110;
  flows.forEach((fl) => {
    const fCard = figma.createFrame();
    fCard.name = fl.title;
    fCard.resize(2040, 200);
    fCard.x = 60; fCard.y = flowY;
    fCard.cornerRadius = 16;
    fCard.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
    fCard.strokes = [{ type: "SOLID", color: { r: 0.88, g: 0.86, b: 0.92 } }];
    board.appendChild(fCard);

    const flTitle = figma.createText();
    flTitle.fontName = { family: fontFam, style: "Bold" };
    flTitle.fontSize = 16;
    flTitle.characters = fl.title;
    flTitle.x = 24; flTitle.y = 18;
    flTitle.fills = [{ type: "SOLID", color: fl.color }];
    fCard.appendChild(flTitle);

    let stepX = 24;
    fl.steps.forEach((st, sIdx) => {
      const stepBox = figma.createFrame();
      stepBox.name = `Step ${sIdx + 1}`;
      stepBox.resize(360, 100);
      stepBox.x = stepX; stepBox.y = 60;
      stepBox.cornerRadius = 12;
      stepBox.fills = [{ type: "SOLID", color: { r: 0.96, g: 0.94, b: 0.98 } }];
      stepBox.strokes = [{ type: "SOLID", color: fl.color }];
      stepBox.strokeWeight = 1.5;
      fCard.appendChild(stepBox);

      const stText = figma.createText();
      stText.fontName = { family: fontFam, style: "Bold" };
      stText.fontSize = 13;
      stText.characters = st;
      stText.x = 16; stText.y = 38;
      stText.fills = [{ type: "SOLID", color: { r: 0.15, g: 0.12, b: 0.2 } }];
      stepBox.appendChild(stText);

      stepX += 400;
    });

    flowY += 230;
  });
}

// ----------------------------------------------------
// PAGE 02: WIREFRAME
// ----------------------------------------------------
function setupPage02Wireframe(page, fontFam) {
  [...page.children].forEach(n => n.remove());

  const COLS = 5;
  const FRAME_W = 390;
  const FRAME_H = 844;
  const GAP_X = 60;
  const GAP_Y = 80;
  const START_X = 80;
  const START_Y = 80;

  SCREEN_SPECS.forEach((scr, idx) => {
    const col = idx % COLS;
    const row = Math.floor(idx / COLS);

    const wf = figma.createFrame();
    wf.name = `[Wireframe] ${scr.name}`;
    wf.resize(FRAME_W, FRAME_H);
    wf.x = START_X + col * (FRAME_W + GAP_X);
    wf.y = START_Y + row * (FRAME_H + GAP_Y);
    wf.cornerRadius = 32;
    wf.clipsContent = true;
    wf.fills = [{ type: "SOLID", color: { r: 0.95, g: 0.95, b: 0.96 } }];
    wf.strokes = [{ type: "SOLID", color: { r: 0.75, g: 0.75, b: 0.78 } }];
    wf.strokeWeight = 1.5;

    page.appendChild(wf);
  });
}

// ----------------------------------------------------
// PAGE 03: FINAL UI (TOÀN BỘ 40 KHUNG TRẮNG HOÀN HẢO)
// ----------------------------------------------------
function setupPage03FinalUI(page, fontFam) {
  [...page.children].forEach(n => n.remove());

  const COLS = 5;
  const FRAME_W = 390;
  const FRAME_H = 844;
  const GAP_X = 60;
  const GAP_Y = 90;
  const START_X = 80;
  const START_Y = 140;

  // Header Banner
  const banner = figma.createFrame();
  banner.name = "Final UI Header Banner";
  banner.resize(2190, 70);
  banner.x = START_X; banner.y = 40;
  banner.cornerRadius = 14;
  banner.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 } }];
  page.appendChild(banner);

  const bText = figma.createText();
  bText.fontName = { family: fontFam, style: "Bold" };
  bText.fontSize = 20;
  bText.characters = "CAMPUS EVENT — TOÀN BỘ 40 MÀN HÌNH FINAL UI (390 x 844 DP)";
  bText.x = 28; bText.y = 23;
  bText.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  banner.appendChild(bText);

  // 40 KHUNG MÀN HÌNH KHÔNG CHỨA BẤT KỲ CHỮ NÀO BÊN TRONG ĐỂ KHÔNG BỊ LỆCH
  SCREEN_SPECS.forEach((scr, idx) => {
    const col = idx % COLS;
    const row = Math.floor(idx / COLS);

    const frame = figma.createFrame();
    frame.name = scr.name;
    frame.resize(FRAME_W, FRAME_H);
    frame.x = START_X + col * (FRAME_W + GAP_X);
    frame.y = START_Y + row * (FRAME_H + GAP_Y);
    frame.cornerRadius = 36;
    frame.clipsContent = true;
    frame.fills = [{ type: "SOLID", color: { r: 0.973, g: 0.965, b: 0.980 } }];
    frame.strokes = [{ type: "SOLID", color: { r: 0.85, g: 0.83, b: 0.88 } }];
    frame.strokeWeight = 1.5;

    page.appendChild(frame);
  });
}

// ----------------------------------------------------
// PAGE 04: DESIGN SYSTEM
// ----------------------------------------------------
function setupPage04DesignSystem(page, fontFam) {
  [...page.children].forEach(n => n.remove());

  const board = figma.createFrame();
  board.name = "Design System Specification";
  board.resize(1600, 1300);
  board.fills = [{ type: "SOLID", color: { r: 0.973, g: 0.965, b: 0.980 } }];
  page.appendChild(board);

  const title = figma.createText();
  title.fontName = { family: fontFam, style: "Bold" };
  title.fontSize = 28;
  title.characters = "CAMPUS EVENT — DESIGN SYSTEM & FIGMA TOKENS";
  title.x = 60; title.y = 50;
  title.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 } }];
  board.appendChild(title);

  let colX = 60;
  let colY = 120;
  COLOR_TOKENS.forEach((c, i) => {
    const swatch = figma.createFrame();
    swatch.name = c.name;
    swatch.resize(220, 90);
    swatch.x = colX; swatch.y = colY;
    swatch.cornerRadius = 14;
    swatch.fills = [{ type: "SOLID", color: c.rgb }];
    swatch.strokes = [{ type: "SOLID", color: { r: 0.85, g: 0.83, b: 0.88 } }];
    board.appendChild(swatch);

    const sLabel = figma.createText();
    sLabel.fontName = { family: fontFam, style: "Bold" };
    sLabel.fontSize = 12;
    sLabel.characters = `${c.name}\n${c.hex}`;
    sLabel.x = colX + 16; sLabel.y = colY + 44;
    const isLight = (c.rgb.r * 0.299 + c.rgb.g * 0.587 + c.rgb.b * 0.114) > 0.6;
    sLabel.fills = [{ type: "SOLID", color: isLight ? { r: 0.1, g: 0.1, b: 0.1 } : { r: 1, g: 1, b: 1 } }];
    board.appendChild(sLabel);

    colX += 240;
    if ((i + 1) % 6 === 0) {
      colX = 60;
      colY += 110;
    }
  });
}

// ----------------------------------------------------
// PAGE 05: COMPONENTS
// ----------------------------------------------------
function setupPage05Components(page, fontFam) {
  [...page.children].forEach(n => n.remove());

  const board = figma.createFrame();
  board.name = "Component Library (9 Nhóm Bắt Buộc)";
  board.resize(1600, 1200);
  board.fills = [{ type: "SOLID", color: { r: 0.98, g: 0.98, b: 0.99 } }];
  page.appendChild(board);

  const title = figma.createText();
  title.fontName = { family: fontFam, style: "Bold" };
  title.fontSize = 28;
  title.characters = "CAMPUS EVENT — COMPONENT LIBRARY (AUTO LAYOUT & VARIANTS)";
  title.x = 60; title.y = 50;
  title.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 } }];
  board.appendChild(title);
}

// ----------------------------------------------------
// HELPER: LINK SCREENS WITH VISIBLE PROTOTYPE WIRES
// ----------------------------------------------------
async function linkScreens(fromFrame, toFrame) {
  if (!fromFrame || !toFrame) return;

  const actionObj = {
    type: "NODE",
    destinationId: toFrame.id,
    navigation: "NAVIGATE",
    transition: {
      type: "SMART_ANIMATE",
      easing: { type: "EASE_OUT" },
      duration: 0.3
    },
    preserveScrollPosition: false
  };

  const reaction = {
    trigger: { type: "ON_CLICK" },
    actions: [actionObj],
    action: actionObj // Tương thích ngược phiên bản cũ của Figma API
  };

  // Helper gán reaction an toàn tuyệt đối
  async function safeSetReaction(node) {
    if (!node) return;
    try {
      if (typeof node.setReactionsAsync === "function") {
        await node.setReactionsAsync([reaction]);
      } else {
        node.reactions = [reaction];
      }
    } catch (err) {
      try {
        // Fallback DISSOLVE nếu SMART_ANIMATE bị từ chối
        const fallbackAction = {
          type: "NODE",
          destinationId: toFrame.id,
          navigation: "NAVIGATE",
          transition: {
            type: "DISSOLVE",
            easing: { type: "EASE_OUT" },
            duration: 0.2
          },
          preserveScrollPosition: false
        };
        const fallbackReaction = {
          trigger: { type: "ON_CLICK" },
          actions: [fallbackAction],
          action: fallbackAction
        };
        if (typeof node.setReactionsAsync === "function") {
          await node.setReactionsAsync([fallbackReaction]);
        } else {
          node.reactions = [fallbackReaction];
        }
      } catch (err2) {
        console.warn("Could not set reaction on", node.name, err2);
      }
    }
  }

  // 1. Gắn reaction lên chính khung màn hình
  await safeSetReaction(fromFrame);

  // 2. Tạo hoặc làm mới Hotspot Frame phủ toàn màn hình ở lớp TRÊN CÙNG
  try {
    const existing = fromFrame.children.filter(c => c.name.startsWith("⚡") || c.name.startsWith("🎯"));
    existing.forEach(e => e.remove());

    const hotspot = figma.createFrame();
    hotspot.name = "⚡ Interactive Click Area";
    hotspot.resize(fromFrame.width, fromFrame.height);
    hotspot.x = 0;
    hotspot.y = 0;
    // Bắt buộc phải có fill opacity > 0 (0.001) để Figma tính hit-test khi click chuột!
    hotspot.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 }, opacity: 0.001 }];
    hotspot.clipsContent = true;
    fromFrame.appendChild(hotspot);
    await safeSetReaction(hotspot);

    // Nếu là màn hình Login (16 - Login), tạo thêm hotspot chuyên biệt cho đúng nút Đăng nhập
    if (fromFrame.name.includes("16") || fromFrame.name.toLowerCase().includes("login")) {
      const btnHotspot = figma.createFrame();
      btnHotspot.name = "🎯 Nút Đăng nhập (Primary CTA)";
      btnHotspot.resize(342, 54);
      btnHotspot.x = 24;
      btnHotspot.y = 440;
      btnHotspot.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 }, opacity: 0.001 }];
      fromFrame.appendChild(btnHotspot);
      await safeSetReaction(btnHotspot);

      const ssoHotspot = figma.createFrame();
      ssoHotspot.name = "🎯 Nút SSO FPT Mail";
      ssoHotspot.resize(342, 50);
      ssoHotspot.x = 24;
      ssoHotspot.y = 230;
      ssoHotspot.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 }, opacity: 0.001 }];
      fromFrame.appendChild(ssoHotspot);
      await safeSetReaction(ssoHotspot);
    }
  } catch (errHotspot) {
    console.warn("Hotspot creation error:", errHotspot);
  }

  // 3. Gắn reaction lên các layer con khác (như layer ảnh Screen UI Content)
  for (const child of fromFrame.children) {
    if (child.name.startsWith("⚡") || child.name.startsWith("🎯")) continue;
    await safeSetReaction(child);
  }
}

// ----------------------------------------------------
// PROTOTYPE SETUP (KHOẢNG CÁCH THOÁNG & NỐI DÂY XANH CHUẨN)
// ----------------------------------------------------
async function setupPage06Prototype(page, fontFam, startX = 80) {
  const FRAME_W = 390;
  const FRAME_H = 844;
  const GAP_X = 60;

  // Header Banner
  const banner = figma.createFrame();
  banner.name = "Prototype Header Banner";
  banner.resize(2700, 70);
  banner.x = startX; banner.y = 40;
  banner.cornerRadius = 14;
  banner.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 } }];
  page.appendChild(banner);

  const bTitle = figma.createText();
  bTitle.fontName = { family: fontFam, style: "Bold" };
  bTitle.fontSize = 20;
  bTitle.characters = "CAMPUS EVENT — 3 CORE PROTOTYPE FLOWS (BẤM PLAY ▶️ ĐỂ MÔ PHỎNG)";
  bTitle.x = 28; bTitle.y = 23;
  bTitle.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  banner.appendChild(bTitle);

  function createProtoScreen(name, x, y) {
    const frame = figma.createFrame();
    frame.name = `[Proto] ${name}`;
    frame.resize(FRAME_W, FRAME_H);
    frame.x = x; frame.y = y;
    frame.cornerRadius = 36;
    frame.clipsContent = true;
    frame.fills = [{ type: "SOLID", color: { r: 0.973, g: 0.965, b: 0.980 } }];
    frame.strokes = [{ type: "SOLID", color: { r: 0.85, g: 0.83, b: 0.88 } }];
    frame.strokeWeight = 1.5;

    page.appendChild(frame);
    return frame;
  }

  function createLaneTitle(titleText, titleY) {
    const laneTag = figma.createFrame();
    laneTag.name = `Title: ${titleText}`;
    laneTag.resize(750, 40);
    laneTag.x = startX; laneTag.y = titleY;
    laneTag.cornerRadius = 8;
    laneTag.fills = [{ type: "SOLID", color: { r: 0.92, g: 0.90, b: 0.96 } }];
    page.appendChild(laneTag);

    const t = figma.createText();
    t.fontName = { family: fontFam, style: "Bold" };
    t.fontSize = 14;
    t.characters = titleText;
    t.x = 16; t.y = 10;
    t.fills = [{ type: "SOLID", color: { r: 0.275, g: 0.235, b: 0.459 } }];
    laneTag.appendChild(t);
  }

  // FLOW 1: STUDENT REGISTRATION
  const LANE1_TITLE_Y = 150;
  const LANE1_Y = 220;
  createLaneTitle("🔥 FLOW 1: STUDENT DISCOVERY & QR REGISTRATION (HAPPY PATH)", LANE1_TITLE_Y);

  const f1_s1 = createProtoScreen("16 - Login", startX + 0 * (FRAME_W + GAP_X), LANE1_Y);
  const f1_s2 = createProtoScreen("01 - Home Campus Pulse", startX + 1 * (FRAME_W + GAP_X), LANE1_Y);
  const f1_s3 = createProtoScreen("05 - Event Detail", startX + 2 * (FRAME_W + GAP_X), LANE1_Y);
  const f1_s4 = createProtoScreen("07 - Registration Confirmation (Modal)", startX + 3 * (FRAME_W + GAP_X), LANE1_Y);
  const f1_s5 = createProtoScreen("09 - Registration Success", startX + 4 * (FRAME_W + GAP_X), LANE1_Y);
  const f1_s6 = createProtoScreen("12 - Digital Event Ticket (QR)", startX + 5 * (FRAME_W + GAP_X), LANE1_Y);

  // NỐI DÂY TRỰC TIẾP GIỮA CÁC FRAME CHÍNH (HIỆN MŨI TÊN XANH FIGMA RÕ RÀNG)
  await linkScreens(f1_s1, f1_s2);
  await linkScreens(f1_s2, f1_s3);
  await linkScreens(f1_s3, f1_s4);
  await linkScreens(f1_s4, f1_s5);
  await linkScreens(f1_s5, f1_s6);
  await linkScreens(f1_s6, f1_s2);

  // FLOW 2: LEADER CREATE EVENT
  const LANE2_TITLE_Y = LANE1_Y + FRAME_H + 90;
  const LANE2_Y = LANE2_TITLE_Y + 70;
  createLaneTitle("📋 FLOW 2: EVENT LEADER 4-STEP WIZARD & DRAFT RECOVERY", LANE2_TITLE_Y);

  const f2_s1 = createProtoScreen("22 - Leader Dashboard", startX + 0 * (FRAME_W + GAP_X), LANE2_Y);
  const f2_s2 = createProtoScreen("24 - Create Event (Step 1-4)", startX + 1 * (FRAME_W + GAP_X), LANE2_Y);
  const f2_s3 = createProtoScreen("26 - Event Draft", startX + 2 * (FRAME_W + GAP_X), LANE2_Y);
  const f2_s4 = createProtoScreen("27 - Submit Event (Modal)", startX + 3 * (FRAME_W + GAP_X), LANE2_Y);
  const f2_s5 = createProtoScreen("28 - Approval Status Tracker", startX + 4 * (FRAME_W + GAP_X), LANE2_Y);

  await linkScreens(f2_s1, f2_s2);
  await linkScreens(f2_s2, f2_s3);
  await linkScreens(f2_s3, f2_s4);
  await linkScreens(f2_s4, f2_s5);
  await linkScreens(f2_s5, f2_s1);

  // FLOW 3: QR SCANNER
  const LANE3_TITLE_Y = LANE2_Y + FRAME_H + 90;
  const LANE3_Y = LANE3_TITLE_Y + 70;
  createLaneTitle("⚡ FLOW 3: STAFF QR CHECK-IN SCANNER & ERROR RECOVERY", LANE3_TITLE_Y);

  const f3_s1 = createProtoScreen("30 - Check-in Management", startX + 0 * (FRAME_W + GAP_X), LANE3_Y);
  const f3_s2 = createProtoScreen("32 - QR Check-in Scanner", startX + 1 * (FRAME_W + GAP_X), LANE3_Y);
  const f3_s3 = createProtoScreen("33 - Check-in Result (Success)", startX + 2 * (FRAME_W + GAP_X), LANE3_Y);
  const f3_s4 = createProtoScreen("10 - Registration Error", startX + 3 * (FRAME_W + GAP_X), LANE3_Y);

  await linkScreens(f3_s1, f3_s2);
  await linkScreens(f3_s2, f3_s3);
  await linkScreens(f3_s3, f3_s2);
  await linkScreens(f3_s4, f3_s2);

  try {
    page.flowStartingPoints = [
      { nodeId: f1_s1.id, name: "Flow 1: Student Event Registration (Happy Path)" },
      { nodeId: f2_s1.id, name: "Flow 2: Event Leader Create & Draft Recovery" },
      { nodeId: f3_s1.id, name: "Flow 3: Staff QR Scanner & Error Recovery" }
    ];
  } catch (errFlow) {}
}

// ----------------------------------------------------
// IMAGE IMPORT HANDLER (FILL TOÀN DIỆN TẤT CẢ FRAMES)
// ----------------------------------------------------
function extractNumber(str) {
  if (!str) return null;
  const m = str.match(/(\d{1,2})/);
  return m ? parseInt(m[1], 10) : null;
}

async function importImages(images) {
  const allFrames = figma.root.findAll(n => n.type === "FRAME" && n.width === 390);

  let count = 0;
  for (const imgData of images) {
    try {
      const u8 = imgData.buffer instanceof Uint8Array ? imgData.buffer : new Uint8Array(imgData.buffer);
      const imgObj = figma.createImage(u8);
      const imgNum = extractNumber(imgData.name);

      let imgH = 844;
      try {
        const size = await imgObj.getSizeAsync();
        imgH = Math.round(390 * (size.height / size.width));
      } catch (errSize) {
        imgH = 844;
      }

      const matched = allFrames.filter(f => {
        if (imgNum !== null && extractNumber(f.name) === imgNum) return true;
        const cleanF = f.name.toLowerCase().replace(/[^a-z0-9]/g, "");
        const cleanI = imgData.name.toLowerCase().replace(/[^a-z0-9]/g, "");
        return cleanF.includes(cleanI) || cleanI.includes(cleanF);
      });

      for (const frame of matched) {
        frame.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
        frame.clipsContent = true;
        try {
          frame.overflowDirection = "VERTICAL_SCROLLING";
        } catch (e) {}

        const oldRects = frame.children.filter(c => c.name === "Screen UI Content");
        oldRects.forEach(r => r.remove());

        // Tạo layer ảnh căn chính xác từ đỉnh y = 0 để giữ trọn vẹn 100% phần đầu và Header
        const imgNode = figma.createRectangle();
        imgNode.name = "Screen UI Content";
        imgNode.resize(390, imgH);
        imgNode.x = 0;
        imgNode.y = 0;
        imgNode.fills = [{
          type: "IMAGE",
          scaleMode: "FILL",
          imageHash: imgObj.hash
        }];

        frame.insertChild(0, imgNode);

        // Kế thừa reaction chuyển cảnh lên layer ảnh để bấm vào đâu trên ảnh cũng nhận click mượt mà!
        if (frame.reactions && frame.reactions.length > 0) {
          try {
            if (typeof imgNode.setReactionsAsync === "function") {
              await imgNode.setReactionsAsync(frame.reactions);
            } else {
              imgNode.reactions = frame.reactions;
            }
          } catch (eRx) {
            try { imgNode.reactions = frame.reactions; } catch (eRx2) {}
          }
        }

        count++;
      }
    } catch (e) {
      console.error("Error setting image for", imgData.name, e);
    }
  }

  figma.notify(`🎉 Đã nạp thành công ${count} ảnh căn chuẩn đỉnh y=0 (Đầy đủ 100% phần đầu Header)!`);
}

// ----------------------------------------------------
// WIRE ALL PROTOTYPES (CHẠY SAU KHI NẠP ẢNH XONG)
// ----------------------------------------------------
async function wireAllPrototypes() {
  figma.notify("🔗 Đang kết nối tương tác Prototype cho cả 3 Flows...");

  const p06 = figma.root.children.find(p => p.name.includes("06") || p.name.toLowerCase().includes("proto"));
  const p03 = figma.root.children.find(p => p.name.includes("03") || p.name.toLowerCase().includes("final"));

  function findFrame(page, keyword) {
    if (!page) return null;
    return page.children.find(n => n.type === "FRAME" && n.name.toLowerCase().includes(keyword.toLowerCase()));
  }

  const protoPage = p06 || p03;
  let firstLoginFrame = null;

  if (protoPage) {
    // Flow 1: Student Event Registration (Happy Path)
    const f1_s1 = findFrame(protoPage, "16 - Login") || findFrame(protoPage, "16");
    const f1_s2 = findFrame(protoPage, "01 - Home Campus Pulse") || findFrame(protoPage, "01");
    const f1_s3 = findFrame(protoPage, "05 - Event Detail") || findFrame(protoPage, "05");
    const f1_s4 = findFrame(protoPage, "07 - Registration Confirmation") || findFrame(protoPage, "07");
    const f1_s5 = findFrame(protoPage, "09 - Registration Success") || findFrame(protoPage, "09");
    const f1_s6 = findFrame(protoPage, "12 - Digital Event Ticket") || findFrame(protoPage, "12");

    if (f1_s1 && f1_s2) await linkScreens(f1_s1, f1_s2);
    if (f1_s2 && f1_s3) await linkScreens(f1_s2, f1_s3);
    if (f1_s3 && f1_s4) await linkScreens(f1_s3, f1_s4);
    if (f1_s4 && f1_s5) await linkScreens(f1_s4, f1_s5);
    if (f1_s5 && f1_s6) await linkScreens(f1_s5, f1_s6);
    if (f1_s6 && f1_s2) await linkScreens(f1_s6, f1_s2);

    firstLoginFrame = f1_s1;

    // Flow 2: Event Leader Create Event & Draft Recovery
    const f2_s1 = findFrame(protoPage, "22 - Leader Dashboard") || findFrame(protoPage, "22");
    const f2_s2 = findFrame(protoPage, "24 - Create Event") || findFrame(protoPage, "24");
    const f2_s3 = findFrame(protoPage, "26 - Event Draft") || findFrame(protoPage, "26");
    const f2_s4 = findFrame(protoPage, "27 - Submit Event") || findFrame(protoPage, "27");
    const f2_s5 = findFrame(protoPage, "28 - Approval Status") || findFrame(protoPage, "28");

    if (f2_s1 && f2_s2) await linkScreens(f2_s1, f2_s2);
    if (f2_s2 && f2_s3) await linkScreens(f2_s2, f2_s3);
    if (f2_s3 && f2_s4) await linkScreens(f2_s3, f2_s4);
    if (f2_s4 && f2_s5) await linkScreens(f2_s4, f2_s5);
    if (f2_s5 && f2_s1) await linkScreens(f2_s5, f2_s1);

    // Flow 3: Staff QR Scanner & Error Recovery
    const f3_s1 = findFrame(protoPage, "30 - Check-in Management") || findFrame(protoPage, "30");
    const f3_s2 = findFrame(protoPage, "32 - QR Check-in Scanner") || findFrame(protoPage, "32");
    const f3_s3 = findFrame(protoPage, "33 - Check-in Result") || findFrame(protoPage, "33");
    const f3_s4 = findFrame(protoPage, "10 - Registration Error") || findFrame(protoPage, "10");

    if (f3_s1 && f3_s2) await linkScreens(f3_s1, f3_s2);
    if (f3_s2 && f3_s3) await linkScreens(f3_s2, f3_s3);
    if (f3_s3 && f3_s2) await linkScreens(f3_s3, f3_s2);
    if (f3_s4 && f3_s2) await linkScreens(f3_s4, f3_s2);

    const sp = [];
    if (f1_s1) sp.push({ nodeId: f1_s1.id, name: "Flow 1: Student Event Registration (Happy Path)" });
    if (f2_s1) sp.push({ nodeId: f2_s1.id, name: "Flow 2: Event Leader Create & Draft Recovery" });
    if (f3_s1) sp.push({ nodeId: f3_s1.id, name: "Flow 3: Staff QR Scanner & Error Recovery" });

    try {
      protoPage.flowStartingPoints = sp;
    } catch (eSP) {}
  }

  // 2. Nối dây trên cả trang 03 Final UI (nếu khác protoPage) để người dùng ở trang nào bấm cũng chạy!
  if (p03 && p03 !== protoPage) {
    const s16 = p03.children.find(c => c.type === "FRAME" && c.name.startsWith("16 - Login"));
    const s01 = p03.children.find(c => c.type === "FRAME" && c.name.startsWith("01 - Home"));
    const s05 = p03.children.find(c => c.type === "FRAME" && c.name.startsWith("05 - Event Detail"));
    const s07 = p03.children.find(c => c.type === "FRAME" && c.name.startsWith("07 - Registration"));
    const s09 = p03.children.find(c => c.type === "FRAME" && c.name.startsWith("09 - Registration Success"));
    const s12 = p03.children.find(c => c.type === "FRAME" && c.name.startsWith("12 - Digital Event Ticket"));

    if (s16 && s01) await linkScreens(s16, s01);
    if (s01 && s05) await linkScreens(s01, s05);
    if (s05 && s07) await linkScreens(s05, s07);
    if (s07 && s09) await linkScreens(s07, s09);
    if (s09 && s12) await linkScreens(s09, s12);
    if (s12 && s01) await linkScreens(s12, s01);

    if (s16) {
      try {
        p03.flowStartingPoints = [{ nodeId: s16.id, name: "Flow 1: Student Login & Registration" }];
      } catch (eSP03) {}
    }
  }

  // 3. Tự động chuyển trang và focus camera thẳng vào màn hình Login!
  const targetPage = protoPage || p03;
  if (targetPage) {
    figma.currentPage = targetPage;
    const focusFrame = firstLoginFrame || targetPage.children.find(c => c.type === "FRAME" && (c.name.includes("16") || c.name.toLowerCase().includes("login")));
    if (focusFrame) {
      figma.currentPage.selection = [focusFrame];
      figma.viewport.scrollAndZoomIntoView([focusFrame]);
    }
  }
}

// ----------------------------------------------------
// MESSAGE DISPATCHER
// ----------------------------------------------------
figma.ui.onmessage = async (msg) => {
  try {
    if (msg.type === "auto-all") {
      figma.notify("⏳ Đang thiết lập đầy đủ 40 màn hình và Prototype...");
      await setupAll();
      await importImages(msg.images);
      await wireAllPrototypes();
      figma.notify("🎉 HOÀN TẤT 100%! Đã nối dây Prototype đầy đủ 3 flows!");
    } else if (msg.type === "setup-all") {
      await setupAll();
      await wireAllPrototypes();
    } else if (msg.type === "import-images") {
      await importImages(msg.images);
      await wireAllPrototypes();
    }
  } catch (err) {
    figma.notify("❌ Lỗi plugin: " + err.message, { error: true });
    console.error("Plugin onmessage error:", err);
  }
};
