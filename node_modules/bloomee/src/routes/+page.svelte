<script>
	import { onMount } from 'svelte';
	import logo from '$lib/assets/tejabeats_logo.png';
	
	export let data;

	let status = "Launching TejaBeats...";
	let subStatus = "Building and launching your native desktop player...";
	let loading = true;
	let error = null;
	let details = "";

	async function launchApp() {
		loading = true;
		error = null;
		status = "Launching TejaBeats...";
		subStatus = "Building and launching your native desktop player...";

		try {
			const res = await fetch('/api/launch');
			const result = await res.json();
			if (result.success) {
				status = "TejaBeats Launched!";
				subStatus = "The native desktop app has been started. You can close this browser tab.";
				loading = false;
			} else {
				status = "Launch Failed";
				subStatus = result.error;
				error = result.error;
				details = result.details || "";
				loading = false;
			}
		} catch (e) {
			status = "Connection Error";
			subStatus = "Failed to communicate with the local SvelteKit server.";
			error = "Server Connection Failed";
			loading = false;
		}
	}

	async function launchPrebuilt() {
		loading = true;
		error = null;
		status = "Launching Pre-built App...";
		subStatus = "Opening the pre-compiled native desktop player...";

		try {
			const res = await fetch('/api/launch-prebuilt');
			const result = await res.json();
			if (result.success) {
				status = "TejaBeats Launched!";
				subStatus = "The pre-built app has been started. You can close this browser tab.";
				loading = false;
			} else {
				status = "Launch Failed";
				subStatus = result.error;
				error = result.error;
				loading = false;
			}
		} catch (e) {
			status = "Connection Error";
			subStatus = "Failed to communicate with the local SvelteKit server.";
			error = "Server Connection Failed";
			loading = false;
		}
	}

	onMount(() => {
		if (data.isDev) {
			if (data.hasVisualStudio) {
				launchApp();
			} else {
				status = "Launch Failed";
				subStatus = "Visual Studio C++ build tools are missing. Please install the \"Desktop development with C++\" workload.";
				error = subStatus;
				details = "Error: Unable to find suitable Visual Studio toolchain. Please run `flutter doctor` for more details.";
				loading = false;
			}
		} else {
			status = "Production Mode";
			subStatus = "The app launcher only runs in local development mode.";
			loading = false;
		}
	});
</script>

<svelte:head>
	<title>TejaBeats Launcher</title>
</svelte:head>

