<?xml version="1.0" encoding="UTF-8"?>
<xsl:package xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
             xmlns:xs="http://www.w3.org/2001/XMLSchema"
             xmlns:array="http://www.w3.org/2005/xpath-functions/array"
             xmlns:map="http://www.w3.org/2005/xpath-functions/map"
             xmlns:math="http://www.w3.org/2005/xpath-functions/math"
             name="package-uri"
             package-version="1.0"
             exclude-result-prefixes="#all"
             expand-text="yes"
             version="3.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:mode name="mode-name" streamable="false" on-no-match="shallow-copy" visibility="public"/>
    
    
    <xsl:template match="/*" mode="mode-name">
        <xsl:copy>
            <xsl:variable name="hello" as="xs:string" select="'hello world'"/>
            
            <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
</xsl:package>