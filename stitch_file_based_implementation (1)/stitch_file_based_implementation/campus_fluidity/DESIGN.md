---
name: Campus Fluidity
colors:
  surface: '#FFFFFF'
  surface-dim: '#ded7e4'
  surface-bright: '#fef7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f1fe'
  surface-container: '#f3ebf8'
  surface-container-high: '#ede5f2'
  surface-container-highest: '#e7e0ed'
  on-surface: '#1d1a23'
  on-surface-variant: '#48454f'
  inverse-surface: '#322f38'
  inverse-on-surface: '#f5eefb'
  outline: '#797580'
  outline-variant: '#c9c4d0'
  surface-tint: '#605691'
  primary: '#463c75'
  on-primary: '#ffffff'
  primary-container: '#5e548e'
  on-primary-container: '#d8cfff'
  inverse-primary: '#cabeff'
  secondary: '#625885'
  on-secondary: '#ffffff'
  secondary-container: '#d8cafe'
  on-secondary-container: '#5e5380'
  tertiary: '#4f3a6e'
  on-tertiary: '#ffffff'
  tertiary-container: '#685187'
  on-tertiary-container: '#e2caff'
  error: '#C65B5B'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e6deff'
  primary-fixed-dim: '#cabeff'
  on-primary-fixed: '#1c1149'
  on-primary-fixed-variant: '#483f77'
  secondary-fixed: '#e8deff'
  secondary-fixed-dim: '#ccbff3'
  on-secondary-fixed: '#1e143d'
  on-secondary-fixed-variant: '#4a406b'
  tertiary-fixed: '#eddcff'
  tertiary-fixed-dim: '#d6bbf9'
  on-tertiary-fixed: '#250f42'
  on-tertiary-fixed-variant: '#523c71'
  background: '#F8F6FA'
  on-background: '#1d1a23'
  surface-variant: '#e7e0ed'
  accent: '#BE95C4'
  light-accent: '#E0B1CB'
  secondary-text: '#706B78'
  border: '#E7E3EB'
  success: '#4E8B65'
typography:
  display:
    fontFamily: Be Vietnam Pro
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  display-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.005em
  headline-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 22px
  eyebrow:
    fontFamily: Be Vietnam Pro
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.08em
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
  code:
    fontFamily: Be Vietnam Pro
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1.25rem
  margin-lg: 1.5rem
  space-2xs: 0.25rem
  space-xs: 0.375rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
  space-3xl: 3rem
---

## Brand & Style

This design system establishes an editorial, spatial, and academically grounded visual language tailored for the campus community of FPT University Ho Chi Minh City. Moving away from generic template paradigms and corporate visual clutter, it treats student life, intellectual discovery, and cultural happenings with the craft of an editorial publication fused with spatial mobile interactions.

### Personality & Emotional Tenor
- **Academic & Contemporary:** Rooted in higher education yet tuned to contemporary student culture through sharp layout architectures and structured typographic authority.
- **Calm & Discerning:** Free of aggressive saturation, harsh gradients, or chaotic clutter. Whitespace and muted chromatic undertones establish focus and composure.
- **Spatial Precision:** Interfaces leverage optical depth, translucent floating controls, and crisp boundary highlights to let photography and campus cartography breathe beneath the UI.

### Design Movement: Liquid Glass & Editorial Spatiality
The aesthetic blends **Editorial Discovery** (asymmetric magazine-inspired grids, high-contrast headline sizing, chronological agenda structures, tactile digital ticket perforations) with **Apple-inspired Liquid Glass** (precision translucency, optical boundary refractions, and floating interactive controls). 

Liquid Glass is strictly functional: it serves as an interactive lens across navigation layers, dynamic sheet headers, floating search modules, and spatial toolbars. It is never applied to primary text cards, long-form content, or nested inside other translucent planes.

## Colors

The color system relies on an intentional distribution where the canvas remains light, clear, and quiet, allowing deep purple brand tonalities to serve as functional waypoints, selection cues, and structural markers.

### Core Architecture
- **Primary (`#5E548E`):** Used as an interactive signal. Dictates selected dates, active navigation indicators, campus map markers, and high-priority category badges.
- **Secondary / Deep Brand (`#231942`):** Grounding neutral tone used for high-contrast focal points, dark-theme modal headers, and primary iconography.
- **Tertiary (`#9F86C0`):** Supporting mid-tone accent used for secondary badges, subtle interactive states, and soft graphic motifs.
- **Neutral / Text (`#201D26`):** The primary typographic ink color, engineered for high contrast over light surfaces without the stark harshness of pure black.

