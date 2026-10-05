// .eslintrc-security.js
// Configuración de seguridad para ESLint — enfocada en SAST.
// Uso: eslint . --config .eslintrc-security.js

module.exports = {
    plugins: ['security', 'no-unsanitized'],

    rules: {
        // ──────────────────────────────────────────────
        // eslint-plugin-security — reglas promovidas a "error"
        // Son las que atrapan vulnerabilidades reales, no solo "hotspots".
        // ──────────────────────────────────────────────
        'security/detect-eval-with-expression': 'error',      // eval(variable) → inyección de código
        'security/detect-unsafe-regex': 'error',              // ReDoS
        'security/detect-bidi-characters': 'error',           // Ataques "trojan source" (Unicode bidi)
        'security/detect-buffer-noassert': 'error',           // Buffer con noAssert → corrupción silenciosa
        'security/detect-child-process': 'error',             // child_process.exec con input no literal
        'security/detect-disable-mustache-escape': 'error',   // Desactivar escape de template engines
        'security/detect-new-buffer': 'error',                // new Buffer(no-literal) → memoria no inicializada
        'security/detect-no-csrf-before-method-override': 'error', // Orden incorrecto de middleware CSRF

        // ──────────────────────────────────────────────
        // eslint-plugin-security — reglas en "warn"
        // Son hotspots que requieren revisión humana, no siempre son vulnerabilidades.
        // ──────────────────────────────────────────────
        'security/detect-object-injection': 'warn',           // Acceso dinámico a propiedades (falsos positivos frecuentes)
        'security/detect-possible-timing-attacks': 'warn',    // Comparaciones que filtran timing
        'security/detect-non-literal-fs-filename': 'warn',    // fs.readFile(variable) → path traversal
        'security/detect-non-literal-require': 'warn',        // require(variable) → carga dinámica
        'security/detect-non-literal-regexp': 'warn',         // new RegExp(variable) → ReDoS
        'security/detect-pseudoRandomBytes': 'warn',          // crypto.pseudoRandomBytes → no criptográfico

        // ──────────────────────────────────────────────
        // eslint-plugin-no-unsanitized — reglas de Mozilla
        // Detecta innerHTML, document.write, insertAdjacentHTML sin sanitizar.
        // ──────────────────────────────────────────────
        'no-unsanitized/method': 'error',     // document.write(), insertAdjacentHTML()
        'no-unsanitized/property': 'error',   // element.innerHTML = input
    },

    // ──────────────────────────────────────────────
    // Entornos donde estas reglas aplican
    // ──────────────────────────────────────────────
    env: {
        browser: true,
        node: true,
        es2024: true,
    },

    // ──────────────────────────────────────────────
    // Ignorar archivos que no son código de producción
    // ──────────────────────────────────────────────
    ignorePatterns: [
        'node_modules/',
        'dist/',
        'build/',
        'coverage/',
        '*.min.js',
        'vendor/',
    ],

    // ──────────────────────────────────────────────
    // Overrides: relajar reglas en archivos de test y config
    // ──────────────────────────────────────────────
    overrides: [
        {
            files: ['**/*.test.js', '**/*.spec.js', '**/test/**', '**/tests/**'],
            rules: {
                // Los tests suelen usar eval, child_process y rutas dinámicas a propósito
                'security/detect-eval-with-expression': 'off',
                'security/detect-child-process': 'off',
                'security/detect-non-literal-fs-filename': 'off',
                'no-unsanitized/method': 'off',
                'no-unsanitized/property': 'off',
            },
        },
        {
            files: ['*.config.js', '.eslintrc*.js', 'webpack.config.js', 'vite.config.js'],
            rules: {
                // Los archivos de configuración suelen usar require() dinámico
                'security/detect-non-literal-require': 'off',
            },
        },
    ],
};