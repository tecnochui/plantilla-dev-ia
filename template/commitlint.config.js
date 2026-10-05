// commitlint.config.js
// Valida que los mensajes de commit sigan Conventional Commits.
module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'type-enum': [
            2,
            'always',
            [
                'feat',      // nueva funcionalidad
                'fix',       // corrección de bug
                'security',  // mejora/corrección de seguridad
                'docs',      // documentación
                'chore',     // mantenimiento
                'refactor',  // refactorización
                'test',      // tests
                'perf',      // rendimiento
                'ci',        // CI/CD
                'build',     // build system
                'revert',    // revertir commit
            ],
        ],
        'scope-case': [2, 'always', 'lower-case'],
        'subject-case': [2, 'never', ['upper-case', 'pascal-case']],
        'subject-empty': [2, 'never'],
        'subject-full-stop': [2, 'never', '.'],
        'header-max-length': [2, 'always', 100],
        'body-max-line-length': [2, 'always', 200],
    },
};