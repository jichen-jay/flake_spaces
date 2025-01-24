NO_STRIP=true cargo tauri build -b appimage

NO_STRIP=true cargo tauri build --no-bundle


steam-run /home/jaykchen/space_tauri/tauri_pdf/src-tauri/target/release/tauri-pdf

rm -rf node_modules pnpm-lock.yaml
pnpm install

pnpm remove @tauri-apps/api
pnpm add @tauri-apps/api


pnpx sv create demo

