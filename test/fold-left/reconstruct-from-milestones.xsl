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
  
  <xsl:include href="../../../../.vscode/extensions/deltaxml.xslt-xpath-1.5.16/xslt-resources/xpath-result-serializer/xpath-result-serializer-color.xsl"/>
  <xsl:include href="modules/element-construction.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="*[@ccl:flattened eq 'true']">
    <xsl:copy>
      <xsl:apply-templates select="@* except @ccl:flattened"/>
      <xsl:variable name="text-groups" as="map(*)" select="ccl:group-text-items(*)"/>
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
  <xsl:function name="ccl:group-text-items" as="map(*)">
    <xsl:param name="text-items" as="element()*"/>
    <xsl:iterate select="$text-items">      
      <xsl:param name="stack" as="map(*)+" select="map { 'element': 'root', 'nodes': ()}"/>
      <xsl:on-completion>
        <xsl:message expand-text="yes">
          ==== ON COMPLETION ====
          stack:  {ext:print($stack,6,'  ')}
        </xsl:message> 
        <xsl:sequence select="$stack"/>
      </xsl:on-completion>
      <xsl:variable name="parentItem" as="map(*)" select="$stack[last()]"/>
      <xsl:variable name="parentAncestors" as="map(*)*" select="subsequence($stack, 1, count($stack) - 1)"/>
      <xsl:variable name="gParentItem" as="map(*)?" select="$stack[last() - 1]"/>
      <xsl:variable name="gParentAncestors" as="map(*)*" select="subsequence($stack, 1, count($stack) - 2)"/>
      <xsl:message expand-text="yes">
        ==== Watch Variables ====
        pos:    {ext:print(position(),6,'  ')}
        ctx:    {ext:print(.,6,'  ')}
        stack:  {ext:print($stack,6,'  ')}
      </xsl:message>      
      <xsl:choose>
        <xsl:when test="self::ccl:milestone[@start]">
          <xsl:next-iteration>
            <xsl:with-param name="stack" select="($stack, map { 'element': string(@start), 'nodes': ()})"/>
          </xsl:next-iteration>
        </xsl:when>
        <xsl:when test="self::ccl:milestone[@end]">
          <xsl:next-iteration>
            <xsl:with-param name="stack" 
              select="$gParentAncestors, map:put(
                  $gParentItem, 'nodes', 
                  ($gParentItem?nodes, $parentItem))"/>
          </xsl:next-iteration>
        </xsl:when>
        <xsl:when test="self::ccl:text">
          <xsl:next-iteration>
            <xsl:with-param name="stack" 
              select="$parentAncestors, map:put(
                  $parentItem, 'nodes',
                  ($parentItem?nodes, string(.)))"/>
          </xsl:next-iteration>
        </xsl:when>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>
  
</xsl:stylesheet>