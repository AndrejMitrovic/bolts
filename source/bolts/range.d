/**
    Static introspection utilties for ranges
*/
module bolts.range;

import bolts.internal;

/**
    True if R is a `SortedRange`

    SeeAlso:
        `std.range.SortedRange`
*/
template isSortedRange(R) {
    import std.range: SortedRange;
    enum isSortedRange = is(R : SortedRange!U, U...);
}

///
unittest {
    import std.algorithm: sort;
    import std.range: assumeSorted;
    static assert(isSortedRange!(typeof([0, 1, 2])) == false);
    static assert(isSortedRange!(typeof([0, 1, 2].sort)) == true);
    static assert(isSortedRange!(typeof([0, 1, 2].assumeSorted)) == true);
    static assert(isSortedRange!int == false);
}

/**
    Given a `SortedRange` R, `sortingPredicate!R(a, b)` will call in to the predicate
    that was used to create the `SortedRange`

    Params:
        Range = the range to extract the predicate from
        fallbackPred = the sorting predicate to fallback to if `Range` is not a `SortedRange`
*/
template sortingPredicate(Range, alias fallbackPred = "a < b")
if (from!"std.range".isInputRange!Range)
{
    import std.range: SortedRange;
    import std.functional: binaryFun;
    static if (is(Range : SortedRange!P, P...))
        alias sortingPredicate = binaryFun!(P[1]);
    else
        alias sortingPredicate = binaryFun!fallbackPred;
}

///
unittest {
    import std.algorithm: sort;
    assert(sortingPredicate!(typeof([1].sort!"a < b"))(1, 2) == true);
    assert(sortingPredicate!(typeof([1].sort!"a > b"))(1, 2) == false);
    assert(sortingPredicate!(typeof([1].sort!((a, b) => a < b)))(1, 2) == true);
    assert(sortingPredicate!(typeof([1].sort!((a, b) => a > b)))(1, 2) == false);
    assert(sortingPredicate!(int[])(1, 2) == true);
}

/// Finds the CommonType of a list of ranges
template CommonTypeOfRanges(Rs...) if (from!"std.meta".allSatisfy!(from!"std.range".isInputRange, Rs)) {
    import std.traits: CommonType;
    import std.meta: staticMap;
    import std.range: ElementType;
    alias CommonTypeOfRanges = CommonType!(staticMap!(ElementType, Rs));
}

///
unittest {
    auto a = [1, 2];
    auto b = [1.0, 2.0];
    static assert(is(CommonTypeOfRanges!(typeof(a), typeof(b)) == double));
}
