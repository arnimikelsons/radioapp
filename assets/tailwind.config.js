// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "../lib/*_web/**/**/*.*ex"
  ],
  theme: {
    fontFamily: {
      'sans': ['Roboto'],
      'serif': ['ui-serif', 'Georgia'],
      'mono': ['ui-monospace', 'SFMono-Regular'],
      'display': ['Oswald'],
      'body': ["Open Sans"]
    },
    extend: {
      colors: {
        brand: "#FD4F00",
        'red': '#ea000000',
        'blue': '#2e5266',
        'green': '#87bba2',
        'gray-green': '7b9e89',
        'yellow': '#e6c229',
        'black': '#000000',
        'gray-dark': '#273444',
        'gray': '#8492a6',
        'gray-light': '#d3dce6',
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
  ]
}