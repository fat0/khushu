# Dome Header — Design Specification

## Approved Layout (2026-04-04)

This document captures the exact positioning and sizing of the dome header so it doesn't need to be re-iterated.

## Implementation

Use the SVG file at `assets/images/dome.svg` (copied from `image_ref/Minimalist mosque with crescent moon.svg`). Do NOT use CustomPaint — the SVG asset is the source of truth.

## Sizing & Positioning (relative to container)

### Localhost (browser) values
| Property | Value |
|----------|-------|
| SVG width | 720px |
| SVG height | 480px |
| Text block top | 255px (~53% of SVG height) |

### Flutter (phone) values — APPROVED 2026-04-04
| Property | Value | Code |
|----------|-------|------|
| SVG display width | `screenWidth * 1.5` | Wider than screen, minarets at edges |
| SVG display height | `svgDisplayWidth / 1.5` | Natural aspect ratio |
| Container height | `svgDisplayHeight * 0.75` | Crop empty bottom 25% |
| Text top offset | `containerHeight * 0.70` | Centers text in dome belly |
| SVG fit | `BoxFit.fill` | Forces SVG to fill dimensions |
| SVG positioned left | `-(svgDisplayWidth - screenWidth) / 2` | Centers wider SVG |
| Container clip | `ClipRect` | Clips overflow |
| Text alignment | Center horizontal | All three lines centered |

## Text Block (inside dome)

| Element | Font Size | Color (Light) | Color (Dark) | Spacing |
|---------|-----------|---------------|--------------|---------|
| KHUSHU | 18px, weight 600, letter-spacing 3px | #3D5A3A (deepGreen) | #A8C5A0 (sage) | — |
| Location | 14px, weight 400 | #8A8275 (lightSecondary) | #6B6B62 (darkSecondary) | margin-top: 8px |
| Date | 13px, weight 400 | #A8C5A0 (sage) | #A8C5A0 (sage) | margin-top: 5px |

## SVG Color Tinting

| Mode | Fill Color | Opacity |
|------|-----------|---------|
| Light | #3D5A3A (deepGreen) | 0.45 |
| Dark | #A8C5A0 (sage) | 0.32 |

Use `ColorFilter.mode(color, BlendMode.srcIn)` in Flutter's `SvgPicture` to tint.

## Flutter Implementation

```dart
SvgPicture.asset(
  'assets/images/dome.svg',
  height: 120,  // adjust for phone screen — dome should take ~30% of screen height
  colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
)
```

Text is overlaid using a `Stack` with the text `Positioned` at ~53% from the top of the dome container.

## Key Rule

**The date line must align with the bottom edge of the dome arc.** If the dome size changes, adjust the text position so the last line of text sits at the dome's bottom edge.
