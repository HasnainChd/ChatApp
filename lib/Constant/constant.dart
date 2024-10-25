// regex_constants.dart

final RegExp emailValidationRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

final RegExp passwordValidationRegex =
   RegExp( r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
// At least 8 characters, one letter, one number

final RegExp nameValidationRegex= RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+");
// Allows alphabets and spaces, ensuring no extra spaces between or at ends
const String personIcon =
    "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg";