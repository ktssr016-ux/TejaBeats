const { exec } = require('child_process');

console.log('Spawning process in current directory...');
const process = exec('flutter run -d windows', { cwd: '.' });

let errorOutput = '';

process.stdout.on('data', (data) => {
    const str = data.toString();
    errorOutput += str;
    console.log(`[STDOUT] ${str.trim()}`);
});

process.stderr.on('data', (data) => {
    const str = data.toString();
    errorOutput += str;
    console.log(`[STDERR] ${str.trim()}`);
});

process.on('exit', (code) => {
    console.log(`[EXIT] Exit code: ${code}`);
    console.log(`Contains toolchain error: ${errorOutput.includes('Unable to find suitable Visual Studio toolchain')}`);
});
