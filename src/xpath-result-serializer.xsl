<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:ext="com.deltaxml.xpath.result.print"
                exclude-result-prefixes="#all"
                version="3.0">
  
  <!--
       (c) DeltaXML ltd. 2023
       Intended for XSLT/XPath debugging in combination with the 'xsl:message' instruction and 'trace()' function:
       Converts the result of an XPath expression to a notation similar to JSON. Main differences:
       1. XPath sequences are represented with parenthesis like: '(1,2,3,4)'
       2. Map keys are enclosed in single-quotes and then only if they are of type xs:string
       3. Atomic values are enclosed in single-quotes but then only if they are of type xs:string
       4. Boolean values are represented as: true() and false()
       5. Nodes are represented by XPath locations - namespace-prefixes are used in the location if declared on the context root element
  -->
  <xsl:param name="alwaysUseColor" static="yes" as="xs:boolean" select="false()"/>

  <xsl:variable name="product-version-parts" static="yes" as="xs:string+" 
    select="system-property('Q{http://www.w3.org/1999/XSL/Transform}product-version') => tokenize('\s+')"/>
  <xsl:variable name="saxon-major-minor-patch" static="yes" as="xs:string*" select="$product-version-parts[2] => tokenize('\.')"/>
  <xsl:variable name="major" static="yes" as="xs:integer" select="($saxon-major-minor-patch[1] => xs:integer(), 0)[1]"/>
  <xsl:variable name="minor" static="yes" as="xs:integer" select="($saxon-major-minor-patch[2] => xs:integer(), 0)[1]"/>
  <xsl:variable name="patch" static="yes" as="xs:integer" select="($saxon-major-minor-patch[3] => xs:integer(), 0)[1]"/>
  <xsl:variable name="patch-version" static="yes" as="xs:integer" select="($saxon-major-minor-patch[4] => xs:integer(), 0)[1]"/>
  <!-- Only Saxon 9.9.0.1 and previous versions can use ANSI escape sequences for colors: -->
  <xsl:variable name="isPriorTo9902" static="yes" as="xs:boolean" select="($major lt 9) or ($major eq 9 and $minor lt 9) or ($major eq 9 and $minor eq 9 and $patch eq 0 and $patch-version le 1)"/>
  <xsl:variable name="useColors" static="yes" as="xs:boolean" select="if ($alwaysUseColor) then $alwaysUseColor else $isPriorTo9902"/>
  <xsl:variable name="colorDataName" static="yes" as="xs:string" 
    select="if ($useColors) then 'color-data.xsl' else 'color-data-empty.xsl'"/>
  
  <xsl:include _href="{$colorDataName}"/>
  
  <xsl:function name="ext:println" as="xs:string">
    <xsl:param name="xdmValue" as="item()*"/>
    <xsl:sequence select="ext:print($xdmValue) || $LF"/>
  </xsl:function>
  
  <xsl:function name="ext:print" as="xs:string">
    <xsl:param name="xdmValue" as="item()*"/>
    <xsl:sequence select="ext:print($xdmValue, 0, '')"/>
  </xsl:function>
  
  <xsl:function name="ext:print" as="xs:string">
    <xsl:param name="xdmValue" as="item()*"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="spaceChars" as="xs:string"/>
    <xsl:variable name="enclosedItems" as="element()" select="ext:buildResultTree($xdmValue)"/>
    <xsl:sequence select="ext:xml-to-xdm($enclosedItems, $level, $spaceChars) || $RESET"/>
  </xsl:function>
  
  <xsl:function name="ext:log" as="item()*">
    <xsl:param name="xdmValue" as="item()*"/>
    <xsl:param name="label" as="xs:string"/>
    <xsl:message select="ext:formatValue($label || ':', 26) || ' ' || ext:print($xdmValue,12,'  ')"/>
  </xsl:function>
  
  <xsl:function name="ext:log" as="item()*">
    <xsl:param name="label" as="xs:string"/>
    <xsl:message select="$label"/>
  </xsl:function>
  
  <xsl:function name="ext:trace" as="item()*">
    <xsl:param name="xdmValue" as="item()*"/>
    <xsl:param name="label" as="xs:string"/>
    <xsl:sequence select="ext:log($xdmValue, $label)"/>
    <xsl:sequence select="$xdmValue"/>
  </xsl:function>
  
  <xsl:function name="ext:bracketColor" as="xs:string">
    <xsl:param name="index" as="xs:integer"/>
    <xsl:variable name="resolved" as="xs:integer" 
      select="let $c := count($BRACKET_COLORS) return let $mod := $index mod $c return if ($mod eq 0) then $c else $mod"/>
    <xsl:sequence select="$BRACKET_COLORS[position() eq $resolved]"/>
  </xsl:function>
  
  <xsl:function name="ext:getURItoPrefixMap" as="map(xs:anyURI, xs:string)">
    <xsl:param name="source" as="node()"/>
    <xsl:sequence 
      select="
        map:merge(
          for $pfx in in-scope-prefixes($source),
            $ns in namespace-uri-for-prefix($pfx, $source)
          return 
            map:entry($ns, $pfx)
        )"/>
  </xsl:function>
  
  <xsl:variable name="regex" as="xs:string" select="'Q\{[^\{]*\}'"/>
  
  <xsl:function name="ext:tidyXPath" as="xs:string*">
    <xsl:param name="node" as="node()"/>
    <xsl:variable name="xmlns" as="map(*)" select="let $e:= $node/ancestor-or-self::*[1] return if ($e) then ext:getURItoPrefixMap($e) else map{}"/>

    <xsl:variable name="parts" as="xs:string*">
      <xsl:analyze-string select="path($node)" regex="{$regex}">
        <xsl:matching-substring>
          <xsl:variable name="uri" as="xs:string" select="substring(., 3, string-length(.) - 3)"/>
          <xsl:variable name="pfx" select="map:get($xmlns, $uri)"/>
          <xsl:sequence select="if (string-length($pfx) eq 0) then '' else $pfx || ':'"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:sequence select="string-join($parts)"/>
  </xsl:function>
  
  <xsl:function name="ext:convertMapEntry"> 
    <xsl:param name="k" as="xs:anyAtomicType?"/>
    <xsl:param name="value" as="item()*"/>
    
    <xsl:variable name="key" as="xs:string" select="
      let $sk := serialize($k) return if ($k instance of xs:string) then '''' || $sk || '''' else $sk"/>
    
    <xsl:choose>
      <xsl:when test="count($value) gt 1">
        <sequence>
          <xsl:if test="$key">
            <xsl:attribute name="key" select="$key"/>
          </xsl:if>
          <xsl:for-each select="$value">
            <xsl:call-template name="encloseItem"/>
          </xsl:for-each>
        </sequence>
      </xsl:when>
      <xsl:when test="exists($value)">
        <xsl:for-each select="$value">
          <xsl:call-template name="encloseItem">
            <xsl:with-param name="key" select="$key"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <sequence key="{$key}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="ext:buildResultTree">
    <xsl:param name="value" as="item()*"/>
    <xsl:choose>
      <xsl:when test="count($value) gt 1">
        <sequence>
          <xsl:for-each select="$value">
            <xsl:call-template name="encloseItem"/>
          </xsl:for-each>
        </sequence>
      </xsl:when>
      <xsl:when test="exists($value)">
        <xsl:for-each select="$value">
          <xsl:call-template name="encloseItem"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <sequence/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="encloseItem">
    <xsl:param name="key" as="xs:string?"/>
    <xsl:variable name="nodeType" as="xs:string?" select="ext:nodeType(.)"/>
    
    <xsl:choose>     
      <xsl:when test="exists($nodeType)">        
        <path>
          <xsl:if test="$key">
            <xsl:attribute name="key" select="$key"/>
          </xsl:if>
          <xsl:attribute name="text" select="ext:getText(., $nodeType)"/>
          <xsl:attribute name="type" select="$nodeType"/>
          <xsl:attribute name="location" select="ext:tidyXPath(.)"/>
          <xsl:choose>
            <xsl:when test="$nodeType eq 'element'">
              <xsl:copy copy-namespaces="false">
                <xsl:copy-of select="@*"/>
              </xsl:copy>
            </xsl:when>
            <xsl:when test="$nodeType eq 'attribute'">
              <ext:attribute>
                <xsl:copy-of select="."/>
              </ext:attribute>
            </xsl:when>
            <xsl:when test="$nodeType eq 'namespace-node'">
              <ext:namespace>
                <xsl:copy-of select="."/>
              </ext:namespace>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </path>
      </xsl:when>
      
      <xsl:when test=". instance of map(*)">
        <map>
          <xsl:if test="$key">
            <xsl:attribute name="key" select="$key"/>
          </xsl:if>
          <xsl:variable name="mapInstance" as="map(*)" select="."/>
          <xsl:for-each select="map:keys($mapInstance)">
            <xsl:sequence select="ext:convertMapEntry(., $mapInstance(.))"/>
          </xsl:for-each>
        </map>
      </xsl:when>
      
      <xsl:when test=". instance of array(*)">        
        <array>
          <xsl:if test="$key">
            <xsl:attribute name="key" select="$key"/>
          </xsl:if>
          <xsl:variable name="array" as="array(*)" select="."/>
          <xsl:for-each select="1 to array:size($array)">
            <xsl:sequence select="ext:buildResultTree($array?(.))"/>
          </xsl:for-each>
        </array>
      </xsl:when>
      
      <xsl:otherwise expand-text="yes">        
        <atomicValue>
          <xsl:if test="$key">
            <xsl:attribute name="key" select="$key"/>
          </xsl:if>
          <xsl:variable name="val" select="serialize(., map {'method': 'text'})"/>
          <xsl:choose>
            <xsl:when test=". instance of xs:boolean"><xsl:attribute name="type" select="'boolean'"/>{$val}()</xsl:when>
            <xsl:when test=". instance of xs:string"><xsl:attribute name="type" select="'string'"/>'{$val}'</xsl:when>
            <xsl:when test=". instance of xs:numeric"><xsl:attribute name="type" select="'numeric'"/>{$val}</xsl:when>
            <xsl:otherwise>{$val}</xsl:otherwise>
          </xsl:choose>         
        </atomicValue>       
      </xsl:otherwise> 
      
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="ext:getText" as="item()*">
    <xsl:param name="c.x" as="item()*"/>
    <xsl:param name="nodeType" as="xs:string?"/>
    <xsl:variable name="maxLength" as="xs:integer" select="25"/>
    <xsl:sequence select="
      if ($nodeType eq 'element') then 
        (if (normalize-space($c.x) ne '') then ext:formatValue(string-join($c.x//text(),' '), $maxLength) else let $a := $c.x/(@name,@id,@class,@*)[1] return 
              if ($a) then ext:formatValue('@' || name($a) || '=' || xs:string($a), $maxLength) else ext:formatValue('[empty-element]', $maxLength))
      else ext:formatValue($c.x, $maxLength)"/>
  </xsl:function>
  
  
  <xsl:function name="ext:explainNode" as="item()*">
    <xsl:param name="c.x" as="node()?"/>
    <xsl:param name="location" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="starts-with($location,'root()')">
        <xsl:choose>
          <xsl:when test="$c.x[self::ext:attribute]">
            <xsl:sequence select="name($c.x/@*) || '=&quot;' || $c.x/@* || '&quot;'"/>
          </xsl:when>
          <xsl:when test="$c.x[self::ext:namespace]">
            <xsl:variable name="prefix" as="xs:string?" select="in-scope-prefixes($c.x)[not(. = ('xml','ext'))][1]"/>
            <xsl:variable name="namespace-uri" as="xs:anyURI" select="namespace-uri-for-prefix($prefix, $c.x)"/>
            <xsl:variable name="p" as="xs:string" select="if ($prefix) then ':' || $prefix else ''"/>
            <xsl:sequence select="'xmlns' || $p || '=&quot;' || $namespace-uri  || '&quot;'"/>
          </xsl:when>
          <xsl:when test="$c.x instance of element()">
            <xsl:variable name="selfClose" as="xs:string" select="if (has-children($c.x)) then '' else '/'"/>
            <xsl:variable name="startTag" select="'&lt;' || name($c.x) || ' ' || string-join(for $a in $c.x/@* return name($a) || '=&quot;' || $a || '&quot;', ' ') || $selfClose || '&gt;'"/>
            <xsl:variable name="endTag" select="'/&lt;' || name($c.x) || '&gt;'"/>
            <xsl:sequence select="if (has-children($c.x)) then $startTag || '...' || $endTag else $startTag"/>
          </xsl:when>
          <xsl:when test="$c.x instance of text()">
            <xsl:sequence select="'&quot;' || normalize-space($c.x) || '&quot;'"/>
          </xsl:when>
          <xsl:when test="$c.x instance of comment()">
            <xsl:sequence select="'&lt;!-- ' || normalize-space($c.x) || ' --&gt;'"/>
          </xsl:when>
          <xsl:when test="$c.x instance of processing-instruction()">
            <xsl:sequence select="'&lt;?' || name($c.x) || ' ' || normalize-space($c.x) || ' ?&gt;'"/>            
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$location"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="ext:formatValue" as="item()*">
    <xsl:param name="c.x" as="item()*"/>
    <xsl:param name="maxLength" as="xs:integer"/>
    <xsl:variable name="ellipsis" as="xs:string" select="'...'"/>
    <xsl:variable name="maxWithEllipsis" as="xs:integer" select="$maxLength - string-length($ellipsis)"/>

    <xsl:sequence select="
      let $nt := normalize-space($c.x),
        $addDots := string-length($nt) gt $maxLength,
                    $len := if ($addDots) then $maxWithEllipsis else $maxLength,
                    $t := substring($nt, 1, $len),
        $tdiff := $maxLength - string-length($t),
        $append := if ($addDots) then '...' else string-join(for $x in 1 to $tdiff return ' ', '')
      return $t || $append"/>
  </xsl:function>
  
  <xsl:function name="ext:xml-to-xdm" as="xs:string">
    <xsl:param name="top" as="element()"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="spaceChars" as="xs:string"/>
    <xsl:sequence select="ext:writeEnclosedItem($top, $level + 1, $spaceChars, 1) => string-join('')"/>
  </xsl:function>
  
  <xsl:function name="ext:writeEnclosedItem" as="xs:string*">
    <xsl:param name="c.x" as="item()*"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="spaceChars" as="xs:string"/>
    <xsl:param name="colorIndex" as="xs:integer"/>
    
    <xsl:variable name="indent" as="xs:string" select="string-join(for $n in 1 to $level return $spaceChars, '')"/>
    <xsl:variable name="BC" as="xs:string" select="ext:bracketColor($colorIndex)"/>
    
    <xsl:variable name="hasNonAtomicSiblings" as="item()*" select="$c.x/..[array, sequence, map, path]"/>
    <xsl:variable name="nl" as="xs:string" select="if ($hasNonAtomicSiblings) then ('&#10;' || $indent) else ''"/>
    
    <xsl:variable name="parts" as="xs:string*">
      <xsl:for-each select="$c.x">
        <xsl:variable name="key" as="xs:string" select="$nl || (if (@key) then $RED || @key || $RESET || ':' else '')"/>        
        <xsl:choose>
          <xsl:when test="self::sequence">
            <xsl:sequence select="$key || $BC || '(' || ext:recurseForChildren(., $level, $spaceChars, $colorIndex) || $BC || ')'"/>
          </xsl:when>
          <xsl:when test="self::array">
            <xsl:sequence select="$key || $BC ||  '[' || ext:recurseForChildren(., $level, $spaceChars, $colorIndex) || $BC || ']'"/>
          </xsl:when>
          <xsl:when test="self::map">
            <xsl:sequence select="$key || $BC || '{' || ext:recurseForChildren(., $level, $spaceChars, $colorIndex) || $BC || '}'"/>
          </xsl:when>
          <xsl:when test="self::path">
            <xsl:variable name="text" as="xs:string" select="ext:processPathText(.)"/>
            <xsl:value-of select="$key || ext:nodeColor(@type) || $text || $YELLOW || ext:explainNode(node(), @location) || $RESET"/>
          </xsl:when>
          <xsl:when test="self::atomicValue">
            <xsl:variable name="color" as="xs:string" 
              select="if (@type eq 'string') then $BLUE else if (@type eq 'boolean') then $GREEN else if (@type eq 'numeric') then $MAGENTA else $CYAN"/>
            <xsl:value-of select="$key || $color || node() || $RESET"/>
          </xsl:when>     
          <xsl:otherwise>
            <xsl:value-of select="$key || node()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="$parts"/>    
  </xsl:function>
  
  <xsl:function name="ext:processPathText" as="item()*">
    <xsl:param name="c.x" as="item()*"/>
    <xsl:sequence select="
      if (matches($c.x/@text, '^@[^\s]+=')) then
        $BLACK || substring-before($c.x/@text,'=') || '=' || $GREEN || substring-after($c.x/@text,'=') 
      else $c.x/@text"/>
  </xsl:function>
  
  <xsl:function name="ext:nodeType" as="xs:string?">
    <xsl:param name="node" as="item()"/>
    <xsl:choose>
      <xsl:when test="$node instance of element()">
        <xsl:sequence select="'element'"/>
      </xsl:when>
      <xsl:when test="$node instance of text()">
        <xsl:sequence select="'text'"/>
      </xsl:when>
      <xsl:when test="$node instance of attribute()">
        <xsl:sequence select="'attribute'"/>
      </xsl:when>
      <xsl:when test="$node instance of processing-instruction()">
        <xsl:sequence select="'processing-instruction'"/>
      </xsl:when>
      <xsl:when test="$node instance of namespace-node()">
        <xsl:sequence select="'namespace-node'"/>
      </xsl:when>
      <xsl:when test="$node instance of comment()">
        <xsl:sequence select="'comment'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="ext:nodeColor" as="xs:string?">
    <xsl:param name="type" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$type eq 'element'">
        <xsl:sequence select="$BLUE"/>
      </xsl:when>
      <xsl:when test="$type eq 'text'">
        <xsl:sequence select="$CYAN"/>
      </xsl:when>
      <xsl:when test="$type eq 'attribute'">
        <xsl:sequence select="$GREEN"/>
      </xsl:when>
      <xsl:when test="$type eq 'processing-instruction'">
        <xsl:sequence select="$MAGENTA"/>
      </xsl:when>
      <xsl:when test="$type eq 'namespace-node'">
        <xsl:sequence select="$MAGENTA"/>
      </xsl:when>
      <xsl:when test="$type eq 'comment'">
        <xsl:sequence select="$MAGENTA"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="ext:recurseForChildren" as="item()*">
    <xsl:param name="c.x" as="item()*"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="spaceChars" as="xs:string"/>
    <xsl:param name="colorIndex" as="xs:integer"/>
    
    <xsl:sequence select="
      ext:writeEnclosedItem($c.x/node(), $level + 1, $spaceChars, $colorIndex + 1) => string-join(',')"/>
  </xsl:function>
  
</xsl:stylesheet>