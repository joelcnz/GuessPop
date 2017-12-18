//#windows version needed for short cut to quit
/+
1 Psalm 32 1 -> A Maskil of David
2 I went for a walk\nand fell down a hole. (notice the \n in there for newline)

Keys 1 and 2 - values 'Psalm ..' and 'I went ..'
+/
import base;

struct Info {
    string text;
    
    string toString() const {
        return text;
    }
}

Info[string] lines;
string title, list, linesKeys;

enum programName = "Guess Pop";
enum projects = "projects";

/**
	The Main
 */
int main(string[] args) {
    import std.stdio: writeln;

	version(Windows) {
		writeln("This is a Windows version of " ~ programName);
	}
	version(OSX) {
		writeln("This is a Mac version of " ~ programName);
	}
	version(linux) {
		writeln("This is a Linux version of " ~ programName);
	}

    int retVal = setupAndStuff(args);
	if (retVal != 0) {
        if (retVal == -10)
            writeln("You must pass a name (eg. './guesspop Joel')");
        else
            writeln("Error in setupAndStuff!");
	}

	return 0;
}

auto setupAndStuff(in string[] args) {
    string userName;
    if (args.length > 1) {
        import std.string: join;

        userName = args[1 .. $].join(" ");
    } else {
        return -10;
    }
	immutable WELCOME = "Welcome, " ~ userName ~ ", to " ~ programName;
	g_window = new RenderWindow(VideoMode(800, 600),
						WELCOME);

    if (setup != 0) {
		gh("Aborting...");
		g_window.close;

		return -1;
	}

    g_checkPoints = true;
    if (int retVal = jec.setup != 0) {
        import std.stdio: writefln;

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s",
            __FILE__, __FUNCTION__, __LINE__, retVal);
        return -2;
    }

    immutable g_fontSize = 40;
    g_font = new Font;
    g_font.loadFromFile("DejaVuSans.ttf");
    if (! g_font) {
        import std.stdio: writeln;
        writeln("Font not load");
        return -3;
    }

    g_checkPoints = true;
    if (int retVal = jec.setup != 0) {
        import std.stdio: writefln;

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s",
            __FILE__, __FUNCTION__, __LINE__, retVal);
        return retVal;
    }

    //immutable size = 100, lower = 40;
    immutable size = g_fontSize, lower = g_fontSize / 2;
    jx = new InputJex(/* position */ Vector2f(0, g_window.getSize.y - size - lower),
                    /* font size */ size,
                    /* header */ "Word: ",
                    /* Type (oneLine, or history) */ InputType.history);
    jx.setColour(Color(255, 200, 0));
    jx.addToHistory(""d);
    jx.edge = false;

    g_mode = Mode.edit;
    g_terminal = true;

    jx.addToHistory(WELCOME);
    jx.showHistory = false;

    g_window.setFramerateLimit(60);

	g_letterBase = new LetterManager("lemblue.png", 8, 17,
        Square(0,0, g_window.getSize.x, g_window.getSize.y));
    assert(g_letterBase, "Error loading bmp");

    updateFileNLetterBase(WELCOME, " - Recall program" ~ newline);
    g_letterBase.setLockAll(true);

    string[] files;

    doProjects(files, /* show */ false);
    run(files);

	return 0;
}

