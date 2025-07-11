import eslint from "eslint";
const { FlatConfig } = eslint;

/** @type {FlatConfig[]} */
export default [
    {
        files: ["**/*.js"],
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                es6: true,
                node: true,
            },
        },
        rules: {
            "no-restricted-globals": ["error", "name", "length"],
            "prefer-arrow-callback": "error",
            "quotes": ["error", "double", { allowTemplateLiterals: true }],
        },
    },
    {
        files: ["**/*.spec.*"],
        languageOptions: {
            globals: {
                mocha: true,
            },
        },
        rules: {},
    },
];
