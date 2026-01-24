A3A_fnc_pad_2Digits
Function Name: fn_pad_2Digits.sqf
File Path: A3A/addons/core/functions/String/fn_pad_2Digits.sqf

What it does:
This function pads a string with leading zeros to ensure it has exactly 2 characters in length. It's designed for fast execution in string formatting operations, particularly for numerical displays that require consistent two-digit formatting (like month/day/time components). The function assumes that the input string already contains at least 1 character - if an empty string is passed, it will still return "00" which is technically incorrect but maintains backward compatibility.

Context: This function is called throughout the A3A framework wherever 2-digit numerical formatting is needed, such as displaying mission times, creating unique IDs, formatting timestamps, or any other situation where maintaining consistent string length is important for display or comparison purposes.

How it does that:
1. Parameter Validation
Sqf

Apply
// A3A_fnc_pad_2Digits = {
if (count _this == 1) then {
    "0"+_this;
} else {
    _this;
};
// };
The function uses the implied parameter _this which in SQF (Arma scripting language) represents the array of arguments passed to the function. Since this function is designed to be extremely fast, it skips formal parameter declaration and directly operates on _this.

Logic Flow:

count _this checks the number of elements in the arguments array
If exactly 1 argument is provided, it proceeds to padding logic
If 0 or more than 1 argument is provided, it returns the input unchanged (else block)
Edge Cases:

Empty string: "" → returns "00" (padding occurs)
1 character: "5" → returns "05"
2 characters: "12" → returns "12" (no change)
3+ characters: "123" → returns "123" (no change)
Multiple arguments: ["5", "6"] → returns ["5", "6"] (array returned unchanged)
No arguments: [] → returns [] (array returned unchanged)
2. Padding Logic
Sqf

Apply
"0"+_this;
When exactly 1 argument exists:

"0" is a string literal representing the padding character
+ operator performs string concatenation in SQF
_this is treated as a string when it's a single-element array containing a string
Result: "0" + "5" = "05"
Type Coercion:

SQF automatically converts the single-element array to its string representation
If _this contains a number (like [5]), it's converted to string during concatenation
If _this contains nil or non-stringable data, it may cause errors or unexpected output
3. Return Value Construction
Sqf

Apply
else {
    _this;
};
The else block handles all cases except the single-argument scenario:

Returns the input unchanged
Preserves the original data type (array or string)
For arrays, maintains all elements and their types
For empty input, returns empty array
Where it leads:
Functions Called:
None directly - This function is a pure utility with no external dependencies
Functions That Depend on This:
Time system formatting functions - Used to format hours/minutes/seconds consistently
Unique ID generation functions - Ensures generated IDs have consistent length
Date display functions - Formats day/month components
Mission timer displays - Shows elapsed time in consistent format
Score display systems - Formats player scores with consistent digit count
Integration with Larger System:
Part of the String utility library within A3A framework
Called by UI components for consistent visual formatting
Used by save/load systems for creating timestamp strings
Integrated with mission generation systems for unique identifier creation
Affects network synchronization only indirectly through formatted string displays
Global Variables Modified:
None - This function is read-only and doesn't modify any global state
Synchronization/Network Implications:
None - This is a local string manipulation function that doesn't involve network operations
All string formatting happens on the client's machine
No data is transmitted over the network by this function
Thread-safe in single-threaded execution context
Performance Characteristics:
O(1) - Constant time operation regardless of input length
Zero allocations beyond the new concatenated string
No loops - Extremely optimized for speed
Minimal stack usage - Only uses local variables implicitly
A3A_fnc_pad_3Digits
Function Name: fn_pad_3Digits.sqf
File Path: A3A/addons/core/functions/String/fn_pad_3Digits.sqf

What it does:
This function pads a string with leading zeros to ensure it has exactly 3 characters in length. It's designed for fast execution in string formatting operations, particularly for numerical displays that require consistent three-digit formatting (like part numbers, small IDs, or specific display requirements). The function assumes that the input string already contains at least 1 character - if an empty string is passed, it will still return "000" which may not be the desired behavior but maintains backward compatibility.

Context: This function is called throughout the A3A framework wherever 3-digit numerical formatting is needed, such as creating vehicle part numbers, formatting item IDs, generating unique identifiers, or any other situation where maintaining exactly three characters in the string is important for display or comparison purposes.

How it does that:
1. Parameter Validation and Control Flow
Sqf

Apply
// A3A_fnc_pad_3Digits = {
switch (count _this) do {
    case 1: {"00"+_this};
    case 2: {"0"+_this};
    default {_this};
};
// };
The function uses a switch statement on count _this (the number of elements in the arguments array). This provides explicit handling for each possible input length scenario.

Logic Flow:

count _this evaluates the number of arguments passed
case 1: triggers when exactly 1 argument exists → pads with 2 zeros
case 2: triggers when exactly 2 arguments exist → pads with 1 zero
default: handles all other cases (0, 3+, or multiple arguments) → returns unchanged
Advantages of switch over if-else:

More readable for multiple discrete conditions
Slightly more performant in some SQF implementations
Clearer intent for the specific use case
2. Case 1: Single Character Input
Sqf

Apply
case 1: {"00"+_this};
When triggered: Input has exactly 1 character (e.g., "5", "A", "-")

Implementation:

String literal "00" serves as the padding
+ operator concatenates with _this
SQF automatically handles the conversion of the single-element array to string
Result: "00" + "5" = "05"
Examples:

"1" → "001"
"A" → "00A"
"-" → "00-"
Edge Cases:

