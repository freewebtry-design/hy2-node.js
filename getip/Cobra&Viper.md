# Cobra & Viper 使用说明

## Cobra资源
- [Github](https://github.com/spf13/cobra): Github repository
- [Docs](https://cobra.dev/docs/): documentation
- [packages](https://pkg.go.dev/github.com/spf13/cobra): go package

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

### cmd/root.go 说明
+ "rootCmd"命令代码, 需要构建cobra.Command结构体 --> "rootCmd"可以是其他名字
+ 需要"Execute()"(当然可以是其他名字), 由main.go调用
+ 需要"init()", 用于初始化"rootCmd"的参数, 比如flags等

```go
var rootCmd = &cobra.Command{
  Use:   "hugo",
  Short: "Hugo is a very fast static site generator",
  Long: `A Fast and Flexible Static Site Generator built with
                love by spf13 and friends in Go.
                Complete documentation is available at https://gohugo.io/documentation/`,
  Run: func(cmd *cobra.Command, args []string) {
    // Do Stuff Here
  },
}

func Execute() {
  if err := rootCmd.Execute(); err != nil {
    fmt.Fprintln(os.Stderr, err)
    os.Exit(1)
  }
}

func init() {
	cobra.OnInitialize(initConfig)

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.cobra.yaml)")
	rootCmd.PersistentFlags().StringP("author", "a", "YOUR NAME", "author name for copyright attribution")
	rootCmd.PersistentFlags().StringVarP(&userLicense, "license", "l", "", "name of license for the project")
	rootCmd.PersistentFlags().Bool("viper", true, "use Viper for configuration")
	viper.BindPFlag("author", rootCmd.PersistentFlags().Lookup("author"))
	viper.BindPFlag("useViper", rootCmd.PersistentFlags().Lookup("viper"))
	viper.SetDefault("author", "NAME HERE <EMAIL ADDRESS>")
	viper.SetDefault("license", "apache")
}
```

### cmd/cmd1.go 说明 - "cmd1"是"rootCmd"的子命令, 类似"git pull"中的"pull"
+ "cmd1"命令代码, 需要构建cobra.Command结构体 
+ 需要"init()", 用于初始化"cmd1"的参数, 比如flags等
+ "init()"中, 需要"rootCmd.AddCommand(cmd1)", 将"cmd1"挂载到"rootCmd"下

```go
var cmd1 = &cobra.Command{
  Use:   "hello",
  Short: "......",
  Long: "......",
  Run: func(cmd *cobra.Command, args []string) {
    // Do Stuff Here
  },
}

func init() {
	cmd1.PersistentFlags().StringVar(...)
	...

	rootCmd.AddCommand(cmd1)
}
```

### Cobra编程习惯
+ 程序目录结构用于表明: 主程序、rootCmd、其他cmd之间的层级关系
+ main.go - 执行rootCmd (cmd.Execute())
+ rootCmd及其他cmd, 分别对应各自的.go file
	- 定义cobra.Command{}结构体
	- init()中初始化命令的参数, flags等
	- init(): 其他cmd命令需要挂载到"parent"上, 形成command的Tree结构
+ rootCmd特别的一点: 需要提供Execute(), 由main.go使用


## Cobra程序框架2: 大规模程序
### 程序目录结构
```
	appName
		|-> cmd
			|-- root.go
		|-> module1
		|-> module2
		|-- main.go
```
**每个module提供自己的command; cmd/root.go来汇总**

### module1样例
```go
package serve

import (
	"fmt"
	"github.com/spf13/cobra"
)

func NewCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "serve",
		Short: "Run the HTTP server",
		RunE: func(cmd *cobra.Command, args []string) error {
			port, _ := cmd.Flags().GetInt("port")
			fmt.Printf("Serving on :%d\n", port)
			return nil
		},
	}
	cmd.Flags().Int("port", 8080, "port to listen on")
	return cmd
}
```
**包含cobra.Command{}结构体初始化、flag设置等**

### cmd/root.go样例
```go
package cmd

import (
	"os"
	"github.com/spf13/cobra"
	"example.com/myapp/module1"
)

var rootCmd = &cobra.Command{Use: "myapp"}

func Execute() { if err := rootCmd.Execute(); err != nil { os.Exit(1) } }

func init() {
	rootCmd.AddCommand(module1.NewCommand())
	......
}
```
**由cmd/root.go调用各个module的NewCommand(), 从而完成Command Tree初始化**


## Cobra.Command{}说明
参考[type Command](https://pkg.go.dev/github.com/spf13/cobra#Command)

### 常用/常见字段
+ Use string: Command/SubCommand 字符串, 显示用法时: "git pull" - git 和 pull 都是"Use"
+ Short string: "<cmd> help"时显示, 短字符串
+ Long string: "help <cmd>"时显示, 长字符串
+ GroupID string: 命令成组时的"组ID"
+ Args PostionalArgs: <cmd>的参数, 非flag
+ Hidden bool: if true, 则"<cmd>"不会出现在命令列表中(help)
+ Run命令组:   
    * Run命令的执行按以下先后顺序进行
		1. PersistentPreRun()
		2. PreRun()
		3. Run()
		4. PostRun()
		5. PersistentPostRun()
	* PreRun和PostRun, 仅在有Run()的情况下才会执行
	* PersistentPreRun/PersistentPostRun, 所有子命令都会继承, 都会被执行
	* Run()和RunE()的区别: RunE有error参数返回, Run无返回结果
	* Run命令组的参数都一致: Run func(cmd *Command, args []string)
