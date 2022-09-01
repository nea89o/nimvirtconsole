import std/sugar
import std/strformat
import std/strutils
import std/tables


type
    Command*[C] = ref object
        name*: string
        aliases*: seq[string]
        runner*: (ShellExecutionContext[C]) -> void

    CommandHolder*[C] = ref object
        commands: TableRef[string, Command[C]]

    ShellExecutionContext*[C] = ref object
        arguments*: seq[string]
        invocationname*: string
        console*: C

proc mkCommand*[C](name: string, aliases: openArray[string], runner: (ShellExecutionContext[C]) -> void): Command[C] =
    Command[C](name: name,
            aliases: @(aliases),
            runner: runner)

proc registerCommand*[C](holder: CommandHolder[C], command: Command[C]) =
    holder.commands[command.name] = command
    for alias in command.aliases:
        holder.commands[alias] = command

proc shlex(inp: string): seq[string] = 
    # Primitive implementation
    inp.split(" ")

proc executeCommand*[C](cmd: CommandHolder[C], commandLine: string, obj: C, errorlog: (string)->void) =
    let parts = shlex(commandLine)
    if parts.len() < 1:
        errorlog("Syntax error")
        return
    let invocation = parts[0]
    let args = parts[1..parts.len()-1]
    if not cmd.commands.hasKey(invocation):
        errorlog(&"Unknown command {invocation}")
        return
    let commandObject = cmd.commands[invocation]
    let sex = ShellExecutionContext[C](arguments: args, invocationname: invocation, console: obj)
    commandObject.runner(sex)


proc createCommandHolder*[C](): CommandHolder[C] =
    CommandHolder[C](commands: newTable[string, Command[C]]())
