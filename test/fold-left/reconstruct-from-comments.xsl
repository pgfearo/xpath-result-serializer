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
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="reconstruct" on-no-match="shallow-copy"/>
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="groupedCommentContents" as="map(*)" select="ccl:groupByCommentMarkers(node())"/>
      <xsl:apply-templates select="$groupedCommentContents?nodes" mode="reconstruct"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match=".[. instance of map(*)]" mode="reconstruct">
    <xsl:choose>
      <xsl:when test="?element">
        <xsl:element name="{?element}">
          <xsl:apply-templates select="?nodes" mode="#current"/>
        </xsl:element>       
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="?nodes" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:function name="ccl:groupByCommentMarkers" as="map(*)">
    <xsl:param name="payload" as="node()*"/>
    <xsl:iterate select="$payload">      
      <xsl:param name="stack" as="map(*)+" select="map { 'element': 'root', 'nodes': ()}"/>
      <xsl:on-completion>
        <xsl:sequence select="$stack"/>
      </xsl:on-completion>
      <xsl:variable name="parentItem" as="map(*)" select="$stack[last()]"/>
      <xsl:variable name="parentAncestors" as="map(*)*" select="subsequence($stack, 1, count($stack) - 1)"/>
      <xsl:variable name="gParentItem" as="map(*)?" select="$stack[last() - 1]"/>
      <xsl:variable name="gParentAncestors" as="map(*)*" select="subsequence($stack, 1, count($stack) - 2)"/>
      
      <xsl:choose>
        <xsl:when test="self::comment()[contains(., '/')]">
          <xsl:next-iteration>
            <xsl:with-param name="stack" 
              select="$gParentAncestors, map:put($gParentItem, 'nodes', ($gParentItem?nodes, $parentItem))"/>
          </xsl:next-iteration>
        </xsl:when>
        <xsl:when test="self::comment()">
          <xsl:next-iteration>
            <xsl:with-param name="stack" select="($stack, map { 'element': normalize-space(), 'nodes': ()})"/>
          </xsl:next-iteration>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="groupedSelfAndDescendants" as="node()*">
            <xsl:apply-templates select="."/>
          </xsl:variable>
          <xsl:variable name="reconstructedGroups" as="node()*">
            <xsl:apply-templates select="$groupedSelfAndDescendants" mode="reconstruct"/>
          </xsl:variable>
          <xsl:next-iteration>
            <xsl:with-param name="stack" 
              select="$parentAncestors, map:put($parentItem, 'nodes', ($parentItem?nodes, $reconstructedGroups))"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>
  
</xsl:stylesheet>