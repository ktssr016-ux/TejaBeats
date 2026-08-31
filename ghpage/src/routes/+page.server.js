import { dev } from '$app/environment';
import os from 'os';
import path from 'path';
import fs from 'fs';

/** @type {import('./$types').PageServerLoad} */
export async function load() {
	const prebuiltPath = path.join(
		os.homedir(),
		'Downloads',
		'bloomee_tunes_windows_x64_v3.0.4+202',
		'Bloomee.exe'
	);
	const hasPrebuilt = fs.existsSync(prebuiltPath);
	
	// Check if Visual Studio installer is present
	const hasVisualStudio = fs.existsSync('C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe');

	return {
		isDev: dev,
		hasPrebuilt,
		hasVisualStudio
	};
}
