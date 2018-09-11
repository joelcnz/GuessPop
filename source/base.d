module base;

import std.conv;
import std.datetime.stopwatch;
import std.range;
import std.stdio;
import std.string;

public import jec;

immutable newline = "\n";
enum YES = true, NO = false;

LetterManager g_letterBase;

void updateFileNLetterBase(T...)(T args) {
	g_letterBase.addTextln(args);
	upDateStatus(args);
}

StopWatch g_sw;

static this() {
	g_sw.start;
}
