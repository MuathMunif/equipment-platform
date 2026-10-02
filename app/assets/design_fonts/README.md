# Offline preview fonts

Downloaded 2026-10-01 from the official Google Fonts repository. Unmodified fonts, SIL Open Font License 1.1; respective OFL files are included (license whitespace normalized, wording unchanged).

- Noto Sans Arabic: https://github.com/google/fonts/tree/main/ofl/notosansarabic
- IBM Plex Sans Arabic Regular / SemiBold: https://github.com/google/fonts/tree/main/ofl/ibmplexsansarabic
- Noto Naskh Arabic (C headings): https://github.com/google/fonts/tree/main/ofl/notonaskharabic

Loaded by `main_design_preview.dart` only. No runtime font download, OS installation or dependency upgrade. Assets add approximately 1.64 MB uncompressed to the shared Flutter asset bundle; production typography is unchanged. Urdu rendering uses Noto Sans Arabic for body content (including B) rather than assuming Plex covers every Urdu glyph. Native Urdu linguistic review is pending.
