import { defineConfig } from "vite-plus";

export default defineConfig({
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
