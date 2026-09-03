# Notice & Modification Log

## Base Project Attribution

**TejaBeats** is an open-source derivative work based on and modified from **Bloomee** (also known as **BloomeeTunes**).

* **Original Author / Maintainer:** Hemant Kumar (@iamhemantindia) and Bloomee Contributors
* **Upstream Project:** [Bloomee](https://github.com/HemantKarya/BloomeeTunes)
* **Base License:** GNU General Public License Version 2.0 (GPL-2.0)
* **Original Copyright:** Copyright © 2024–2026 Hemant Kumar & Bloomee Contributors

All original copyright notices, license texts, and attribution from the Bloomee project have been preserved intact in accordance with Section 1 and Section 2 of the GNU GPL v2.0.

---

## TejaBeats Modifications

Pursuant to Section 2(a) of the GNU General Public License v2.0, the following prominent notice identifies modifications made in this derivative work:

* **Modifications Copyright:** Copyright © 2026 Teja
* **Derivative Project Repository:** [ktssr016-ux/TejaBeats](https://github.com/ktssr016-ux/TejaBeats)
* **Date of Modifications:** 2026

### Summary of Changes Made in TejaBeats:

1. **Branding & Visual Identity:**
   * Customized app branding, titles, strings, and theme aesthetic (`#0A060E` background with `#FF2D78` accent).
   * Added custom application icon and multi-resolution launcher assets (`assets/icons/tejabeats_logo.png`).
   * Updated About screen with TejaBeats identity while maintaining base attribution.

2. **Automated CI/CD & Multi-Platform Release Packaging:**
   * Built unified GitHub Actions release workflow (`.github/workflows/build_releases.yml`) for automated packaging of Windows desktop binaries and Android APKs.
   * Created Windows Inno Setup installer script (`installer.iss`) with GPL-2.0 license integration.
   * Configured Android release signing properties, Gradle packaging optimizations, and target SDK configurations.

3. **Application Updates & Maintenance:**
   * Updated in-app update checker (`lib/services/bloomee_updater_tools.dart`) to track official TejaBeats releases on GitHub (`ktssr016-ux/TejaBeats`).

4. **License Compliance & Open Source Attribution:**
   * Corrected license declarations across repository files to consistently specify GNU GPL v2.0.
   * Added `OPEN_SOURCE_LICENSES.md` detailing all Flutter, Rust, font, and toolchain dependencies.
   * Integrated in-app Open Source Licenses viewer accessible from Settings and About.
   * Clarified that GNU GPL v2.0 applies to the client source code and does not convey ownership of or rights to third-party streaming content or media APIs.
