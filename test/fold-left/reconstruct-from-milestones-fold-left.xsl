<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:ccl="com.deltaxml.ccl"
                xmlns:ext="com.deltaxml.xpath.result.print"
                exclude-result-prefixes="#all"
                version="3.0">
  
  <!-- 
       Purpose:
       Transform the context XML so each element with the attribute
       'ccl:flattened="true' has its flattened child elements reconstructed
       using the child 'ccl:milestone' elements.
  -->
  
  <xsl:include href="../../src/xpath-result-serializer-color.xsl"/>
  <xsl:include href="modules/element-construction.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="*[@ccl:flattened eq 'true']">
    <xsl:copy>
      <xsl:apply-templates select="@* except @ccl:flattened"/>
      <xsl:variable name="text-groups" as="map(*)*" select="ccl:group-text-items(*)"/>
      <xsl:apply-templates select="$text-groups?nodes" mode="reconstruct"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- 
       Function: ccl:group-text-items(text-items as element()*)
       Parameters: 
       'text-items': A sequence of elements representing the flattened structure of an XML element
       Returns:
       An XPath map with a hierarchy corresponding to the element stucture of the flattened element
  -->
  <xsl:function name="ccl:group-text-items" as="map(*)*">
    <xsl:param name="text-items" as="element()*"/>
    <xsl:sequence select="fold-left($text-items, map { 'element': 'root', 'nodes': ()}, 
        function($stack as map(*)*, $item as element()) {
          ext:log( '======= iteratation ========'),
          ext:log($item, 'item'),
          ext:log($stack, 'stack'),
          let $p := $stack[last()] return
            if ($item[self::ccl:milestone[@start]]) then (
                $stack, ext:trace(map { 'element': string($item/@start), 'nodes': ()}, 'trace')
              )
            else if ($item[self::ccl:milestone[@end]]) then (
                let $gpAncestors := subsequence($stack, 1, count($stack) -2),
                  $gp := $stack[last() - 1] return
                  ($gpAncestors, map:put($gp, 'nodes', ($gp?nodes, $p)))
              )
            else (
                let $pAncestors := subsequence($stack, 1, count($stack) -1) return
                  ($pAncestors, map:put($p, 'nodes', ($p?nodes, string($item))))
              )
        })"/>   
  </xsl:function>
  
  <xsl:function name="ext:trace" as="item()*">
    <xsl:param name="value" as="item()*"/>
    <xsl:param name="label" as="xs:string"/>
    <xsl:message expand-text="yes">
      ==== {$label} ====
      {ext:print($value,2,'  ')}
    </xsl:message>
    <xsl:sequence select="$value"/>
  </xsl:function>
  
</xsl:stylesheet>