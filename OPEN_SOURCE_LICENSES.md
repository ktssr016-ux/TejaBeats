# Open Source Licenses & Third-Party Dependencies

This document provides a comprehensive inventory of open-source licenses, third-party software libraries, tools, and font assets used in **TejaBeats**.

---

## 1. Core Application

* **Project:** TejaBeats (modified from Bloomee)
* **License:** GNU General Public License Version 2.0 (GPL-2.0)
* **Original Bloomee Code:** Copyright © 2024–2026 Hemant Kumar & Bloomee Contributors
* **TejaBeats Modifications:** Copyright © 2026 Teja
* **Full License Text:** See [LICENSE](LICENSE)

---

## 2. Build Tools & Embedded Subsystems

### Cargokit
* **Role:** Rust FFI build tool integration for Flutter
* **Copyright:** Copyright © 2022 Matej Knopp
* **License:** MIT License
* **License Text:** See `rust_builder/cargokit/LICENSE`

---

## 3. Flutter & Dart Dependencies

The following open-source Dart/Flutter packages are referenced in `pubspec.yaml`:

| Package | License | Copyright / Maintainer |
| :--- | :--- | :--- |
| `flutter` (SDK) | BSD-3-Clause | Google LLC |
| `flutter_localizations` | BSD-3-Clause | Google LLC |
| `intl` | BSD-3-Clause | Dart project authors |
| `device_info_plus` | BSD-3-Clause | Flutter Community |
| `equatable` | MIT | Felix Angelov |
| `icons_plus` | MIT | Font Awesome & Icon authors / icons_plus maintainers |
| `cached_network_image` | Apache-2.0 | Rene Floor |
| `flutter_bloc` / `bloc` | MIT | Felix Angelov |
| `dart_des` | MIT | Dart DES contributors |
| `http` | BSD-3-Clause | Dart project authors |
| `archive` | Apache-2.0 | Brendan Duncan |
| `convert` | BSD-3-Clause | Dart project authors |
| `html` | BSD-3-Clause | Dart project authors |
| `google_nav_bar` | MIT | Sooxt98 |
| `carousel_slider` | MIT | serenader |
| `palette_generator` | BSD-3-Clause | Flutter Authors |
| `rxdart` | Apache-2.0 | ReactiveX / RxDart contributors |
| `go_router` | BSD-3-Clause | Flutter Authors |
| `easy_debounce` | MIT | roipeker |
| `isar_community` / `isar_community_flutter_libs` | Apache-2.0 | Simon Leier & Isar Community |
| `path_provider` | BSD-3-Clause | Flutter Authors |
| `path` | BSD-3-Clause | Dart project authors |
| `modal_bottom_sheet` | MIT | Jaime Blasco |
| `html_unescape` | MIT | Maciej Chałapuk |
| `marquee` | MIT | Marcel Garus |
| `string_similarity` | MIT | Akash Khandelwal |
| `package_info_plus` | BSD-3-Clause | Flutter Community |
| `url_launcher` | BSD-3-Clause | Flutter Authors |
| `badges` | Apache-2.0 | Gianfranco Boi |
| `flutter_displaymode` | MIT | Flutter Community |
| `country_codes` | MIT | Miguel R. |
| `connectivity_plus` | BSD-3-Clause | Flutter Community |
| `share_plus` | BSD-3-Clause | Flutter Community |
| `file_picker` | MIT | Miguel Ruivo |
| `fuzzywuzzy` | MIT | FuzzyWuzzy contributors |
| `numberpicker` | MIT | Marcin Szałek |
| `permission_handler` | MIT | Baseflow |
| `share_handler` | MIT | Alexey Kiselev |
| `sliding_up_panel` | MIT | Akshath Jain |
| `responsive_framework` | Apache-2.0 | Codelessly |
| `scrollable_positioned_list` | Apache-2.0 | Google LLC |
| `crypto` | BSD-3-Clause | Dart project authors |
| `dart_discord_rpc` | MIT | Dart Discord RPC contributors |
| `mime` | BSD-3-Clause | Dart project authors |
| `photo_manager` | MIT | CaiJingLong |
| `audio_service` | MIT | Ryan Heise |
| `audio_session` | MIT | Ryan Heise |
| `media_kit` / `media_kit_libs_audio` | MIT / LGPL-2.1+ | Hitesh Kumar Saini (alexmercerind) / mpv contributors |
| `audio_service_mpris` | MIT | Ryan Heise |
| `audio_service_win` | MIT | Audio Service Win contributors |
| `flutter_rust_bridge` | MIT / Apache-2.0 | Desdaemon & flutter_rust_bridge contributors |
| `freezed_annotation` | MIT | Remi Rousselet |
| `async` | BSD-3-Clause | Dart project authors |

