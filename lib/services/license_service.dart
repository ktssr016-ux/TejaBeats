import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service responsible for managing open-source software license registration
/// and presentation within TejaBeats.
class LicenseService {
  static bool _registered = false;

  /// Registers custom licenses (TejaBeats, Bloomee, Cargokit, Fonts) into
  /// Flutter's native [LicenseRegistry] so they appear in [showLicensePage].
  static void registerCustomLicenses() {
    if (_registered) return;
    _registered = true;

    LicenseRegistry.addLicense(() async* {
      // Core Application License
      yield const LicenseEntryWithLineBreaks(
        ['TejaBeats (Derivative Work)'],
        '''GNU General Public License Version 2.0 (GPL-2.0)

Copyright (C) 2026 Teja. All modifications.
Based on Bloomee: Copyright (C) 2024-2026 Hemant Kumar & Bloomee Contributors.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.''',
      );

      // Base Project Notice
      yield const LicenseEntryWithLineBreaks(
        ['Bloomee (Base Project)'],
        '''Original Base Project: Bloomee / BloomeeTunes
Author: Hemant Kumar (@iamhemantindia) and Bloomee Contributors
Upstream: https://github.com/HemantKarya/BloomeeTunes
License: GNU General Public License v2.0 (GPL-2.0)
Copyright (C) 2024-2026 Hemant Kumar & Bloomee Contributors

All original Bloomee copyright and license notices are retained intact.''',
      );

      // Cargokit Build Tool
      yield const LicenseEntryWithLineBreaks(
        ['cargokit'],
        '''MIT License

Copyright (c) 2022 Matej Knopp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''',
      );

      // Typography - Unageo
      yield const LicenseEntryWithLineBreaks(
        ['Unageo Font'],
        '''SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
Copyright (c) 2023, Unacross (https://unacross.art), with Reserved Font Name "Unageo".

Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font Software,
subject to the conditions of the SIL Open Font License.''',
      );

      // Typography - Rethink Sans
      yield const LicenseEntryWithLineBreaks(
        ['Rethink Sans Font'],
        '''SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
Copyright 2023 The Rethink Sans Project Authors (https://github.com/hanspagel/rethink-sans).

Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font Software,
subject to the conditions of the SIL Open Font License.''',
      );

      // Font Awesome Free
      yield const LicenseEntryWithLineBreaks(
        ['Font Awesome Free (v6.4.0)'],
        '''Font Awesome Free License
Font Awesome Free is free, open source, and GPL friendly.
- Font files: Licensed under SIL OFL 1.1 (http://scripts.sil.org/OFL)
- Code: Licensed under the MIT License (https://opensource.org/licenses/MIT)
- Icons: Licensed under CC BY 4.0 License (https://creativecommons.org/licenses/by/4.0/)
Copyright (c) 2023 Fonticons, Inc.''',
      );

      // Media and Provider Disclaimer
      yield const LicenseEntryWithLineBreaks(
        ['Third-Party Media & Services Disclaimer'],
        '''Important Disclaimer Regarding Music, Media Streams, & APIs:

TejaBeats is an independent open-source music player client. TejaBeats
does NOT host, store, stream, own, or license any music tracks, audio
recordings, lyrics, artist photographs, or metadata.

All content, media streams, and trademarks accessed through external plugins
and services (including YouTube, JioSaavn, YouTube Music, etc.) remain the
exclusive intellectual property and copyright of their respective rights holders.

The GNU General Public License v2.0 applies solely to the software source
code of TejaBeats and grants no rights or licenses to third-party media content
or proprietary service APIs.''',
      );
    });
  }

  /// Displays the full open-source license viewer.
  static void openLicenses(BuildContext context) {
    registerCustomLicenses();
    showLicensePage(
      context: context,
      applicationName: 'TejaBeats',
      applicationVersion: '3.0.4',
      applicationLegalese:
          'Licensed under GNU General Public License v2.0 (GPL-2.0).\n'
          'Based on Bloomee by Hemant Kumar & Contributors.\n'
          'TejaBeats modifications Copyright © 2026 Teja.',
      applicationIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.asset(
          'assets/icons/tejabeats_logo.png',
          width: 56,
          height: 56,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.music_note_rounded,
            size: 48,
            color: Color(0xFFFF2D78),
          ),
        ),
      ),
    );
  }
}
