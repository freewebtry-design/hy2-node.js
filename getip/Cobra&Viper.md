# Cobra & Viper 使用说明

## Cobra资源
- [Github](https://github.com/spf13/cobra): Github repository
- [Docs](https://cobra.dev/docs/): Cobra documentation
- [packages](https://pkg.go.dev/github.com/spf13/cobra): go.dev package

## Cobra程序框架1: 小规模程序
### 程序目录结构
```
	appName
		|-> cmd
			|-- root.go
			|-- cmd1.go
				|-- cmd1.sub.go
			|-- cmd2.go
			|-- ...
			|-- cmdN.go
		|-- main.go
```

### main.go 说明
+ 主程序(package main)
+ import "cmd"
+ 执行"cmd.Execute()"(使用Cobra)


```go
package main

import "appName/cmd"

func main() {
  cmd.Execute()
}
```




