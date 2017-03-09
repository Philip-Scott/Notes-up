. tests/functions.sh

title "embedded latex"

rc=0
MARKDOWN_FLAGS=

try -flatex 'latex w/ \( .. \)' '\(\tex\)' '<p>\(\tex\)</p>'
try -flatex 'latex w/ \( .. \) and link inside' '\([(1+2)*3-4](1-2)\)' '<p>\([(1+2)*3-4](1-2)\)</p>'
try -flatex 'latex w/ \( .. \) and special characters' 'Equation:\(a<+>b\).' \
    '<p>Equation:\(a&lt;+&gt;b\).</p>'

try -flatex 'latex $ delimiter not supported' '$[a](b)$' '<p>$<a href="b">a</a>$</p>'

try -flatex 'latex with $$ .. $$' '$$foo$$' '<p>$$foo$$</p>'
try -flatex 'latex with $$ .. $$ like a link' '$$[(1+2)*3-4](1-2)$$' '<p>$$[(1+2)*3-4](1-2)$$</p>'
try -flatex 'latex with multiple $$ .. $$' '$$[a](b)$$$$[a](b)$$' '<p>$$[a](b)$$$$[a](b)$$</p>'
try -flatex 'latex with $$ .. $$ and a real link' '$$[a](b)$$[a](b)$$' '<p>$$[a](b)$$<a href="b">a</a>$$</p>'
try -flatex 'latex with $$ .. $$ and a real link' '$$[a](b)$$$[a](b)$$' '<p>$$[a](b)$$$<a href="b">a</a>$$</p>'
try -flatex 'latex with $$ .. $$ multi lines' '$$\begin{split}\nabla \times \vec{\mathbf{B}} -\, \frac1c\, \frac{\partial\vec{\mathbf{E}}}{\partial t} & = \frac{4\pi}{c}\vec{\mathbf{j}} \\   \nabla \cdot \vec{\mathbf{E}} & = 4 \pi \rho \\ \nabla \times \vec{\mathbf{E}}\, +\, \frac1c\, \frac{\partial\vec{\mathbf{B}}}{\partial t} & = \vec{\mathbf{0}} \\ \nabla \cdot \vec{\mathbf{B}} & = 0 \end{split}$$' '<p>$$\begin{split}\nabla \times \vec{\mathbf{B}} -\, \frac1c\, \frac{\partial\vec{\mathbf{E}}}{\partial t} &amp; = \frac{4\pi}{c}\vec{\mathbf{j}} \\   \nabla \cdot \vec{\mathbf{E}} &amp; = 4 \pi \rho \\ \nabla \times \vec{\mathbf{E}}\, +\, \frac1c\, \frac{\partial\vec{\mathbf{B}}}{\partial t} &amp; = \vec{\mathbf{0}} \\ \nabla \cdot \vec{\mathbf{B}} &amp; = 0 \end{split}$$</p>'

try -flatex 'latex with \[ .. \]' '\[foo\]' '<p>\[foo\]</p>'
try -flatex 'latex with \[ .. \] and link inside' '\[[(1+2)*3-4](1-2)\]' '<p>\[[(1+2)*3-4](1-2)\]</p>'
try -flatex 'latex with \[ .. \] multi lines' '\[\begin{split}\nabla \times \vec{\mathbf{B}} -\, \frac1c\, \frac{\partial\vec{\mathbf{E}}}{\partial t} & = \frac{4\pi}{c}\vec{\mathbf{j}} \\   \nabla \cdot \vec{\mathbf{E}} & = 4 \pi \rho \\ \nabla \times \vec{\mathbf{E}}\, +\, \frac1c\, \frac{\partial\vec{\mathbf{B}}}{\partial t} & = \vec{\mathbf{0}} \\ \nabla \cdot \vec{\mathbf{B}} & = 0 \end{split}\]' '<p>\[\begin{split}\nabla \times \vec{\mathbf{B}} -\, \frac1c\, \frac{\partial\vec{\mathbf{E}}}{\partial t} &amp; = \frac{4\pi}{c}\vec{\mathbf{j}} \\   \nabla \cdot \vec{\mathbf{E}} &amp; = 4 \pi \rho \\ \nabla \times \vec{\mathbf{E}}\, +\, \frac1c\, \frac{\partial\vec{\mathbf{B}}}{\partial t} &amp; = \vec{\mathbf{0}} \\ \nabla \cdot \vec{\mathbf{B}} &amp; = 0 \end{split}\]</p>'

summary $0
exit $rc
