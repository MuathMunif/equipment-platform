# Direction A typography comparison assets

Locally bundled font binaries, downloaded unmodified from the official [Google Fonts repository](https://github.com/google/fonts) at commit `9710da1eacb3be272583c3224dcb70f9da6eadbb`. No runtime font download, global installation, purchased font, or dependency upgrade.

| Option | Family / upstream directory | Bundled faces | Flutter loader alias | Locale mapping |
|---|---|---|---|---|
| F1 | [IBM Plex Sans Arabic](https://github.com/google/fonts/tree/9710da1eacb3be272583c3224dcb70f9da6eadbb/ofl/ibmplexsansarabic) | Regular400, Bold700 | ComparisonPlex | ar/en/ur and numbers |
| F2 | [Tajawal](https://github.com/google/fonts/tree/9710da1eacb3be272583c3224dcb70f9da6eadbb/ofl/tajawal) | Regular400, Bold700 | ComparisonTajawal | ar/en and numbers; entire ur locale uses ComparisonPlex |
| F3 | [Almarai](https://github.com/google/fonts/tree/9710da1eacb3be272583c3224dcb70f9da6eadbb/ofl/almarai) | Regular400, Bold700 | ComparisonAlmarai | ar/en/ur and numbers |

Each family's original `*-OFL.txt` (SIL Open Font License 1.1, including copyright notice) and `*-METADATA.pb` are included. `sources.json` records every original URL, byte count and SHA-256. The font binaries and metadata are unmodified. License wording/copyright notices are unchanged; trailing whitespace was removed from the three OFL files. The manifest records original and normalized hashes/sizes for those notices. The metadata lists upstream faces beyond the two downloaded here; those additional faces are not bundled or requested.

`app/lib/typography_preview/fonts.dart` loads both faces using Flutter `FontLoader` before `runApp`. Static OS/2 weight metadata is400/700, with no variable axes. Preview styles request only these two weights; existing Noto is a separately labelled rejected baseline. The owner subsequently selected F3. Production `EquipmentAlmarai` (Almarai400/700) and `EquipmentPlex` (Plex400/700, unsupported-character fallback only) are explicitly registered in pubspec and applied only to the Equipment Detail pilot via `design_system/equipment_typography.dart`. All three locales keep Almarai as their primary face. Preview aliases and F1/F2/reference assets remain available.

Run `python3 scripts/audit-typography-fonts.py` from the repository root. Its dependency-free sfnt/cmap audit is saved in `docs/design/ui-refresh/typography-font-audit.json`. Both Plex and Almarai contain all requested Urdu characters `ٹ ڈ ڑ ں ھ ہ ے پ چ ژ گ`. Tajawal contains only `پ` of that sample; therefore F2 uses Plex for the entire Urdu locale. A Plex missing-glyph fallback is also configured for mixed user text in all three candidates. The Urdu specimen embedded in an Arabic F2 screen can consequently contain fallback glyphs. Coverage and shaping tables are technical evidence, not Urdu linguistic approval or per-glyph runtime attribution.

The six font files total912,764 bytes. They are included in the shared Flutter asset bundle, so the production web build gains these bundled bytes; only the selected Almarai and fallback Plex are registered for production, with their use scoped to the pilot. The original comparison remains independently runnable. No new font bytes were added for the production integration. Existing `assets/design_fonts/` assets remain intact.