<div class="launcher-container">
	<div class="glow-bg" class:error-glow={error}></div>
	<div class="content-box">
		<img src={logo} alt="TejaBeats" class="logo" />
		
		{#if loading}
			<div class="spinner-container">
				<div class="spinner"></div>
				<div class="spinner-glow"></div>
			</div>
			<p class="status">{status}</p>
			<p class="substatus">{subStatus}</p>
		{:else if error}
			<div class="error-container">
				<div class="error-icon">⚠️</div>
				<p class="status error-text">{status}</p>
				<p class="substatus error-subtext">{subStatus}</p>
				
				{#if data.hasPrebuilt}
					<div class="suggestion-box prebuilt-box">
						<h3>Alternative: Run Pre-built Version</h3>
						<p>I found a pre-compiled version of the application in your Downloads folder. You can launch it directly, but note that it uses the older layout (without the redesigned fullscreen player and mini player UI changes).</p>
						<button on:click={launchPrebuilt} class="btn btn-success-grad">
							Launch Pre-built Version (Older UI)
						</button>
					</div>
				{/if}

				{#if details && details.includes('Visual Studio')}
					<div class="suggestion-box">
						<h3>Required Action to Enable Redesigned UI:</h3>
						<p>You need to install Visual Studio C++ build tools to compile and run the Windows desktop application.</p>
						<ol>
							<li>Download Visual Studio Installer from the link below.</li>
							<li>Choose <strong>Desktop development with C++</strong> workload.</li>
							<li>Keep default components checked and click Install.</li>
						</ol>
						<a href="https://visualstudio.microsoft.com/downloads/" target="_blank" rel="noopener noreferrer" class="btn btn-primary">
							Download Visual Studio
						</a>
					</div>
				{/if}

				{#if details}
					<details class="details-box">
						<summary>View Technical Details</summary>
						<pre>{details}</pre>
					</details>
				{/if}

				<button on:click={launchApp} class="btn btn-secondary">
					Retry Native Build & Launch
				</button>
			</div>
		{:else}
			<div class="success-container">
				<div class="success-icon">✓</div>
				<p class="status success-text">{status}</p>
				<p class="substatus">{subStatus}</p>
			</div>
		{/if}
	</div>
</div>

<style>
	:global(body) {
		background-color: #080206;
		color: #ffffff;
		margin: 0;
		font-family: 'Inter', system-ui, -apple-system, sans-serif;
		overflow-x: hidden;
	}

	.launcher-container {
		display: flex;
		align-items: center;
		justify-content: center;
		min-height: 100vh;
		width: 100vw;
		position: relative;
		background: radial-gradient(circle at center, rgba(236, 72, 153, 0.03) 0%, transparent 80%);
		padding: 2rem 0;
		box-sizing: border-box;
	}

	.glow-bg {
		position: absolute;
		width: 300px;
		height: 300px;
		background: #ec4899;
		filter: blur(150px);
		opacity: 0.15;
		z-index: 1;
		animation: pulse 4s ease-in-out infinite alternate;
	}

	.glow-bg.error-glow {
		background: #ef4444;
	}

	@keyframes pulse {
		0% { transform: scale(1); opacity: 0.12; }
		100% { transform: scale(1.2); opacity: 0.2; }
	}

	.content-box {
		display: flex;
		flex-direction: column;
		align-items: center;
		text-align: center;
		z-index: 10;
		padding: 2rem;
		width: 100%;
		max-width: 600px;
		box-sizing: border-box;
	}

	.logo {
		width: 160px;
		height: 160px;
		object-fit: contain;
		margin: 0 0 2rem 0;
		filter: drop-shadow(0 0 30px rgba(236, 72, 153, 0.45));
		animation: logoFloat 4s ease-in-out infinite alternate;
	}

	@keyframes logoFloat {
		0% { transform: translateY(0px); filter: drop-shadow(0 0 25px rgba(236, 72, 153, 0.4)); }
		100% { transform: translateY(-8px); filter: drop-shadow(0 0 45px rgba(236, 72, 153, 0.65)); }
	}

	.spinner-container {
		position: relative;
		width: 64px;
		height: 64px;
		margin-bottom: 2rem;
	}

	.spinner {
		width: 100%;
		height: 100%;
		border: 4px solid rgba(255, 255, 255, 0.05);
		border-left-color: #ec4899;
		border-right-color: #8b5cf6;
		border-radius: 50%;
		animation: spin 1s cubic-bezier(0.5, 0.1, 0.4, 0.9) infinite;
	}

	.spinner-glow {
		position: absolute;
		inset: -8px;
		border: 4px solid transparent;
		border-left-color: rgba(236, 72, 153, 0.3);
		border-radius: 50%;
		filter: blur(4px);
		animation: spin 1.5s linear infinite;
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}

	.error-container, .success-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		width: 100%;
	}

	.error-icon {
		font-size: 3rem;
		margin-bottom: 1rem;
		text-shadow: 0 0 20px rgba(239, 68, 68, 0.5);
	}

	.success-icon {
		font-size: 3rem;
		margin-bottom: 1rem;
		color: #10b981;
		text-shadow: 0 0 20px rgba(16, 185, 129, 0.5);
	}

	.status {
		font-size: 1.4rem;
		font-weight: 700;
		margin: 0 0 0.5rem 0;
		letter-spacing: -0.2px;
	}

	.error-text {
		color: #ef4444;
	}

	.success-text {
		color: #10b981;
	}

	.substatus {
		font-size: 0.95rem;
		color: rgba(255, 255, 255, 0.7);
		margin: 0 0 2rem 0;
		max-width: 450px;
		line-height: 1.6;
	}

	.suggestion-box {
		background: rgba(236, 72, 153, 0.05);
		border: 1px solid rgba(236, 72, 153, 0.15);
		border-radius: 12px;
		padding: 1.5rem;
		margin-bottom: 1.5rem;
		text-align: left;
		width: 100%;
		box-sizing: border-box;
	}

	.suggestion-box h3 {
		margin-top: 0;
		font-size: 1.05rem;
		color: #ec4899;
	}

	.suggestion-box p {
		font-size: 0.9rem;
		line-height: 1.5;
		margin-bottom: 1rem;
		color: rgba(255, 255, 255, 0.8);
	}

	.suggestion-box ol {
		margin: 0 0 1.5rem 0;
		padding-left: 1.2rem;
		font-size: 0.85rem;
		color: rgba(255, 255, 255, 0.7);
	}

	.suggestion-box li {
		margin-bottom: 0.5rem;
	}

	.prebuilt-box {
		background: rgba(16, 185, 129, 0.05);
		border-color: rgba(16, 185, 129, 0.15);
	}

	.prebuilt-box h3 {
		color: #10b981;
	}

	.details-box {
		background: rgba(0, 0, 0, 0.4);
		border: 1px solid rgba(255, 255, 255, 0.05);
		border-radius: 8px;
		width: 100%;
		margin-bottom: 2rem;
		text-align: left;
	}

	.details-box summary {
		padding: 0.75rem 1rem;
		font-size: 0.85rem;
		color: rgba(255, 255, 255, 0.5);
		cursor: pointer;
		user-select: none;
	}

	.details-box pre {
		margin: 0;
		padding: 1rem;
		font-family: 'Courier New', Courier, monospace;
		font-size: 0.75rem;
		overflow-x: auto;
		color: rgba(239, 68, 68, 0.9);
		background: rgba(239, 68, 68, 0.02);
		border-top: 1px solid rgba(255, 255, 255, 0.05);
		max-height: 150px;
		overflow-y: auto;
		white-space: pre-wrap;
	}

	.btn {
		display: inline-block;
		text-decoration: none;
		padding: 0.75rem 1.5rem;
		font-size: 0.9rem;
		font-weight: 600;
		border-radius: 8px;
		border: none;
		cursor: pointer;
		transition: all 0.2s ease;
		text-align: center;
	}

	.btn-primary {
		background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%);
		color: #ffffff;
		box-shadow: 0 4px 15px rgba(236, 72, 153, 0.3);
	}

	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(236, 72, 153, 0.45);
	}

	.btn-success-grad {
		background: linear-gradient(135deg, #10b981 0%, #059669 100%);
		color: #ffffff;
		box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
	}

	.btn-success-grad:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(16, 185, 129, 0.45);
	}

	.btn-secondary {
		background: rgba(255, 255, 255, 0.08);
		color: #ffffff;
		border: 1px solid rgba(255, 255, 255, 0.1);
	}

	.btn-secondary:hover {
		background: rgba(255, 255, 255, 0.12);
	}
</style>