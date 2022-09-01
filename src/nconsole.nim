import dom

type 
    NConsole* = object
        root: Element
        text: Element
        prompt: Element



proc appendCreateChild(parent: Element, identifier: string): Element =
    result = document.createElement(identifier)
    parent.appendChild(result)
    

proc createConsole*(root: Element): NConsole = 
    let text = root.appendCreateChild("pre")
    text.classList.add("nconsole-console")
    let prompt = text.appendCreateChild("p")
    prompt.classList.add("nconsole-prompt")
    text.innerText = "Inner text"
    result = NConsole(root: root, text: text, prompt: prompt)