### Canvas & Surface Hierarchy
- **Canvas (`#F8F6FA`):** The global viewport background. Purple is explicitly barred from serving as a global page canvas.
- **Surface (`#FFFFFF`):** High-opacity foundation for cards, sheets, ticket stubs, and editorial rows. Content is anchored on pure white to preserve legibility.
- **Border (`#E7E3EB`):** Ultra-subtle hairline framing for containers, ticket cutouts, and list dividers.

### Functional Glass Tinting
Translucent controls utilize `rgba(255, 255, 255, 0.72)` to `rgba(248, 246, 250, 0.85)` with a hairline highlight border (`rgba(255, 255, 255, 0.6)`) and ambient shadow tinting derived from `#231942`.

## Typography

The typography is built around **Be Vietnam Pro**, selected for its contemporary geometric clarity, humanist warmth, and first-class native rendering of complex Vietnamese tone marks and diacritics.

### Hierarchy & Style Directives
- **Eyebrow / Overline:** Set in uppercase with wide letter spacing (`0.08em`). Used exclusively for academic labels (e.g., `FPT UNIVERSITY HCMC`), date groupers (`12 THÁNG 10`), ticket identifiers, and event status markers.
- **Editorial Headlines (`display`, `headline-lg`):** Display sizes use tight letter tracking (`-0.02em` to `-0.01em`) and bold weights to anchor visual hierarchy against full-bleed imagery.
- **Body Rhythm:** `body-md` (14px) and `body-lg` (16px) balance generous line height (1.4–1.5x) to ensure extended event briefs, speaker profiles, and agenda summaries read cleanly without crowding.
- **Ticket Codes (`code`):** Employs regular-to-medium styling with wide tracking (`0.04em`) to establish visual structure on physical ticket replicas.

## Layout & Spacing

Layout geometry follows a flexible mobile viewport approach anchored by strict internal safe margins and systematic layout rhythms.

### Viewport & Canvas Layout
- **Mobile Foundation:** Single-column layout with fixed outer margins (`1.25rem` / 20px). Edge-to-edge photography breaks out into full-bleed sections with inner content aligned back to the primary margin track.
- **Floating Chrome Offset:** A permanent bottom padding clearance of `5.5rem` (88px) must be maintained across all scroll containers to ensure content scrolls beneath the floating Liquid Glass tab bar without collision.
- **Asymmetric Composition:** Prevents monotonous card stacks by pairing contrasting card scales:
  - *Featured Hero:* Full-width `350px × 220px` media frame.
  - *Dành Cho Bạn (Curated Pairings):* 60/40 asymmetric card clusters (one dominant visual card accompanied by a condensed secondary card).
  - *Editorial Row:* Horizontal list items with left-aligned typographic blocks and right-aligned thumbnail anchors.

### Touch Boundaries
All primary touch targets enforce an absolute minimum touch zone of `44px × 44px`, regardless of the optical size of the child icon or label.

## Elevation & Depth

Visual hierarchy uses optical layering: base canvas, white surface containers, and spatial Liquid Glass overlays.

### Liquid Glass Surface Specification
Liquid Glass acts as an interactive lens. It must never look flat or frosted white; instead, it preserves transparency, tint, and light refraction:
- **Fill:** `rgba(255, 255, 255, 0.76)` with CSS `backdrop-filter: blur(20px) saturate(180%)`.
- **Optical Rim:** A 1px top/lateral stroke: `linear-gradient(180deg, rgba(255, 255, 255, 0.8) 0%, rgba(255, 255, 255, 0.2) 100%)`.
- **Cast Shadow:** Soft, diffused ambient drop: `0 8px 32px -4px rgba(35, 25, 66, 0.08), 0 2px 8px -2px rgba(35, 25, 66, 0.04)`.
- **Application:** Reserved exclusively for the floating tab bar, top utility controls (back, share, search), floating map controls, interactive filter capsules, and contextual action sheets.

### Standard Surface Elevation
- **Level 0 (Flat Canvas):** `#F8F6FA` page background with zero shadow.
- **Level 1 (Card / Content Surface):** `#FFFFFF` fill with hairline outline `1px solid #E7E3EB`. Ambient lift: `0 2px 8px rgba(35, 25, 66, 0.03)`.
- **Level 2 (Ticket / Modal Card):** `#FFFFFF` fill with `0 12px 28px -6px rgba(35, 25, 66, 0.08)`.
- **Modal Scrim:** Contextual bottom sheets cast a dimming veil over the underlying canvas: `rgba(32, 29, 38, 0.45)` with `backdrop-filter: blur(4px)`.

