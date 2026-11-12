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
  constructor(name, width = 1600, height = 1100) {
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
    const html = `<div style="font-family:Segoe UI, sans-serif; text-align:left; padding:4px 8px;">
      <div style="display:inline-block; font-size:10px; font-weight:800; color:#2563eb; background:#eff6ff; padding:3px 10px; border-radius:12px; margin-bottom:4px; border:1px solid #bfdbfe; letter-spacing:0.5px;">${escapeXml(tagText)}</div>
      <div style="font-size:19px; font-weight:800; color:#0f172a; line-height:1.2; letter-spacing:-0.2px;">${escapeXml(titleText)}</div>
      <div style="font-size:11px; color:#475569; margin-top:3px; font-weight:500;">${escapeXml(subtitleText)}</div>
    </div>`;
    this.cells.push(`
      <mxCell id="${id}" value="${escapeXml(html)}" style="text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;" vertex="1" parent="1">
        <mxGeometry x="40" y="15" width="1000" height="75" as="geometry" />
      </mxCell>
    `);
    return id;
  }

  addBox({ id, parent = '1', x, y, w, h, title, subtitle, details = [], style, colorTheme = 'blue', rx = 8 }) {
    const cellId = id || this.nextId();
    
    // Modern UI Color Palette with High Contrast & Clear Margins
    const themes = {
      slate:  { bg: '#f8fafc', border: '#64748b', headerColor: '#0f172a' },
      blue:   { bg: '#eff6ff', border: '#3b82f6', headerColor: '#1d4ed8' },
      green:  { bg: '#ecfdf5', border: '#10b981', headerColor: '#047857' },
      amber:  { bg: '#fffbeb', border: '#f59e0b', headerColor: '#b45309' },
      red:    { bg: '#fef2f2', border: '#ef4444', headerColor: '#b91c1c' },
      purple: { bg: '#faf5ff', border: '#8b5cf6', headerColor: '#6d28d9' },
      gray:   { bg: '#ffffff', border: '#94a3b8', headerColor: '#1e293b' }
    };
    const t = themes[colorTheme] || themes.blue;

    let detailsHtml = '';
    if (details && details.length > 0) {
      detailsHtml = '<div style="margin-top:6px; padding-top:6px; border-top:1px dashed ' + t.border + '; font-size:10px; color:#1e293b; line-height:1.45; word-break:break-word;">' +
        details.map(d => `<div style="margin-bottom:3px;">• ${escapeXml(d)}</div>`).join('') +
        '</div>';
    }

    let subtitleHtml = '';
    if (subtitle) {
      subtitleHtml = `<div style="font-size:10px; color:#475569; margin-top:2px; line-height:1.35; font-weight:500; word-break:break-word;">${escapeXml(subtitle)}</div>`;
    }

    const html = `<div style="font-family:Segoe UI, sans-serif; padding:8px 10px; text-align:left; box-sizing:border-box; width:100%; height:100%;">
      <div style="font-size:12px; font-weight:800; color:${t.headerColor}; line-height:1.3; word-break:break-word;">${escapeXml(title)}</div>
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
      slate:  { headerBg: '#0f172a', border: '#94a3b8', bodyBg: '#f8fafc' },
      blue:   { headerBg: '#1e40af', border: '#93c5fd', bodyBg: '#f8fafc' },
      purple: { headerBg: '#5b21b6', border: '#c4b5fd', bodyBg: '#f8fafc' },
      emerald:{ headerBg: '#065f46', border: '#6ee7b7', bodyBg: '#f8fafc' }
    };
    const t = themes[colorTheme] || themes.slate;

    const labelHtml = `<div style="font-family:Segoe UI, sans-serif; text-align:center; padding:6px 4px;">
      <div style="font-size:13px; font-weight:800; color:#ffffff; letter-spacing:0.5px;">${escapeXml(title)}</div>
      ${subtitle ? `<div style="font-size:10px; color:#e2e8f0; font-weight:400; margin-top:2px;">${escapeXml(subtitle)}</div>` : ''}
    </div>`;

    const style = `swimlane;startSize=46;horizontal=1;swimlaneFillColor=${t.bodyBg};fillColor=${t.headerBg};strokeColor=${t.border};strokeWidth=1.5;rounded=1;arcSize=6;html=1;whiteSpace=wrap;overflow=hidden;shadow=0;`;
    
    this.cells.push(`
      <mxCell id="${cellId}" value="${escapeXml(labelHtml)}" style="${style}" vertex="1" parent="1">
        <mxGeometry x="${x}" y="${y}" width="${w}" height="${h}" as="geometry" />
      </mxCell>
    `);
    return cellId;
  }

  addConnection({ source, target, label, style, color = '#334155', dashed = 0, strokeWidth = 1.5, exitX, exitY, entryX, entryY, offsetY = -14, offsetX = 0 }) {
    const id = this.nextId();
    let edgeStyle = `edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=${color};strokeWidth=${strokeWidth};dashed=${dashed};fontFamily=Segoe UI;fontSize=10;fontStyle=1;fontColor=#0f172a;labelBackgroundColor=#ffffff;labelBorderColor=#94a3b8;arcSize=4;`;
    if (exitX !== undefined) edgeStyle += `exitX=${exitX};exitY=${exitY};`;
    if (entryX !== undefined) edgeStyle += `entryX=${entryX};entryY=${entryY};`;

    const finalStyle = style || edgeStyle;
    const labelXml = label ? escapeXml(label) : '';

    this.cells.push(`
      <mxCell id="${id}" value="${labelXml}" style="${finalStyle}" edge="1" parent="1" source="${source}" target="${target}">
        <mxGeometry relative="1" as="geometry">
          <mxPoint as="offset" x="${offsetX}" y="${offsetY}" />
        </mxGeometry>
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
