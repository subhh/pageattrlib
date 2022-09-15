# Work with PAGE XML custom attributes

Copyright (c) 2021–2022 by State and University Library Hamburg and released under the terms of the MIT license.

## Usage

The file [pageattrlib.xsl](src/main/xslt/pageattrlib.xsl) defines a function and a named template to work with PAGE XML
custom attributes.

### fn:properties-to-map($properties as xs:string) as map(xs:string, map(xs:string, item()))

Returns a map with the custom attributes when called with the content of the @‍custom attribute as argument.

### fn:properties-to-fs($properties as map(*)) as element(tei:fs)

Returns a tei:fs tree representing the content of the map.

## Author

David Maus &lt;david.maus@sub.uni-hamburg.de&gt;
