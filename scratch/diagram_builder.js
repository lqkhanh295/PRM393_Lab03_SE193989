const fs = require('fs');
const path = require('path');

function escapeXml(unsafe) {
  if (typeof unsafe !== 'string') return '';
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

class DiagramBuilder {
  constructor(name, width = 1400, height = 950) {
    this.name = name;
    this.width = width;
    this.height = height;
    this.cells = [];
    this.idCounter = 1;

    // Root elements required by Draw.io
    this.cells.push('<mxCell id="0" />');
    this.cells.push('<mxCell id="1" parent="0" />');
  }

  nextId() {
    return 'cell_' + (this.idCounter++);
  }

  addTitle(titleText, subtitleText, tagText = 'PRM393 - CAMPUS EVENT') {
    const id = this.nextId();
    const html = `<div style="font-family:Segoe UI, sans-serif; text-align:left; padding:8px 12px;">
      <div style="display:inline-block; font-size:10px; font-weight:700; color:#2563eb; background:#eff6ff; padding:2px 8px; border-radius:12px; margin-bottom:4px; border:1px solid #bfdbfe;">${escapeXml(tagText)}</div>
      <div style="font-size:18px; font-weight:800; color:#0f172a; line-height:1.2;">${escapeXml(titleText)}</div>
      <div style="font-size:11px; color:#64748b; margin-top:2px;">${escapeXml(subtitleText)}</div>
    </div>`;
    this.cells.push(`
      <mxCell id="${id}" value="${escapeXml(html)}" style="text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;" vertex="1" parent="1">
        <mxGeometry x="40" y="20" width="700" height="65" as="geometry" />
      </mxCell>
    `);
    return id;
  }

  addBox({ id, parent = '1', x, y, w, h, title, subtitle, details = [], style, colorTheme = 'blue', rx = 8 }) {
    const cellId = id || this.nextId();
    
    // Modern UI Color Palette
    const themes = {
      slate:  { bg: '#f8fafc', border: '#94a3b8', headerBg: '#0f172a', headerColor: '#ffffff', pillBg: '#e2e8f0', pillColor: '#334155' },
      blue:   { bg: '#eff6ff', border: '#60a5fa', headerBg: '#2563eb', headerColor: '#ffffff', pillBg: '#dbeafe', pillColor: '#1d4ed8' },
      green:  { bg: '#ecfdf5', border: '#34d399', headerBg: '#059669', headerColor: '#ffffff', pillBg: '#d1fae5', pillColor: '#065f46' },
      amber:  { bg: '#fffbeb', border: '#fbbf24', headerBg: '#d97706', headerColor: '#ffffff', pillBg: '#fef3c7', pillColor: '#92400e' },
      red:    { bg: '#fef2f2', border: '#f87171', headerBg: '#dc2626', headerColor: '#ffffff', pillBg: '#fee2e2', pillColor: '#991b1b' },
      purple: { bg: '#faf5ff', border: '#c084fc', headerBg: '#7c3aed', headerColor: '#ffffff', pillBg: '#ede9fe', pillColor: '#5b21b6' },
      gray:   { bg: '#ffffff', border: '#cbd5e1', headerBg: '#334155', headerColor: '#ffffff', pillBg: '#f1f5f9', pillColor: '#475569' }
    };
    const t = themes[colorTheme] || themes.blue;

    let detailsHtml = '';
    if (details && details.length > 0) {
      detailsHtml = '<div style="margin-top:6px; padding-top:6px; border-top:1px dashed ' + t.border + '; font-size:10px; color:#334155; line-height:1.4;">' +
        details.map(d => `<div style="margin-bottom:2px;">• ${escapeXml(d)}</div>`).join('') +
        '</div>';
    }

    let subtitleHtml = '';
    if (subtitle) {
      subtitleHtml = `<div style="font-size:10px; color:#475569; margin-top:2px; line-height:1.3;">${escapeXml(subtitle)}</div>`;
    }

    const html = `<div style="font-family:Segoe UI, sans-serif; padding:10px; text-align:left; box-sizing:border-box;">
      <div style="font-size:12px; font-weight:700; color:#0f172a; line-height:1.3;">${escapeXml(title)}</div>
      ${subtitleHtml}
      ${detailsHtml}
    </div>`;

    const defaultStyle = `rounded=1;arcSize=${rx};whiteSpace=wrap;html=1;overflow=hidden;fillColor=${t.bg};strokeColor=${t.border};strokeWidth=1.5;shadow=0;verticalAlign=top;align=left;`;
    const finalStyle = style || defaultStyle;

    this.cells.push(`
      <mxCell id="${cellId}" value="${escapeXml(html)}" style="${finalStyle}" vertex="1" parent="${parent}">
        <mxGeometry x="${x}" y="${y}" width="${w}" height="${h}" as="geometry" />
      </mxCell>
    `);
    return cellId;
  }

  addSwimlane({ id, x, y, w, h, title, subtitle, colorTheme = 'slate' }) {
    const cellId = id || this.nextId();
    const themes = {
      slate:  { headerBg: '#1e293b', border: '#cbd5e1', bodyBg: '#f8fafc' },
      blue:   { headerBg: '#1d4ed8', border: '#bfdbfe', bodyBg: '#f8fafc' },
      purple: { headerBg: '#6d28d9', border: '#ddd6fe', bodyBg: '#f8fafc' },
      emerald:{ headerBg: '#047857', border: '#a7f3d0', bodyBg: '#f8fafc' }
    };
    const t = themes[colorTheme] || themes.slate;

    const labelHtml = `<div style="font-family:Segoe UI, sans-serif; text-align:center; padding:6px 4px;">
      <div style="font-size:13px; font-weight:800; color:#ffffff; letter-spacing:0.5px;">${escapeXml(title)}</div>
      ${subtitle ? `<div style="font-size:10px; color:#e2e8f0; font-weight:400; margin-top:2px;">${escapeXml(subtitle)}</div>` : ''}
    </div>`;

    const style = `swimlane;startSize=44;horizontal=1;swimlaneFillColor=${t.bodyBg};fillColor=${t.headerBg};strokeColor=${t.border};strokeWidth=1.5;rounded=1;arcSize=6;html=1;whiteSpace=wrap;overflow=hidden;shadow=0;`;
    
    this.cells.push(`
      <mxCell id="${cellId}" value="${escapeXml(labelHtml)}" style="${style}" vertex="1" parent="1">
        <mxGeometry x="${x}" y="${y}" width="${w}" height="${h}" as="geometry" />
      </mxCell>
    `);
    return cellId;
  }

  addConnection({ source, target, label, style, color = '#475569', dashed = 0, strokeWidth = 1.5, exitX, exitY, entryX, entryY }) {
    const id = this.nextId();
    let edgeStyle = `edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=${color};strokeWidth=${strokeWidth};dashed=${dashed};fontFamily=Segoe UI;fontSize=10;fontColor=#1e293b;`;
    if (exitX !== undefined) edgeStyle += `exitX=${exitX};exitY=${exitY};`;
    if (entryX !== undefined) edgeStyle += `entryX=${entryX};entryY=${entryY};`;

    const finalStyle = style || edgeStyle;
    const labelXml = label ? escapeXml(label) : '';

    this.cells.push(`
      <mxCell id="${id}" value="${labelXml}" style="${finalStyle}" edge="1" parent="1" source="${source}" target="${target}">
        <mxGeometry relative="1" as="geometry" />
      </mxCell>
    `);
    return id;
  }

  addRuleBadge({ x, y, w = 110, h = 26, code, text, type = 'rule' }) {
    const id = this.nextId();
    const colors = {
      rule: { bg: '#fef3c7', border: '#f59e0b', color: '#92400e' },
      guard: { bg: '#fee2e2', border: '#ef4444', color: '#991b1b' },
      info: { bg: '#e0e7ff', border: '#6366f1', color: '#3730a3' }
    };
    const c = colors[type] || colors.rule;
    const html = `<div style="font-family:Segoe UI, sans-serif; font-size:10px; font-weight:700; color:${c.color}; text-align:center; line-height:24px;">
      <span style="background:${c.border}; color:#ffffff; padding:1px 5px; border-radius:4px; margin-right:4px;">${escapeXml(code)}</span>${escapeXml(text)}
    </div>`;

    this.cells.push(`
      <mxCell id="${id}" value="${escapeXml(html)}" style="rounded=1;whiteSpace=wrap;html=1;fillColor=${c.bg};strokeColor=${c.border};strokeWidth=1;shadow=0;" vertex="1" parent="1">
        <mxGeometry x="${x}" y="${y}" width="${w}" height="${h}" as="geometry" />
      </mxCell>
    `);
    return id;
  }

  toXml() {
    return `<diagram id="${this.name.replace(/\s+/g, '_')}" name="${this.name}">
  <mxGraphModel dx="${this.width}" dy="${this.height}" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="${this.width}" pageHeight="${this.height}" background="#ffffff">
    <root>
      ${this.cells.join('\n      ')}
    </root>
  </mxGraphModel>
</diagram>`;
  }
}

module.exports = { DiagramBuilder, escapeXml };
