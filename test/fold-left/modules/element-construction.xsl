<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:ccl="com.deltaxml.ccl"                         
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">
  
  <xsl:template match=".[. instance of map(*)]" mode="reconstruct">
    <xsl:choose>
      <xsl:when test="?element">
        <xsl:element name="{?element}">
          <xsl:apply-templates select="?nodes" mode="#current"/>
        </xsl:element>       
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="?text"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
</xsl:stylesheet>