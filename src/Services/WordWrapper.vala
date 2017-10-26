
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

    private string first_half;
    private string second_half;

    static construct {
        //  TODO: create 1 single regex to capture both starting and ending whitespaces only
        WordWrapper.starting_whitespaces_regex = new Regex ("^(\\s)+", RegexCompileFlags.EXTENDED);
        WordWrapper.ending_whitespaces_regex = new Regex ("(\\s)+$", RegexCompileFlags.EXTENDED);
    }

    public WordWrapper (string first_half, string second_half) {
        this.first_half = first_half;
        this.second_half = second_half;
    }

    /**
     * Moves start and end iterators to the beggining and end of an word, respectively, additionaly
     * with its wrappers, if present.
     * Retuns the found string.
     */
    public string identify_word (ref Gtk.TextIter start, ref Gtk.TextIter end) {
        detect_edges (ref start, ref end);
        return start.get_text (end);
    }

    /**
     * Wraps this instance's text with first and second halves.
     * Unwraps this instance's text element if already wrapped with first and second halves.
     */
     public string wrap_string (string original_text) {
        string leading_spaces = "";
        string trailing_spaces = "";

        save_surrouding_spaces (original_text, ref leading_spaces, ref trailing_spaces);

        string text = original_text.strip ();

        if (already_wrapped (text)) {
            // unwraps the text, removing first and second halves
            int head = this.first_half.char_count ();
            int tail = text.last_index_of (second_half, text.length - second_half.length);
            return get_return_string (text.substring (head, tail - head), leading_spaces, trailing_spaces);
        } else {
            // wraps the text, adding first and second halves 
            return get_return_string (this.first_half + text + this.second_half, leading_spaces, trailing_spaces);
        }
    }

    /**
     * Adjusts iterators to surround a word or its wrappers if present
     */
    private void detect_edges (ref Gtk.TextIter start, ref Gtk.TextIter end) {
        if (no_edges (end)) {
            return;
        }
        if (start.get_char ().isalnum () || end.get_char ().isspace () || end.ends_line ()) {
            // moves iter start to beggining of word and iter end to ending of word
            if (!start.starts_word ()) {
                start.backward_word_start ();
            }
            if (!end.ends_word ()) {
                end.forward_word_end ();
            }
        }
        detect_wrapping (ref start, ref end);
    }

    /**
     * Detects if iterators' pointed text is surrounded by first and second halves
     */
    private void detect_wrapping (ref Gtk.TextIter start, ref Gtk.TextIter end) {
        if (opens_wrapping (start)) {
            forwards_iter_until_whitespace (ref start, this.first_half.length);
            end = start;
            end.forward_visible_word_end ();
            end.forward_chars (this.second_half.length) ;
        } else if (closes_wrapping (end)) {
            forwards_iter_to_whitespace (ref end, this.second_half.length);
            start = end;
            start.backward_visible_word_start ();
            start.backward_chars (this.first_half.length) ;
        }
    }

    /**
     * Detects if current word pointed by iter is an opening tag that wraps a word
     */
    private bool opens_wrapping (Gtk.TextIter iter) {
        forwards_iter_until_whitespace (ref iter, this.first_half.length);
        return (iter_is_followed_by (iter, this.first_half) && word_ends_with (iter, this.second_half));
    }


    /**
     * Detects if current word pointed by iter is a closing tag that wraps a word
     */
    private bool closes_wrapping (Gtk.TextIter iter) {
        forwards_iter_to_whitespace (ref iter, this.second_half.length);
        return (iter_starts_after (iter, this.second_half) && word_starts_with (iter, this.first_half));
    }

    /**
     * Returns true if param text is already wrapped by first and second halves
     */
    private bool already_wrapped (string text) {
        return text.has_prefix (this.first_half) && text.has_suffix (this.second_half);
    }

    /**
     * Returns the given stripped string with its leading and trailing whitespaces back on
     */
    private static string get_return_string (string text, string leading_spaces, string trailing_spaces) {
        return leading_spaces.concat (text).concat (trailing_spaces);
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

    /**
     * Backwards an iterator up to n times searching for a whitespace
     */
    private static void forwards_iter_until_whitespace (ref Gtk.TextIter iter, int n) {
        Gtk.TextIter search_limit = iter;
        search_limit.backward_chars (n + 1);
        iter.backward_find_char ((c) => {
            return c.isspace ();
        }, search_limit);
        if (iter.get_char ().isspace ()) {
            iter.forward_char ();
        }
    }

    /**
     * Forwards an iterator up to n times searching for a whitespace
     */
    private static void forwards_iter_to_whitespace (ref Gtk.TextIter iter, int n) {
        Gtk.TextIter search_limit = iter;
        search_limit.forward_chars (n + 1);
        iter.forward_find_char ((c) => {
            return c.isspace ();
        }, search_limit);
    }

    /**
     * Detects if the word pointed by the iterator is prefixed with tag
     */
    private static bool word_ends_with (Gtk.TextIter iter, string tag) {
        iter.forward_visible_word_end ();
        return iter_is_followed_by(iter, tag);
    }

    /**
     * Detects if the word pointed by the iterator is prefixed with tag
     */
    private static bool word_starts_with (Gtk.TextIter iter, string tag) {
        iter.backward_visible_word_start ();
        return iter_starts_after(iter, tag);
    }

    /**
     * Checks if a text iterator starts after parameter text
     */
    private static bool iter_starts_after (Gtk.TextIter iter, string text) {
        Gtk.TextIter peek_surroundings = iter;
        peek_surroundings.backward_chars (text.length);
        return peek_surroundings.get_text (iter) == text;
    }

    /**
     * Checks if a text iterator is followed by parameter text
     */
    private static bool iter_is_followed_by (Gtk.TextIter iter, string text) {
        Gtk.TextIter peek_surroundings = iter;
        peek_surroundings.forward_chars (text.length);
        return peek_surroundings.get_text (iter) == text;
    }

    /**
     * Detects if iter is in between two whitespaces
     */
    private static bool no_edges (Gtk.TextIter iter) {
        bool previous_value = iter.get_char ().isspace ();
        iter.backward_char ();
        return iter.get_char ().isspace () && previous_value && true;
    }
}
