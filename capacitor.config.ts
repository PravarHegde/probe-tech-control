import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
    appId: 'com.probetech.control',
    appName: 'Probe Tech Control',
    webDir: 'dist',
    server: {
        androidScheme: 'https'
    },
    plugins: {
        Keyboard: {
            resize: "body",
            style: "dark",
            resizeOnFullScreen: true
        }
    }
};

export default config;
