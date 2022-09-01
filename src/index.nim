import nconsole
import dom
import commands
import std/sugar
import std/strutils

let console = createConsole(document.getElementById("app"))
console.addCommand("echo", [], (sex: ShellExecutionContext[NConsole]) =>
    sex.console.addLine(sex.arguments.join(" ")))
console.rerender()

