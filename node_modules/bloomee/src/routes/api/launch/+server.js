import { exec } from 'child_process';
import { json } from '@sveltejs/kit';
import { dev } from '$app/environment';
import fs from 'fs';
import path from 'path';

export async function GET() {
	if (!dev) {
		return json({ success: false, error: 'Not in development mode' });
	}

	// Dynamically determine the Flutter project root (containing pubspec.yaml)
	let flutterRoot = process.cwd();
	if (!fs.existsSync(path.join(flutterRoot, 'pubspec.yaml'))) {
		flutterRoot = path.resolve(flutterRoot, '..');
	}
	if (!fs.existsSync(path.join(flutterRoot, 'pubspec.yaml'))) {
		console.warn(`⚠️ Could not find pubspec.yaml in ${process.cwd()} or parent. Defaulting to cwd.`);
		flutterRoot = process.cwd();
	}

	console.log(`📂 Flutter project root resolved to: ${flutterRoot}`);

	return new Promise((resolve) => {
		console.log('🚀 Launching TejaBeats native desktop app...');
		
		const processRef = exec('flutter run -d windows', { cwd: flutterRoot });
		
		let errorOutput = '';
		let isResolved = false;

		const handleFailure = (message, details) => {
			if (isResolved) return;
			isResolved = true;
			try {
				if (processRef.pid) {
					console.log(`🧹 Killing process tree for PID ${processRef.pid}...`);
					exec(`taskkill /F /T /PID ${processRef.pid}`);
				} else {
					processRef.kill();
				}
			} catch (e) {
				// Ignore kill errors
			}
			resolve(json({ success: false, error: message, details }));
		};

		const handleSuccess = () => {
			if (isResolved) return;
			isResolved = true;
			console.log('✅ Native app compile/launch sequence successfully initiated.');
			resolve(json({ success: true }));
		};

		processRef.stdout?.on('data', (data) => {
			const str = data.toString();
			errorOutput += str;
			console.log(`[Flutter] ${str.trim()}`);

			if (str.includes('Unable to find suitable Visual Studio toolchain')) {
				handleFailure(
					'Visual Studio C++ build tools are missing. Please install the "Desktop development with C++" workload via the Visual Studio Installer.',
					errorOutput
				);
			} else if (str.includes('No supported devices found')) {
				handleFailure('No compatible Windows device found to run the application.', errorOutput);
			} else if (str.includes('Building Windows application') || str.includes('Syncing files to device')) {
				handleSuccess();
			}
		});

		processRef.stderr?.on('data', (data) => {
			const str = data.toString();
			errorOutput += str;
			console.error(`[Flutter Error] ${str.trim()}`);

			if (str.includes('Unable to find suitable Visual Studio toolchain') || str.includes('Visual Studio')) {
				handleFailure(
					'Visual Studio C++ build tools are missing. Please install the "Desktop development with C++" workload via the Visual Studio Installer.',
					errorOutput
				);
			}
		});

		processRef.on('exit', (code) => {
			if (isResolved) return;
			if (code !== 0 && code !== null) {
				console.error(`❌ Process exited with code ${code}`);
				let msg = 'Failed to compile or start the native application.';
				if (errorOutput.toLowerCase().includes('visual studio') || errorOutput.toLowerCase().includes('toolchain')) {
					msg = 'Visual Studio C++ build tools are missing. Please install the "Desktop development with C++" workload.';
				}
				handleFailure(msg, errorOutput);
			}
		});

		processRef.on('error', (err) => {
			handleFailure(`Process spawn error: ${err.message}`, err.message);
		});

		// Keep a safety timeout of 30 seconds. If it survives 30 seconds without exiting or printing failure,
		// it is definitely building the app in the background successfully.
		setTimeout(() => {
			if (!isResolved) {
				handleSuccess();
			}
		}, 30000);
	});
}
