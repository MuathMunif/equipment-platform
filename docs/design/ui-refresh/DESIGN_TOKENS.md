# Tokens / typography

Experimental source: `app/lib/design_preview/tokens.dart`. `ThemeData`, `ColorScheme`, `TextTheme`, `DesignTokens` extension; shared `PreviewSurface`, `SectionHeading`, `PreviewRow`, `PreviewBadge`, `MoneyPreviewRow`, `AdaptiveColumns`.

| Token | A · Clear | B · Industrial | C · Warm |
|---|---|---|---|
| Canvas | `#F5F7F9` | `#F3F3EE` | `#F8F4ED` |
| Ink | `#182F40` | `#282F2E` | `#263E34` |
| Accent | `#1D4C65` | `#97451F` | `#315A43` |
| Muted text | `#536674` | `#59615D` | `#626A5E` |
| Tint | `#EAF1F5` | `#F3E9DD` | `#E9EEDF` |
| Divider | `#DDE4E9` | `#CFD3CB` | `#DEDCD0` |
| Radius | 12 | 4 | 22 |
| Section gap | 24 | 20 | 28 |
| Arabic body / heading | Noto Sans Arabic | IBM Plex Sans Arabic | Noto Sans Arabic / Noto Naskh Arabic |
| Heading | 30 / 600 | 30 / 600 | 36 / 600 |
| Character | white surfaces, quiet division | numbered sections, compact spacing, square corners | warm canvas, tinted grouping, softer headings |

Body 14, secondary 12, section title 16/600, title 20/600. Urdu uses Noto Sans Arabic in all directions with generous line height (1.6 for body). Figures use existing `localizedMoney`; date-only display uses existing `localizedDate`. The preview reuses `exactMoney` via a restricted import without constructing an API client.

Responsive: shell rail starts at 1000px; content columns at 780px and normal text scale. At 1.5+ text scale content stacks. Mobile padding 20, desktop 36; directional start/end layout. Buttons/icons have minimum 48px touch targets; primary button minimum height 50. No ellipsizing essential text.

OFL font sources/licenses: `app/assets/design_fonts/README.md`. No dependency upgrades. Preview fonts loaded only from the preview entry point; shared asset bundle grows by about 1.64 MB uncompressed. Production typography remains unchanged. Final production bundling strategy is part of the chosen-direction migration, not this exploration.

After independent review, interactive outlines use A `#7A8A93`, B `#7B847D`, C `#808878` (all >=3:1 against white, tested). Mobile expense title uses the 24px heading style, selected-equipment context is compact, and the attachment experiment is collapsible. Text scaling remains enabled.
