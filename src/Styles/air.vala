/*
The MIT License (MIT)

Copyright (c) 2014-2015 John Otander

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

public class ENotes.Styles.air {
    public const string css = """
html {
  font-size: 16px;
}

body {
  line-height: 1.85;
}

p,
.air-p {
  font-size: 1rem;
  margin-bottom: 1.3rem;
}

h1,
.air-h1,
h2,
.air-h2,
h3,
.air-h3,
h4,
.air-h4 {
  margin: 1.214rem 0 .5rem;
  font-weight: inherit;
  line-height: 1.42;
}

h1,
.air-h1 {
  margin-top: 0;
  font-size: 3rem;
}

h2,
.air-h2 {
  font-size: 2rem;
}

h3,
.air-h3 {
  font-size: 1.5rem;
}

h4,
.air-h4 {
  font-size: 1.214rem;
}

h5,
.air-h5 {
  font-size: 1.121rem;
}

h6,
.air-h6 {
  font-size: .88rem;
}

small,
.air-small {
  font-size: .707em;
}

/* https://github.com/mrmrs/fluidity */

img,
canvas,
iframe,
video,
svg,
select,
textarea {
  display: block;
  max-width: 40%;
}

body {
  color: #222;
  font-family: 'Open Sans', Helvetica, sans-serif;
  font-weight: 300;
  margin-left: auto;
  margin-right: auto;
  max-width: 48rem;
  text-align: center;
}

img {
  border-radius: 10%;
  height: auto;
  margin: 0 auto;
}

a,
a:visited {
  color: #3498db;
}

a:hover,
a:focus,
a:active {
  color: #2980b9;
}

pre {
  background-color: #fafafa;
  padding: 1rem;
  text-align: left;
}

blockquote {
  margin: 0;
  border-left: 5px solid #7a7a7a;
  font-style: italic;
  padding: 1em;
  text-align: left;
}

ul,
ol,
li {
  text-align: left;
}

p {
  color: #444;
}""";
}
