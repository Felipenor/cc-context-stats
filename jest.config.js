/** @type {import('jest').Config} */
module.exports = {
    testEnvironment: 'node',
    testMatch: ['**/tests/node/**/*.test.js'],
    collectCoverageFrom: ['scripts/statusline.js'],
    coverageDirectory: 'coverage/node',
    coverageReporters: ['text', 'lcov', 'html'],
    modulePathIgnorePatterns: ['<rootDir>/tests/fixtures/'],
    verbose: true,
    testTimeout: 10000,
};
