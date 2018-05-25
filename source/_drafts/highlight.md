---
title: "关于 Hexo 中的代码高亮"
tags: "blog hexo"
---

## Lib
*	[hexo-filter-highlight](https://github.com/Jamling/hexo-filter-highlight)
*	[hexo-prism-plugin](https://github.com/ele828/hexo-prism-plugin)

## Install
```bash
$ npm i -S hexo-prism-plugin
```
## Usage
Firstly, you should edit your `_config.yml` by adding following configuration.
```yaml
prism_plugin:
  mode: 'preprocess'    # realtime/preprocess
  theme: 'default'
  line_number: false    # default false
  custom_css: 'path/to/your/custom.css'     # optional
```
After that, check `highlight` option in `_config.yml`. Make sure that default code highlight plugin is disabled.
```yaml
highlight:
  enable: false
```
Finally, clean and re-generate your project by running following commands:

```shell
$ hexo clean
```

```bash
$ hexo generate
```

```javascript
function getText() {
  return 'hello';
}

const text = getText();
console.log(text);
```

```javascript
import { Input } from 'antd';

export default ({ value }) => {
  return <Input value={value} />
};

```

``` html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Document</title>
  </head>
  <body>
  </body>
</html>
```