void run(string[] files) {
    import std.file: readText;
    import std.path;
    import std.string;

    auto helpText = readText("help.txt");
    with(g_letterBase)
        setTextType(TextType.line);
    scope(exit)
        g_window.close();
    string userInput;
    bool enterPressed = false; //#enter pressed
    int prefix;
    prefix = g_letterBase.count();
    auto firstRun = true;
    auto done = NO;
    while(! done) {
        if (! g_window.isOpen())
            done = YES;

        Event event;

        while(g_window.pollEvent(event)) {
            if(event.type == event.EventType.Closed) {
                done = YES;
            }
        }

        version(OSX)
            if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) ||
                Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
                Keyboard.isKeyPressed(Keyboard.Key.Q))
                done = YES;
        //#windows version needed for short cut to quit

        // print for prompt, text depending on whether the section has any verses or not
        if (enterPressed || firstRun) {
            firstRun = false;
            enterPressed = false;
            if (! done)
                updateFileNLetterBase("Enter query, (Enter 'help' for help):");
            g_letterBase.setLockAll(true);
            prefix = g_letterBase.count();
        }
        // exit program if set to exit else get user input
        if (done == NO) {
            import std.string;
            g_window.clear;
            
            g_letterBase.draw();

            with( g_letterBase ) {
                doInput(/* ref: */ enterPressed);
                update(); //#not much
            }

            g_window.display;
            
            if (enterPressed) {
                userInput = g_letterBase.getText[prefix .. $].stripRight;
                upDateStatus(userInput);

                if (userInput in lines) {
                    updateFileNLetterBase(lines[userInput]);
                    userInput = "";
                    continue;
                }
            }
        }
        if (userInput.length > 0) {
            import std.string: toLower;

            // If command not used, the user input is treated as thing typed from memory
            // Switch on command
            const args = userInput.split[1 .. $];
            switch (userInput.split[0].toLower) {
                // Display help
                case "help":
                    updateFileNLetterBase(helpText);
                break;
                case "projects":
                    doProjects(files);
                break;
                case "load":
                    if (args.length != 1) {
                        updateFileNLetterBase("Wrong amount of parameters!");
                        break;
                    }
                    string fileName;
                    try {
                        import std.conv;

                        const index = args[0].to!int;
                        if (index >= 0 && index < files.length)
                            fileName = files[index];
                        else
                            throw new Exception("Index out of bounds");
                    } catch(Exception e) {
                        updateFileNLetterBase("Input error!");
                        break;
                    }
                    loadProject(fileName);
                    import std.path: stripExtension;
                    updateFileNLetterBase(fileName.stripExtension, " - project loaded..");
                break;
                case "cls", "clear":
                    clearScreen;
                    updateFileNLetterBase("Screen cleared..");
                break;
                case "list":
                    updateFileNLetterBase(title, "\n\n", list);
                break;
                case "keys":
                    updateFileNLetterBase(title, ", Keys: ", linesKeys);
                break;
                // quit program
                case "exit", "quit", "command+q":
                    done = true;
                break;
                default:
                    import std.algorithm: startsWith;
                    import std.string: toLower;

                    if (! (userInput.startsWith(";") || userInput.toLower.startsWith("rem")))
                        updateFileNLetterBase(userInput.split[0], " - Unhandled command, or key ..");
                break;
            }
        }
        if (enterPressed) {
            userInput.length = 0;
            g_letterBase.setLockAll(true);
            prefix = g_letterBase.count();
        }
    }
}

/// clear the screen
void clearScreen() {
    g_letterBase.setText("");
}

void doProjects(ref string[] files, in bool show = true) {
    import std.file: dirEntries, SpanMode;
    import std.path: buildPath, dirSeparator, stripExtension;
    import std.range: enumerate;
    import std.string: split;

    if (show)
        updateFileNLetterBase("File list:");
    files.length = 0;
    foreach(i, string name; dirEntries(buildPath(projects), "*.{txt}", SpanMode.shallow).enumerate) {
        import std.conv: to;

        name = name.split(dirSeparator)[1];
        if (show)
            updateFileNLetterBase(i, " - ", name.stripExtension);
        files ~= name;
    }
}

void loadProject(in string fileName) {
    import std.conv: to;
    import std.stdio: File;
    import std.string: split, replace;
    import std.path: buildPath;
    import std.range: enumerate;

    enum Flag {down, up}

    Flag listFlag;
    list.length = 0;
    linesKeys.length = 0;
    lines.clear;
    foreach(i, line; File(buildPath(projects, fileName)).byLine.enumerate) {
        if (i == 1)
            title = line.to!string;
        if (listFlag == Flag.up) {
            const key = line.split[0].to!string;
            lines[key] = Info(line[key.length + 1 .. $].to!string);
            lines[key].text = lines[key].text.replace(`\n`, "\n");
            linesKeys ~= key ~ " ";
            list ~= line.to!string ~ "\n";
        }
        if (line.to!string == "list:")
            listFlag = Flag.up;
    }
    import std.range: popBack;

    linesKeys.popBack; // get rid of the extra space
}
