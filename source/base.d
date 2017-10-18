//#not used
//#not much
//input display an do not work on Mac
module base;

import std.stdio;
import std.string;
import std.datetime;
import std.conv;
import std.range;

public import jec;

immutable newline = "\n";
enum YES = true, NO = false;

LetterManager g_letterBase;

void updateFileNLetterBase(T...)(T args) {
	import std.typecons: tuple; // untested
	import std.conv: text;

	g_letterBase.addTextln(text(tuple(args).expand));
	upDateStatus(args);
}

StopWatch g_sw;

static this() {
	g_sw.start;
}