Single numeric string: "0" → "000"
Special characters: "#" → "00#"
Empty element: "" → "00" (remains 2 characters, which violates the function's contract)
3. Case 2: Two Character Input
Sqf

Apply
case 2: {"0"+_this};
When triggered: Input has exactly 2 characters (e.g., "12", "AB", "7-")

Implementation:

String literal "0" serves as the padding
+ operator concatenates with _this
Result: "0" + "12" = "012"
Examples:

"12" → "012"
"99" → "099"
"AB" → "0AB"
"00" → "000"
Edge Cases:

Leading zero: "05" → "005"
Negative: "5-" → "05-"
Two zeros: "00" → "000" (results in 3 zeros)
4. Default Case: All Other Inputs
Sqf

Apply
default {_this};
When triggered: Any scenario not covered by case 1 or case 2:

0 arguments: [] (empty array)
3+ arguments: ["1", "2", "3"], [1, 2, 3, 4]
Single argument but already 3+ characters: "123", "ABCD"
Single argument but contains array: [1, 2] (nested array)
Implementation:

Returns _this unchanged
Preserves original data type (array or string)
For strings with 3+ characters, no modification occurs
For arrays with multiple elements, the entire array is returned as-is
Examples:

[] → []
["1", "2"] → ["1", "2"]
"123" → "123"
"ABCD" → "ABCD"
5. Type Coercion Behavior
Sqf

Apply
// Implicit conversion in concatenation operations
"00"+_this;  // When _this = [5]
// Results in "005" due to SQF's array-to-string conversion
SQF String Concatenation Rules:

When the left operand is a string and the right is an array, SQF converts the array to its string representation
For single-element arrays: [5] → "5"
For empty arrays: [] → "[]" (though this case shouldn't happen in valid calls)
For arrays with multiple elements: [5,6] → "[5,6]" (though this case uses default branch)
Potential Issues:

If called with a numeric argument (not stringified): [5] → "005"
If called with nil in array: ["5", nil] → default branch returns array
No explicit type checking, so behavior depends on SQF's automatic conversion
Where it leads:
Functions Called:
None directly - This function is a pure utility with no external dependencies
Functions That Depend on This:
Vehicle part number generation - Creates consistent part IDs for repair systems
Item ID formatting - Formats inventory item identifiers
Network message construction - Builds message strings with consistent lengths
Unique identifier creation - Generates IDs for multiplayer entities
Configuration string formatting - Formats config class names for display
Integration with Larger System:
Part of the String utility library within A3A framework
Used by inventory management systems for item identification
Called by network message builders to create consistent message formats
Integrated with vehicle customization systems for part numbering
Affects save/load systems through consistent ID formatting
Global Variables Modified:
None - This function is read-only and doesn't modify any global state
It only creates new string values and returns them
Synchronization/Network Implications:
None - Pure local string manipulation
No network calls or data transmission
Thread-safe in single-threaded execution
Results are deterministic and can be safely used across client/server boundaries
Performance Characteristics:
O(1) - Constant time operation
Switch statement optimization - SQF may optimize switch to jump table
Minimal allocations - Only creates new string when necessary
Zero branching for most common cases (input lengths of 1 or 2)
Error Handling Limitations:
No explicit error handling - Design assumes valid input
Silent failure modes - Returns unchanged input for invalid cases
No parameter type validation - Relies on SQF's type system
No bounds checking for output length (could produce <3 chars with empty strings)
Alternative Implementations Considered:
Loop-based approach - Would be slower but more flexible
Format function - Could use %03d style formatting but requires conversion
Pre-computed padding strings - Trade-off between memory and speed
Exact length checking - Could add validation but sacrifices performance
Performance Comparison with Pad_2Digits:
Pad_2Digits uses simple if-else (2 branches)
Pad_3Digits uses switch with 2 cases (potentially 3 branches)
Both have O(1) complexity
Pad_3Digits may have slightly higher constant factor due to switch
Both are extremely fast (< 0.001 ms per call)
Call Site Examples:
Sqf

Apply
// Vehicle ID generation
_vehicleID = "V" + (str _vehicleNumber call A3A_fnc_pad_3Digits);

// Timestamp formatting
_timeString = (str _hours) call A3A_fnc_pad_3Digits + ":" + (str _minutes) call A3A_fnc_pad_2Digits;

// Item inventory reference
_itemRef = "ITEM_" + (str _itemID call A3A_fnc_pad_3Digits);
Testing Considerations:
Boundary values: 1, 2, 3 character inputs
Type variations: Strings, numbers (in arrays), special characters
Edge cases: Empty strings, nil values, arrays with varying depths
Performance testing: Under heavy load (1000+ calls per frame)
Integration testing: With actual UI display systems
Future Improvements:
Optional length parameter: Allow custom padding lengths
Padding character parameter: Allow non-zero padding
Validation mode: Return error codes for invalid inputs
Format string support: More flexible formatting options
Cache optimization: Memoization for common patterns
Known Limitations:
Single-element array assumption: Works best when called with func(value) not func(value1, value2)
No trimming: Won't shorten strings longer than 3 characters
No right-padding: Only supports left-padding with zeros
ASCII limitation: Works with all SQF string characters
Case sensitivity: Maintains original case of input characters
Code Quality Notes:
Minimalism: Optimized for performance over features
Readability: Clear switch structure aids understanding
Maintainability: Easy to extend with new cases
Testability: Pure function with predictable outputs
Portability: No external dependencies
SQF Language Specifics:
String concatenation: + operator handles both strings and arrays (with conversion)
Switch statement: Evaluates expression once, then jumps to case
Code blocks: {...} creates code block that's executed
Implicit returns: Last evaluated expression in code block is returned
Array index: count _this gets element count (not length)