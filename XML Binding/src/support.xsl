<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ddifunc="ddi:functions"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:function name="ddifunc:to-upper-cc">
        <xsl:param name="content"/>
        <xsl:value-of select="upper-case(substring($content, 1, 1))"/>
        <xsl:value-of select="substring($content, 2)"/>
    </xsl:function>
</xsl:stylesheet>