import dom
import std/sugar
import std/strutils
import std/strformat
import commands

type 
    NConsole* = ref object
        root: Element
        text: Element
        prompt: Element
        input: string
        commands: CommandHolder[NConsole]


proc appendCreateChild(parent: Element, identifier: string): Element =
    result = document.createElement(identifier)
    parent.appendChild(result)

proc rerender*(console: NConsole) =
    console.prompt.innerText = cstring(&"$ {console.input}")

proc scrollDown*(console: NConsole) =
    console.text.lastChild.scrollIntoView()

proc addLine*(console: NConsole, va: string) =
    let p = document.createElement("p")
    p.innerText = va
    console.text.insertBefore(p, console.prompt)
    console.rerender()


proc handleSubmit(console: NConsole) = 
    let toExecute = console.input
    console.input = ""
    console.addLine(&"$ {toExecute}")
    console.commands.executeCommand(toExecute, console, (feedback: string) => console.addLine(feedback))

proc boundKeydownHandler(console: NConsole): (Event) -> void =
    return proc(ev: Event) =
        let ev = KeyboardEvent(ev)
        if ev.altKey or ev.ctrlKey or ev.metaKey: return
        let toHandle = $(ev.key)
        case toHandle
            of "Enter":
                console.handleSubmit()
            of "Backspace":
                let lastChar = console.input.len()-1
                if lastChar >= 0:
                    console.input.delete(lastChar..lastChar)
            else:
                console.input.add(toHandle)
        console.rerender()
        console.scrollDown()

proc createConsole*(root: Element): NConsole = 
    let text = root.appendCreateChild("pre")
    text.classList.add("nconsole-console")
    let prompt = text.appendCreateChild("p")
    prompt.classList.add("nconsole-prompt")
    result = NConsole(root: root, text: text, prompt: prompt, commands: createCommandHolder[NConsole]())
    document.body.addEventListener("keydown", result.boundKeydownHandler())

proc addCommand*(console: NConsole, name: string, aliases: openArray[string], a: (ShellExecutionContext[NConsole])->void) =
    console.commands.registerCommand(mkCommand(name, aliases, a))