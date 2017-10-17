
/*
* Copyright (c) 2017 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Natan Streppel <streppels at gmail.com>
*/

/**
 * This class handles the wrapping logic for a given text within the bounds of 
 * two informed strings, which act as "string wrappers" for the text 
 */
public class WordWrapper : Object {
    private static Regex starting_whitespaces_regex;
    private static Regex ending_whitespaces_regex;

    static construct {
        //  TODO: create 1 single regex to capture both starting and ending whitespaces only
        WordWrapper.starting_whitespaces_regex = new Regex ("^(\\s)+", RegexCompileFlags.EXTENDED);
        WordWrapper.ending_whitespaces_regex = new Regex ("(\\s)+$", RegexCompileFlags.EXTENDED);
    }

    /**
     * Wraps this instance's text with first and second halves.
     * Unwraps this instance's text element if already wrapped with first and second halves.
     */
     public static string apply_wrap (string original_text, string first_half, string second_half) {
        string leading_spaces = "";
        string trailing_spaces = "";

        save_surrouding_spaces (original_text, ref leading_spaces, ref trailing_spaces);

        string text = original_text.strip ();

        if (already_wrapped (text, first_half, second_half)) {
            // removes first and second halves within selected text
            int head = first_half.char_count ();
            int tail = text.char_count () - second_half.char_count ();
            return get_return_string (text.substring (head, tail - head), leading_spaces, trailing_spaces);
        } else {
            // adds first and second halveschar_count ()
            return get_return_string (first_half + text + second_half, leading_spaces, trailing_spaces);
        }
    }

    /**
     * Returns the given stripped string with its leading and trailing whitespaces back on
     */
    private static string get_return_string (string text, string leading_spaces, string trailing_spaces) {
        return leading_spaces.concat(text).concat(trailing_spaces);
    }

    /**
     * Counts the number of whitespace characters to the left and right of a given text
     */
    private static void save_surrouding_spaces (string text, ref string leading_spaces, ref string trailing_spaces) {
        MatchInfo match_info;
        // leading whitespaces
        WordWrapper.starting_whitespaces_regex.match (text, 0, out match_info);
        if (match_info.matches ()) {
            leading_spaces = match_info.fetch (0);
        }

        // trailing whitespaces
        WordWrapper.ending_whitespaces_regex.match (text, 0, out match_info);
        if (match_info.matches ()) {
            trailing_spaces = match_info.fetch (0);
        }
    }

    private static bool already_wrapped (string text, string first_half, string second_half) {
        return text.has_prefix (first_half) && text.has_suffix (second_half);
    }
}
