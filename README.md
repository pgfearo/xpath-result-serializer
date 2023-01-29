# XPath Result Serializer

A standard XSLT module intended to help with XSLT/XPath debugging in combination with the `xsl:message` instruction and `trace()` function.

Using two XSLT functions, `print()` and `println()`, the result of an XPath expression is converted to a notation similar to JSON.

> **Note:** The standard *fn:serialize()* function, using the 'adaptive' output method, provides similar functionality:<br>
> `fn:serialize($n, map{'method':'adaptive'})`<br>
> The XSLT functions here simply provide more extensibility for features such as coloring and indentation 

## Main differences from JSON:

1. XPath sequences are represented with parenthesis like: '(1,2,3,4)'
2. Map keys are enclosed in single-quotes and then only if they are of type xs:string
3. Atomic values are enclosed in single-quotes but then only if they are of type xs:string
4. Boolean values are represented as: true() and false()
5. Nodes are represented by XPath locations - namespace-prefixes are used in the location if declared on the context root element
6. Colorised output via ANSI escape sequences (requires messageEmitter setting - only available for SaxonJ versions prior to 9.9.0.2) 


### Sample xsl:message output
The xsl:message output to the VS Code terminal using `ext:print()` and `ext:println()`:

![screenshot of xsl:message](sample/colorised-xpath.png)

## Key Resource Files
- Source XSLT: `src/xpath-result-serializer.xsl`
- Sample: `sample/test-serializer.xsl`

## Colorising of xsl:message Output with Saxon

If a Saxon version prior to `9.9.0.1` is detected, ANSI escape sequences are included in the outputs of `ext:print()` and `ext:println()` to provide colorisation (see screenshot).

These escape sequences would normally escaped as XML character references in the result. In SaxonJ, prior to v9.9.0.2, the command-line option `-m:net.sf.saxon.serialize.TEXTEmitter` can be used to prevent this XML escaping so xsl:message colors can be seen as intended.