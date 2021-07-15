/*
 * Replace first occurrence of needle in haystack and replace it
 */
func string PickLockHelper_STR_ReplaceOnce(var string haystack, var string needle, var string replace) {
    var zString zSh; zSh = _^(_@s(haystack));
    var zString zSn; zSn = _^(_@s(needle));
    if (!zSh.len) || (!zSn.len) {
        return haystack;
    };

    var int startPos; startPos = STR_IndexOf(haystack, needle);
    if (startPos == -1) {
        return haystack;
    };

    var string destStr; destStr = "";

    destStr = STR_Prefix(haystack, startPos);
    destStr = ConcatStrings(destStr, replace);
    destStr = ConcatStrings(destStr, STR_Substr(haystack, startPos+zSn.len, zSh.len-(startPos+zSn.len)));

    return destStr;
};


/*
 * Replace all occurrences of needle in haystack and replace them
 */
func string PickLockHelper_STR_ReplaceAll(var string haystack, var string needle, var string replace) {
    var string before; before = "";
    while(!Hlp_StrCmp(haystack, before));
        before = haystack;
        haystack = PickLockHelper_STR_ReplaceOnce(before, needle, replace);
    end;
    return haystack;
};

/*
 * Complement to STR_Prefix in Ikarus (from ScriptBin/strings.d)
 */
func string PickLockHelper_STR_Postfix(var string str, var int off) {
    return STR_SubStr(str, off, STR_Len(str)-off);
};
