import { exec } from 'child_process';
import { json } from '@sveltejs/kit';
import { dev } from '$app/environment';
import os from 'os';
import path from 'path';
import fs from 'fs';

export async function GET() {
	if (!dev) {
		return json({ success: false, error: 'Not in development mode' });
	}

	const prebuiltPath = path.join(
		os.homedir(),
		'Downloads',
		'bloomee_tunes_windows_x64_v3.0.4+202',
		'Bloomee.exe'
	);

	if (!fs.existsSync(prebuiltPath)) {
		return json({ success: false, error: 'Pre-built application not found in Downloads folder.' });
	}

	const prebuiltDir = path.dirname(prebuiltPath);
	console.log(`🚀 Launching pre-built app: ${prebuiltPath}`);

	return new Promise((resolve) => {
		exec('Bloomee.exe', { cwd: prebuiltDir }, (error) => {
			if (error) {
				console.error(`❌ Failed to run pre-built app: ${error.message}`);
				resolve(json({ success: false, error: error.message }));
			}
		});
		
		// Resolve success after 1 second of spawning
		setTimeout(() => {
			resolve(json({ success: true }));
		}, 1000);
	});
}
