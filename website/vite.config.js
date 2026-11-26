import { readFileSync } from "node:fs";
import { defineConfig } from "vite-plus";

// install.sh lives at the repo root so people find it on GitHub; serve it at /install.sh too.
const installScript = new URL("../install.sh", import.meta.url);

/** @returns {import("vite-plus").Plugin} */
function serveInstallScript() {
    return {
        name: "nightbar-install-script",
        configureServer(server) {
            server.middlewares.use("/install.sh", (_req, res) => {
                res.setHeader("Content-Type", "text/plain; charset=utf-8");
                res.end(readFileSync(installScript));
            });
        },
        generateBundle() {
            this.emitFile({
                type: "asset",
                fileName: "install.sh",
                source: readFileSync(installScript),
            });
        },
    };
}

export default defineConfig({
    plugins: [serveInstallScript()],
    fmt: {
        tabWidth: 4,
        ignorePatterns: ["dist/**"],
    },
    lint: {
        jsPlugins: [{ name: "vite-plus", specifier: "vite-plus/oxlint-plugin" }],
        rules: { "vite-plus/prefer-vite-plus-imports": "error" },
        options: { typeAware: true, typeCheck: true },
    },
    server: { port: 8040 },
    preview: { port: 8040 },
});