## Shapes

The shape system balances architectural discipline with soft, tactile contours.

### Corner Radii Guidelines
- **Level 2 Standard (`roundedness: 2` = 0.5rem / 8px):** Structural cards, form fields, and agenda list items.
- **Large Containers (`rounded-lg` = 1rem / 16px):** Event featured cards, schedule blocks, and bottom sheet top boundaries.
- **Spatial Floating Surfaces (`rounded-xl` = 1.5rem / 24px):** Liquid Glass floating navigation bar and expanded search trays.
- **Full Pill (`rounded-full` = 9999px):** All interactive action triggers, category tags, calendar date selection rings, and circular utility buttons (`40px–44px`).

### Ticket Perforation Architecture
The digital admission ticket utilizes geometric punch-outs. Semi-circular cutouts (12px radius) indent symmetrically along the left and right borders at the junction between the event details and the QR code stub, bridged by a hairline dashed divider (`border-top: 1.5px dashed #E7E3EB`).

## Components

### Buttons & Interactive Triggers
- **Primary Floating Action ("Đăng ký tham gia"):** Pill-shaped (`rounded-full`), min-height `48px`. Gradient fill transitioning from `#5E548E` to `#4D4478`. Text is `label-md` white with an subtle inset highlight. Supports inline morphing into a circular loading spinner without shifting page layout.
- **Secondary Liquid Glass Control:** Circular `44px × 44px` or pill capsule. Background `rgba(255, 255, 255, 0.72)` with blur, framed in hairline white outline. Active states trigger a scale reduction (`transform: scale(0.96)`).
- **Destructive Action:** Low-saturation light red background (`rgba(198, 91, 91, 0.08)`) with `#C65B5B` text and icons.

### Navigation & Chrome
- **Floating Liquid Glass Tab Bar:** Floating centered container (`width: ~350px`, `height: 68px`, anchored 24px above viewport bottom). Features 4 primary destinations (Home, Khám phá, Vé của tôi, Cá nhân). Active states highlight icons in `#5E548E` with a micro dot indicator underneath.
- **Floating Search Capsule:** Liquid Glass pill with a search icon, placeholder text in `#706B78`, and a quick-filter icon button at the trailing edge. Tapping expands smoothly into a full-width header search input.

### Event Cards
- **Featured Card:** Full bleed media framing (`350px × 220px` aspect ratio) with high-contrast bottom gradient vignette. Overlaid with an `eyebrow` badge (`#5E548E` or Liquid Glass) at the top-left and primary event title in bold white at the bottom-left.
- **Editorial Asymmetric Card:** Pure `#FFFFFF` surface, `1px solid #E7E3EB` boundary, `16px` border-radius. Clean typographic hierarchy pairing event title, human-readable date/time, and campus location marker.

### Chips & Badges
- **Category Badge:** Semi-translucent Liquid Glass or soft accent fill (`#E0B1CB` at 25% opacity), pill-shaped, padding `4px 10px`. Text is `eyebrow` in `#5E548E`.
- **Status Badges:** Pill-shaped with status dots (e.g., `#4E8B65` for "Đã xác nhận", `#5E548E` for "Sắp diễn ra").

### Inputs & Form Elements
- **Field Shell:** Minimal `#FFFFFF` surface container with `1px solid #E7E3EB` border and `8px` corner radius. Focused state applies a `1.5px` border in `#5E548E` and a soft ambient glow (`rgba(94, 84, 142, 0.15)`).
- **Checkboxes & Radios:** Circular interactive elements with a `20px` diameter. Unselected: `1.5px solid #E7E3EB`. Selected: `#5E548E` background with a crisp white check vector.

### Campus Map Controls
- **Floating Map Action Cluster:** Vertically stacked Liquid Glass capsules positioned in the bottom-right viewport (Compass, Re-center, Floor Switcher).
- **Map Pins:** Circular `#5E548E` pins with pure white iconography and an ambient pulse indicator for real-time live events.

### Digital Ticket Stub
- **Physical Surface Metaphor:** `#FFFFFF` card with dual circular notch perforations and a dashed connecting rule. Top section hosts the event title, venue, and attendee name; bottom section holds an SVG QR code, ticket code in `code` styling, and check-in status.