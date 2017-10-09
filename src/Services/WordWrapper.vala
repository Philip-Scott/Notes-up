
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
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

/**
 * This class handles the wrapping logic for a given text within the bounds of 
 * two informed strings, which act as "string wrappers" for the text 
 */
public class WordWrapper : Object {
    private string text;

    private int n_leading_spaces = 0;
    private int n_trailing_spaces = 0;

    private static Regex regex_start_whitespaces;
    private static Regex regex_end_whitespaces;

    class construct {
        //  TODO: create 1 single regex to capture both starting and ending whitespaces only
        const string START_WHITESPACES_PATTERN = "^(\\s)+"; 
        const string END_WHITESPACES_PATTERN = "(\\s)+$"; 
        regex_start_whitespaces = new Regex (START_WHITESPACES_PATTERN, RegexCompileFlags.EXTENDED);
        regex_end_whitespaces = new Regex (END_WHITESPACES_PATTERN, RegexCompileFlags.EXTENDED);
    }

    public WordWrapper (string text) {
        count_surrouding_spaces (text, ref n_leading_spaces, ref n_trailing_spaces);
        this.text = text.strip ();
    }

    /**
     * Wraps this instance's text with first and second halves.
     * Unwraps this instance's text element if already wrapped with first and second halves.
     */
    public string apply_wrap (string first_half, string second_half) {
        if (already_wrapped (this.text, first_half, second_half)) {
            // removes first and second halves within selected text
            int head = first_half.char_count ();
            int tail = this.text.char_count () - second_half.char_count ();
            return get_return_string (this.text.substring (head, tail - head));
        } else {
            // adds first and second halves
            return get_return_string (first_half + this.text + second_half);
        }
    }

    /**
     * Returns the given stripped string with its leading and trailing whitespaces back on
     */
    private string get_return_string (string text) {
        string leading_whitespaces = string.nfill (this.n_leading_spaces, ' ');
        string trailing_whitespaces = string.nfill (this.n_trailing_spaces, ' ');
        return leading_whitespaces.concat(text).concat(trailing_whitespaces);
    }

    /**
     * Counts the number of whitespace characters to the left and right of a given text
     */
    private static void count_surrouding_spaces (string text, ref int n_leading_spaces, ref int n_trailing_spaces) {
        MatchInfo match_info;
        // leading whitespaces
        regex_start_whitespaces.match (text, 0, out match_info);
        if (match_info.matches ()) {
            n_leading_spaces = match_info.fetch (0).char_count ();
        }
        // trailing whitespaces
        regex_end_whitespaces.match (text, 0, out match_info);
        if (match_info.matches ()) {
            n_trailing_spaces = match_info.fetch (0).char_count ();
        }
    }

    private static bool already_wrapped (string text, string first_half, string second_half) {
        return text.has_prefix (first_half) && text.has_suffix (second_half);
    }
}