---

## 4. Rust Crates

The following crates are compiled into the native Rust bridge (`rust_lib_Bloomee`):

| Crate | License | Purpose |
| :--- | :--- | :--- |
| `flutter_rust_bridge` | MIT / Apache-2.0 | Dart-Rust interop bindings |
| `anyhow` | MIT / Apache-2.0 | Error handling framework |
| `once_cell` | MIT / Apache-2.0 | Lazy static initialization |
| `serde` / `serde_json` | MIT / Apache-2.0 | Serialization & deserialization |
| `tokio` | MIT | Asynchronous runtime |
| `wasm_runtime_layer` | MIT / Apache-2.0 | Generic WebAssembly runtime abstraction |
| `wasmi_runtime_layer` | MIT / Apache-2.0 | WASM interpreter backend |
| `chrono` | MIT / Apache-2.0 | Date and time utilities |
| `waclay` | MIT | WASM component tools |
| `reqwest` | MIT / Apache-2.0 | HTTP client |
| `tar` | MIT / Apache-2.0 | TAR archive parser |
| `zstd` | BSD-3-Clause / MIT | Zstandard compression |
| `base64` | MIT / Apache-2.0 | Base64 encoding/decoding |
| `rand` | MIT / Apache-2.0 | Random number generation |
| `url` | MIT / Apache-2.0 | URL parsing & manipulation |
| `tracing` | MIT | Application instrumentation & logging |
| `lofty` | MIT / Apache-2.0 | Audio metadata tagging library |
| `sha2` | MIT / Apache-2.0 | Cryptographic hash functions |
| `image` | MIT / Apache-2.0 | Image decoding/encoding |

---

## 5. Bundled Fonts & Typography

The font assets bundled in `assets/fonts/` are subject to the following licenses:

* **Unageo**: SIL Open Font License 1.1 (Copyright © 2023 Unacross). See `assets/fonts/Unageo/OFL.txt`.
* **Rethink Sans**: SIL Open Font License 1.1 (Copyright © 2023 Rethink). See `assets/fonts/ReThinkSans/OFL.txt`.
* **Noto Sans**: SIL Open Font License 1.1 (Copyright © 2022 The Noto Project Authors).
* **Fjalla One**: SIL Open Font License 1.1 (Copyright © 2012 Sorkin Type Co).
* **Font Awesome Free (v6.4.0)**:
  * Font Files: SIL Open Font License 1.1
  * Code: MIT License
  * Icons (SVG): Creative Commons Attribution 4.0 International (CC BY 4.0)
  * Full notice: `assets/fonts/fontawesome-free-6.4.0-desktop/LICENSE.txt`.
* **Segoe Fluent Icons**:
  * Licensed under Microsoft EULA for Windows platform development. See `assets/fonts/SegoeFluentIcons/EULA.txt`.
* **Gilroy & Code Pro**:
  * Font assets bundled from upstream Bloomee repository. Retained under their original terms.

---

## 6. Important Disclaimer on Third-Party Media & Services

* The software licenses documented above cover the **application code, compiled binaries, libraries, and open-source assets**.
* They do **not** grant rights, titles, or permissions to any copyrighted music tracks, audio streams, lyrics, artist cover art, or metadata accessed via user search or third-party plugins.
* All external media and trademarks accessed via YouTube, JioSaavn, YouTube Music, or any other external service remain the proprietary intellectual property of their respective copyright owners.
