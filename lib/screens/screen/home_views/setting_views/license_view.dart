import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class TejaBeatsLicenseView extends StatelessWidget {
  const TejaBeatsLicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Default_Theme.primaryColor1),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Open Source Licenses',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF14101A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentPink.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/tejabeats_logo.png',
                      width: 64,
                      height: 64,
                      errorBuilder: (_, __, ___) => const Icon(
                        MingCute.music_2_fill,
                        size: 48,
                        color: AppTheme.accentPink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'TejaBeats',
                      style: TextStyle(
                        fontFamily: 'Unageo',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'YOUR MUSIC. YOUR BEATS. • v3.0.4',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.accentPink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Copyright © 2026 Teja. All rights reserved.\nLicensed under GNU General Public License v2.0 (GPL-2.0).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: TejaBeats Core License
              const _LicenseCard(
                title: 'TejaBeats (GPL-2.0)',
                subtitle: 'Core Application Software',
                licenseText: '''GNU GENERAL PUBLIC LICENSE
Version 2, June 1991

Copyright (C) 2026 Teja. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.''',
              ),

              const SizedBox(height: 16),

              // Section 2: Fonts
              const _LicenseCard(
                title: 'Unageo & Rethink Sans Fonts',
                subtitle: 'SIL Open Font License 1.1',
                licenseText: '''SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007

Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font Software,
subject to the conditions of the SIL Open Font License.''',
              ),

              const SizedBox(height: 16),

              // Section 3: Cargokit
              const _LicenseCard(
                title: 'Cargokit & Rust Bridge',
                subtitle: 'MIT License',
                licenseText: '''MIT License
Copyright (c) 2022 Matej Knopp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.''',
              ),

              const SizedBox(height: 16),

              // Section 4: FontAwesome & MingCute Icons
              const _LicenseCard(
                title: 'Font Awesome & MingCute Icons',
                subtitle: 'CC BY 4.0 / MIT License',
                licenseText: '''Font Awesome Free & MingCute Icons
Icons are licensed under CC BY 4.0 License and MIT License.
Code is licensed under the MIT License.''',
              ),

              const SizedBox(height: 16),

              // Section 5: Third-party Disclaimer
              const _LicenseCard(
                title: 'Third-Party Media & APIs Disclaimer',
                subtitle: 'Important Content Notice',
                licenseText: '''TejaBeats is an independent open-source music player client. TejaBeats does NOT host, store, stream, own, or license any music tracks, audio recordings, lyrics, artist photographs, or metadata.

All content, media streams, and trademarks accessed through external plugins and services (including YouTube, JioSaavn, YouTube Music, etc.) remain the exclusive intellectual property and copyright of their respective rights holders.''',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String licenseText;

  const _LicenseCard({
    required this.title,
    required this.subtitle,
    required this.licenseText,
  });

  @override
  State<_LicenseCard> createState() => _LicenseCardState();
}

class _LicenseCardState extends State<_LicenseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14101A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? MingCute.up_line : MingCute.down_line,
                      color: AppTheme.accentPink,
                      size: 20,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0910),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.licenseText,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
