# Dataflow Customization
---

### Theme

The following superset frontend files were updated to match the theme of dataflow.
* [packages/superset-ui-core/src/color/colorSchemes/categorical/presetAndSuperset.ts](superset-frontend/packages/superset-ui-core/src/color/colorSchemes/categorical/presetAndSuperset.ts)
* [packages/superset-ui-core/src/style/index.tsx](superset-frontend/packages/superset-ui-core/src/style/index.tsx)
* [src/assets/staticPages/404.html](superset-frontend/src/assets/staticPages/404.html)
* [src/assets/staticPages/500.html](superset-frontend/src/assets/staticPages/500.html)
* [src/assets/stylesheets/antd/index.less](superset-frontend/src/assets/stylesheets/antd/index.less)
* [src/assets/stylesheets/less/variables.less](superset-frontend/src/assets/stylesheets/less/variables.less)

The following color codes were replaced with some existing colors in above files to match the theme
* <font color="#30baba">#30baba</font>
* <font color="#3fb0ac">#3fb0ac</font>
* <font color="#39a9a5">#39a9a5</font>


### Working behind proxies

- Constants **ASSET_BASE_URL** and **BASE_PATH** in [constants.ts](superset-frontend/src/constants.ts) were refactored to route the traffic to singleuser pods behind the proxy in runtime.
- Variable **ASSET_BASE_URL** in [webpack.config.js](superset-frontend/webpack.config.js) was refactored to update the urls of static assets during build time.

### Additional

- Links to *Logout* and *Row Level Security* were removed in [RightMenu.tsx](superset-frontend/src/features/home/RightMenu.tsx)